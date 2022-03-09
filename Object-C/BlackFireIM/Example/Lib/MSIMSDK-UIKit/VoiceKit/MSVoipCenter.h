//
//  MSVoipCenter.h
//  BlackFireIM
//
//  Created by benny wang on 2022/3/2.
//

#import <Foundation/Foundation.h>
#import "MSCallManager.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSVoipCenter : NSObject

+ (instancetype)shareInstance;

/// 记录正在通话的calling
@property(nonatomic,copy,readonly) NSString *currentCalling;

- (NSString *)createUUIDWithRoomID:(NSString *)room_id fromUid:(NSString *)fromUid subType:(MSCallType)callType;

- (NSString *)roomIDWithUUID:(NSString *)uuid;

- (void)acceptCallWithUuid:(NSString *)uuid;

- (void)endCallWithUuid:(NSString *)uuid;

- (void)muteCall:(BOOL)isMute uuid:(NSString *)uuid;

- (void)didActivateAudioSession;


@end

NS_ASSUME_NONNULL_END
