//
//  BFHelper.m
//  BlackFireIM
//
//  Created by benny wang on 2021/5/27.
//

#import "BFHelper.h"
#import <SVProgressHUD.h>


@implementation BFHelper

+ (void)showToast
{
    [SVProgressHUD show];
}

+ (void)showToastString:(NSString *)text
{
    [SVProgressHUD showInfoWithStatus:text];
}

+ (void)showToastSucc:(NSString *)text
{
    [SVProgressHUD showSuccessWithStatus:text];
}

+ (void)showToastFail:(NSString *)text
{
    [SVProgressHUD showErrorWithStatus:text];
}

+ (void)dismissToast
{
    [SVProgressHUD dismiss];
}


@end
