//
//  messageController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import "MSMessageController.h"
#import "MSHeader.h"
#import "MSTextMessageCellData.h"
#import "MSImageMessageCellData.h"
#import "MSWinkMessageCellData.h"
#import "MSTextMessageCell.h"
#import "MSImageMessageCell.h"
#import "MSSystemMessageCell.h"
#import "MSVideoMessageCell.h"
#import "MSWinkMessageCell.h"
#import "MSVoiceMessageCell.h"
#import <MSIMSDK/MSIMSDK.h>
#import "MSSystemMessageCellData.h"
#import "MSNoticeCountView.h"
#import <MJRefresh.h>


#define MAX_MESSAGE_SEP_DLAY (5 * 60)
@interface MSMessageController ()<MSMessageCellDelegate,MSNoticeCountViewDelegate>

@property (nonatomic, strong) NSMutableArray<MSMessageCellData *> *uiMsgs;
@property (nonatomic, strong) NSMutableArray *heightCache;

@property (nonatomic, assign) BOOL isScrollBottom;
@property(nonatomic,assign) BOOL isShowKeyboard;
@property (nonatomic, assign) BOOL firstLoad;
@property (nonatomic, assign) BOOL isLoadingMsg;
@property (nonatomic, assign) BOOL noMoreMsg;
@property(nonatomic,strong) MSIMElem *msgForDate;

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
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_MessageSendStatusUpdate object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf messageStatusUpdate:note];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_ProfileUpdate object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf profileUpdate:note];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_MessageRecieveRevoke object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf recieveRevokeMessage:note];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_MessageReceipt object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf recieveMessageReceipt:note];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapViewController)];
    [self.view addGestureRecognizer:tap];
    
    self.tableView.scrollsToTop = NO;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    [self.tableView registerClass:[MSTextMessageCell class] forCellReuseIdentifier:TTextMessageCell_ReuseId];
    [self.tableView registerClass:[MSImageMessageCell class] forCellReuseIdentifier:TImageMessageCell_ReuseId];
    [self.tableView registerClass:[MSSystemMessageCell class] forCellReuseIdentifier:TSystemMessageCell_ReuseId];
    [self.tableView registerClass:[MSVideoMessageCell class] forCellReuseIdentifier:TVideoMessageCell_ReuseId];
    [self.tableView registerClass:[MSVoiceMessageCell class] forCellReuseIdentifier:TVoiceMessageCell_ReuseId];
    [self.tableView registerClass:[MSWinkMessageCell class] forCellReuseIdentifier:TWinkMessageCell_ReuseId];
 
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
    [[MSIMManager sharedInstance] resendC2CMessage:data.elem toReciever:data.elem.toUid successed:^(NSInteger msg_id) {
        data.elem.msg_id = msg_id;
    } failed:^(NSInteger code, NSString * _Nonnull desc) {
        [MSHelper showToastFail:desc];
    }];
}

