//
//  MSUnreadView.m
//  BlackFireIM
//
//  Created by benny wang on 2021/5/28.
//

#import "MSUnreadView.h"

@implementation MSUnreadView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setNum:(NSInteger)num
{
    NSString *unReadStr = [[NSNumber numberWithInteger:num] stringValue];
//    if (num > 99){
//        unReadStr = @"99+";
//    }
    _unReadLabel.text = unReadStr;
    self.hidden = (num <= 0? YES: NO);
    [self defaultLayout];
}

- (void)setupViews
{
    _unReadLabel = [[UILabel alloc] init];
    _unReadLabel.text = @"11";
    _unReadLabel.font = [UIFont systemFontOfSize:12];
    _unReadLabel.textColor = [UIColor whiteColor];
    _unReadLabel.textAlignment = NSTextAlignmentCenter;
    [_unReadLabel sizeToFit];
    [self addSubview:_unReadLabel];

    self.layer.cornerRadius = (_unReadLabel.frame.size.height + 2 * 2)/2.0;
    [self.layer masksToBounds];
    self.backgroundColor = [UIColor redColor];
    self.hidden = YES;
}

- (void)defaultLayout
{
    [_unReadLabel sizeToFit];
    CGFloat width = _unReadLabel.frame.size.width + 2 * 4;
    CGFloat height =  _unReadLabel.frame.size.height + 2 * 2;
    if(width < height){
        width = height;
    }
    self.bounds = CGRectMake(0, 0, width, height);
    _unReadLabel.frame = self.bounds;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (@available(iOS 11.0, *)){
        //Here is a workaround on iOS 11 UINavigationBarItem init with custom view, position issue
        UIView *view = self;
        while (![view isKindOfClass:[UINavigationBar class]] && [view superview] != nil)
        {
            view = [view superview];
            if ([view isKindOfClass:[UIStackView class]] && [view superview] != nil)
            {
                    CGFloat margin = 40.0f;
                        //margin = 4.0f;
                    [view.superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                                    attribute:NSLayoutAttributeLeading
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                    toItem:view.superview
                                                                                    attribute:NSLayoutAttributeLeading
                                                                                    multiplier:1.0
                                                                                    constant:margin]];
                break;
            }
        }
    }
}

@end
