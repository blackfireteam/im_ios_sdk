//
//  UIView+BFExtension.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import "UIView+BFExtension.h"

@implementation UIView (BFExtension)

- (UIViewController *)bf_viewController {
    UIView *view = self;
    while (view) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
        view = view.superview;
      }
    return nil;
}

- (void)setGradientLayer:(UIColor*)startColor endColor:(UIColor*)endColor {

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    [self.layer addSublayer:gradientLayer];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    
    gradientLayer.colors = @[(__bridge id)startColor.CGColor,
                             (__bridge id)endColor.CGColor];
}

@end
