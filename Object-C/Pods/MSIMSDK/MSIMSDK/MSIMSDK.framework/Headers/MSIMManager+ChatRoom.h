//
//  MSIMManager+ChatRoom.h
//  MSIMSDK
//
//  Created by benny wang on 2021/10/28.
//

#import <MSIMSDK/MSIMManager.h>
#import <MSIMSDK/MSChatRoomInfo.h>


NS_ASSUME_NONNULL_BEGIN


@interface MSIMManager (ChatRoom)

/// 申请加入聊天室
- (void)joinInChatRoom:(NSInteger)room_id
                  succ:(void (^)(MSChatRoomInfo *info))succed
                failed:(MSIMFail)failed;

/// 退出聊天室
- (void)quitChatRoom:(NSInteger)room_id
                succ:(MSIMSucc)succed
              failed:(MSIMFail)failed;


/// 发送聊天室消息
/// @param elem 消息体
/// @param room_id 聊天室id
/// @param success 发送成功，返回消息的唯一标识ID
/// @param failed 发送失败
- (void)sendChatRoomMessage:(MSIMElem *)elem
                   toRoomID:(NSString *)room_id
                  successed:(void(^)(NSInteger msg_id))success
                     failed:(MSIMFail)failed;

/// 聊天室消息重发
/// @param elem 消息体
/// @param room_id 聊天室id
/// @param success 发送成功，返回消息的唯一标识ID
/// @param failed 发送失败
- (void)resendChatRoomMessage:(MSIMElem *)elem
                     toRoomID:(NSString *)room_id
                    successed:(void(^)(NSInteger msg_id))success
                       failed:(MSIMFail)failed;


/// 聊天室所有的群成员
/// @param room_id 聊天室id
/// @param success 发送成功，返回群成员列表
/// @param failed 发送失败
- (void)chatRoomMembers:(NSInteger)room_id
              successed:(void(^)(NSArray<MSProfileInfo *> *))success
                 failed:(MSIMFail)failed;
@end

NS_ASSUME_NONNULL_END
