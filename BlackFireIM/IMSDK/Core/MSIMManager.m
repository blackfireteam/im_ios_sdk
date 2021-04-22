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
#import "Reachability.h"


#define kMsgMaxOutTime 30
@interface MSIMManager()<GCDAsyncSocketDelegate>

@property(nonatomic,strong) IMSDKConfig *config;

@property(nonatomic, strong) Reachability *reachability;

@property(nonatomic,assign) NetworkStatus netStatus;//当前的网络状态

@property(nonatomic,strong) NSMutableData *buffer;// 接收缓冲区
@property(nonatomic,assign) NSInteger bodyLength;//包体总长度
@property(nonatomic,strong) NSTimer *heartTimer; // 心跳 timer

@property(nonatomic,strong) NSTimer *retryTimer;//断线重连timer

@property(nonatomic,strong) NSTimer *callbackTimer;

@property(nonatomic,strong) NSLock *dictionaryLock;
@property(nonatomic,strong) NSMutableDictionary *callbackBlock;

@property(nonatomic,strong) NSMutableDictionary *taskIDs;

@property(nonatomic,strong) GCDAsyncSocket *socket;
@property(nonatomic,strong)dispatch_queue_t socketQueue;// 数据的串行队列

@property(nonatomic,assign) NSInteger retryCount;//自动重连次数

@property(nonatomic,assign) BFIMNetStatus connStatus;//tcp连接状态

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
        _taskIDs = [NSMutableDictionary dictionary];
        _socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:self.socketQueue];
        _callbackTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(callbackHandler:) userInfo:nil repeats:true];
        [[NSRunLoop mainRunLoop]addTimer:_callbackTimer forMode:NSRunLoopCommonModes];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        self.reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
        [self.reachability startNotifier];
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

- (NSMutableArray *)profileCaches
{
    if (!_profileCaches) {
        _profileCaches = [NSMutableArray array];
    }
    return _profileCaches;
}

- (dispatch_queue_t)socketQueue
{
    if(!_socketQueue) {
        _socketQueue = dispatch_queue_create("com.sendSocket", DISPATCH_QUEUE_SERIAL);
    }
    return _socketQueue;
}

- (void)initWithConfig:(IMSDKConfig *)config listener:(id<MSIMSDKListener>)listener
{
    _config = config;
    _connListener = listener;
    [self connectTCPToServer];
}

- (void)connectTCPToServer
{
    if (self.connStatus == IMNET_STATUS_SUCC || self.connStatus == IMNET_STATUS_CONNECTING) return;
    MSLog(@"请求建立TCP连接");
    self.connStatus = IMNET_STATUS_CONNECTING;
    NSError *error = nil;
    [self.socket connectToHost:self.config.ip onPort:self.config.port error:&error];
    if(error) {
        MSLog(@"socket连接错误：%@", error);
        if (self.connListener && [self.connListener respondsToSelector:@selector(connectFailed:err:)]) {
            [self.connListener connectFailed:error.code err:error.localizedDescription];
        }
        self.connStatus = IMNET_STATUS_CONNFAILED;
    }else {
        if (self.connListener && [self.connListener respondsToSelector:@selector(onConnecting)]) {
            [self.connListener onConnecting];
        }
    }
}

- (void)disConnectTCP
{
    MSLog(@"请求断开TCP连接");
    [self.socket disconnect];
}

- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability *curReach = note.object;
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    self.netStatus = netStatus;
    switch (netStatus) {
        case NotReachable:
            MSLog(@"当前网络不能用");
        {
            if (self.connListener && [self.connListener respondsToSelector:@selector(connectFailed:err:)]) {
                [self.connListener connectFailed:-99 err:@"当前网络不可用"];
            }
        }
            break;
        case ReachableViaWWAN:
            MSLog(@"当前网络WAN");
            [self connectTCPToServer];
            break;
        case ReachableViaWiFi:
            MSLog(@"当前网络WIFI");
            [self connectTCPToServer];
            break;
        default:
            break;
    }
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    MSLog(@"****建立连接成功****");
    if (self.connListener && [self.connListener respondsToSelector:@selector(connectSucc)]) {
        [self.connListener connectSucc];
    }
    self.connStatus = IMNET_STATUS_SUCC;
    [self.socket readDataWithTimeout:-1 tag:100];
    self.retryCount = 0;
    [self.retryTimer invalidate];
    self.retryTimer = nil;
    [self startHeartBeat];
    if ([MSIMTools sharedInstance].user_sign) {
        [self imLogin:[MSIMTools sharedInstance].user_sign];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    MSLog(@"****连接断开****");
    self.connStatus = IMNET_STATUS_CONNFAILED;
    [self closeTimer];
    [self.retryTimer invalidate];
    self.retryTimer = nil;
    if (self.netStatus != NotReachable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.retryCount <= self.config.retryCount) {//断线重连
                MSLog(@"断线重连");
                self.retryCount++;
                self.retryTimer = [NSTimer scheduledTimerWithTimeInterval:self.retryCount*self.retryCount target:self selector:@selector(connectTCPToServer) userInfo:nil repeats:true];
                [[NSRunLoop mainRunLoop]addTimer:self.retryTimer forMode:NSRunLoopCommonModes];
            }else {//断线重连失败
                MSLog(@"断线重连失败");
                if (self.connListener && [self.connListener respondsToSelector:@selector(onReConnFailed:err:)]) {
                    [self.connListener onReConnFailed:err.code err:err.localizedDescription];
                }
            }
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
                    MSLog(@"exception name is %@,reason is %@",exception.name,exception.reason);
                }
                
            }else {
                break;
            }
        }
    }
    [self.socket readDataWithTimeout:-1 tag:100];
}

