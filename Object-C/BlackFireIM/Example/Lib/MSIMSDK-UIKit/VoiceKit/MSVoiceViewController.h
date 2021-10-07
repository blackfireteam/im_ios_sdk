//
//  MSVoiceViewController.h
//  BlackFireIM
//
//  Created by benny wang on 2021/7/20.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AudioCallState) {
    AudioCallState_Dailing,     //呼叫
    AudioCallState_OnInvitee,   //被呼叫
    AudioCallState_Calling,     //通话中
};

@interface MSVoiceViewController : UIViewController

///  sponsor: 邀请者uid invitee: 被邀请者uid
- (instancetype)initWithSponsor:(NSString *)sponsor invitee:(NSString *)invitee;

@property(nonatomic,assign,readonly) NSInteger duration;

- (void)recieveAccept;

- (void)recieveReject;

- (void)recieveHangup;

- (void)recieveCancel;

@end

NS_ASSUME_NONNULL_END
