//
//  messageController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import "BFMessageController.h"
#import "BFHeader.h"
#import "UIColor+BFDarkMode.h"
#import "MSIMManager+Message.h"
#import "BFTextMessageCellData.h"
#import "BFImageMessageCellData.h"
#import "BFTextMessageCell.h"
#import "BFImageMessageCell.h"
#import "BFSystemMessageCell.h"
#import "MSIMHeader.h"
#import "BFSystemMessageCellData.h"
#import "NSDate+MSKit.h"
#import "NSBundle+BFKit.h"
#import "UIView+Frame.h"
#import "MSIMTools.h"


#define MAX_MESSAGE_SEP_DLAY (5 * 60)
@interface BFMessageController ()<BFMessageCellDelegate>

@property (nonatomic, strong) NSMutableArray *uiMsgs;
@property (nonatomic, strong) NSMutableArray *heightCache;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, assign) BOOL isScrollBottom;
@property (nonatomic, assign) BOOL firstLoad;
@property (nonatomic, assign) BOOL isLoadingMsg;
@property (nonatomic, assign) BOOL noMoreMsg;
@property(nonatomic,strong) MSIMElem *msgForDate;

@property(nonatomic,strong) BFMessageCellData *menuUIMsg;

@property(nonatomic,assign) NSInteger last_msg_sign;

@end

@implementation BFMessageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self loadMessages];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self readedReport];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self readedReport];
}

- (void)setupUI
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewMessage:) name:MSUIKitNotification_MessageListener object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageStatusUpdate:) name:MSUIKitNotification_MessageSendStatusUpdate object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapViewController)];
    [self.view addGestureRecognizer:tap];
    
    self.tableView.scrollsToTop = NO;
    self.tableView.estimatedRowHeight = 0;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    [self.tableView registerClass:[BFTextMessageCell class] forCellReuseIdentifier:TTextMessageCell_ReuseId];
    [self.tableView registerClass:[BFImageMessageCell class] forCellReuseIdentifier:TImageMessageCell_ReuseId];
    [self.tableView registerClass:[BFSystemMessageCell class] forCellReuseIdentifier:TSystemMessageCell_ReuseId];
    
    _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.tableView.tableHeaderView = _indicatorView;
    
    _heightCache = [NSMutableArray array];
    _uiMsgs = [[NSMutableArray alloc] init];
    _firstLoad = YES;
}

- (void)readedReport
{
    
}

///重发消息
- (void)resendMessage:(BFMessageCellData *)data
{
    [[MSIMManager sharedInstance] resendC2CMessage:data.elem toReciever:data.elem.toUid successed:^(NSInteger msg_id) {
        data.elem.msg_id = msg_id;
    } failed:^(NSInteger code, NSString * _Nonnull desc) {
        
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
            if (msgs.count != 0) {
                strongSelf.last_msg_sign = msgs.lastObject.msg_sign;
            }
            if (isFinished) {
                strongSelf.indicatorView.height = 0;
                strongSelf.noMoreMsg = isFinished;
            }
            NSMutableArray *uiMsgs = [strongSelf transUIMsgFromIMMsg:msgs];
            if (uiMsgs != 0) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, uiMsgs.count)];
                [strongSelf.uiMsgs insertObjects:uiMsgs atIndexes:indexSet];
                [strongSelf.heightCache removeAllObjects];
                [strongSelf.tableView reloadData];
                [strongSelf.tableView layoutIfNeeded];
            }
            strongSelf.isLoadingMsg = NO;
            [strongSelf.indicatorView stopAnimating];
            
                } fail:^(NSInteger code, NSString * _Nonnull desc) {
                    
                    STRONG_SELF(strongSelf)
                    strongSelf.isLoadingMsg = NO;
                    
        }];
    }
}

- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray<MSIMElem *> *)elems
{
    NSMutableArray *uiMsgs = [NSMutableArray array];
    for (NSInteger k = elems.count-1; k >= 0; --k) {
        MSIMElem *elem = elems[k];
        // 时间信息
        BFSystemMessageCellData *dateMsg = [self transSystemMsgFromDate: elem.msg_sign];
        
        BFMessageCellData *data;
        if (elem.type == BFIM_MSG_TYPE_RECALL) {// 撤回的消息
            BFSystemMessageCellData *revoke = [[BFSystemMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
            if (elem.isSelf) {
                revoke.content = [NSBundle bf_localizedStringForKey:@"TUIKitMessageTipsYouRecallMessage"];
            }else {
                revoke.content = [NSBundle bf_localizedStringForKey:@"TUIkitMessageTipsOthersRecallMessage"];
            }
            data = revoke;
        }else if (elem.type == BFIM_MSG_TYPE_TEXT) {
            MSIMTextElem *textElem = (MSIMTextElem *)elem;
            BFTextMessageCellData *textMsg = [[BFTextMessageCellData alloc]initWithDirection:(elem.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
            textMsg.content = textElem.text;
            textMsg.elem = textElem;
            data = textMsg;
        }else if (elem.type == BFIM_MSG_TYPE_IMAGE) {
            MSIMImageElem *imageElem = (MSIMImageElem *)elem;
            BFImageMessageCellData *imageMsg = [[BFImageMessageCellData alloc]initWithDirection:(elem.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
            imageMsg.elem = imageElem;
            data = imageMsg;
        }else {
            BFSystemMessageCellData *unknowData = [[BFSystemMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
            unknowData.content = [NSBundle bf_localizedStringForKey:@"TUIkitMessageTipsUnknowMessage"];
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

- (BFSystemMessageCellData *)transSystemMsgFromDate:(NSInteger)date
{
    if(self.msgForDate == nil || labs(date - self.msgForDate.msg_sign)/1000/1000 > MAX_MESSAGE_SEP_DLAY){
        BFSystemMessageCellData *system = [[BFSystemMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
        system.content = [[NSDate dateWithTimeIntervalSince1970:date/1000/1000] ms_messageString];
        return system;
    }
    return nil;
}

- (void)onNewMessage:(NSNotification *)note
{
    NSArray *elems = note.object;
    NSMutableArray *uiMsgs = [self transUIMsgFromIMMsg:elems];
    if (uiMsgs.count) {
        [self.tableView beginUpdates];
        for (BFMessageCellData *data in uiMsgs) {
            [self.uiMsgs addObject:data];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_uiMsgs.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableView endUpdates];
        [self scrollToBottom:YES];
        [self readedReport];
    }
}

- (void)messageStatusUpdate:(NSNotification *)note
{
    MSIMElem *elem = note.object;
    for (NSInteger i = 0; i < self.uiMsgs.count; i++) {
        BFMessageCellData *data = self.uiMsgs[i];
        if (data.elem.msg_sign == elem.msg_sign) {
            data.elem.sendStatus = elem.sendStatus;
            BFMessageCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell fillWithData:data];
        }
    }
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
    BFMessageCellData *data = self.uiMsgs[indexPath.row];
    height = [data heightOfWidth:Screen_Width];
    [_heightCache insertObject:@(height) atIndex:indexPath.row];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BFMessageCellData *data = _uiMsgs[indexPath.row];
    BFMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
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
    if (!self.noMoreMsg && scrollView.contentOffset.y <= self.indicatorView.height) {
        if (!self.indicatorView.isAnimating) {
            [self.indicatorView startAnimating];
        }
    }else {
        if (self.indicatorView.isAnimating) {
            [self.indicatorView stopAnimating];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y <= self.indicatorView.height) {
        [self loadMessages];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(_delegate && [_delegate respondsToSelector:@selector(didTapInMessageController:)]){
        [_delegate didTapInMessageController:self];
    }
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isScrollBottom == NO) {
        [self scrollToBottom:NO];
        if (indexPath.row == _uiMsgs.count-1) {
            _isScrollBottom = YES;
        }
    }
}

#pragma mark - @protocol BFMessageCellDelegate <NSObject>

- (void)onLongPressMessage:(BFMessageCell *)cell
{
    BFMessageCellData *data = cell.messageData;
    if ([data isKindOfClass:[BFSystemMessageCellData class]]) {
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
    if ([data isKindOfClass:[BFTextMessageCellData class]]) {
        [items addObject:[[UIMenuItem alloc]initWithTitle:[NSBundle bf_localizedStringForKey:@"Copy"] action:@selector(onCopyMsg:)]];
    }
    if (data.elem.sendStatus == BFIM_MSG_STATUS_SEND_SUCC) {
        [items addObject:[[UIMenuItem alloc]initWithTitle:[NSBundle bf_localizedStringForKey:@"Revoke"] action:@selector(onRevoke:)]];
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
- (void)onRetryMessage:(BFMessageCell *)cell
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSBundle bf_localizedStringForKey:@"TUIKitTipsConfirmResendMessage"] message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:[NSBundle bf_localizedStringForKey:@"Re-send"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self resendMessage:cell.messageData];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:[NSBundle bf_localizedStringForKey:@"Cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }]];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)onSelectMessage:(BFMessageCell *)cell
{
    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageContent:)]) {
        [self.delegate messageController:self onSelectMessageContent:cell];
    }
}

- (void)onSelectMessageAvatar:(BFMessageCell *)cell
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
    if ([_menuUIMsg isKindOfClass:[BFTextMessageCellData class]]) {
        BFTextMessageCellData *txtMsg = (BFTextMessageCellData *)_menuUIMsg;
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = txtMsg.content;
    }
}

- (void)onRevoke:(id)sender
{
    [[MSIMManager sharedInstance] revokeMessage:self.menuUIMsg.elem.msg_id toReciever:self.partner_id.integerValue successed:^{
            
        } failed:^(NSInteger code, NSString * _Nonnull desc) {
            
    }];
}

@end
