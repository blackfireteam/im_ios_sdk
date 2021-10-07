//
//  MSIMManager.h
//  BlackFireIM
//
//  Created by benny wang on 2021/2/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MSIMSDK/MSIMManagerListener.h>
#import <MSIMSDK/MSDBMessageStore.h>
#import <MSIMSDK/MSDBConversationStore.h>
#import <MSIMSDK/MSTCPSocket.h>
#import <MSIMSDK/MSUploadMediator.h>


NS_ASSUME_NONNULL_BEGIN

/// 获取历史消息成功回调
typedef void (^MSIMConversationListSucc)(NSArray<MSIMConversation *> * convs,NSInteger nexSeq,BOOL isFinished);

@interface MSIMManager : NSObject

@property(nonatomic,strong,readonly) MSTCPSocket *socket;

@property(nonatomic,assign,readonly) MSIMNetStatus connStatus;//tcp连接状态

@property(nonatomic,strong) MSDBMessageStore *messageStore;

@property(nonatomic,strong) MSDBConversationStore *convStore;

///暂时缓存服务器返回的会话列表，当接收到服务器返回的所有会话时，再写入数据库
@property(nonatomic,strong) NSMutableArray *convCaches;

///消息池，当短时间内收到大量消息时，批量消息处理以提高性能
@property(nonatomic,strong) NSMutableArray *messageCaches;

///用户下线消息池，当短时间内收到大量用户下线消息时，批量处理
@property(nonatomic,strong) NSMutableArray *offlineCache;

///当接收到服务器返回的所有会话时,批量同步profile信息，再写入数据库
@property(nonatomic,strong) NSMutableArray *profileCaches;

///记录上次同步会话的时间戳
@property(nonatomic,assign) NSInteger chatUpdateTime;

///同步会话列表是否完成
@property(nonatomic,assign) BOOL isChatListResult;

///更新同步会话时间
- (void)updateChatListUpdateTime:(NSInteger)updateTime;

+ (instancetype)sharedInstance;

///IM连接状态监听器
@property(nonatomic,weak) id<MSIMSDKListener> connListener;

///收发消息监听器
@property(nonatomic,weak) id<MSIMMessageListener> msgListener;

///会话列表监听器
@property(nonatomic,weak) id<MSIMConversationListener> convListener;

///profile信息变更监听器
@property(nonatomic,weak) id<MSIMProfileListener> profileListener;

///文件上传服务
@property(nonatomic,weak) id<MSUploadMediator> uploadMediator;

///初始化 SDK 并设置 MSIMSDKListener 的监听对象
///initSDK 后 SDK 会自动连接网络，网络连接状态可以在 MSIMSDKListener 回调里面监听
- (void)initSDK:(IMSDKConfig *)config listener:(id<MSIMSDKListener>)listener;

///反初始化 SDK
- (void) unInitSDK;

///登录需要用户签名 token
- (void)login:(NSString *)userSign
        imUrl:(NSString *)imUrl
     subAppID:(NSInteger)subID
         succ:(MSIMSucc)succ
       failed:(MSIMFail)fail;

///退出登录
- (void)logout:(MSIMSucc)succ
        failed:(MSIMFail)fail;

///更新推送的token. device_token为空时，表示推送权限关闭，不接受推送
- (void)refreshPushDeviceToken:(nullable NSString *)device_token;

@end

NS_ASSUME_NONNULL_END
