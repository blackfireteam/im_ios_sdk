//
//  messageController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import "MSMessageController.h"
#import "MSIMSDK-UIKit.h"
#import <MSIMSDK/MSIMSDK.h>
#import <MJRefresh.h>
#import "MSLocationManager.h"
#import "MSSnapChatTimerManager.h"

#define MAX_MESSAGE_SEP_DLAY (5 * 60)
@interface MSMessageController ()<MSMessageCellDelegate,MSNoticeCountViewDelegate>

@property (nonatomic, strong) NSMutableArray<MSMessageCellData *> *uiMsgs;
@property (nonatomic, strong) NSMutableArray *heightCache;

@property (nonatomic, assign) BOOL isScrollBottom;
@property(nonatomic,assign) BOOL isShowKeyboard;
@property (nonatomic, assign) BOOL firstLoad;
@property (nonatomic, assign) BOOL isLoadingMsg;
@property (nonatomic, assign) BOOL noMoreMsg;

@property(nonatomic,strong) MSMessageCellData *menuUIMsg;

@property(nonatomic,assign) NSInteger last_msg_sign;

@property(nonatomic,strong) MSNoticeCountView *countTipView;

@end

@implementation MSMessageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self loadMessages];
}

- (void)dealloc
{
    MSLog(@"%@ dealloc",self.class);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)setupUI
{
    WS(weakSelf)
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_MessageListener object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
       [weakSelf onNewMessage:note];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_SignalMessageListener object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
       [weakSelf onSignalMessage:note];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_MessageUpdate object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf messageUpdate:note];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_MessageReceipt object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf recieveMessageReceipt:note];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_MessageRecieveDelete object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf recieveMessageDelete:note];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:SNAPCHAT_COUNTDOWN_CHANGED object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf snapchatCountDownChanged:note];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapViewController)];
    [self.view addGestureRecognizer:tap];
    
    self.tableView.scrollsToTop = NO;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.contentInset = UIEdgeInsetsMake(StatusBar_Height + NavBar_Height, 0, 0, 0);
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[MSTextMessageCell class] forCellReuseIdentifier:TTextMessageCell_ReuseId];
    [self.tableView registerClass:[MSImageMessageCell class] forCellReuseIdentifier:TImageMessageCell_ReuseId];
    [self.tableView registerClass:[MSSystemMessageCell class] forCellReuseIdentifier:TSystemMessageCell_ReuseId];
    [self.tableView registerClass:[MSVideoMessageCell class] forCellReuseIdentifier:TVideoMessageCell_ReuseId];
    [self.tableView registerClass:[MSVoiceMessageCell class] forCellReuseIdentifier:TVoiceMessageCell_ReuseId];
    [self.tableView registerClass:[MSLocationMessageCell class] forCellReuseIdentifier:TLocationMessageCell_ReuseId];
    [self.tableView registerClass:[MSEmotionMessageCell class] forCellReuseIdentifier:TEmotionMessageCell_ReuseId];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadMessages];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
    
    _countTipView = [[MSNoticeCountView alloc]init];
    [_countTipView setHidden:YES];
    _countTipView.delegate = self;
    
    _heightCache = [NSMutableArray array];
    _uiMsgs = [[NSMutableArray alloc] init];
    _firstLoad = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (self.countTipView.superview == nil) {
        [self.parentViewController.view addSubview:self.countTipView];
    }
    self.countTipView.frame = CGRectMake(self.tableView.width-30-10, self.tableView.height-30-10, 30, 30);
}

- (void)readedReport:(NSArray<MSMessageCellData *> *)datas
{
    [[MSIMManager sharedInstance] markC2CMessageAsRead:self.partner_id succ:^{
            
        } failed:^(NSInteger code, NSString * _Nonnull desc) {

    }];
}

