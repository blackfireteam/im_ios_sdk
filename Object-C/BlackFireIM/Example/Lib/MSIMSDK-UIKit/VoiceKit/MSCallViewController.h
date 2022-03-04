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
- (instancetype)initWithCallType:(MSCallType)type sponsor:(NSString *)sponsor invitee:(NSString *)invitee room_id:(NSString *)room_id;

@property(nonatomic,assign,readonly) NSInteger duration;

- (void)recieveAccept:(MSCallType)callType room_id:(NSString *)room_id;

- (void)recieveHangup:(MSCallType)callType room_id:(NSString *)room_id;

- (void)acceptBtnDidClick:(MSCallType)type;

- (void)rejectBtnDidClick:(MSCallType)type;

- (void)hangupBtnDidClick:(MSCallType)type;

@end

NS_ASSUME_NONNULL_END
