//
//  UIImage+BFKit.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import "UIImage+BFKit.h"
#import "UIImage+BFDarkMode.h"
#import "BFHeader.h"

@implementation UIImage (BFKit)

+ (UIImage *)bf_imageNamed:(NSString *)name
{
    UIImage *image = [UIImage d_imageWithImageLight:TUIKitResource(name) dark:[NSString stringWithFormat:@"%@_dark",TUIKitResource(name)]];
    return image;
}

+ (UIImage *)bf_imagePath:(NSString *)path
{
    UIImage *image = [UIImage d_imageWithImageLight:path dark:[NSString stringWithFormat:@"%@_dark",path]];
    return image;
}

@end
