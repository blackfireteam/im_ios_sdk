//
//  BFesponderTextView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFResponderTextView : UITextView

@property(nonatomic,weak) UIResponder *overrideNextResponder;

@end

NS_ASSUME_NONNULL_END
