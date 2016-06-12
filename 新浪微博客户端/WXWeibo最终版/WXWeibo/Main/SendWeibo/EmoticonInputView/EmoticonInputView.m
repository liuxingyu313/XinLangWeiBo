//
//  EmoticonInputView.m
//  WXWeibo
//
//  Created by JayWon on 15/11/25.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import "EmoticonInputView.h"
#import "EmoticonCollectionView.h"
#import "YYModel.h"

@interface EmoticonInputView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *toolbarButtons;       //自定义SegmentedControl
@property (nonatomic, strong) NSMutableArray *emoticonGroups;       //数据源Array<EmoticonGroup>
@property (nonatomic, assign) NSInteger emoticonGroupTotalPageCount;//总页数，一页定为一个section
@property (nonatomic, strong) NSMutableArray *emoticonGroupPageIndexs;  //每组表情在collectionView中的起始索引
@property (nonatomic, strong) NSMutableArray *emoticonGroupPageCounts;  //每组表情有几页
@property (nonatomic, assign) NSInteger currentPageIndex;               //当前页

@end


@implementation EmoticonInputView

-(instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, kScreenWidth, kEmoticonViewHeight)];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kEmoticonInputViewBgColor;
        _currentPageIndex = NSNotFound;
        
        //初始化数据源
        [self _initDataSource];
        
        //初始化collectionView
        [self _initCollectionView];
        
        //初始化toolbar（自定义SegmentedControl）
        [self _initToolbar];
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    //画top分割线
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, kSeparatorColor.CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, kScreenWidth, 0);
    CGContextDrawPath(context, kCGPathStroke);
}

-(void)_initDataSource
{
    /* -- 1、解析表情配置文件 emoticons.plist -- */
    self.emoticonGroups = @[].mutableCopy;
    
    //临时变量，数据格式为：{@"com.sina.default" : EmoticonGroup}
    NSMutableDictionary *groupDic = [[NSMutableDictionary alloc] init];
    
    //表情分组配置文件
    NSString *emoticonPlistPath = [[WeiboHelper emoticonBundle] pathForResource:@"emoticons" ofType:@"plist"];
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:emoticonPlistPath];
    NSArray *packages = plist[@"packages"];
    //遍历分组信息
    for (NSDictionary *pkDic in packages) {
        NSString *groupID = pkDic[@"id"];
        if (!groupID || groupID.length == 0)
            continue;
        NSString *path = [[WeiboHelper emoticonBundle].bundlePath stringByAppendingPathComponent:groupID];
        NSString *infoPlistPath = [path stringByAppendingPathComponent:@"info.plist"];
        NSDictionary *groupInfo = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
        if (!groupInfo)
            continue;
        //字典映射EmoticonGroup
        EmoticonGroup *group = [EmoticonGroup yy_modelWithDictionary:groupInfo];
        if (group.emoticons.count == 0)
            continue;
        [_emoticonGroups addObject:group];
        
        groupDic[groupID] = group;
    }
    
    //设置additional表情
    NSString *additionalPath = [[WeiboHelper emoticonBundle].bundlePath stringByAppendingPathComponent:@"additional"];
    NSArray *subDirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:additionalPath error:NULL];
    for (NSString *dirName in subDirs) {
        EmoticonGroup *group = groupDic[dirName];
        if (!group) continue;
        NSString *infoJSONPath = [[additionalPath stringByAppendingPathComponent:dirName] stringByAppendingPathComponent:@"info.json"];
        NSData *infoJSON = [NSData dataWithContentsOfFile:infoJSONPath];
        EmoticonGroup *addGroup = [EmoticonGroup yy_modelWithJSON:infoJSON];
        //设置addGroup里面emoticon所属分组
        for (EmoticonModel *emoticon in addGroup.emoticons) {
            emoticon.group = group;
        }
        //把additional表情插入到原分组里面
        [(NSMutableArray *)group.emoticons insertObjects:addGroup.emoticons atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, addGroup.emoticons.count)]];
    }
    
    
    /* -- 2、根据数据源，计算各项分组数据 -- */
    /*
    //计算总页数，一页定为一个section
    _emoticonGroupTotalPageCount = 0;
    for (EmoticonGroup *group in _emoticonGroups) {
        NSUInteger pageCount = ceil(group.emoticons.count / (float)kOnePageCount);
        _emoticonGroupTotalPageCount += pageCount;
    }
    
    //计算每组表情在collectionView中的起始索引
    NSMutableArray *indexs = [[NSMutableArray alloc] init];
    NSUInteger index = 0;
    for (EmoticonGroup *group in _emoticonGroups) {
        [indexs addObject:@(index)];
        NSUInteger pageCount = ceil(group.emoticons.count / (float)kOnePageCount);
        if (pageCount == 0) pageCount = 1;
        index += pageCount;
    }
    _emoticonGroupPageIndexs = indexs;
    
    //计算每一组表情有几页
    NSMutableArray *pageCounts = [[NSMutableArray alloc] init];
    for (EmoticonGroup *group in _emoticonGroups) {
        NSUInteger pageCount = ceil(group.emoticons.count / (float)kOnePageCount);
        if (pageCount == 0) pageCount = 1;
        [pageCounts addObject:@(pageCount)];
    }
    _emoticonGroupPageCounts = pageCounts;
    */
    
    //上面三合一
    self.emoticonGroupTotalPageCount = 0;
    self.emoticonGroupPageIndexs = @[].mutableCopy;
    self.emoticonGroupPageCounts = @[].mutableCopy;
    
    NSUInteger index = 0;
    for (EmoticonGroup *group in _emoticonGroups) {
        [_emoticonGroupPageIndexs addObject:@(index)];
        
        NSUInteger pageCount = ceil(group.emoticons.count / (float)kOnePageCount);
        _emoticonGroupTotalPageCount += pageCount;
        
        if (pageCount == 0) pageCount = 1;
        [_emoticonGroupPageCounts addObject:@(pageCount)];
        index += pageCount;
    }
}

