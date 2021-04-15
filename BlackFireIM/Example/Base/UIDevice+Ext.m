//
//  UIDevice+Ext.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/15.
//

#import "UIDevice+Ext.h"

@implementation UIDevice (Ext)

// UIImpactFeedbackGenerator类是标准的触觉反馈类
+ (void)impactFeedback
{
    if(@available(iOS 10.0, *)) {
        UIImpactFeedbackGenerator *impactLight = [[UIImpactFeedbackGenerator alloc]initWithStyle:UIImpactFeedbackStyleMedium];
        [impactLight impactOccurred];
    }
}

@end
