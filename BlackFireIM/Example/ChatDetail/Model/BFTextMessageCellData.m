//
//  BFTextMessageCellData.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "BFTextMessageCellData.h"
#import "BFHeader.h"
#import "UIColor+BFDarkMode.h"


#ifndef CGFLOAT_CEIL
#ifdef CGFLOAT_IS_DOUBLE
#define CGFLOAT_CEIL(value) ceil(value)
#else
#define CGFLOAT_CEIL(value) ceilf(value)
#endif
#endif

@interface BFTextMessageCellData()

@property CGSize textSize;
@property CGPoint textOrigin;

@end
@implementation BFTextMessageCellData

- (instancetype)initWithDirection:(TMsgDirection)direction
{
    self = [super initWithDirection:direction];
    if (self) {
        if (direction == MsgDirectionIncoming) {
            _textColor = [[self class] incommingTextColor];
            _textFont = [[self class] incommingTextFont];
        } else {
            _textColor = [[self class] outgoingTextColor];
            _textFont = [[self class] outgoingTextFont];
        }
    }
    return self;
}

- (CGSize)contentSize
{
    UIEdgeInsets contentInset = UIEdgeInsetsMake(10, 16, 16, 16);
    CGRect rect = [self.attributedString boundingRectWithSize:CGSizeMake(TTextMessageCell_Text_Width_Max, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    CGSize size = CGSizeMake(CGFLOAT_CEIL(rect.size.width), CGFLOAT_CEIL(rect.size.height));
    self.textSize = size;
    self.textOrigin = CGPointMake(contentInset.left, contentInset.top);

    size.height += contentInset.top+contentInset.bottom;
    size.width += contentInset.left+contentInset.right;
    
    return size;
}

- (NSAttributedString *)attributedString
{
    if (!_attributedString) {
        _attributedString = [self formatMessageString:_content];
    }
    return _attributedString;
}

- (NSAttributedString *)formatMessageString:(NSString *)text
{
    //先判断text是否存在
    if (text == nil || text.length == 0) {
        NSLog(@"TTextMessageCell formatMessageString failed , current text is nil");
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    //1、创建一个可变的属性字符串
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];

    //2、通过正则表达式来匹配字符串
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]"; //匹配表情

    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (!re) {
        NSLog(@"%@", [error localizedDescription]);
        return attributeString;
    }
    [attributeString addAttribute:NSFontAttributeName value:self.textFont range:NSMakeRange(0, attributeString.length)];

    return attributeString;
}

static UIColor *sOutgoingTextColor;

+ (UIColor *)outgoingTextColor
{
    if (!sOutgoingTextColor) {
        sOutgoingTextColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_OutMessage_Color_Dark];
    }
    return sOutgoingTextColor;
}

+ (void)setOutgoingTextColor:(UIColor *)outgoingTextColor
{
    sOutgoingTextColor = outgoingTextColor;
}

static UIFont *sOutgoingTextFont;

+ (UIFont *)outgoingTextFont
{
    if (!sOutgoingTextFont) {
        sOutgoingTextFont = [UIFont systemFontOfSize:16];
    }
    return sOutgoingTextFont;
}

+ (void)setOutgoingTextFont:(UIFont *)outgoingTextFont
{
    sOutgoingTextFont = outgoingTextFont;
}

static UIColor *sIncommingTextColor;

+ (UIColor *)incommingTextColor
{
    if (!sIncommingTextColor) {
        sIncommingTextColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
    }
    return sIncommingTextColor;
}

+ (void)setIncommingTextColor:(UIColor *)incommingTextColor
{
    sIncommingTextColor = incommingTextColor;
}

static UIFont *sIncommingTextFont;

+ (UIFont *)incommingTextFont
{
    if (!sIncommingTextFont) {
        sIncommingTextFont = [UIFont systemFontOfSize:16];
    }
    return sIncommingTextFont;
}

+ (void)setIncommingTextFont:(UIFont *)incommingTextFont
{
    sIncommingTextFont = incommingTextFont;
}

- (NSString *)reuseId
{
    return TTextMessageCell_ReuseId;
}

@end
