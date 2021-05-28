//
//  BFesponderTextView.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import "BFResponderTextView.h"

@implementation BFResponderTextView

- (UIResponder *)nextResponder
{
    if(_overrideNextResponder == nil){
        return [super nextResponder];
    }
    else{
        return _overrideNextResponder;
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (_overrideNextResponder != nil)
        return NO;
    else
        return [super canPerformAction:action withSender:sender];
}

@end
