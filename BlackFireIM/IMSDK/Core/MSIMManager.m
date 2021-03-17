//
//  MSIMManager.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/25.
//

#import "MSIMManager.h"
#import "NSData+zlib.h"
#import "MSIMConst.h"
#import <GCDAsyncSocket.h>
#import "NSString+AES.h"
#import "MSIMTools.h"
#import "MSIMErrorCode.h"
#import "MSDBManager.h"
#import "MSIMManager+Conversation.h"
#import "MSProfileProvider.h"
#import "MSIMManager+Parse.h"


@interface MSIMManager()<GCDAsyncSocketDelegate>

@property(nonatomic,strong) IMSDKConfig *config;

@property(nonatomic,strong) NSMutableData *buffer;// 接收缓冲区
@property(nonatomic,assign) NSInteger bodyLength;//包体总长度
@property(nonatomic,strong) NSTimer *heartTimer; // 心跳 timer

@property(nonatomic,strong) NSTimer *callbackTimer;

@property(nonatomic,strong) NSLock *dictionaryLock;
@property(nonatomic,nonatomic) NSMutableDictionary *callbackBlock;

@property(nonatomic,strong) GCDAsyncSocket *socket;
@property(nonatomic,strong)dispatch_queue_t socketQueue;// 数据的串行队列

@property(nonatomic,assign) BOOL needToDisconnect;//是否是主动断开连接，主动断开不自动重连 默认：no

@property(nonatomic,assign) NSInteger retryCount;//自动重连次数

@property(nonatomic,copy) MSIMSucc loginSuccBlock;
@property(nonatomic,copy) MSIMFail loginFailBlock;

@end
@implementation MSIMManager

static MSIMManager *_manager;
+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _manager = [[MSIMManager alloc]init];
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
        _callbackTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(callbackHandler:) userInfo:nil repeats:true];
        [[NSRunLoop mainRunLoop]addTimer:_callbackTimer forMode:NSRunLoopCommonModes];
        
    }
    return self;
}

- (MSDBMessageStore *)messageStore
{
    if (!_messageStore) {
        _messageStore = [[MSDBMessageStore alloc]init];
    }
    return _messageStore;
}

- (MSDBConversationStore *)convStore
{
    if (!_convStore) {
        _convStore = [[MSDBConversationStore alloc]init];
    }
    return _convStore;
}

- (NSMutableArray *)convCaches
{
    if (!_convCaches) {
        _convCaches = [NSMutableArray array];
    }
    return _convCaches;
}

- (dispatch_queue_t)socketQueue
{
    if(!_socketQueue) {
        _socketQueue = dispatch_queue_create("com.sendSocket", DISPATCH_QUEUE_SERIAL);
    }
    return _socketQueue;
}

- (void)initWithConfig:(IMSDKConfig *)config listener:(id<MSIMManagerListener>)listener
{
    _config = config;
    _listener = listener;
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
    [self imLogin];//建立长链接，马上鉴权
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
                    if(data != nil && isSecrect) {//先解密
                        NSString *encryStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                        data = [[NSString decryptAES:encryStr key:nil]dataUsingEncoding:NSUTF8StringEncoding];
                    }
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
                [self sendMessageResponse:result.sign resultCode:ERR_SUCC resultMsg:@"单条消息已发送到服务器" response:result];
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
                [self recieveMessages:@[recieve]];
            }else {
                NSLog(@"消息protobuf解析失败-- %@",error);
            }
        }
            break;
        case XMChatProtoTypeMassRecieve: //收到批量消息
        {
            NSError *error;
            ChatRBatch *batch = [[ChatRBatch alloc]initWithData:package error:&error];
            if (error == nil && batch.msgsArray != nil) {
                [self recieveMessages:batch.msgsArray];
                [self sendMessageResponse:batch.sign resultCode:ERR_SUCC resultMsg:@"收到历史消息" response:batch];
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
                [self chatUnreadCountChanged:result];
            }
        }
            break;
        case XMChatProtoTypeGetChatListResponse: //拉取会话列表结果
        {
            NSError *error;
            ChatList *result = [[ChatList alloc]initWithData:package error:&error];
            if (error != nil) {
                [self chatListResultHandler:result];
            }
        }
            break;
        case XMChatProtoTypeGetProfileResult: //返回的单个用户信息结果
        {
            NSError *error;
            Profile *profile = [[Profile alloc]initWithData:package error:&error];
            if(error == nil && profile != nil) {
                [self sendMessageResponse:profile.sign resultCode:ERR_SUCC resultMsg:@"" response:profile];
            }else {
                NSLog(@"消息protobuf解析失败-- %@",error);
            }
        }
            break;
        case XMChatProtoTypeGetProfiles: //返回批量用户信息结果
        {
            NSError *error;
            ProfileList *profiles = [[ProfileList alloc]initWithData:package error:&error];
            if(error == nil && profiles != nil) {
                [self profilesResultHandler:profiles];
            }else {
                NSLog(@"消息protobuf解析失败-- %@",error);
            }
        }
            break;
        case XMChatProtoTypeDeleteChat: //删除一条会成功通知
        {
            NSError *error;
            DelChat *result = [[DelChat alloc]initWithData:package error:&error];
            if(error == nil && result != nil) {
                [self sendMessageResponse:result.sign resultCode:ERR_SUCC resultMsg:@"" response:result];
            }else {
                NSLog(@"消息protobuf解析失败-- %@",error);
            }
        }
            break;
        case XMChatProtoTypeResult: //主动发起操作处理结果
        {
            NSError *error;
            Result *result = [[Result alloc]initWithData:package error:&error];
            if(error == nil && result != nil) {
                [self messageRsultHandler:result];
            }else {
                NSLog(@"消息protobuf解析失败-- %@",error);
            }
        }
            break;
        default:
            break;
    }
}

