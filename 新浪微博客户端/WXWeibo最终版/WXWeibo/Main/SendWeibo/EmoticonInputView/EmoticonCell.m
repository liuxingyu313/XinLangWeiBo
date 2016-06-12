//
//  EmoticonCell.m
//  WXWeibo
//
//  Created by JayWon on 15/11/25.
//  Copyright © 2015年 JayWon. All rights reserved.
//

#import "EmoticonCell.h"

@implementation EmoticonCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundColor = [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:1.0];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(frame)-kEmoticonSize)/2, (CGRectGetHeight(frame)-kEmoticonSize)/2, kEmoticonSize, kEmoticonSize)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_imageView];
    }
    return self;
}

-(void)setEmoticon:(EmoticonModel *)emoticon {
    if (_emoticon == emoticon) return;
    _emoticon = emoticon;
    [self updateContent];
}

-(void)setIsDelete:(BOOL)isDelete {
    if (_isDelete == isDelete) return;
    _isDelete = isDelete;
    [self updateContent];
}

-(void)updateContent {
    
    _imageView.image = nil;
    
    if (_isDelete) {
        _imageView.image = [UIImage imageNamed:@"Resource.bundle/compose_emotion_delete"];
    } else if (_emoticon) {
        if (_emoticon.type == EmoticonTypeEmoji) {
            //把emoji转换为图片显示
            _imageView.image = [self imageWithEmoji:[self emojiUnicodeWithString:_emoticon.code] withSize:kEmoticonSize];
        } else if (_emoticon.group.groupID && _emoticon.png){
            /*
            //方法一
            NSString *pngPath = [[WeiboHelper emoticonBundle].bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", _emoticon.group.groupID, _emoticon.png]];
            UIImage *img = [UIImage imageWithContentsOfFile:pngPath];
            if (!img) {
                pngPath = [[WeiboHelper emoticonBundle].bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"additional/%@/%@", _emoticon.group.groupID, _emoticon.png]];
                img = [UIImage imageWithContentsOfFile:pngPath];
            }
            _imageView.image = img;
            */
            //方法二
            NSString *pngPath = [self pathForScaledResource:[WeiboHelper emoticonBundle] fileName:_emoticon.png inDirectory:_emoticon.group.groupID];
            if (!pngPath) {
                NSString *addBundlePath = [[WeiboHelper emoticonBundle].bundlePath stringByAppendingPathComponent:@"additional"];
                pngPath = [self pathForScaledResource:[NSBundle bundleWithPath:addBundlePath] fileName:_emoticon.png inDirectory:_emoticon.group.groupID];
            }
            _imageView.image = [UIImage imageWithContentsOfFile:pngPath];
        }
    }
}

//根据图片的名字获取对应分辨率的完整图片路径
-(NSString *)pathForScaledResource:(NSBundle *)bundle fileName:(NSString *)name inDirectory:(NSString *)subpath
{
    NSString *path = nil;
    NSArray *scales = [self preferredScales];
    for (int s = 0; s < scales.count; s++) {
        CGFloat scale = ((NSNumber *)scales[s]).floatValue;
        NSString *scaledName = nil;
        if (scale > 1) {
            NSString *ext = name.pathExtension;
            NSRange extRange = NSMakeRange(name.length - ext.length - 1, 0);
            NSString *scaleStr = [NSString stringWithFormat:@"@%@x", @(scale)];
            scaledName = [name stringByReplacingCharactersInRange:extRange withString:scaleStr];
        }else{
            scaledName = name;
        }
        //NSLog(@"%@ -- %@", name, scaledName);
        path = [bundle pathForResource:scaledName ofType:nil inDirectory:subpath];
        if (path) break;
    }
    
    return path;
}

-(NSArray *)preferredScales
{
    static NSArray *scales;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat screenScale = [UIScreen mainScreen].scale;
        if (screenScale <= 1) {
            scales = @[@1,@2,@3];
        } else if (screenScale <= 2) {
            scales = @[@2,@3,@1];
        } else {
            scales = @[@3,@2,@1];
        }
    });
    return scales;
}

//获取emoji的unicode编码
-(NSString *)emojiUnicodeWithString:(NSString *)str
{
    NSNumber *num = [self numberWithString:str];
    UTF32Char char32 = NSSwapHostIntToLittle(num.unsignedIntValue);
    return [[NSString alloc] initWithBytes:&char32 length:4 encoding:NSUTF32LittleEndianStringEncoding];
}

//十六进制 -> 十进制 -> NSNumber
-(NSNumber *)numberWithString:(NSString *)string
{
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{@"true" :   @(YES),
                @"yes" :    @(YES),
                @"false" :  @(NO),
                @"no" :     @(NO),
                @"nil" :    [NSNull null],
                @"null" :   [NSNull null],
                @"<null>" : [NSNull null]};
    });
    NSNumber *num = dic[string];
    if (num) {
        if (num == (id)[NSNull null]) return nil;
        return num;
    }
    
    // hex number
    int sign = 0;
    if ([string hasPrefix:@"0x"]) sign = 1;
    else if ([string hasPrefix:@"-0x"]) sign = -1;
    if (sign != 0) {
        NSScanner *scan = [NSScanner scannerWithString:string];
        unsigned num = -1;
        BOOL suc = [scan scanHexInt:&num];
        if (suc)
            return [NSNumber numberWithLong:((long)num * sign)];
        else
            return nil;
    }
    // normal number
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:string];
}

//把emoji转换为图片
-(UIImage *)imageWithEmoji:(NSString *)emoji withSize:(CGFloat)size
{
    /*
    //方法一，用label显示emoji表情，然后把label截图返回
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"AppleColorEmoji" size:size];
    label.text = emoji;
    label.opaque = NO;
    label.backgroundColor = [UIColor clearColor];
    label.frame = CGRectMake(0, 0, size, size);

    UIGraphicsPushContext(UIGraphicsGetCurrentContext());
    UIGraphicsBeginImageContextWithOptions(label.frame.size, label.opaque, 0.0);
    [label.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIGraphicsPopContext();
    return img;
    */
    
    //方法二，把emoji当成NSString画出来，截图返回
    NSDictionary *textAttr = @{
                               //NSBackgroundColorAttributeName : [UIColor orangeColor],
                               NSFontAttributeName : [UIFont systemFontOfSize:size],
                               };
    static CGFloat originY = 0.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize newSize = [emoji sizeWithAttributes:textAttr];
        originY = (newSize.height-newSize.width)/2;
    });
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0.0);
    [emoji drawAtPoint:CGPointMake(0, -originY) withAttributes:textAttr];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}

@end
