//
//  UIColor+BFDarkMode.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (BFDarkMode)

+ (UIColor *)d_colorWithColorLight:(UIColor *)light dark:(UIColor *)dark;

+ (UIColor *)d_systemGrayColor;

+ (UIColor *)d_systemRedColor;

+ (UIColor *)d_systemBlueColor;

@end

NS_ASSUME_NONNULL_END