- (void)handlePackage:(NSData *)package protoType:(NSInteger)type
{
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
                //更新会话更新时间
                [[MSIMTools sharedInstance]updateConversationTime:result.msgTime];
            }else {
                MSLog(@"消息protobuf解析失败-- %@",error);
            }
            MSLog(@"收到单条消息回执***%@",result);
        }
            break;
        case XMChatProtoTypeRecieve: // 收到新消息
        {
            NSError *error;
            ChatR *recieve = [[ChatR alloc]initWithData:package error:&error];
            if (error == nil && recieve != nil) {
                [self recieveMessage:recieve];
            }else {
                MSLog(@"消息protobuf解析失败-- %@",error);
            }
            MSLog(@"[收到]新消息***%@",recieve);
        }
            break;
        case XMChatProtoTypeMassRecieve: //收到批量消息
        {
            NSError *error;
            ChatRBatch *batch = [[ChatRBatch alloc]initWithData:package error:&error];
            if (error == nil && batch.msgsArray != nil) {
                [self sendMessageResponse:batch.sign resultCode:ERR_SUCC resultMsg:@"收到历史消息" response:batch];
            }else {
                MSLog(@"消息protobuf解析失败-- %@",error);
            }
            MSLog(@"[收到]历史消息:%@",batch);
        }
            break;
        case XMChatProtoTypeLastReadMsg: //消息已读状态发生变更通知（客户端收到这个才去变更）
        {
            NSError *error;
            LastReadMsg *result = [[LastReadMsg alloc]initWithData:package error:&error];
            if (error == nil) {
                [self chatUnreadCountChanged:result];
                //更新会话更新时间
                [[MSIMTools sharedInstance]updateConversationTime:result.updateTime];
            }
            MSLog(@"[收到]消息已读状态发生变更通知***%@",result);
        }
            break;
        case XMChatProtoTypeGetChatListResponse: //拉取会话列表结果
        {
            NSError *error;
            ChatList *result = [[ChatList alloc]initWithData:package error:&error];
            if (error == nil) {
                [self chatListResultHandler:result];
            }
            MSLog(@"[收到]会话列表***%@",result);
        }
            break;
        case XMChatProtoTypeGetProfileResult: //返回的单个用户信息结果
        {
            NSError *error;
            Profile *profile = [[Profile alloc]initWithData:package error:&error];
            if(error == nil && profile != nil) {
                [self profilesResultHandler:@[profile]];
                [self sendMessageResponse:profile.sign resultCode:ERR_SUCC resultMsg:@"" response:profile];
            }else {
                MSLog(@"消息protobuf解析失败-- %@",error);
            }
            MSLog(@"[收到]用户信息***%@",profile);
        }
            break;
        case XMChatProtoTypeGetProfilesResult: //返回批量用户信息结果
        {
            NSError *error;
            ProfileList *profiles = [[ProfileList alloc]initWithData:package error:&error];
            if(error == nil && profiles != nil) {
                [self profilesResultHandler:profiles.profilesArray];
            }else {
                MSLog(@"消息protobuf解析失败-- %@",error);
            }
            MSLog(@"[收到]批量用户信息***%@",profiles);
        }
            break;
        case XMChatProtoTypeDeleteChat: //删除一条会话成功通知
        {
            NSError *error;
            DelChat *result = [[DelChat alloc]initWithData:package error:&error];
            if(error == nil && result != nil) {
                [self deleteChatHandler:result];
            }else {
                MSLog(@"消息protobuf解析失败-- %@",error);
            }
            MSLog(@"[收到]删除一条会话成功通知***%@",result);
        }
            break;
        case XMChatProtoTypeResult: //主动发起操作处理结果
        {
            NSError *error;
            Result *result = [[Result alloc]initWithData:package error:&error];
            if(error == nil && result != nil) {
                [self messageRsultHandler:result];
            }else {
                MSLog(@"消息protobuf解析失败-- %@",error);
            }
            MSLog(@"主动发起操作处理结果***%@",result);
        }
            break;
        case XMChatProtoTypeProfileOnline: //有用户上线了
        {
            NSError *error;
            ProfileOnline *online = [[ProfileOnline alloc]initWithData:package error:&error];
            if (error == nil && online != nil) {
                [self userOnLineHandler:online];
            }else {
                MSLog(@"消息protobuf解析失败-- %@",error);
            }
            MSLog(@"[收到]有用户上线了***%@",online);
        }
            break;
            
        case XMChatProtoTypeProfileOffline: //有用户下线了
        {
            NSError *error;
            UsrOffline *offline = [[UsrOffline alloc]initWithData:package error:&error];
            if (error == nil && offline != nil) {
                [self userOfflineHandler:offline];
            }else {
                MSLog(@"消息protobuf解析失败-- %@",error);
            }
            MSLog(@"[收到]有用户下线了***%@",offline);
        }
            break;
        case XMChatProtoTypeGetSparkResponse: //获取首页sparks返回   for demo
        {
            NSError *error;
            Sparks *datas = [[Sparks alloc]initWithData:package error:&error];
            if(error == nil && datas != nil) {
                [self sendMessageResponse:datas.sign resultCode:ERR_SUCC resultMsg:@"" response:datas];
            }else {
                MSLog(@"消息protobuf解析失败-- %@",error);
            }
            MSLog(@"[收到]首页Sparks数据***");
        }
            break;
        default:
            break;
    }
}

