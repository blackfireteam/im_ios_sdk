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


@end
