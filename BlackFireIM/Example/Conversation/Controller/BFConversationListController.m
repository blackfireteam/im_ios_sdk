//
//  BFConversationListController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import "BFConversationListController.h"
#import "MSIMSDK.h"
#import "BFNaviBarIndicatorView.h"
#import "BFHeader.h"
#import "BFConversationListCell.h"
#import "BFConversationListViewModel.h"
#import "NSBundle+BFKit.h"
#import "BFChatViewController.h"


@interface BFConversationListController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) BFNaviBarIndicatorView *titleView;

@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic,strong) BFConversationListViewModel *viewModel;


@end

@implementation BFConversationListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavigation];
    [self setupViews];
}

- (void)setupNavigation
{
    _titleView = [[BFNaviBarIndicatorView alloc]init];
    [_titleView setTitle:@"MS·IM"];
    self.navigationItem.titleView = _titleView;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNetworkChanged:) name:TUIKitNotification_TIMConnListener object:nil];
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    [self.tableView registerClass:[BFConversationListCell class] forCellReuseIdentifier:@"TConversationCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)onNetworkChanged:(NSNotification *)notification
{
    BFIMNetStatus status = [notification.object intValue];
    switch (status) {
        case IMNET_STATUS_SUCC:
            [_titleView setTitle:@"MS·IM"];
            [_titleView stopAnimating];
            break;
        case IMNET_STATUS_CONNECTING:
            [_titleView setTitle:@"连接中..."];
            [_titleView startAnimating];
            break;
        case IMNET_STATUS_DISCONNECT:
            [_titleView setTitle:@"MS·IM(未连接)"];
            [_titleView stopAnimating];
            break;
        case IMNET_STATUS_CONNFAILED:
            [_titleView setTitle:@"MS·IM(未连接)"];
            [_titleView stopAnimating];
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewModel.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NSBundle bf_localizedStringForKey:@"Delete"];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        BFConversationCellData *convData = self.viewModel.dataList[indexPath.row];
        [self.viewModel removeData:convData];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BFConversationListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TConversationCell" forIndexPath:indexPath];
    BFConversationCellData *data = self.viewModel.dataList[indexPath.row];
    [cell configWithData:data];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BFChatViewController *vc = [[BFChatViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
           [cell setSeparatorInset:UIEdgeInsetsMake(0, 75, 0, 0)];
        if (indexPath.row == (self.viewModel.dataList.count - 1)) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
    }

    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end
