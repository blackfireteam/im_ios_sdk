//
//  MSIMManager.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/25.
//

#import "MSIMManager.h"
#import "MSIMConst.h"
#import "MSIMTools.h"
#import "MSIMErrorCode.h"
#import "MSDBManager.h"
#import "MSIMManager+Conversation.h"
#import "MSProfileProvider.h"
#import "MSIMManager+Parse.h"


@interface MSIMManager()<MSTCPSocketDelegate>

@property(nonatomic,strong) MSTCPSocket *socket;

@property(nonatomic,copy) MSIMSucc loginSuccBlock;
@property(nonatomic,copy) MSIMFail loginFailBlock;

@property(nonatomic,strong) dispatch_queue_t commonQueue;

@property(nonatomic,assign) NSInteger lastRecieveMsgTime;

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
    }
    return self;
}

- (MSTCPSocket *)socket
{
    if (!_socket) {
        _socket = [[MSTCPSocket alloc]init];
        _socket.delegate = self;
    }
    return _socket;
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

- (NSMutableArray *)messageCaches
{
    if (!_messageCaches) {
        _messageCaches = [NSMutableArray array];
    }
    return _messageCaches;
}

- (MSIMNetStatus)connStatus
{
    return self.socket.connStatus;
}

- (dispatch_queue_t)commonQueue
{
    if (!_commonQueue) {
        _commonQueue = dispatch_queue_create("mQueue", NULL);
    }
    return _commonQueue;
}

- (void)initSDK:(IMSDKConfig *)config listener:(id<MSIMSDKListener>)listener
{
    self.socket.config = config;
    _connListener = listener;
}

#pragma mark - MSTCPSocketDelegate
- (void)connectSucc
{
    if ([self.connListener respondsToSelector:@selector(connectSucc)]) {
        [self.connListener connectSucc];
    }
}

- (void)connectFailed:(NSInteger)code err:(NSString *)errString
{
    if ([self.connListener respondsToSelector:@selector(connectFailed:err:)]) {
        [self.connListener connectFailed:code err:errString];
    }
}

- (void)onConnecting
{
    if ([self.connListener respondsToSelector:@selector(onConnecting)]) {
        [self.connListener onConnecting];
    }
}

- (void)onForceOffline
{
    if ([self.connListener respondsToSelector:@selector(onForceOffline)]) {
        [self.connListener onForceOffline];
    }
}

- (void)onUserSigExpired
{
    if ([self.connListener respondsToSelector:@selector(onUserSigExpired)]) {
        [self.connListener onUserSigExpired];
    }
}

- (void)onIMLoginSucc
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.loginSuccBlock) self.loginSuccBlock();
        self.loginSuccBlock = nil;
    });
    //同步会话列表
    [self.convCaches removeAllObjects];
    [self synchronizeConversationList];
}

- (void)onIMLoginFail:(NSInteger)code msg:(NSString *)err
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.loginFailBlock) self.loginFailBlock(code, err);
        self.loginFailBlock = nil;
    });
}

- (void)globTimerCallback
{
    dispatch_async(self.commonQueue, ^{
        @synchronized (self) {
            [self receiveMessageHandler:self.messageCaches.copy];
            [self.messageCaches removeAllObjects];
        }
    });
}

- (void)onRevieveData:(NSData *)package protoType:(XMChatProtoType)type
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
                [self.socket sendMessageResponse:result.sign resultCode:ERR_SUCC resultMsg:@"单条消息已发送到服务器" response:result];
                //更新会话更新时间
                [self updateChatListUpdateTime:result.msgTime];
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
                NSInteger currentTime = [MSIMTools sharedInstance].adjustLocalTimeInterval;
                @synchronized (self) {
                    if (self.messageCaches.count == 0 && (currentTime - self.lastRecieveMsgTime > 0.05*1000*1000)) {
                        [self receiveMessageHandler:@[recieve]];
                    }else {
                        [self.messageCaches addObject:recieve];
                    }
                    self.lastRecieveMsgTime = currentTime;
                }
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
                [self.socket sendMessageResponse:batch.sign resultCode:ERR_SUCC resultMsg:@"收到历史消息" response:batch];
            }else {
                MSLog(@"消息protobuf解析失败-- %@",error);
            }
            MSLog(@"[收到]历史消息:%@",batch);
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
                [self.socket sendMessageResponse:profile.sign resultCode:ERR_SUCC resultMsg:@"" response:profile];
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
        case XMChatProtoTypeChatListChanged: //会话某些属性发生变更
        {
            NSError *error;
            ChatItemUpdate *item = [[ChatItemUpdate alloc]initWithData:package error:&error];
            if (error == nil && item != nil) {
                [self chatListChanged:item];
            }else {
                MSLog(@"消息protobuf解析失败-- %@",error);
            }
        }
            break;
        case XMChatProtoTypeGetSparkResponse: //获取首页sparks返回   for demo
        {
            NSError *error;
            Sparks *datas = [[Sparks alloc]initWithData:package error:&error];
            if(error == nil && datas != nil) {
                [self.socket sendMessageResponse:datas.sign resultCode:ERR_SUCC resultMsg:@"" response:datas];
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
    if (result.code == ERR_USER_SIG_EXPIRED || result.code == ERR_IM_TOKEN_NOT_FIND) {
        
        if (self.connListener && [self.connListener respondsToSelector:@selector(onUserSigExpired)]) {
            [self.connListener onUserSigExpired];
        }
        //清空本地的token
        [self cleanIMToken];
        
    }else if (result.code == ERR_LOGIN_KICKED_OFF_BY_OTHER) {
        if (self.connListener && [self.connListener respondsToSelector:@selector(onForceOffline)]) {
            [self.connListener onForceOffline];
        }
        //清空本地的token
        [self cleanIMToken];
    }
    [self.socket sendMessageResponse:result.sign resultCode:result.code resultMsg:result.msg response:result];
}

///反初始化 SDK
- (void) unInitSDK
{
    
}

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
    if (self.socket.userStatus == IMUSER_STATUS_LOGIN) {
        return;
    }
    if (self.socket.connStatus == IMNET_STATUS_SUCC) {
        [self.socket imLogin:userSign];
    }else {
        [self.socket connectTCPToServer];
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
    [self.socket send:[logout data] protoType:XMChatProtoTypeLogout needToEncry:NO sign:logout.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        STRONG_SELF(strongSelf)
        dispatch_async(dispatch_get_main_queue(), ^{
            if (code == ERR_SUCC) {
                [strongSelf cleanIMToken];
                succ();
            }else {
                MSLog(@"退出登录失败*******code = %ld,response = %@,errorMsg = %@",code,response,error);
                fail(code, error);
            }
        });
    }];
}

///更新同步会话时间
- (void)updateChatListUpdateTime:(NSInteger)updateTime
{
    if (self.isChatListResult == NO) {
        self.chatUpdateTime = updateTime;
    }else {
        [[MSIMTools sharedInstance]updateConversationTime:updateTime];
        self.chatUpdateTime = 0;
    }
}

- (void)cleanIMToken
{
    self.chatUpdateTime = 0;
    [self.socket disConnectTCP];
    [self.socket cleanCache];
    [MSIMTools sharedInstance].user_id = nil;
    [MSIMTools sharedInstance].user_sign = nil;
    [[MSIMTools sharedInstance]cleanConvUpdateTime];
    [[MSDBManager sharedInstance] accountChanged];
}

@end