- (void)messageRsultHandler:(Result *)result
{
    if (result.code == ERR_LOGIN_KICKED_OFF_BY_OTHER) {
        if (self.connListener && [self.connListener respondsToSelector:@selector(onForceOffline)]) {
            [self.connListener onForceOffline];
        }
        //清空本地的token
        [self cleanIMToken];
    }
    
    NSString *taskID = [self taskIDForMsgSeq:result.sign];
    if (taskID == nil) return;
    NSDictionary *dic = [self.callbackBlock objectForKey:taskID];
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
    NSString *taskID = [self taskIDForMsgSeq:sign];
    if (taskID) {
        NSDictionary *dic = [self.callbackBlock objectForKey:taskID];
        TCPBlock complete = dic[@"callback"];
        if(complete) {
            [self.callbackBlock removeObjectForKey:taskID];
            [self.taskIDs removeObjectForKey:taskID];
            complete(code,response,msg);
        }
    }
}

- (NSString *)taskIDForMsgSeq:(NSInteger)sign
{
    NSString *msg_seq = [NSString stringWithFormat:@"%ld",sign];
    __block NSString *taskID = nil;
    [self.taskIDs enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL * _Nonnull stop) {
            if ([msg_seq isEqualToString:value]) {
                taskID = key;
                *stop = YES;
            }
    }];
    return taskID;
}

- (void)send:(NSData *)sendData protoType:(XMChatProtoType)protoType needToEncry:(BOOL)encry sign:(int64_t)sign callback:(TCPBlock)block
{
    // 包头是 4个字节 包括：前20位代表整个数据包的长度，后11位代表proto的编码 ，最后一位表示报文是否压缩
    NSInteger type = protoType;
    type = type << 2;
    NSInteger isZip = 0;
    if((sendData.length + 4)/1024 > 10) {//如果发送的文本大于10kb,进行zlib压缩
        isZip = 1;
        sendData = [NSData dataByCompressingData:sendData];
    }
    encry = encry << 1;
    NSInteger originalLength = ((NSInteger)sendData.length + 4) << 12;
    NSInteger allLength = originalLength + type + encry + isZip;
    
    HTONL(allLength);
    NSMutableData *data = [NSMutableData dataWithBytes:&allLength length:4];//生成包头
    [data appendData:sendData];
    
    if(block) {
        // 保存回调 block 到字典里，接收时候用到
        [_dictionaryLock lock];
        //重新生成一个taskID,映射到msg_seq
        NSString *taskID = [NSString stringWithFormat:@"%zd",[MSIMTools sharedInstance].adjustLocalTimeInterval];
        [self.taskIDs setValue:[NSString stringWithFormat:@"%lld",sign] forKey:taskID];
        [_callbackBlock setObject:@{@"callback": block,@"protoType": @(protoType),@"data":sendData,@"encry":@(encry)} forKey:taskID];
        [_dictionaryLock unlock];
    }
    [self.socket writeData:data withTimeout:-1 tag:100];
}