-(void)_initCollectionView
{
    CGFloat padding = (kScreenWidth - kEmoticonSize*kColumnCount) / (kColumnCount+1) / 2;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, padding, 0, padding);
    layout.itemSize = CGSizeMake(kEmoticonSize + padding*2, kItemHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    _collectionView = [[EmoticonCollectionView alloc] initWithFrame:CGRectMake(0, 5, kScreenWidth, kItemHeight * kRowCount) collectionViewLayout:layout];
    [_collectionView registerClass:[EmoticonCell class] forCellWithReuseIdentifier:@"kEmoticonInputCell"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self addSubview:_collectionView];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_collectionView.frame), kScreenWidth, 20)];
    _pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1.0];
    _pageControl.userInteractionEnabled = NO;
    [self addSubview:_pageControl];
}

-(void)_initToolbar
{
    UIImageView *toolbar = [[UIImageView alloc] initWithFrame:CGRectMake(0, kEmoticonViewHeight-kToolbarHeight, kScreenWidth, kToolbarHeight)];
    toolbar.userInteractionEnabled = YES;
    toolbar.image = [UIImage imageNamed:@"Resource.bundle/compose_emotion_table_right_normal"];
    
    self.toolbarButtons = @[].mutableCopy;
    UIButton *btn;
    for (NSUInteger i = 0; i < _emoticonGroups.count; i++) {
        EmoticonGroup *group = _emoticonGroups[i];
        btn = [self _createToolbarButton];
        [btn setTitle:group.nameCN forState:UIControlStateNormal];
        btn.frame = CGRectMake(kScreenWidth / (float)_emoticonGroups.count * i, 0, kScreenWidth / (float)_emoticonGroups.count, CGRectGetHeight(toolbar.frame));
        btn.tag = i;
        [toolbar addSubview:btn];
        [_toolbarButtons addObject:btn];
    }
    
    [self addSubview:toolbar];
    
    //默认选中第一组表情
    [self _toolbarBtnDidTapped:_toolbarButtons.firstObject];
}

