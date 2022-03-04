//
//  MSCallManager.h
//  BlackFireIM
//
//  Created by benny wang on 2021/7/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,CallAction) {
    CallAction_Error = -1,    //系统错误
    CallAction_Unknown,       //未知流程
    CallAction_Call,          //邀请方发起请求
    CallAction_Cancel,        //邀请方取消请求（只有在被邀请方还没处理的时候才能取消）
    CallAction_Reject,        //被邀请方拒绝邀请
    CallAction_Timeout,       //被邀请方超时未响应
    CallAction_End,           //通话中断
    CallAction_Linebusy,      //被邀请方正忙
    CallAction_Accept,        //被邀请方接受邀请
};

typedef NS_ENUM(NSInteger, MSCallType) {
    MSCallType_Voice,     //语音通话
    MSCallType_Video,   //视频通话
};

typedef NS_ENUM(NSInteger, CallState) {
    CallState_Dailing,     //呼叫
    CallState_OnInvitee,   //被呼叫
    CallState_Calling,     //通话中
};

@interface MSCallManager : NSObject

+ (instancetype)shareInstance;

- (void)callToPartner:(NSString *)partner_id
              creator:(NSString *)creator
             callType:(MSCallType)callType
               action:(CallAction)action
              room_id:(nullable NSString *)room_id;

- (void)recieveCall:(NSString *)from
            creator:(NSString *)creator
           callType:(MSCallType)callType
             action:(CallAction)action
            room_id:(nullable NSString *)room_id;

/// 根据自定义参数解析出消息中展示的内容
+ (NSString *)parseToMessageShow:(NSDictionary *)customParams callType:(MSCallType)callType isSelf:(BOOL)isSelf;

/// 根据自定义参数解析出在会话中展示的内容
+ (NSString *)parseToConversationShow:(NSDictionary *)customParams callType:(MSCallType)callType isSelf:(BOOL)isSelf;

+ (NSString *)getCreatorFrom:(NSString *)room_id;

- (void)acceptBtnDidClick:(MSCallType)type;

- (void)rejectBtnDidClick:(MSCallType)type;

- (void)hangupBtnDidClick:(MSCallType)type;

@end

NS_ASSUME_NONNULL_END
