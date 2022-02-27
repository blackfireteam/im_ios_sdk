//
//  MSSnapPreview.h
//  BlackFireIM
//
//  Created by benny wang on 2022/2/22.
//

#import <UIKit/UIKit.h>
#import <MSIMSDK/MSIMSDK.h>
#import "MSHeader.h"
#import "MSSnapChatTimerManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSSnapPreview : UIView

@property(nonatomic,strong) UIScrollView *scrollView;

@property(nonatomic,strong) UIButton *closeBtn;

@property(nonatomic,strong) UILabel *countL;

@property(nonatomic,strong,readonly) MSIMMessage *message;

- (void)reloadMessage:(MSIMMessage *)message;

- (void)showWithAnimation:(BOOL)animate;

- (void)dismissWithAnimation:(BOOL)animate;

@end

NS_ASSUME_NONNULL_END
