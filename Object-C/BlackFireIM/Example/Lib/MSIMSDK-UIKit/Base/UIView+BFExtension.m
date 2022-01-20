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

@end