///重发消息
- (void)resendMessage:(MSMessageCellData *)data
{
    [[MSIMManager sharedInstance] resendC2CMessage:data.message toReciever:data.message.toUid successed:^(NSInteger msg_id) {
        data.message.msgID = msg_id;
    } failed:^(NSInteger code, NSString * _Nonnull desc) {
        [MSHelper showToastFail:desc];
    }];
}

- (void)loadMessages
{
    if(_isLoadingMsg || _noMoreMsg || self.partner_id.length == 0){
        return;
    }
    _isLoadingMsg = YES;

    WS(weakSelf)
    [[MSIMManager sharedInstance] getC2CHistoryMessageList:self.partner_id count:20 lastMsg:self.last_msg_sign succ:^(NSArray<MSIMMessage *> * _Nonnull msgs, BOOL isFinished) {
        
        STRONG_SELF(strongSelf)
        NSArray<MSIMMessage *> *tempMessages = [strongSelf deduplicateMessage:msgs];
        [strongSelf.tableView.mj_header endRefreshing];
        if (msgs.count) {
            strongSelf.last_msg_sign = msgs.lastObject.msgSign;
        }
        if (isFinished) {
            strongSelf.noMoreMsg = YES;
            strongSelf.tableView.mj_header.hidden = YES;
        }
        NSArray *tempUimsgs = [strongSelf transUIMsgFromIMMsg:tempMessages];
        NSArray *uiMsgs = [strongSelf calculateMessageInterval:tempUimsgs];
        if (uiMsgs.count != 0) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, uiMsgs.count)];
            [strongSelf.uiMsgs insertObjects:uiMsgs atIndexes:indexSet];
            [strongSelf.heightCache removeAllObjects];
            [strongSelf.tableView reloadData];
            [strongSelf.tableView layoutIfNeeded];
            if(!strongSelf.firstLoad) {
                CGFloat visibleHeight = 0;
                for (NSInteger i = 0; i < uiMsgs.count; ++i) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    visibleHeight += [strongSelf tableView:strongSelf.tableView heightForRowAtIndexPath:indexPath];
                }
                [strongSelf.tableView scrollRectToVisible:CGRectMake(0, strongSelf.tableView.contentOffset.y + visibleHeight, strongSelf.tableView.frame.size.width, strongSelf.tableView.frame.size.height) animated:NO];
            }else {
                MSIMConversation *conv = [[MSConversationProvider provider]providerConversation:self.partner_id];
                if (conv.unread_count > 0) {
                    [strongSelf readedReport:uiMsgs];
                }
            }
        }
        strongSelf.isLoadingMsg = NO;
        strongSelf.firstLoad = NO;
            } fail:^(NSInteger code, NSString * _Nonnull desc) {
                
                STRONG_SELF(strongSelf)
                strongSelf.isLoadingMsg = NO;
                strongSelf.firstLoad = NO;
                [strongSelf.tableView.mj_header endRefreshing];
                
    }];
}

- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray<MSIMMessage *> *)messages
{
    NSMutableArray *uiMsgs = [NSMutableArray array];
    for (NSInteger k = messages.count - 1; k >= 0; --k) {
        MSIMMessage *message = messages[k];
        MSMessageCellData *data;
        if ([self.delegate respondsToSelector:@selector(messageController:prepareForMessage:)]) {
            MSMessageCellData *cellData = [self.delegate messageController:self prepareForMessage:message];
            if (cellData != nil) {
                [uiMsgs addObject:cellData];
                continue;
            }
        }
        BOOL showName = YES;
        if (message.type == MSIM_MSG_TYPE_REVOKE) {// 撤回的消息
            MSSystemMessageCellData *revoke = [[MSSystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
            if (message.isSelf) {
                revoke.content = TUILocalizableString(TUIKitMessageTipsYouRecallMessage);
            }else {
                revoke.content = TUILocalizableString(TUIkitMessageTipsOthersRecallMessage);
            }
            revoke.type = SYS_REVOKE;
            showName = NO;
            data = revoke;
        }else if (message.type == MSIM_MSG_TYPE_TEXT) {
            MSTextMessageCellData *textMsg = [[MSTextMessageCellData alloc]initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
            textMsg.content = message.textElem.text;
            data = textMsg;
        }else if (message.type == MSIM_MSG_TYPE_IMAGE) {
            MSImageMessageCellData *imageMsg = [[MSImageMessageCellData alloc]initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
            data = imageMsg;
        }else if (message.type == MSIM_MSG_TYPE_VIDEO) {
            MSVideoMessageCellData *videoMsg = [[MSVideoMessageCellData alloc]initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
            data = videoMsg;
        }else if (message.type == MSIM_MSG_TYPE_VOICE) {
            MSVoiceMessageCellData *voiceMsg = [[MSVoiceMessageCellData alloc]initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
            data = voiceMsg;
        }else if (message.type == MSIM_MSG_TYPE_LOCATION) {
            MSLocationMessageCellData *locationMsg = [[MSLocationMessageCellData alloc]initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
            data = locationMsg;
        }else if (message.type == MSIM_MSG_TYPE_EMOTION) {
            MSEmotionMessageCellData *emotionMSG = [[MSEmotionMessageCellData alloc]initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
            data = emotionMSG;
        }else {
            MSSystemMessageCellData *unknowData = [[MSSystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
            unknowData.content = TUILocalizableString(TUIkitMessageTipsUnknowMessage);
            showName = NO;
            unknowData.type = SYS_UNKNOWN;
            data = unknowData;
        }
        data.showName = showName;
        data.message = message;
        [uiMsgs addObject:data];
    }
    return uiMsgs;
}

/// 在消息之前插入合适的时间
- (NSArray<MSMessageCellData *> *)calculateMessageInterval:(NSArray<MSMessageCellData *> *)msgDatas
{
    if (msgDatas.count == 0) return @[];
    NSMutableArray *arr = [NSMutableArray array];
    NSInteger msgTime = 0;
    for (NSInteger i = 0; i < msgDatas.count; i++) {
        MSMessageCellData *data = msgDatas[i];
        MSSystemMessageCellData *timeData = [self transSystemMsgFromDate:data.message.msgSign toDate:msgTime];
        if (timeData) {
            [arr addObject:timeData];
        }
        [arr addObject:data];
        msgTime = data.message.msgSign;
    }
    return arr;
}

- (MSSystemMessageCellData *)transSystemMsgFromDate:(NSInteger)fromDate toDate:(NSInteger)toDate
{
    if(labs(fromDate - toDate)/1000/1000 > MAX_MESSAGE_SEP_DLAY){
        MSSystemMessageCellData *system = [[MSSystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        system.content = [[NSDate dateWithTimeIntervalSince1970:fromDate/1000/1000] ms_messageString];
        system.type = SYS_TIME;
        return system;
    }
    return nil;
}

//消息去重
- (NSArray<MSIMMessage *> *)deduplicateMessage:(NSArray *)messages
{
    NSMutableArray<MSIMMessage *> *tempArr = [NSMutableArray array];
    for (MSIMMessage *message in messages) {
        if (![message.partnerID isEqualToString:self.partner_id]) return nil;
        BOOL isExsit = NO;
        for (MSMessageCellData *data in self.uiMsgs) {
            if (message.msgSign == data.message.msgSign) {
                isExsit = YES;
                data.message = message;
                [self.tableView reloadData];
                break;
            }
        }
        if (isExsit == NO) {
            [tempArr addObject:message];
        }
    }
    return tempArr;
}

///收到新消息
- (void)onNewMessage:(NSNotification *)note
{
    NSArray *messages = note.object;
    //消息去重
    NSArray *tempMessages = [self deduplicateMessage:messages];
    NSArray *uiMsgs = [self transUIMsgFromIMMsg:tempMessages];

    if (uiMsgs.count) {
        //当前列表是否停留在底部
        BOOL isAtBottom = (self.tableView.contentOffset.y + self.tableView.height + 20 >= self.tableView.contentSize.height);
        for (MSMessageCellData *data in uiMsgs) {
            MSSystemMessageCellData *timeData = [self transSystemMsgFromDate:data.message.msgSign toDate:self.uiMsgs.lastObject.message.msgSign];
            if (timeData) {
                [self.heightCache addObject:@(0)];
                [self.uiMsgs addObject:timeData];
            }
            [self.heightCache addObject:@(0)];
            [self.uiMsgs addObject:data];
        }
        [self.tableView reloadData];
        //当列表没有停留在底部时，不自动滚动显示出新消息。会在底部显示未读数，点击滚动到底部。
        //适当增加些容错
        if (isAtBottom || self.isShowKeyboard) {
            [self scrollToBottom:YES];
            [self readedReport: uiMsgs];//标记已读
        }else {
            [self.countTipView increaseCount: tempMessages.count];
        }
    }
}

/// 收到消息被删除
- (void)recieveMessageDelete:(NSNotification *)note
{
    NSArray *arr = note.object;
    [self removeMessageWithMessageIDs:arr];
}

/// 通过msg_id删除某条消息
- (void)removeMessageWithMessageIDs:(NSArray *)msg_ids
{
    NSMutableArray *deleteArr = [NSMutableArray array];
    for (NSNumber *msgIDNum in msg_ids) {
        NSInteger msg_id = msgIDNum.integerValue;
        
        MSMessageCellData *delData;
        NSInteger delIndex = 0;
  
        for (NSInteger j = 0; j < self.uiMsgs.count; j++) {
            MSMessageCellData *data = self.uiMsgs[j];
            if (data.message.msgID == msg_id) {
                delData = data;
                delIndex = j;
                break;
            }
        }
        
        if (delData) {
            MSMessageCellData *preData = delIndex >= 1 ? self.uiMsgs[delIndex-1] : nil;
            MSMessageCellData *nextData = delIndex < self.uiMsgs.count-1 ? self.uiMsgs[delIndex+1] : nil;
            
            [self.uiMsgs removeObject:delData];
            [self.heightCache removeObjectAtIndex:delIndex];
            [deleteArr addObject:[NSIndexPath indexPathForRow:delIndex inSection:0]];
            if (([preData isKindOfClass:[MSSystemMessageCellData class]] && ((MSSystemMessageCellData *)preData).type == SYS_TIME  && [nextData isKindOfClass:[MSSystemMessageCellData class]] && ((MSSystemMessageCellData *)nextData).type == SYS_TIME) ||([preData isKindOfClass:[MSSystemMessageCellData class]] && ((MSSystemMessageCellData *)preData).type == SYS_TIME && nextData == nil)) {
                [self.uiMsgs removeObject:preData];
                [self.heightCache removeObjectAtIndex:delIndex-1];
                [deleteArr addObject:[NSIndexPath indexPathForRow:delIndex-1 inSection:0]];
            }
        }
    }
    if (deleteArr.count) {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:deleteArr withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

///  阅后即焚消息倒记时变化
- (void)snapchatCountDownChanged:(NSNotification *)note
{
    NSDictionary *dic = note.object;
    NSInteger msg_id = [dic[@"msg_id"]integerValue];
    NSInteger count = [dic[@"count"]integerValue];

    for (NSInteger i = self.uiMsgs.count - 1; i >= 0; i--) {
        MSMessageCellData *data = self.uiMsgs[i];
        if (data.message.msgID == msg_id) {
            data.snapCount = count;
            MSMessageCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell fillWithData:data];
            //倒记时结束时，将列表中的对应消息删除
            if (count <= 0) {
                [self removeMessageWithMessageIDs:@[@(msg_id)]];
            }
            break;
        }
    }
}

///消息状态发生变化通知
- (void)messageUpdate:(NSNotification *)note
{
    MSIMMessage *message = note.object;
    if (![message.partnerID isEqualToString:self.partner_id]) return;
    if (message.type == MSIM_MSG_TYPE_REVOKE) {//撤回消息导致cell高度发生变化，需要更新缓存的高度
        for (NSInteger i = 0; i < self.uiMsgs.count; i++) {
            MSMessageCellData *data = self.uiMsgs[i];
            if (data.message.msgID == message.msgID) {
                [self.uiMsgs removeObject:data];
                [self.heightCache removeObjectAtIndex:i];
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                MSSystemMessageCellData *data = [[MSSystemMessageCellData alloc]initWithDirection:MsgDirectionIncoming];
                if (message.isSelf) {
                    data.content = TUILocalizableString(TUIKitMessageTipsYouRecallMessage);
                }else {
                    data.content = TUILocalizableString(TUIkitMessageTipsOthersRecallMessage);
                }
                data.type = SYS_REVOKE;
                [self.heightCache insertObject:@(0) atIndex:i];
                [self.uiMsgs insertObject:data atIndex:i];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                break;
            }
        }
        
        return;
    }
    for (NSInteger i = 0; i < self.uiMsgs.count; i++) {
        MSMessageCellData *data = self.uiMsgs[i];
        if (data.message.msgSign == message.msgSign) {
            data.message = message;
            MSMessageCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell fillWithData:data];
        }
    }
}

- (void)onSignalMessage:(NSNotification *)note
{
    NSArray *messages = note.object;
    if ([self.delegate respondsToSelector:@selector(messageController:onRecieveSignalMessage:)]) {
        [self.delegate messageController:self onRecieveSignalMessage:messages];
    }
}

///收到对方发出的消息已读回执
- (void)recieveMessageReceipt:(NSNotification *)note
{
    MSIMMessageReceipt *receipt = note.object;
    if (![receipt.user_id isEqualToString:self.partner_id]) return;
    for (MSMessageCellData *data in self.uiMsgs) {
        if (data.message.msgID <= receipt.msg_id) {
            data.message.readStatus = MSIM_MSG_STATUS_READ;
        }else {
            data.message.readStatus = MSIM_MSG_STATUS_UNREAD;
        }
    }
    [self.tableView reloadData];
}

- (void)keyboardWillShow
{
    self.isShowKeyboard = YES;
}

- (void)keyboardWillHidden
{
    self.isShowKeyboard = NO;
}

- (void)scrollToBottom:(BOOL)animate
{
    if (_uiMsgs.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_uiMsgs.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animate];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _uiMsgs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_heightCache.count > indexPath.row){
        CGFloat height = [_heightCache[indexPath.row] floatValue];
        if (height > 0) {
            return height;
        }
        MSMessageCellData *data = self.uiMsgs[indexPath.row];
        height = [data heightOfWidth:Screen_Width];
        [_heightCache replaceObjectAtIndex:indexPath.row withObject:@(height)];
        return height;
    }else {
        MSMessageCellData *data = self.uiMsgs[indexPath.row];
        CGFloat height = [data heightOfWidth:Screen_Width];
        [_heightCache insertObject:@(height) atIndex:indexPath.row];
        return height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSMessageCellData *data = _uiMsgs[indexPath.row];
    MSMessageCell *cell;
    if ([self.delegate respondsToSelector:@selector(messageController:onShowMessageData:)]) {
        Class class = [self.delegate messageController:self onShowMessageData:data];
        if (class != nil) {
            [self.tableView registerClass:class forCellReuseIdentifier:data.reuseId];
            cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
            cell.delegate = self;
            [cell fillWithData:data];
            return cell;
        }
    }
    cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
    cell.delegate = self;
    [cell fillWithData:data];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)didTapViewController
{
    if(_delegate && [_delegate respondsToSelector:@selector(didTapInMessageController:)]){
        [_delegate didTapInMessageController:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY + scrollView.height + 20 >= scrollView.contentSize.height) {
        if (self.countTipView.isHidden == NO) {
            [self.countTipView cleanCount];
            [self readedReport:self.uiMsgs];//标记已读
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(_delegate && [_delegate respondsToSelector:@selector(didTapInMessageController:)]){
        [_delegate didTapInMessageController:self];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isScrollBottom == NO) {
        [self scrollToBottom:NO];
        if (indexPath.row == _uiMsgs.count-1) {
            _isScrollBottom = YES;
        }
    }
    //当滚动到第二个时，自动触发加载下一页
    if (self.noMoreMsg == NO && indexPath.row == 0) {
        [self loadMessages];
    }
}


#pragma mark - @protocol MSMessageCellDelegate <NSObject>

- (void)onLongPressMessage:(MSMessageCell *)cell
{
    MSMessageCellData *data = cell.messageData;
    if ([data isKindOfClass:[MSSystemMessageCellData class]]) {
        return;// 系统消息不响应
    }
    BOOL isFirstResponder = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageController:willShowMenuInCell:)]) {
        isFirstResponder = [self.delegate messageController:self willShowMenuInCell:cell];
    }
    if(isFirstResponder){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
    }else{
        [self becomeFirstResponder];
    }
    
    NSMutableArray *items = [NSMutableArray array];
    if ([data isKindOfClass:[MSTextMessageCellData class]] && data.message.isSnapChat == false) {
        [items addObject:[[UIMenuItem alloc]initWithTitle:TUILocalizableString(Copy) action:@selector(onCopyMsg:)]];
    }
    if (data.message.isSelf && data.message.sendStatus == MSIM_MSG_STATUS_SEND_SUCC && data.message.type != MSIM_MSG_TYPE_CUSTOM_UNREADCOUNT_NO_RECALL) {
        [items addObject:[[UIMenuItem alloc]initWithTitle:TUILocalizableString(Revoke) action:@selector(onRevoke:)]];
    }
    [items addObject:[[UIMenuItem alloc]initWithTitle:TUILocalizableString(Delete) action:@selector(onDelete:)]];
    UIMenuController *vc = [UIMenuController sharedMenuController];
    vc.menuItems = items;
    self.menuUIMsg = data;
    [vc setTargetRect:cell.container.bounds inView:cell.container];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [vc setMenuVisible:YES animated:YES];
    });
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(onRevoke:) ||
        action == @selector(onCopyMsg:) ||
        action == @selector(onDelete:)) {
        return YES;
    }
    return NO;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

/** 消息失败重发*/
- (void)onRetryMessage:(MSMessageCell *)cell
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TUILocalizableString(TUIKitTipsConfirmResendMessage) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TUILocalizableString(Re-send) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self resendMessage:cell.messageData];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:TUILocalizableString(Cancel) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }]];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)onSelectMessage:(MSMessageCell *)cell
{
    if ([cell isKindOfClass:[MSVoiceMessageCell class]]) {//点击音频
        MSVoiceMessageCell *voiceCell = (MSVoiceMessageCell *)cell;
        for (NSInteger index = 0; index < self.uiMsgs.count; ++index) {
            if(![self.uiMsgs[index] isKindOfClass:[MSVoiceMessageCellData class]]){
                continue;
            }
            MSVoiceMessageCellData *uiMsg = (MSVoiceMessageCellData *)_uiMsgs[index];
            if(uiMsg == voiceCell.voiceData){
                if (uiMsg.isPlaying) {
                    [uiMsg stopVoiceMessage];
                }else {
                    [uiMsg playVoiceMessage];
                }
            }else{
                [uiMsg stopVoiceMessage];
            }
        }
    }
    if (cell.messageData.message.type == MSIM_MSG_TYPE_LOCATION) {
        MSLocationMessageCellData *locationData = (MSLocationMessageCellData *)cell.messageData;
        //将gps坐标转换成高德坐标
        CLLocationCoordinate2D n_coor = [[MSLocationManager shareInstance]gPSCoordinateConvertToAMap:CLLocationCoordinate2DMake(locationData.message.locationElem.latitude, locationData.message.locationElem.longitude)];
        MSLocationDetailController *vc = [[MSLocationDetailController alloc]init];
        MSLocationInfo *info = [[MSLocationInfo alloc]init];
        info.name = locationData.message.locationElem.title;
        info.detail = locationData.message.locationElem.detail;
        info.latitude = n_coor.latitude;
        info.longitude = n_coor.longitude;
        info.zoom = locationData.message.locationElem.zoom;
        vc.locationInfo = info;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageContent:)]) {
        [self.delegate messageController:self onSelectMessageContent:cell];
    }
}

- (void)onSelectMessageAvatar:(MSMessageCell *)cell
{
    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageAvatar:)]) {
        [self.delegate messageController:self onSelectMessageAvatar:cell];
    }
}

