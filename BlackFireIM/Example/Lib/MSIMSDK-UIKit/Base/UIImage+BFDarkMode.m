//
//  UIImage+BFDarkMode.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import "UIImage+BFDarkMode.h"

@implementation UIImage (BFDarkMode)


+ (UITraitCollection *)lightTrait API_AVAILABLE(ios(13.0)) {
    static UITraitCollection *trait = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        trait = [UITraitCollection traitCollectionWithTraitsFromCollections:@[
            [UITraitCollection traitCollectionWithDisplayScale:UIScreen.mainScreen.scale],
            [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]
        ]];
    });

    return trait;
}

+ (UITraitCollection *)darkTrait API_AVAILABLE(ios(13.0)) {
    static UITraitCollection *trait = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        trait = [UITraitCollection traitCollectionWithTraitsFromCollections:@[
            [UITraitCollection traitCollectionWithDisplayScale:UIScreen.mainScreen.scale],
            [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark]
        ]];
    });

    return trait;
}

+ (UIImage *)d_imageWithImageLight:(NSString *)light dark:(NSString *)dark {
    UIImage *lightImage = [UIImage imageNamed:light];
    if (!lightImage) {
        return nil;
    }
    if (@available(iOS 13.0, *)) {
        UIImage *darkImage= [UIImage imageNamed:dark];
        UITraitCollection *const scaleTraitCollection = [UITraitCollection currentTraitCollection];
        UITraitCollection *const darkUnscaledTraitCollection = [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark];
        UITraitCollection *const darkScaledTraitCollection = [UITraitCollection traitCollectionWithTraitsFromCollections:@[scaleTraitCollection, darkUnscaledTraitCollection]];
        UIImage *image = [lightImage imageWithConfiguration:[lightImage.configuration configurationWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]]];
        darkImage = [darkImage imageWithConfiguration:[darkImage.configuration configurationWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark]]];
        [image.imageAsset registerImage:darkImage withTraitCollection:darkScaledTraitCollection];
        return image;
    } else {
        return lightImage;
    }
    return nil;
}

@end
