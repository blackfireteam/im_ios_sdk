//
//  BFIMManager.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/25.
//

#import "BFIMManager.h"
#import "NSData+zlib.h"
#import "BFIMConst.h"
#import <GCDAsyncSocket.h>
#import "NSString+AES.h"
#import "BFIMTools.h"
#import "ChatProtobuf.pbobjc.h"

@interface BFIMManager()<GCDAsyncSocketDelegate>

@property(nonatomic,strong) IMSDKConfig *config;
@property(nonatomic,weak) id<BFIMManagerListener> listener;

@property(nonatomic,strong) NSMutableData *buffer;// 接收缓冲区
@property(nonatomic,assign) NSInteger bodyLength;//包体总长度
@property(nonatomic,strong) NSTimer *heartTimer; // 心跳 timer

@property(nonatomic,strong) NSLock *dictionaryLock;
@property(nonatomic,nonatomic) NSMutableDictionary *callbackBlock;

@property(nonatomic,strong) GCDAsyncSocket *socket;
@property(nonatomic,strong)dispatch_queue_t socketQueue;// 数据的串行队列

@property(nonatomic,assign) BOOL needToDisconnect;//断线是否需要重连 默认：yes

@property(nonatomic,assign) NSInteger retryCount;//自动重连次数

@end
@implementation BFIMManager

static BFIMManager *_manager;
+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _manager = [[BFIMManager alloc]init];
    });
    return _manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        _buffer = [NSMutableData data];
        [_buffer setLength: 0];
        _callbackBlock = [NSMutableDictionary dictionary];
        _socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:self.socketQueue];
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

- (void)initWithConfig:(IMSDKConfig *)config listener:(id<BFIMManagerListener>)listener
{
    _config = config;
    _listener = listener;
    [self connectTCPToServer];
}

- (void)connectTCPToServer
{
    NSError *error = nil;
    [self.socket connectToHost:self.config.ip onPort:self.config.port error:&error];
    if(error) {
        NSLog(@"socket连接错误：%@", error);
    }
}

- (void)disConnectTCP
{
    [self.socket disconnect];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [self.socket readDataWithTimeout:-1 tag:100];
    self.retryCount = 0;
    [self startHeartBeat];
    [self handshake];//建立长链接，马上鉴权
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [self closeTimer];
    //在非手动断开的情况下才进行重连
    if(self.needToDisconnect == NO && self.retryCount <= self.config.retryCount) {
        self.retryCount++;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.retryCount*self.retryCount * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self connectTCPToServer];
        });
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [_buffer appendData:data];
    while (_buffer.length >=4) {
        SInt32 length = 0;
        [_buffer getBytes:&length length:4];//1.先读取包头4字节的长度
        HTONL(length);//ios系统采用的是小端序，将网络的大端序转换成本机序
        if(length == 0) {
            //没有申明长度的包作为异常包丢弃
            [_buffer setLength:0];
        }else {
            _bodyLength = (length >> 12) - 4;
            BOOL isZip = (length & 4095) & 1;//对应是否压缩
            BOOL isSecrect = ((length & 4095) >> 1) & 1; //是否加密
            NSInteger type = (length & 4095) >> 2;//对应protobuf的模型
            
            if((_bodyLength+4) <= _buffer.length) {//如果数据包没有超过缓冲区的大小
                @try {
                    NSData *data = [_buffer subdataWithRange:NSMakeRange(4, _bodyLength)];
//                    if(data != nil && isSecrect) {//先解密
//                        data = [NSData encryptAES:data key:nil];
//                    }
                    if(data != nil && isZip) {//先解压
                        data = [NSData dataByDecompressingData:data];
                    }
                    [self handlePackage:data protoType:type];//收到的数据分发
                    // 截取剩下的作为下个数据包
                    NSData *tmp = [_buffer subdataWithRange:NSMakeRange(_bodyLength+4, _buffer.length-_bodyLength-4)];
                    [_buffer setLength:0];//清零
                    [_buffer appendData:tmp];
                }@catch (NSException *exception) {
                    NSLog(@"exception name is %@,reason is %@",exception.name,exception.reason);
                }
                
            }else {
                break;
            }
        }
    }
    [self.socket readDataWithTimeout:-1 tag:100];
    [self startHeartBeat];
}


