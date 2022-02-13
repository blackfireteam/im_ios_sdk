//
//  MSHelper.m
//  BlackFireIM
//
//  Created by benny wang on 2021/5/27.
//

#import "MSHelper.h"
#import <SVProgressHUD.h>


@implementation MSHelper

+ (void)showToast
{
    [SVProgressHUD show];
}

+ (void)showToastString:(NSString *)text
{
    [SVProgressHUD setMinimumDismissTimeInterval:3];
    [SVProgressHUD showInfoWithStatus:text];
}

+ (void)showToastSucc:(NSString *)text
{
    [SVProgressHUD setMinimumDismissTimeInterval:3];
    [SVProgressHUD showSuccessWithStatus:text];
}

+ (void)showToastFail:(NSString *)text
{
    [SVProgressHUD setMinimumDismissTimeInterval:3];
    [SVProgressHUD showErrorWithStatus:text];
}

+ (void)dismissToast
{
    [SVProgressHUD dismiss];
}


static NSArray *emotionResources() {
    static NSArray *resource;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"TUIKitFace" ofType:@"bundle"];
        NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
        NSString *filePath = [resourceBundle pathForResource:@"/emotion/emotion" ofType:@"plist"];
        resource = [NSArray arrayWithContentsOfFile:filePath];
    });
    return resource;
}

/// 通过表情查找表情名称
+ (NSString *)emoteionName:(NSString *)emotion_id
{
    for (NSDictionary *dic in emotionResources()) {
        NSString *e_id = dic[@"id"];
        if ([e_id isEqualToString:emotion_id]) {
            return dic[@"lottie"];
        }
    }
    return @"";
}


@end
