//
//  MSVoiceViewController.h
//  BlackFireIM
//
//  Created by benny wang on 2021/7/20.
//

#import <UIKit/UIKit.h>
#import "MSCallManager.h"


NS_ASSUME_NONNULL_BEGIN



@interface MSCallViewController : UIViewController

///  sponsor: 邀请者    invitee: 被邀请者uid
- (instancetype)initWithCallType:(MSCallType)type sponsor:(NSString *)sponsor invitee:(NSString *)invitee;

@property(nonatomic,assign,readonly) NSInteger duration;

- (void)recieveAccept:(MSCallType)callType;

- (void)recieveReject:(MSCallType)callType;

- (void)recieveHangup:(MSCallType)callType;

- (void)recieveCancel:(MSCallType)callType;

@end

NS_ASSUME_NONNULL_END