- (void)loadMessages
{
    if(_isLoadingMsg || _noMoreMsg){
        return;
    }
    _isLoadingMsg = YES;
    int msgCount = 20;
    
    WS(weakSelf)
    if (self.partner_id > 0) {
        [[MSIMManager sharedInstance] getC2CHistoryMessageList:self.partner_id count:msgCount lastMsg:self.last_msg_sign succ:^(NSArray<MSIMElem *> * _Nonnull msgs, BOOL isFinished) {
            
            STRONG_SELF(strongSelf)
            NSArray<MSIMElem *> *tempElems = [strongSelf deduplicateMessage:msgs];
            [strongSelf.tableView.mj_header endRefreshing];
            strongSelf.last_msg_sign = msgs.lastObject.msg_sign;
            
            if (isFinished) {
                strongSelf.noMoreMsg = YES;
                strongSelf.tableView.mj_header.hidden = YES;
            }
            NSMutableArray *uiMsgs = [strongSelf transUIMsgFromIMMsg:tempElems];
            if (uiMsgs.count != 0) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, uiMsgs.count)];
                [strongSelf.uiMsgs insertObjects:uiMsgs atIndexes:indexSet];
                [strongSelf.heightCache removeAllObjects];
                [strongSelf.tableView reloadData];
                [strongSelf.tableView layoutIfNeeded];
                if(!strongSelf.firstLoad){
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
}

- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray<MSIMElem *> *)elems
{
    NSMutableArray *uiMsgs = [NSMutableArray array];
    for (NSInteger k = elems.count-1; k >= 0; --k) {
        MSIMElem *elem = elems[k];
        // 时间信息
        MSSystemMessageCellData *dateMsg = [self transSystemMsgFromDate: elem.msg_sign];
        
        MSMessageCellData *data;
        if (elem.type == MSIM_MSG_TYPE_REVOKE) {// 撤回的消息
            MSSystemMessageCellData *revoke = [[MSSystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
            if (elem.isSelf) {
                revoke.content = TUILocalizableString(TUIKitMessageTipsYouRecallMessage);
            }else {
                revoke.content = TUILocalizableString(TUIkitMessageTipsOthersRecallMessage);
            }
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
        }else if (elem.type == MSIM_MSG_TYPE_CUSTOM) {
            MSWinkMessageCellData *winkMsg = [[MSWinkMessageCellData alloc]initWithDirection:(elem.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
            winkMsg.showName = YES;
            winkMsg.elem = elem;
            data = winkMsg;
        }else {
            MSSystemMessageCellData *unknowData = [[MSSystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
            unknowData.content = TUILocalizableString(TUIkitMessageTipsUnknowMessage);
            unknowData.elem = elem;
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
    if(self.msgForDate == nil || labs(date - self.msgForDate.msg_sign)/1000/1000 > MAX_MESSAGE_SEP_DLAY){
        MSSystemMessageCellData *system = [[MSSystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        system.content = [[NSDate dateWithTimeIntervalSince1970:date/1000/1000] ms_messageString];
        return system;
    }
    return nil;
}

//消息去重
- (NSArray<MSIMElem *> *)deduplicateMessage:(NSArray *)elems
{
    NSMutableArray<MSIMElem *> *tempArr = [NSMutableArray array];
    for (MSIMElem *elem in elems) {
        if (![elem.partner_id isEqualToString:self.partner_id]) return nil;
        BOOL isExsit = NO;
        for (MSMessageCellData *data in self.uiMsgs) {
            if (elem.msg_id > 0 && elem.msg_id == data.elem.msg_id) {
                isExsit = YES;
                break;
            }
            if (elem.msg_sign == data.elem.msg_sign) {
                isExsit = YES;
                data.elem = elem;
                [self.tableView reloadData];
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
    elems = [[elems reverseObjectEnumerator] allObjects];
    //消息去重
    NSArray *tempElems = [self deduplicateMessage:elems];
    NSMutableArray *uiMsgs = [NSMutableArray array];
    for (MSIMElem *e in tempElems) {
        if ([self.delegate respondsToSelector:@selector(messageController:onNewMessage:)]) {
            MSMessageCellData *data = [self.delegate messageController:self onNewMessage:e];
            if (data != nil) {
                [uiMsgs addObject:data];
            }else {
                [uiMsgs addObjectsFromArray:[self transUIMsgFromIMMsg:@[e]]];
            }
        }else {
            [uiMsgs addObjectsFromArray:[self transUIMsgFromIMMsg:@[e]]];
        }
    }
    
    if (uiMsgs.count) {
        //当前列表是否停留在底部
        BOOL isAtBottom = (self.tableView.contentOffset.y + self.tableView.height + 20 >= self.tableView.contentSize.height);
        [self.uiMsgs addObjectsFromArray:uiMsgs];
        [self.tableView reloadData];
        //当列表没有停留在底部时，不自动滚动显示出新消息。会在底部显示未读数，点击滚动到底部。
        //适当增加些容错
        if (isAtBottom || self.isShowKeyboard) {
            [self scrollToBottom:YES];
            [self readedReport: uiMsgs];//标记已读
        }else {
            [self.countTipView increaseCount: tempElems.count];
        }
    }
}

///收到一条对方撤回的消息
- (void)recieveRevokeMessage:(NSNotification *)note
{
    MSIMElem *elem = note.object;
    if (![elem.partner_id isEqualToString:self.partner_id]) return;
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

///收到对方发出的消息已读回执
- (void)recieveMessageReceipt:(NSNotification *)note
{
    MSIMMessageReceipt *receipt = note.object;
    if (![receipt.user_id isEqualToString:self.partner_id]) return;
    for (MSMessageCellData *data in self.uiMsgs) {
        if (data.elem.msg_id <= receipt.msg_id) {
            data.elem.readStatus = MSIM_MSG_STATUS_READ;
        }else {
            data.elem.readStatus = MSIM_MSG_STATUS_UNREAD;
        }
    }
    [self.tableView reloadData];
}

///消息状态发生变化通知
- (void)messageStatusUpdate:(NSNotification *)note
{
    MSIMElem *elem = note.object;
    if (![elem.partner_id isEqualToString:self.partner_id]) return;
    for (NSInteger i = 0; i < self.uiMsgs.count; i++) {
        MSMessageCellData *data = self.uiMsgs[i];
        if (data.elem.msg_sign == elem.msg_sign) {
            data.elem = elem;
            MSMessageCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell fillWithData:data];
        }
    }
}

///用户个人信息更新通知
- (void)profileUpdate:(NSNotification *)note
{
    NSArray<MSProfileInfo *> *profiles = note.object;
    for (MSProfileInfo *info in profiles) {
        if ([info.user_id isEqualToString:self.partner_id] || [info.user_id isEqualToString:[MSIMTools sharedInstance].user_id]) {
            [self.tableView reloadData];
        }
        if ([info.user_id isEqualToString:self.partner_id]) {
            self.navigationItem.title = info.nick_name;
        }
    }
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
        cell = [self.delegate messageController:self onShowMessageData:data];
        if (cell) {
            [self.tableView registerClass:[cell class] forCellReuseIdentifier:data.reuseId];
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
    if ([data isKindOfClass:[MSTextMessageCellData class]]) {
        [items addObject:[[UIMenuItem alloc]initWithTitle:TUILocalizableString(Copy) action:@selector(onCopyMsg:)]];
    }
    if (data.elem.isSelf && data.elem.sendStatus == MSIM_MSG_STATUS_SEND_SUCC && data.elem.type != MSIM_MSG_TYPE_CUSTOM) {
        [items addObject:[[UIMenuItem alloc]initWithTitle:TUILocalizableString(Revoke) action:@selector(onRevoke:)]];
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
        action == @selector(onCopyMsg:)){
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
    [[MSIMManager sharedInstance] revokeMessage:self.menuUIMsg.elem.msg_id toReciever:self.partner_id.integerValue successed:^{
        
        NSLog(@"撤回成功");
        
        } failed:^(NSInteger code, NSString * _Nonnull desc) {
            
    }];
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
        data.content = TUILocalizableString(TUIkitMessageTipsOthersRecallMessage);
    }
    [self.uiMsgs insertObject:data atIndex:index];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark - MSNoticeCountViewDelegate

- (void)countViewDidTap
{
    [self.countTipView cleanCount];
    [self scrollToBottom:YES];
    [self readedReport:self.uiMsgs];//标记已读
}

@end
