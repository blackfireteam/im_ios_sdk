//
//  MSMenuView.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/23.
//

#import "MSMenuView.h"
#import "UIColor+BFDarkMode.h"
#import "MSHeader.h"
#import "NSBundle+BFKit.h"

@implementation MSMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = [UIColor d_colorWithColorLight:TInput_Background_Color dark:TInput_Background_Color_Dark];

    _sendButton = [[UIButton alloc] init];
    _sendButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_sendButton setTitle:TUILocalizableString(Send) forState:UIControlStateNormal];
    _sendButton.backgroundColor = RGBA(87, 190, 105, 1.0);
    [_sendButton addTarget:self action:@selector(sendUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sendButton];
}

- (void)defaultLayout
{
    CGFloat buttonWidth = self.frame.size.height * 1.3;
    _sendButton.frame = CGRectMake(self.frame.size.width - buttonWidth, 0, buttonWidth, self.frame.size.height);
}

- (void)sendUpInside:(UIButton *)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(menuViewDidSendMessage:)]){
        [_delegate menuViewDidSendMessage:self];
    }
}

@end