-(UIButton *)_createToolbarButton
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.exclusiveTouch = YES;
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRed:93/255.0 green:92/255.0 blue:90/255.0 alpha:1.0] forState:UIControlStateSelected];
    
    UIImage *img;
    img = [UIImage imageNamed:@"Resource.bundle/compose_emotion_table_left_normal"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, img.size.width - 1) resizingMode:UIImageResizingModeStretch];
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    
    img = [UIImage imageNamed:@"Resource.bundle/compose_emotion_table_left_selected"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, img.size.width - 1) resizingMode:UIImageResizingModeStretch];
    [btn setBackgroundImage:img forState:UIControlStateSelected];
    
    [btn addTarget:self action:@selector(_toolbarBtnDidTapped:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(void)_toolbarBtnDidTapped:(UIButton *)btn
{
    //根据每组的起始索引页计算 组在collectionView显示的CGRect
    NSInteger groupIndex = btn.tag;
    NSInteger page = ((NSNumber *)_emoticonGroupPageIndexs[groupIndex]).integerValue;
    CGRect rect = CGRectMake(page * CGRectGetWidth(_collectionView.frame), 0, CGRectGetWidth(_collectionView.frame), CGRectGetHeight(_collectionView.frame));
    //collectionView滑动到组对应的CGRect
    [_collectionView scrollRectToVisible:rect animated:NO];
    //调用代理方法计算pageControl的页码
    [self scrollViewDidScroll:_collectionView];
}

//根据indexPath获取数据源里面对应的EmoticonModel
-(EmoticonModel *)_emoticonForIndexPath:(NSIndexPath *)indexPath
{
    //根据NSIndexPath计算emoticon在EmoticonGroup里面的索引
    NSUInteger section = indexPath.section;
    for (NSInteger i = _emoticonGroupPageIndexs.count - 1; i >= 0; i--) {
        NSNumber *pageIndex = _emoticonGroupPageIndexs[i];
        if (section >= pageIndex.unsignedIntegerValue) {
            EmoticonGroup *group = _emoticonGroups[i];
            NSUInteger page = section - pageIndex.unsignedIntegerValue;
            NSUInteger index = page * kOnePageCount + indexPath.row;
            
            //行列变换（水平方向的collectionView显示cell是依次按列显示，而我们希望的是依次按行显示）
            NSUInteger ip = index / kOnePageCount;
            NSUInteger ii = index % kOnePageCount;
            NSUInteger reIndex = (ii % kRowCount) * kColumnCount + (ii / kRowCount);
            //NSLog(@"%ld---%ld", index, reIndex + ip * kOnePageCount);
            index = reIndex + ip * kOnePageCount;
            
            if (index < group.emoticons.count) {
                return group.emoticons[index];
            } else {
                return nil;
            }
        }
    }
    return nil;
}

#pragma mark -
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //计算页码
    NSInteger page = round(scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame));
    if (page < 0) page = 0;
    else if (page >= _emoticonGroupTotalPageCount) page = _emoticonGroupTotalPageCount - 1;
    if (page == _currentPageIndex) return;
    _currentPageIndex = page;
    
    //计算所属分组
    NSInteger curGroupIndex = 0, curGroupPageIndex = 0;
    for (NSInteger i = _emoticonGroupPageIndexs.count - 1; i >= 0; i--) {
        NSNumber *pageIndex = _emoticonGroupPageIndexs[i];
        if (page >= pageIndex.unsignedIntegerValue) {
            curGroupIndex = i;
            curGroupPageIndex = ((NSNumber *)_emoticonGroupPageIndexs[i]).integerValue;
            _pageControl.numberOfPages = ((NSNumber *)_emoticonGroupPageCounts[i]).integerValue;
            break;
        }
    }
    
    //设置pageControl
    _pageControl.currentPage = page - curGroupPageIndex;
    
    //设置SegmentedControl选中
    [_toolbarButtons enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
        btn.selected = (idx == curGroupIndex);
    }];
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _emoticonGroupTotalPageCount;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return kOnePageCount + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    EmoticonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kEmoticonInputCell" forIndexPath:indexPath];
    if (indexPath.row == kOnePageCount) {
        cell.isDelete = YES;
        cell.emoticon = nil;
    } else {
        cell.isDelete = NO;
        cell.emoticon = [self _emoticonForIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - EmoticonTapDelegate
-(void)emoticonDidTapCell:(EmoticonCell *)cell
{
    if (!cell) return;
    if (cell.isDelete) {        //如果点击的是删除
        if ([self.delegate respondsToSelector:@selector(emoticonInputDidTapBackspace)]) {
            [self.delegate emoticonInputDidTapBackspace];
        }
    } else if (cell.emoticon) { //如果点击的是表情
        NSString *text = nil;
        switch (cell.emoticon.type) {
            case EmoticonTypeImage: {
                text = cell.emoticon.chs;
            } break;
            case EmoticonTypeEmoji: {
                text = [cell emojiUnicodeWithString:cell.emoticon.code];
            } break;
            default:break;
        }
        if (text && [self.delegate respondsToSelector:@selector(emoticonInputDidTapText:)]) {
            [self.delegate emoticonInputDidTapText:text];
        }
    }
}

@end
