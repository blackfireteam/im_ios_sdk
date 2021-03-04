//
//  BFAsyncSocketManager.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/25.
//

#import "BFAsyncSocketManager.h"


@interface BFAsyncSocketManager()<GCDAsyncSocketDelegate>

@property(nonatomic,strong) GCDAsyncSocket *socket;
@property (nonatomic,strong)dispatch_queue_t socketQueue;// 发数据的串行队列
@property (nonatomic,strong)dispatch_queue_t recieveQueue;// 收数据处理的串行队列
@property (strong, nonatomic) NSString *ip;
@property (assign, nonatomic) UInt16 port;

@end
@implementation BFAsyncSocketManager

static BFAsyncSocketManager *_manager = nil;
+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[BFAsyncSocketManager alloc]init];
    });
    return _manager;
}

- (instancetype)init
{
    if(self = [super init]) {
        self.socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:self.socketQueue];
    }
    return self;
}

- (dispatch_queue_t)socketQueue
{
    if(!_socketQueue) {
        _socketQueue = dispatch_queue_create("com.sendSocket", DISPATCH_QUEUE_SERIAL);
    }
    return _socketQueue;
}

- (dispatch_queue_t)recieveQueue
{
    if(!_recieveQueue) {
        _recieveQueue = dispatch_queue_create("com.recieveSocket", DISPATCH_QUEUE_SERIAL);
    }
    return _recieveQueue;
}

- (void)connectWithIp:(NSString *)ip port:(UInt16)port
{
    _ip = ip;
    _port = port;
    //    [self disConnect];
    NSError *error = nil;
    [self.socket connectToHost:ip onPort:port error:&error];
    if(error) {
        NSLog(@"socket连接错误：%@", error);
    }
}

- (void)disConnect
{
    [self.socket disconnect];
}


- (void)send:(NSData *)data
{
    NSLog(@"socket send 发送数据");
    [self.socket writeData:data withTimeout:-1 tag:100];
}

- (BOOL)status
{
    if(self.socket != nil && self.socket.isConnected) {
        return YES;
    }
    return NO;
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    dispatch_async(self.recieveQueue, ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(socket:didConnect:port:)]) {
            [self.delegate socket:sock didConnect:host port:port];
        }
        [self.socket readDataWithTimeout:-1 tag:100];
    });
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    dispatch_async(self.recieveQueue, ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(socketDidDisconnect:)]) {
            [self.delegate socketDidDisconnect:sock];
        }
    });
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    dispatch_async(self.recieveQueue, ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(socket:didReadData:)]) {
            [self.delegate socket:sock didReadData:data];
        }
        [self.socket readDataWithTimeout:-1 tag:100];
    });
}

@end
