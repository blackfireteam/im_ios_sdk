//
//  MSGroupMessageController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/10/28.
//

#import "MSChatRoomMessageController.h"
#import "MSIMSDK-UIKit.h"
#import <MSIMSDK/MSIMSDK.h>
#import <MJRefresh.h>
#import "MSTipsView.h"

@interface MSChatRoomMessageController ()<MSMessageCellDelegate,MSNoticeCountViewDelegate>

@property (nonatomic, strong) NSMutableArray<MSMessageCellData *> *uiMsgs;
@property (nonatomic, strong) NSMutableArray *heightCache;

@property (nonatomic, assign) BOOL isScrollBottom;
@property(nonatomic,assign) BOOL isShowKeyboard;
@property (nonatomic, assign) BOOL firstLoad;
@property (nonatomic, assign) BOOL noMoreMsg;
@property(nonatomic,strong) MSIMElem *msgForDate;

@property(nonatomic,strong) MSMessageCellData *menuUIMsg;

@property(nonatomic,strong) MSNoticeCountView *countTipView;

@property(nonatomic,strong) MSTipsView *tipsView; //公告提示

@end

@implementation MSChatRoomMessageController

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
    /// 标记已读
    [[MSIMManager sharedInstance]markChatRoomMessageAsRead:self.uiMsgs.lastObject.elem.msg_id succ:^{
        
    } failed:^(NSInteger code, NSString *desc) {
        
    }];
}

- (void)setupUI
{
    WS(weakSelf)
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_ChatRoom_MessageListener object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
       [weakSelf onNewMessage:note];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_ChatRoom_MessageSendStatusUpdate object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf messageStatusUpdate:note];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_ChatRoomMessageRecieveDelete object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf recieveMessageDelete:note];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_ChatroomMessageRecieveRevoke object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf recieveRevokeMessage:note];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_ChatroomMessageRecieveTipsOfDay object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf recieveTipsOfDay:note];
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
    
    _countTipView = [[MSNoticeCountView alloc]init];
    [_countTipView setHidden:YES];
    _countTipView.delegate = self;
    
    _heightCache = [NSMutableArray array];
    _uiMsgs = [[NSMutableArray alloc] init];
    _firstLoad = YES;
}

