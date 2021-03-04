//
//  BFAsyncSocketManager.h
//  BlackFireIM
//
//  Created by benny wang on 2021/2/25.
//

#import <Foundation/Foundation.h>
#import <GCDAsyncSocket.h>


NS_ASSUME_NONNULL_BEGIN

@protocol BFAsyncSocketManagerDelegate<NSObject>

- (void)socket:(GCDAsyncSocket *)socket didReadData:(NSData *)data;
- (void)socket:(GCDAsyncSocket *)socket didConnect:(NSString *)host port:(uint16_t)port;
- (void)socketDidDisconnect:(GCDAsyncSocket *)socket;

@end

@interface BFAsyncSocketManager : NSObject


@property (nonatomic,weak)id <BFAsyncSocketManagerDelegate>delegate;

+ (instancetype)manager;
- (void)connectWithIp:(NSString *)ip port:(UInt16)port;     // 手动连接服务器
- (void)disConnect;
- (void)send:(NSData *)data;
- (BOOL)status;

@end

NS_ASSUME_NONNULL_END