- (void)messageRsultHandler:(Result *)result
{
    NSString *key = [NSString stringWithFormat:@"%lld",result.sign];
    NSDictionary *dic = [self.callbackBlock objectForKey:key];
    if (dic) {
        XMChatProtoType protoType = [dic[@"protoType"] integerValue];
        if (protoType == XMChatProtoTypeSend) {
            
        }else if (protoType == XMChatProtoTypeGetHistoryMsg) {
            
        }else if (protoType == XMChatProtoTypeRecall) {//消息撤回失败
            
        }else if (protoType == XMChatProtoTypeMsgread) {//标识某条消息已读
            
        }else if (protoType == XMChatProtoTypeDeleteChat) {//删除某一条会话
            
        }else if (protoType == XMChatProtoTypeGetChatList) {
            
        }
        [self sendMessageResponse:result.sign resultCode:result.code resultMsg:result.msg response:result];
    }
}

- (void)sendMessageResponse:(NSInteger)sign resultCode:(NSInteger)code resultMsg:(NSString *)msg response:(id)response
{
    NSString *key = [NSString stringWithFormat:@"%ld",sign];
    NSDictionary *dic = [self.callbackBlock objectForKey:key];
    TCPBlock complete = dic[@"callback"];
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
        [_callbackBlock setObject:@{@"callback": block,@"protoType": @(protoType),@"data": sendData} forKey:key];
        [_dictionaryLock unlock];
    }
    [self.socket writeData:data withTimeout:-1 tag:100];
    [self startHeartBeat];
}

- (void)callbackHandler:(NSTimer *)timer
{
    NSArray *allKeys = self.callbackBlock.allKeys;
    for (NSString *key in allKeys) {
        NSInteger sendTime = key.integerValue;
        if (([MSIMTools sharedInstance].adjustLocalTimeInterval - sendTime) > 60*1000*1000) {//判断超时，回调失败
            NSDictionary *dic = self.callbackBlock[key];
            TCPBlock complete = dic[@"callback"];
            if (complete) {
                complete(key.integerValue,nil,nil);
            }
            [self.callbackBlock removeObjectForKey:key];
        }
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
- (void)imLogin
{
    WS(weakSelf)
    ImLogin *login = [[ImLogin alloc]init];
    login.token = self.config.token;
    login.sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
    [self send:[login data] protoType:XMChatProtoTypeLogin needToEncry:false sign:login.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        STRONG_SELF(strongSelf)
        if (code == ERR_SUCC) {
            Result *result = response;
            [MSIMTools sharedInstance].user_id = [NSString stringWithFormat:@"%lld",result.uid];
            [[MSIMTools sharedInstance] updateServerTime:result.nowTime];
            strongSelf.loginSuccBlock();
            //同步会话列表
            [strongSelf.convCaches removeAllObjects];
            [strongSelf synchronizeConversationList];
        }else {
            NSLog(@"token 鉴权失败*******code = %ld,response = %@,errorMsg = %@",code,response,error);
            [strongSelf disConnectTCP];//断开链接，启动重连
            strongSelf.loginFailBlock(code, error);
        }
    }];
}

///反初始化 SDK
- (void) unInitSDK
{
    
}

///登录需要设置用户名 userID 和用户签名 token
- (void)login:(NSString *)userID
        token:(NSString *)token
         succ:(MSIMSucc)succ
       failed:(MSIMFail)fail
{
    if (userID == nil) {
        return;
    }
    if (token == nil) {
        return;
    }
    [MSIMTools sharedInstance].user_id = userID;
    self.config.token = token;
    self.loginSuccBlock = succ;
    self.loginFailBlock = fail;
    if (self.socket.isConnected) {
        self.needToDisconnect = YES;
        [self disConnectTCP];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.needToDisconnect = NO;
            [self connectTCPToServer];
        });
    }else {
        self.needToDisconnect = NO;
        [self connectTCPToServer];
    }
}

///退出登录
- (void)logout:(MSIMSucc)succ
        failed:(MSIMFail)fail
{
    WS(weakSelf)
    ImLogout *logout = [[ImLogout alloc]init];
    logout.sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
    [self send:[logout data] protoType:XMChatProtoTypeLogout needToEncry:NO sign:logout.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        STRONG_SELF(strongSelf)
        if (code == ERR_SUCC) {
//            Result *result = response;
            succ();
        }else {
            NSLog(@"token 鉴权失败*******code = %ld,response = %@,errorMsg = %@",code,response,error);
            strongSelf.needToDisconnect = YES;
            [strongSelf disConnectTCP];//断开链接，启动重连
            [[MSDBManager sharedInstance] accountChanged];
            fail(code, error);
        }
    }];
}

@end
