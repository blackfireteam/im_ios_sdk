//
//  UIView+BFExtension.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (BFExtension)

- (UIViewController *)bf_viewController;

- (void)setGradientLayer:(UIColor*)startColor endColor:(UIColor*)endColor;

@end

NS_ASSUME_NONNULL_END
