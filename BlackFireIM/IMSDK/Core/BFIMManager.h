//
//  BFIMManager.h
//  BlackFireIM
//
//  Created by benny wang on 2021/2/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IMSDKConfig.h"
#import "BFIMConst.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TCPBlock)(NSInteger code, id _Nullable response, NSString * _Nullable error);
@protocol BFIMManagerListener <NSObject>

- (void)onConnecting;
- (void)onConnectSuccess;
- (void)onConnectFailed:(int)code err:(NSString *)errString;

@end

@interface BFIMManager : NSObject

+ (instancetype)sharedInstance;

///初始化 SDK 并设置 V2TIMSDKListener 的监听对象
///initSDK 后 SDK 会自动连接网络，网络连接状态可以在 V2TIMSDKListener 回调里面监听
- (void)initWithConfig:(IMSDKConfig *)config listener:(id<BFIMManagerListener>)listener;


///  发送消息
/// @param sendData 消息体
/// @param protoType 对应proto类型
/// @param encry 是否需要加密
/// @param sign 本地消息ID
/// @param block 结束回调
- (void)send:(NSData *)sendData protoType:(XMChatProtoType)protoType needToEncry:(BOOL)encry sign:(int64_t)sign callback:(TCPBlock)block;

@end

NS_ASSUME_NONNULL_END