- (void)handlePackage:(NSData *)package protoType:(NSInteger)type
{
    NSLog(@"收到数据的长度:%ld**type = %ld",package.length,type);
    if(package == nil || package.length == 0) {
        return;
    }
    switch (type) {
        case XMChatProtoTypeResponse://单条消息回执
        {
            NSError *error;
            ChatSR *result = [[ChatSR alloc]initWithData:package error:&error];
            if (error == nil && result != nil) {
                [self sendMessageResponse:result.sign resultCode:0 resultMsg:@"单条消息已发送到服务器" response:result];
            }else {
                NSLog(@"消息protobuf解析失败-- %@",error);
            }
        }
            break;
        case XMChatProtoTypeMassResponse://批量消息回执
        {
            NSError *error;
            ChatRbatch *result = [[ChatRbatch alloc]initWithData:package error:&error];
            if (error == nil && result != nil) {
                [self sendMessageResponse:result.sign resultCode:0 resultMsg:@"批量消息已发送到服务器" response:result];
            }else {
                NSLog(@"消息protobuf解析失败-- %@",error);
            }
        }
            break;
        case XMChatProtoTypeRecieve: // 收到新消息
        {
            NSError *error;
            ChatR *recieve = [[ChatR alloc]initWithData:package error:&error];
            if (error == nil && recieve != nil) {
                
            }else {
                NSLog(@"消息protobuf解析失败-- %@",error);
            }
        }
            break;
        case XMChatProtoTypeLastReadMsg: //消息已读状态发生变更通知（客户端收到这个才去变更）
        {
            NSError *error;
            LastReadMsg *result = [[LastReadMsg alloc]initWithData:package error:&error];
            if (error != nil) {
                
            }
        }
            break;
        case XMChatProtoTypeGetChatListRespnse: //会话列表
        {
            NSError *error;
            ChatList *result = [[ChatList alloc]initWithData:package error:&error];
            if (error != nil) {
                
            }
        }
            break;
        case XMChatProtoTypeResult: //主动发起操作处理结果
        {
            NSError *error;
            Result *result = [[Result alloc]initWithData:package error:&error];
            if(error == nil && result != nil) {
                [self sendMessageResponse:result.sign resultCode:result.code resultMsg:result.msg response:result];
            }else {
                NSLog(@"消息protobuf解析失败-- %@",error);
            }
        }
            break;
        default:
            break;
    }
}

- (void)sendMessageResponse:(NSInteger)sign resultCode:(NSInteger)code resultMsg:(NSString *)msg response:(id)response
{
    NSString *key = [NSString stringWithFormat:@"%ld",sign];
    TCPBlock complete = [self.callbackBlock objectForKey:key];
    if(complete) {
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(code,response,msg);
            [self.callbackBlock removeObjectForKey:key];
        });
    }
}

- (void)send:(NSData *)sendData protoType:(XMChatProtoType)protoType needToEncry:(BOOL)encry sign:(int64_t)sign callback:(TCPBlock)block
{
    // 包头是 4个字节 包括：前20位代表整个数据包的长度，后11位代表proto的编码 ，最后一位表示报文是否压缩
    NSLog(@"压缩前***%zd",sendData.length);
    NSInteger type = protoType;
    type = type << 2;
    NSInteger isZip = 0;
    if((sendData.length + 4)/1024 > 10) {//如果发送的文本大于10kb,进行zlib压缩
        isZip = 1;
        sendData = [NSData dataByCompressingData:sendData];
        NSLog(@"压缩后***%zd",sendData.length);
    }
    encry = encry << 1;
    NSInteger originalLength = ((NSInteger)sendData.length + 4) << 12;
    NSInteger allLength = originalLength + type + encry + isZip;
    
    HTONL(allLength);
    NSMutableData *data = [NSMutableData dataWithBytes:&allLength length:4];//生成包头
    [data appendData:sendData];
    
    if(block) {
        // 保存回调 block 到字典里，接收时候用到
        NSString *key = [NSString stringWithFormat:@"%lld",sign];
        [_dictionaryLock lock];
        [_callbackBlock setObject:block forKey:key];
        [_dictionaryLock unlock];
        // 60 秒超时, 找到 key 删除
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self timerRemove:key];
        });
    }
    [self.socket writeData:data withTimeout:-1 tag:100];
    [self startHeartBeat];
}

- (void)timerRemove:(NSString *)key
{
    if(key) {
        [_dictionaryLock lock];
        TCPBlock complete = [self.callbackBlock objectForKey:key];
        if(complete) {
            complete([key integerValue],nil,nil);
        }
        [_callbackBlock removeObjectForKey:key];
        [_dictionaryLock unlock];
    }
}

/** 开启心跳 */
- (void)startHeartBeat
{
    [self closeTimer];
    // timer 要在主线程中开启才有效
    dispatch_async(dispatch_get_main_queue(), ^{
        self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:self.config.heartDuration target:self selector:@selector(sendHeart) userInfo:nil repeats:true];
        [[NSRunLoop mainRunLoop]addTimer:self.heartTimer forMode:NSRunLoopCommonModes];
    });
}

/** 关闭心跳*/
- (void)closeTimer
{
    if (self.heartTimer != nil) {
        [self.heartTimer invalidate];
        self.heartTimer = nil;
    }
}

/** 发送心跳*/
- (void)sendHeart
{
    NSLog(@"*****heat beat ********");
    Ping *ping = [[Ping alloc]init];
    ping.type = 0;
    [self send:[ping data] protoType:XMChatProtoTypeHeadBeat needToEncry:NO sign:0 callback:nil];
}

/** 鉴权*/
- (void)handshake
{
    ImToken *tokenModel = [[ImToken alloc]init];
    tokenModel.token = self.config.token;
    tokenModel.sign = [BFIMTools sharedInstance].adjustLocalTimeInterval;
    [self send:[tokenModel data] protoType:XMChatProtoTypeToken needToEncry:false sign:tokenModel.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        if (code == tokenModel.sign) {
            NSLog(@"token 鉴权失败*******code = %ld,response = %@,errorMsg = %@",code,response,error);
            [self disConnectTCP];//断开链接，启动重连
        }else {
            Result *result = response;
            [BFIMTools sharedInstance].user_id = result.uid;
            [[BFIMTools sharedInstance] updateServerTime:result.nowTime];
        }
    }];
}


@end