- (void)callbackHandler:(NSTimer *)timer
{
    NSArray *allKeys = self.callbackBlock.allKeys;
    for (NSString *key in allKeys) {
        NSInteger sendTime = key.integerValue;
        if (([MSIMTools sharedInstance].adjustLocalTimeInterval - sendTime) > kMsgMaxOutTime*1000*1000) {//判断超时，回调失败
            NSDictionary *dic = self.callbackBlock[key];
            NSString *msg_seq = [self.taskIDs valueForKey:key];
            TCPBlock complete = dic[@"callback"];
            if (complete) {
                complete(msg_seq.integerValue,nil,@"发送超时");
            }
            [self.callbackBlock removeObjectForKey:key];
            [self.taskIDs removeObjectForKey:key];
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
    Ping *ping = [[Ping alloc]init];
    ping.type = 0;
    MSLog(@"[发送消息-心跳包]:\n%@",ping);
    [self send:[ping data] protoType:XMChatProtoTypeHeadBeat needToEncry:NO sign:0 callback:nil];
}

/** 鉴权*/
- (void)imLogin:(NSString *)user_sign
{
    WS(weakSelf)
    ImLogin *login = [[ImLogin alloc]init];
    login.token = user_sign;
    login.sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
    login.ct = 1;
    MSLog(@"[发送消息-login]:\n%@",login);
    [self send:[login data] protoType:XMChatProtoTypeLogin needToEncry:false sign:login.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        STRONG_SELF(strongSelf)
        if (code == ERR_SUCC) {
            Result *result = response;
            [MSIMTools sharedInstance].user_id = [NSString stringWithFormat:@"%lld",result.uid];
            [MSIMTools sharedInstance].user_sign = user_sign;
            [[MSIMTools sharedInstance] updateServerTime:result.nowTime*1000*1000];
            //将消息队列中的消息重新发送一遍
            [strongSelf resendAllMessages];
            
            if (strongSelf.loginSuccBlock) strongSelf.loginSuccBlock();
            strongSelf.loginSuccBlock = nil;
            //同步会话列表
            [strongSelf.convCaches removeAllObjects];
            [strongSelf synchronizeConversationList];
        }else {
            if (code == ERR_USER_SIG_EXPIRED) {
                if (strongSelf.connListener && [strongSelf.connListener respondsToSelector:@selector(onUserSigExpired)]) {
                    [strongSelf.connListener onUserSigExpired];
                }
            }
            MSLog(@"token 鉴权失败*******code = %ld,response = %@,errorMsg = %@",code,response,error);
            if (strongSelf.loginFailBlock) strongSelf.loginFailBlock(code, error);
            strongSelf.loginFailBlock = nil;
        }
    }];
}

///反初始化 SDK
- (void) unInitSDK
{
    
}

///登录需要设置用户名 userID 和用户签名 token
- (void)login:(NSString *)userSign
         succ:(MSIMSucc)succ
       failed:(MSIMFail)fail
{
    if (userSign == nil) {
        fail(ERR_USER_PARAMS_ERROR, @"token为空");
        return;
    }
    self.loginSuccBlock = succ;
    self.loginFailBlock = fail;
    if (self.socket.isConnected) {
        [self imLogin:userSign];//鉴权
    }else {
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
    MSLog(@"[发送消息-logout]:\n%@",logout);
    [self send:[logout data] protoType:XMChatProtoTypeLogout needToEncry:NO sign:logout.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        STRONG_SELF(strongSelf)
        if (code == ERR_SUCC) {
//            Result *result = response;
            [strongSelf cleanIMToken];
            succ();
        }else {
            MSLog(@"退出登录失败*******code = %ld,response = %@,errorMsg = %@",code,response,error);
            fail(code, error);
        }
    }];
}

//断线重连成功后，将所有消息队列中的消息重新发送一遍
- (void)resendAllMessages
{
    NSDictionary *tempDic = self.callbackBlock.mutableCopy;
    NSDictionary *tempTasks = self.taskIDs.mutableCopy;
    NSArray *allKeys = [tempDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return obj1.integerValue > obj2.integerValue;
    }];
    [self.callbackBlock removeAllObjects];
    [self.taskIDs removeAllObjects];
    for (NSInteger i = 0; i < allKeys.count; i++) {
        NSString *taskID = allKeys[i];
        NSDictionary *dic = tempDic[taskID];
        [self send:dic[@"data"] protoType:[dic[@"protoType"] integerValue] needToEncry:[dic[@"encry"] boolValue] sign:[tempTasks[taskID] integerValue] callback:dic[@"callback"]];
        MSLog(@"重发sign = %zd",[tempTasks[taskID] integerValue]);
    }
}

- (void)cleanIMToken
{
    [MSIMTools sharedInstance].user_id = nil;
    [MSIMTools sharedInstance].user_sign = nil;
    [[MSDBManager sharedInstance] accountChanged];
}

@end
