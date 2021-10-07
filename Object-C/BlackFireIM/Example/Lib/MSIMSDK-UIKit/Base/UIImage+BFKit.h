//
//  UIImage+BFKit.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (BFKit)

+ (UIImage *)bf_imageNamed:(NSString *)name;

+ (UIImage *)bf_imagePath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
