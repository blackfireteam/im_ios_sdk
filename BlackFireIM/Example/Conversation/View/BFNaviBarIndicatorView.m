//
//  BFNaviBarIndicatorView.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import "BFNaviBarIndicatorView.h"
#import "BFHeader.h"
#import "UIColor+BFDarkMode.h"

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
    _indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    _indicator.center = CGPointMake(0, NavBar_Height*0.5);
    _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self addSubview:_indicator];
    
    _label = [[UILabel alloc]init];
    _label.font = [UIFont systemFontOfSize:17];
    _label.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
    [self addSubview:_label];
}

- (void)setTitle:(NSString *)title
{
    _label.text = title;
    [self updateLayout];
}

- (void)updateLayout
{
    CGSize labelSize = [_label sizeThatFits:CGSizeMake(Screen_Width, NavBar_Height)];
    CGFloat labelY = 0;
    CGFloat labelX = _indicator.hidden ? 0 : (_indicator.frame.origin.x + _indicator.frame.size.width + 5);
    _label.frame = CGRectMake(labelX, labelY, labelSize.width, NavBar_Height);
    self.frame = CGRectMake(0, 0, labelX+labelSize.width+5, NavBar_Height);
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