- (void)menuDidHide:(NSNotification*)notification
{
    if(_delegate && [_delegate respondsToSelector:@selector(didHideMenuInMessageController:)]){
        [_delegate didHideMenuInMessageController:self];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
}

- (void)onCopyMsg:(id)sender
{
    if ([_menuUIMsg isKindOfClass:[MSTextMessageCellData class]]) {
        MSTextMessageCellData *txtMsg = (MSTextMessageCellData *)_menuUIMsg;
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = txtMsg.content;
    }
}

- (void)onRevoke:(id)sender
{
    [[MSIMManager sharedInstance] revokeMessage:self.menuUIMsg.message.msgID toReciever:self.partner_id successed:^{
        
        NSLog(@"撤回成功");
        
        } failed:^(NSInteger code, NSString * _Nonnull desc) {
            
    }];
}

- (void)onDelete:(id)sender
{
    [[MSIMManager sharedInstance]deleteMessageFromLocal:self.menuUIMsg.message];
    NSInteger msg_sign = self.menuUIMsg.message.msgSign;
    MSMessageCellData *delData;
    NSInteger delIndex = 0;
    NSMutableArray *deleteArr = [NSMutableArray array];
    
    for (NSInteger j = 0; j < self.uiMsgs.count; j++) {
        MSMessageCellData *data = self.uiMsgs[j];
        if (data.message.msgSign == msg_sign) {
            delData = data;
            delIndex = j;
            break;
        }
    }
    
    if (delData) {
        MSMessageCellData *preData = delIndex >= 1 ? self.uiMsgs[delIndex-1] : nil;
        MSMessageCellData *nextData = delIndex < self.uiMsgs.count-1 ? self.uiMsgs[delIndex+1] : nil;
        
        [self.uiMsgs removeObject:delData];
        [self.heightCache removeObjectAtIndex:delIndex];
        [deleteArr addObject:[NSIndexPath indexPathForRow:delIndex inSection:0]];
        if (([preData isKindOfClass:[MSSystemMessageCellData class]] && ((MSSystemMessageCellData *)preData).type == SYS_TIME  && [nextData isKindOfClass:[MSSystemMessageCellData class]] && ((MSSystemMessageCellData *)nextData).type == SYS_TIME) ||([preData isKindOfClass:[MSSystemMessageCellData class]] && ((MSSystemMessageCellData *)preData).type == SYS_TIME && nextData == nil)) {
            [self.uiMsgs removeObject:preData];
            [self.heightCache removeObjectAtIndex:delIndex-1];
            [deleteArr addObject:[NSIndexPath indexPathForRow:delIndex-1 inSection:0]];
        }
    }
    if (deleteArr.count) {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:deleteArr withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}


#pragma mark - MSNoticeCountViewDelegate

- (void)countViewDidTap
{
    [self.countTipView cleanCount];
    [self scrollToBottom:YES];
    [self readedReport:self.uiMsgs];//标记已读
}

@end
