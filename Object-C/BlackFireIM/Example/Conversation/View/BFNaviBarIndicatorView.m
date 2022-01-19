//
//  BFNaviBarIndicatorView.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import "BFNaviBarIndicatorView.h"
#import "MSIMSDK-UIKit.h"


@implementation BFNaviBarIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:[UIColor blackColor]];
    _indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    _indicator.center = CGPointMake(0, NavBar_Height*0.5 + StatusBar_Height);
    _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self addSubview:_indicator];
    
    _label = [[UILabel alloc]init];
    _label.font = [UIFont systemFontOfSize:17];
    _label.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
    [self addSubview:_label];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, StatusBar_Height + NavBar_Height - 0.5, Screen_Width, 0.5)];
    line.backgroundColor = [UIColor d_colorWithColorLight:TCell_separatorColor dark:TCell_separatorColor_Dark];;
    [self addSubview:line];
}

- (void)setTitle:(NSString *)title
{
    _label.text = title;
    [self updateLayout];
}

- (void)updateLayout
{
    CGSize labelSize = [_label sizeThatFits:CGSizeMake(Screen_Width, NavBar_Height)];
    _label.frame = CGRectMake(Screen_Width * 0.5 - labelSize.width * 0.5, StatusBar_Height + NavBar_Height * 0.5 - labelSize.height * 0.5, labelSize.width, labelSize.height);
    _indicator.frame = CGRectMake(self.label.x - 25, StatusBar_Height + NavBar_Height * 0.5 - 10, 20, 20);
}

- (void)startAnimating
{
    [_indicator startAnimating];
}

- (void)stopAnimating
{
    [_indicator stopAnimating];
}

@end
