//
//  messageController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import "BFMessageController.h"
#import "BFHeader.h"
#import "UIColor+BFDarkMode.h"
#import "BFIMManager+Message.h"
#import "BFTextMessageCellData.h"
#import "BFImageMessageCellData.h"
#import "BFTextMessageCell.h"
#import "BFImageMessageCell.h"


@interface BFMessageController ()<BFMessageCellDelegate>

@property (nonatomic, strong) NSMutableArray *uiMsgs;
@property (nonatomic, strong) NSMutableArray *heightCache;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, assign) BOOL firstLoad;
@property (nonatomic, assign) BOOL isLoadingMsg;
@property (nonatomic, assign) BOOL noMoreMsg;
@property(nonatomic,assign) NSInteger last_msg_sign;

@end

@implementation BFMessageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewMessage:) name:TUIKitNotification_TIMMessageListener object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRevokeMessage:) name:TUIKitNotification_TIMMessageRevokeListener object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecvMessageReceipts:) name:TUIKitNotification_onRecvMessageReceipts object:nil];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapViewController)];
    [self.view addGestureRecognizer:tap];
    
    self.tableView.scrollsToTop = NO;
    self.tableView.estimatedRowHeight = 0;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    
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

- (void)loadMessages
{
    if(_isLoadingMsg || _noMoreMsg){
        return;
    }
    _isLoadingMsg = YES;
    int msgCount = 20;
    
    WS(weakSelf)
    if (self.partner_id > 0) {
        [[BFIMManager sharedInstance] getC2CHistoryMessageList:self.partner_id count:msgCount lastMsg:self.last_msg_sign succ:^(NSArray<BFIMElem *> * _Nonnull msgs) {
                    STRONG_SELF(strongSelf)
                    strongSelf.last_msg_sign = msgs.firstObject.msg_sign;
                    strongSelf.isLoadingMsg = NO;
                } fail:^(int code, NSString * _Nonnull desc) {
                    STRONG_SELF(strongSelf)
                    strongSelf.isLoadingMsg = NO;
        }];
    }
}

- (void)onNewMessage:(NSNotification *)note
{
    
}

- (void)onRevokeMessage:(NSNotification *)note
{
    
}

- (void)didRecvMessageReceipts:(NSNotification *)note
{
    
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
    return 0;
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

- (void)scrollToBottom:(BOOL)animate
{
    if (_uiMsgs.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_uiMsgs.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animate];
    }
}

- (void)didTapViewController
{
 
}

#pragma mark - @protocol BFMessageCellDelegate <NSObject>

- (void)onLongPressMessage:(BFMessageCell *)cell
{
    
}

- (void)onRetryMessage:(BFMessageCell *)cell
{
    
}

- (void)onSelectMessage:(BFMessageCell *)cell
{
    
}

- (void)onSelectMessageAvatar:(BFMessageCell *)cell
{
    
}

@end
