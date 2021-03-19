//
//  MSIMManager.h
//  BlackFireIM
//
//  Created by benny wang on 2021/2/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IMSDKConfig.h"
#import "MSIMConst.h"
#import "MSIMManagerListener.h"
#import "MSDBMessageStore.h"
#import "ChatProtobuf.pbobjc.h"
#import "MSDBConversationStore.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TCPBlock)(NSInteger code, id _Nullable response, NSString * _Nullable error);
/// 成功通用回调
typedef void (^MSIMSucc)(void);
/// 失败通用回调
typedef void (^MSIMFail)(NSInteger code, NSString * desc);

@interface MSIMManager : NSObject

@property(nonatomic,strong) MSDBMessageStore *messageStore;

@property(nonatomic,strong) MSDBConversationStore *convStore;

///暂时缓存服务器返回的会话列表，当接收到服务器返回的所有会话时，再写入数据库
@property(nonatomic,strong) NSMutableArray *convCaches;

///记录上次同步会话的时间戳
@property(nonatomic,assign) NSInteger chatUpdateTime;

+ (instancetype)sharedInstance;

///IM连接状态监听器
@property(nonatomic,weak) id<MSIMSDKListener> connListener;

///收发消息监听器
@property(nonatomic,weak) id<MSIMMessageListener> msgListener;

///会话列表监听器
@property(nonatomic,weak) id<MSIMConversationListener> convListener;

///profile信息变更监听器
@property(nonatomic,weak) id<MSIMProfileListener> profileListener;

///初始化 SDK 并设置 V2TIMSDKListener 的监听对象
///initSDK 后 SDK 会自动连接网络，网络连接状态可以在 V2TIMSDKListener 回调里面监听
- (void)initWithConfig:(IMSDKConfig *)config listener:(id<MSIMSDKListener>)listener;


///  发送消息
/// @param sendData 消息体
/// @param protoType 对应proto类型
/// @param encry 是否需要加密
/// @param sign 本地消息ID
/// @param block 结束回调
- (void)send:(NSData *)sendData protoType:(XMChatProtoType)protoType needToEncry:(BOOL)encry sign:(int64_t)sign callback:(TCPBlock _Nullable)block;

- (void)sendMessageResponse:(NSInteger)sign resultCode:(NSInteger)code resultMsg:(NSString *)msg response:(id)response;

///反初始化 SDK
- (void) unInitSDK;

///登录需要设置用户名 userID 和用户签名 token
- (void)login:(NSString *)userID
        token:(NSString *)token
         succ:(MSIMSucc)succ
       failed:(MSIMFail)fail;

///退出登录
- (void)logout:(MSIMSucc)succ
        failed:(MSIMFail)fail;

@end

NS_ASSUME_NONNULL_END
