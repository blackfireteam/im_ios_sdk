//
//  MSSnapTextPreview.m
//  BlackFireIM
//
//  Created by benny wang on 2022/2/21.
//

#import "MSSnapTextPreview.h"



@interface MSSnapTextPreview()

@property(nonatomic,strong) UILabel *contentL;

@end
@implementation MSSnapTextPreview

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.contentL = [[UILabel alloc]init];
        self.contentL.numberOfLines = 0;
        self.contentL.font = [UIFont systemFontOfSize:25];
        self.contentL.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        [self addSubview:self.contentL];
    }
    return self;
}

- (void)reloadMessage:(MSIMMessage *)message
{
    [super reloadMessage:message];
    self.contentL.text = message.textElem.text;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat top = StatusBar_Height + NavBar_Height;
    CGSize textSize = [self.contentL.text textSizeIn:CGSizeMake(Screen_Width - 40, Screen_Height - top) font:self.contentL.font];
    self.scrollView.contentSize = CGSizeMake(Screen_Width, MAX(Screen_Height, textSize.height + top));
    self.contentL.frame = CGRectMake(Screen_Width * 0.5 - textSize.width * 0.5, top + (Screen_Height - top - textSize.height) * 0.5, textSize.width, textSize.height);
}

@end
