//
//  MSTCPSocket.h
//  BlackFireIM
//
//  Created by benny wang on 2021/5/14.
//

#import <UIKit/UIKit.h>
#import "IMSDKConfig.h"
#import "MSIMConst.h"


NS_ASSUME_NONNULL_BEGIN


@protocol MSTCPSocketDelegate <NSObject>

- (void)connectSucc;

- (void)connectFailed:(NSInteger)code err:(NSString *)errString;

- (void)onConnecting;

- (void)onForceOffline;

- (void)onReConnFailed:(NSInteger)code err:(NSString*)err;

- (void)onUserSigExpired;

- (void)onIMLoginSucc;

- (void)onIMLoginFail:(NSInteger)code msg:(NSString *)err;

- (void)onRevieveData:(NSData *)package protoType:(XMChatProtoType)type;

@end

typedef void (^TCPBlock)(NSInteger code, id _Nullable response, NSString * _Nullable error);

@interface MSTCPSocket : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic,strong) IMSDKConfig *config;

@property(nonatomic,weak) id<MSTCPSocketDelegate> delegate;

@property(nonatomic,assign,readonly) BFIMNetStatus connStatus;//tcp连接状态

@property(nonatomic,assign,readonly) BFIMUserStatus userStatus;//用户登录状态

- (void)sendMessageResponse:(NSInteger)sign resultCode:(NSInteger)code resultMsg:(NSString *)msg response:(id)response;

- (void)connectTCPToServer;

- (void)disConnectTCP;

- (void)send:(NSData *)sendData protoType:(XMChatProtoType)protoType needToEncry:(BOOL)encry sign:(int64_t)sign callback:(TCPBlock)block;

/** 鉴权*/
- (void)imLogin:(NSString *)user_sign;

- (void)cleanCache;

@end

@interface MSMsgCacheItem: NSObject

@property(nonatomic,strong) NSData *data;
@property(nonatomic,assign) XMChatProtoType protoType;
@property(nonatomic,assign) BOOL encry;
@property(nonatomic,assign) NSInteger sign;
@property(nonatomic,copy) TCPBlock block;
@property(nonatomic,assign) BOOL isSending;

@property(nonatomic,copy) NSString *taskID;

@end
NS_ASSUME_NONNULL_END
