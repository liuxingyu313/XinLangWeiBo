//
//  ImgFaceView.m
//  WXWeibo
//
//  Created by JayWon on 15/10/30.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "ImgFaceView.h"

#define kRowCount 4     //4行
#define kColumnCount 7  //7列

#define kFaceSize 30    //一个表情的大小

//表情行间距
#define kRowSpace 12
//表情列间距（7列8个间距）
#define kColumnSpace ((kScreenWidth - kColumnCount*kFaceSize) / (kColumnCount+1))


@implementation ImgFaceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        lastTouchIndex = -1;
        
        //1.读取字典
        [self parseFaceArr];
        
        [self configUI];
        //2.画表情
        
        //3.计算点击的是哪个表情
    }
    return self;
}

/*
 *items = [
 ["表情1","表情2","表情3",....."表情28"],
 ["表情1","表情2","表情3",....."表情28"],
 ["表情1","表情2","表情3",....."表情28"]
 ];
 */
-(void)parseFaceArr
{
    faceItemArr = [[NSMutableArray alloc] init];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"emoticons" ofType:@"plist"];
    NSArray *faceArr = [NSArray arrayWithContentsOfFile:filePath];
    
    //数据格式化
    NSMutableArray *pageFaceArr = nil;
    int pageCount = kRowCount*kColumnCount;
    
    for (int i=0; i<faceArr.count; i++) {
        if (i % pageCount == 0) {
            pageFaceArr = [[NSMutableArray alloc] initWithCapacity:pageCount];
            [faceItemArr addObject:pageFaceArr];
        }
        
        [pageFaceArr addObject:faceArr[i]];
    }
    
    self.pageCount = faceItemArr.count;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, kScreenWidth * faceItemArr.count, kFaceSize * kRowCount + kRowSpace * (kRowCount+1));
}

-(void)configUI
{
    //放大镜
    manifierView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emoticon_keyboard_magnifier"]];
    manifierView.frame = CGRectMake(0, 0, manifierView.image.size.width, manifierView.image.size.height);
    
    //放大镜上面的表情视图
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((manifierView.image.size.width-40)/2, 12, 40, 40)];
    imgView.tag = 300;
    [manifierView addSubview:imgView];
    
    [self addSubview:manifierView];
    manifierView.hidden = YES;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    int row = 0, column = 0;
    for (int i=0; i<faceItemArr.count; i++) {
        //一页表情
        NSMutableArray *pageArr = faceItemArr[i];
        for (int j=0; j<pageArr.count; j++) {
            //一个表情
            NSDictionary *faceDic = pageArr[j];
            UIImage *img = [UIImage imageNamed:faceDic[@"png"]];
            
            //画表情
            [img drawInRect:CGRectMake(kFaceSize*column+kColumnSpace*(column+1)+kScreenWidth*i, kFaceSize*row+kRowSpace*(row+1), kFaceSize, kFaceSize)];

            //换列
            column++;

            //换行
            if (column % kColumnCount == 0) {
                row++;
                column = 0;
            }
            
            //换页
            if (row % kRowCount == 0) {
                row = 0;
            }
        }
    }
}

-(void)touchFace:(CGPoint)point
{
    //1.确定页码
    int page = point.x / kScreenWidth;
    
    //2.确定行与列
    float faceItemWidth = kFaceSize + kColumnSpace; //表情所占区域宽度（左列间距/2+表情宽度+右列间距/2）
    float faceItemHeight = kFaceSize + kRowSpace;   //表情所占区域高度（上行间距/2+表情高度+下行间距/2）
    
    int row = (point.y-kRowSpace/2) / faceItemHeight;
    int column = ((point.x-kScreenWidth*page)-kColumnSpace/2) / faceItemWidth;
    
    //3.边界值判断（row：0-3；column：0-6）
    row = MAX(MIN(3, row), 0);
    column = MAX(0, MIN(column, 6));
    
    //NSLog(@"%d -- %d", row, column);
    
    //4.一页表情
    NSArray *pageArr = faceItemArr[page];
    int index = row * kColumnCount + column;
    if (index > pageArr.count-1) {
        lastTouchIndex = -1;
        //如果超出范围，把选中的表情置为nil
        _faceName_kvo = nil;
        return;
    }
    
    if (lastTouchIndex != index) {
        //5.获取选中的表情
        NSDictionary *faceDic = pageArr[index];
        NSString *faceName = faceDic[@"chs"];
        //记录选中的表情，不响应kvo
        _faceName_kvo = faceName;
        
        //拿到放大镜
        UIImageView *imgView = (UIImageView *)[manifierView viewWithTag:300];
        imgView.image = [UIImage imageNamed:faceDic[@"png"]];
        
        //更新放大镜frame
        float x = kColumnSpace*(column+1)+kFaceSize/2+kFaceSize*column + kScreenWidth*page - manifierView.bounds.size.width/2;
        float y = kRowSpace*(row+1)+kFaceSize*row - manifierView.bounds.size.height;
        manifierView.frame = CGRectMake(x, y, CGRectGetWidth(manifierView.frame), CGRectGetHeight(manifierView.frame));
        
    }
    
    manifierView.hidden = NO;
    
    //记录最后的索引
    lastTouchIndex = index;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    [self touchFace:point];
    
    //禁止scrollview滑动
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        scrollView.scrollEnabled = NO;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    [self touchFace:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    manifierView.hidden = YES;
    
    //禁止scrollview滑动
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        scrollView.scrollEnabled = YES;
    }
    
    //如果_faceName_kvo有值，就响应kvo
    if (_faceName_kvo) {
        self.faceName_kvo = _faceName_kvo;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    manifierView.hidden = YES;
    
    //禁止scrollview滑动
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        scrollView.scrollEnabled = YES;
    }
}

@end
