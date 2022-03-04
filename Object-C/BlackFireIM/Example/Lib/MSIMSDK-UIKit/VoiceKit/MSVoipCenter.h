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

- (NSString *)createUUIDWithRoomID:(NSString *)room_id fromUid:(NSString *)fromUid subType:(MSCallType)callType;

- (NSString *)roomIDWithUUID:(NSString *)uuid;

- (void)startCallWithUuid:(NSString *)uuid;

- (void)endCallWithUuid:(NSString *)uuid;

- (void)muteCall:(BOOL)isMute;

- (void)acceptBtnDidClick:(MSCallType)type room_id:(NSString *)room_id;

- (void)rejectBtnDidClick:(MSCallType)type room_id:(NSString *)room_id;

- (void)hangupBtnDidClick:(MSCallType)type room_id:(NSString *)room_id;

- (void)cancelBtnDidClick:(MSCallType)type room_id:(NSString *)room_id;

@end

NS_ASSUME_NONNULL_END
