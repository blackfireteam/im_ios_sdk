//
//  MSChatRoomInfo.h
//  BlackFireIM
//
//  Created by benny wang on 2021/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSChatRoomInfo : NSObject

/** 聊天室id*/
@property(nonatomic,copy) NSString *room_id;

/** 聊天室名称 */
@property(nonatomic,copy) NSString *room_name;

/** 聊天室最大同时在线人数*/
@property(nonatomic,assign) NSInteger max_count;

/** 是否全体禁言*/
@property(nonatomic,assign) BOOL is_mute;

/** 在线的用户id列表*/
@property(nonatomic,strong) NSArray *uids;

@end

@interface MSChatRoomEvent: NSObject

/** 聊天室id*/
@property(nonatomic,copy) NSString *room_id;

/** 聊天室名称 */
@property(nonatomic,copy) NSString *room_name;

/** 聊天室最大同时在线人数*/
@property(nonatomic,assign) NSInteger max_count;

//事件 0：聊天室被销毁（所有用户被迫离开聊天室）1：聊天室信息修改，
//2：用户上线， 3：用户下线(自己被踢掉也会收到)
//4：全体禁言 5：解除全体禁言
@property(nonatomic,assign) NSInteger eventType;

/// 用户上线下线时有值
@property(nonatomic,copy) NSString *uid;

@end

NS_ASSUME_NONNULL_END