- (void)loadMessages
{
    NSArray *msgs = MSChatRoomManager.sharedInstance.messages;
    NSMutableArray *uiMsgs = [self transUIMsgFromIMMsg:msgs];
    [self.uiMsgs addObjectsFromArray:uiMsgs];
    [self.tableView reloadData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (self.countTipView.superview == nil) {
        [self.parentViewController.view addSubview:self.countTipView];
    }
    self.countTipView.frame = CGRectMake(self.tableView.width-30-10, self.tableView.height-30-10, 30, 30);
}

///重发消息
- (void)resendMessage:(MSMessageCellData *)data
{
    [[MSIMManager sharedInstance] resendChatRoomMessage:data.elem toRoomID:self.roomInfo.room_id successed:^(NSInteger msg_id) {
        data.elem.msg_id = msg_id;
    } failed:^(NSInteger code, NSString *desc) {
        [MSHelper showToastFail:desc];
    }];
}

- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray<MSIMElem *> *)elems
{
    NSMutableArray *uiMsgs = [NSMutableArray array];
    for (NSInteger k = elems.count-1; k >= 0; --k) {
        MSIMElem *elem = elems[k];
        // 时间信息
        MSSystemMessageCellData *dateMsg = [self transSystemMsgFromDate: elem.msg_sign];
        
        MSMessageCellData *data;
        if ([self.delegate respondsToSelector:@selector(messageController:prepareForMessage:)]) {
            MSMessageCellData *cellData = [self.delegate messageController:self prepareForMessage:elem];
            if (cellData != nil) {
                if (dateMsg) {
                    self.msgForDate = elem;
                    [uiMsgs addObject:dateMsg];
                }
                [uiMsgs addObject:cellData];
                continue;
            }
        }
        
        if (elem.type == MSIM_MSG_TYPE_REVOKE) {// 撤回的消息
            MSSystemMessageCellData *revoke = [[MSSystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
            if (elem.isSelf) {
                revoke.content = TUILocalizableString(TUIKitMessageTipsYouRecallMessage);
            }else {
                revoke.content = [NSString stringWithFormat:TUILocalizableString(TUIKitMessageTipsRecallMessageFormat),XMNoNilString(elem.owner.nick_name)];
            }
            revoke.type = SYS_REVOKE;
            revoke.elem = elem;
            data = revoke;
        }else if (elem.type == MSIM_MSG_TYPE_TEXT) {
            MSIMTextElem *textElem = (MSIMTextElem *)elem;
            MSTextMessageCellData *textMsg = [[MSTextMessageCellData alloc]initWithDirection:(elem.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
            textMsg.showName = YES;
            textMsg.content = textElem.text;
            textMsg.elem = textElem;
            data = textMsg;
        }else if (elem.type == MSIM_MSG_TYPE_IMAGE) {
            MSImageMessageCellData *imageMsg = [[MSImageMessageCellData alloc]initWithDirection:(elem.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
            imageMsg.showName = YES;
            imageMsg.elem = elem;
            data = imageMsg;
        }else if (elem.type == MSIM_MSG_TYPE_VIDEO) {
            MSVideoMessageCellData *videoMsg = [[MSVideoMessageCellData alloc]initWithDirection:(elem.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
            videoMsg.showName = YES;
            videoMsg.elem = elem;
            data = videoMsg;
        }else if (elem.type == MSIM_MSG_TYPE_VOICE) {
            MSVoiceMessageCellData *voiceMsg = [[MSVoiceMessageCellData alloc]initWithDirection:(elem.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
            voiceMsg.showName = YES;
            voiceMsg.elem = elem;
            data = voiceMsg;
        }else if (elem.type == MSIM_MSG_TYPE_LOCATION) {
            MSLocationMessageCellData *locationMsg = [[MSLocationMessageCellData alloc]initWithDirection:(elem.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
            locationMsg.showName = YES;
            locationMsg.elem = elem;
            data = locationMsg;
        }else {
            MSSystemMessageCellData *unknowData = [[MSSystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
            unknowData.content = TUILocalizableString(TUIkitMessageTipsUnknowMessage);
            unknowData.elem = elem;
            unknowData.type = SYS_UNKNOWN;
            data = unknowData;
        }
        if (dateMsg) {
            self.msgForDate = elem;
            [uiMsgs addObject:dateMsg];
        }
        [uiMsgs addObject:data];
    }
    return uiMsgs;
}

- (MSSystemMessageCellData *)transSystemMsgFromDate:(NSInteger)date
{
    if(self.msgForDate == nil || labs(date - self.msgForDate.msg_sign)/1000/1000 > 5 * 60){
        MSSystemMessageCellData *system = [[MSSystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        system.content = [[NSDate dateWithTimeIntervalSince1970:date/1000/1000] ms_messageString];
        system.type = SYS_TIME;
        return system;
    }
    return nil;
}

//消息去重
- (NSArray<MSIMElem *> *)deduplicateMessage:(NSArray *)elems
{
    NSMutableArray<MSIMElem *> *tempArr = [NSMutableArray array];
    for (MSIMElem *elem in elems) {
        if (elem.chatType != MSIM_CHAT_TYPE_CHATROOM) continue;
        if (![elem.toUid isEqualToString:self.roomInfo.room_id]) continue;
        BOOL isExsit = NO;
        for (MSMessageCellData *data in self.uiMsgs) {
            if (elem.msg_sign == data.elem.msg_sign) {
                isExsit = YES;
                data.elem = elem;
                [self.tableView reloadData];
                break;
            }
            if (elem.msg_id > 0 && elem.msg_id == data.elem.msg_id) {
                isExsit = YES;
                break;
            }
        }
        if (isExsit == NO) {
            [tempArr addObject:elem];
        }
    }
    return tempArr;
}

///收到新消息
- (void)onNewMessage:(NSNotification *)note
{
    NSArray *elems = note.object;
    //消息去重
    NSArray *tempElems = [self deduplicateMessage:elems];
    NSMutableArray *uiMsgs = [self transUIMsgFromIMMsg:tempElems];

    if (uiMsgs.count) {
        //当前列表是否停留在底部
        BOOL isAtBottom = (self.tableView.contentOffset.y + self.tableView.height + 20 >= self.tableView.contentSize.height);
        [self.uiMsgs addObjectsFromArray:uiMsgs];
        [self.tableView reloadData];
        //当列表没有停留在底部时，不自动滚动显示出新消息。会在底部显示未读数，点击滚动到底部。
        //适当增加些容错
        if (isAtBottom || self.isShowKeyboard) {
            [self scrollToBottom:YES];
        }else {
            [self.countTipView increaseCount: tempElems.count];
        }
    }
}

///消息状态发生变化通知
- (void)messageStatusUpdate:(NSNotification *)note
{
    MSIMElem *elem = note.object;
    if (elem.chatType != MSIM_CHAT_TYPE_CHATROOM) return;
    if (![elem.toUid isEqualToString:self.roomInfo.room_id]) return;
    for (NSInteger i = 0; i < self.uiMsgs.count; i++) {
        MSMessageCellData *data = self.uiMsgs[i];
        if (data.elem.msg_sign == elem.msg_sign) {
            data.elem = elem;
            MSMessageCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell fillWithData:data];
        }
    }
}

///收到一条对方撤回的消息
- (void)recieveRevokeMessage:(NSNotification *)note
{
    MSIMElem *elem = note.object;
    if (![elem.toUid isEqualToString:self.roomInfo.room_id]) return;
    MSMessageCellData *revokeData = nil;
    for (MSMessageCellData *data in self.uiMsgs) {
        if (data.elem.msg_id == elem.revoke_msg_id) {
            revokeData = data;
        }
    }
    if (revokeData) {
        [self revokeMsg:revokeData];
    }
}

- (void)revokeMsg:(MSMessageCellData *)msg
{
    if (msg == nil) return;
    NSInteger index = [self.uiMsgs indexOfObject:msg];
    if (index == NSNotFound) return;
    [self.uiMsgs removeObject:msg];
    if (index < self.heightCache.count) {
        [self.heightCache replaceObjectAtIndex:index withObject:@(0)];
    }
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    MSSystemMessageCellData *data = [[MSSystemMessageCellData alloc]initWithDirection:MsgDirectionIncoming];
    if (msg.elem.isSelf) {
        data.content = TUILocalizableString(TUIKitMessageTipsYouRecallMessage);
    }else {
        data.content = [NSString stringWithFormat:TUILocalizableString(TUIKitMessageTipsRecallMessageFormat),XMNoNilString(msg.elem.owner.nick_name)];
    }
    data.type = SYS_REVOKE;
    [self.uiMsgs insertObject:data atIndex:index];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

///收到聊天室公告
- (void)recieveTipsOfDay:(NSNotification *)note
{
    if (self.tipsView) {
        [self.tipsView dismiss];
        self.tipsView = nil;
    }
    self.tipsView = [[MSTipsView alloc]initWithFrame:CGRectMake(0, NavBar_Height + StatusBar_Height, Screen_Width, 40)];
    [self.parentViewController.view addSubview:self.tipsView];
    [self.tipsView showTips:[NSString stringWithFormat:@"公告: %@",note.object]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tipsView dismiss];
        self.tipsView = nil;
    });
}

///收到服务器将消息删除
- (void)recieveMessageDelete:(NSNotification *)note
{
    NSArray *msg_ids = note.object;
    NSMutableArray *deleteArr = [NSMutableArray array];
    for (NSInteger i = 0; i < self.uiMsgs.count; i++) {
        MSMessageCellData *cellData = self.uiMsgs[i];
        for (NSInteger j = 0; j < msg_ids.count; j++) {
            NSInteger msg_id = [msg_ids[j] integerValue];
            if (cellData.elem.msg_id == msg_id) {
                [self.uiMsgs removeObject:cellData];
                [deleteArr addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                if (i < self.heightCache.count) {
                    [self.heightCache replaceObjectAtIndex:i withObject:@(0)];
                }
                MSMessageCellData *preData = i >= 1 ? self.uiMsgs[i-1] : nil;
                MSMessageCellData *nextData = i < self.uiMsgs.count-1 ? self.uiMsgs[i+1] : nil;

                //时间显示的处理
                if (([preData isKindOfClass:[MSSystemMessageCellData class]] && ((MSSystemMessageCellData *)preData).type == SYS_TIME && [nextData isKindOfClass:[MSSystemMessageCellData class]] && ((MSSystemMessageCellData *)nextData).type == SYS_TIME) ||([preData isKindOfClass:[MSSystemMessageCellData class]] && ((MSSystemMessageCellData *)preData).type == SYS_TIME && nextData == nil)) {
                    NSInteger preIndex = [self.uiMsgs indexOfObject:preData];
                    [self.uiMsgs removeObject:preData];
                    if (preIndex < self.heightCache.count) {
                        [self.heightCache replaceObjectAtIndex:preIndex withObject:@(0)];
                    }
                    [deleteArr addObject:[NSIndexPath indexPathForRow:preIndex inSection:0]];
                }
                break;
            }
        }
    }
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deleteArr withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
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
    CGFloat height = 0;
    if(_heightCache.count > indexPath.row){
        height = [_heightCache[indexPath.row] floatValue];
    }
    if (height) {
        return height;
    }
    MSMessageCellData *data = self.uiMsgs[indexPath.row];
    height = [data heightOfWidth:Screen_Width];
    [_heightCache insertObject:@(height) atIndex:indexPath.row];
    return height;
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
    if (scrollView.contentOffset.y + scrollView.height + 20 >= scrollView.contentSize.height) {
        if (self.countTipView.isHidden == NO) {
            [self.countTipView cleanCount];
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
    if ([data isKindOfClass:[MSTextMessageCellData class]]) {
        [items addObject:[[UIMenuItem alloc]initWithTitle:TUILocalizableString(Copy) action:@selector(onCopyMsg:)]];
    }
    if (data.elem.isSelf && data.elem.sendStatus == MSIM_MSG_STATUS_SEND_SUCC && data.elem.type != MSIM_MSG_TYPE_CUSTOM_UNREADCOUNT_NO_RECALL) {
        [items addObject:[[UIMenuItem alloc]initWithTitle:TUILocalizableString(Revoke) action:@selector(onRevoke:)]];
    }
    //删除消息有权限要求，管理员才能删除
    if (self.roomInfo.action_del_msg == YES || self.menuUIMsg.elem.sendStatus == MSIM_MSG_STATUS_SEND_FAIL) {
        [items addObject:[[UIMenuItem alloc]initWithTitle:TUILocalizableString(Delete) action:@selector(onDelete:)]];
    }
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
    [[MSIMManager sharedInstance]chatRoomRevokeMessage:self.menuUIMsg.elem.msg_id fromRoomID:self.roomInfo.room_id successed:^{
        
        NSLog(@"撤回成功");
        
    } failed:^(NSInteger code, NSString *desc) {
        
    }];
}

- (void)onDelete:(id)sender
{
    NSInteger index = [self.uiMsgs indexOfObject:self.menuUIMsg];
    if (index == NSNotFound) return;
    NSMutableArray *deleteArr = [NSMutableArray array];
    MSMessageCellData *preData = index >= 1 ? self.uiMsgs[index-1] : nil;
    MSMessageCellData *nextData = index < self.uiMsgs.count-1 ? self.uiMsgs[index+1] : nil;
    
    [self.uiMsgs removeObject:self.menuUIMsg];
    [deleteArr addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    
    if (index < self.heightCache.count) {
        [self.heightCache replaceObjectAtIndex:index withObject:@(0)];
    }
    //时间显示的处理
    if (([preData isKindOfClass:[MSSystemMessageCellData class]] && ((MSSystemMessageCellData *)preData).type == SYS_TIME && [nextData isKindOfClass:[MSSystemMessageCellData class]] && ((MSSystemMessageCellData *)nextData).type == SYS_TIME) ||([preData isKindOfClass:[MSSystemMessageCellData class]] && ((MSSystemMessageCellData *)preData).type == SYS_TIME && nextData == nil)) {
        NSInteger preIndex = [self.uiMsgs indexOfObject:preData];
        [self.uiMsgs removeObject:preData];
        if (preIndex < self.heightCache.count) {
            [self.heightCache replaceObjectAtIndex:preIndex withObject:@(0)];
        }
        [deleteArr addObject:[NSIndexPath indexPathForRow:preIndex inSection:0]];
    }
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deleteArr withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    //通知服务器删除
    [[MSIMManager sharedInstance]deleteChatroomMsgs:self.roomInfo.room_id msgIDs:@[@(self.menuUIMsg.elem.msg_id)] successed:^{
        
    } failed:^(NSInteger code, NSString *desc) {
        
    }];
}

- (void)addSystemTips:(NSString *)text
{
    MSSystemMessageCellData *system = [[MSSystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
    system.content = text;
    system.type = SYS_OTHER;
    //当前列表是否停留在底部
    BOOL isAtBottom = (self.tableView.contentOffset.y + self.tableView.height + 20 >= self.tableView.contentSize.height);
    [self.uiMsgs addObject:system];
    [self.tableView reloadData];
    //当列表没有停留在底部时，不自动滚动显示出新消息。会在底部显示未读数，点击滚动到底部。
    //适当增加些容错
    if (isAtBottom || self.isShowKeyboard) {
        [self scrollToBottom:YES];
    }
}

#pragma mark - MSNoticeCountViewDelegate

- (void)countViewDidTap
{
    [self.countTipView cleanCount];
    [self scrollToBottom:YES];
}

@end
