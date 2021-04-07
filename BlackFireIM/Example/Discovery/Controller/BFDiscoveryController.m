//
//  BFDiscoveryController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/24.
//

#import "BFDiscoveryController.h"
#import "UIColor+BFDarkMode.h"
#import "BFHeader.h"
#import "BFUserListCell.h"
#import "BFChatViewController.h"
#import "MSIMSDK.h"


@interface BFDiscoveryController ()

@property(nonatomic,strong) NSMutableArray<MSProfileInfo *> *dataArray;

@end

@implementation BFDiscoveryController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"在线用户";
    [self setupUI];
}

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userOnline:) name:@"MSUIKitNotification_Profile_online" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userOffline:) name:@"MSUIKitNotification_Profile_offline" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableArray<MSProfileInfo *> *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)userOnline:(NSNotification *)note
{
    MSProfileInfo *info = note.object;
    [[MSProfileProvider provider] updateProfile:info];
    [self.dataArray insertObject:info atIndex:0];
    [self.tableView reloadData];
}

- (void)userOffline:(NSNotification *)note
{
    NSString *user_id = note.object;
    for (NSInteger i = 0; i < self.dataArray.count; i++) {
        MSProfileInfo *info = self.dataArray[i];
        if ([info.user_id isEqualToString:user_id]) {
            [self.dataArray removeObject:info];
            break;
        }
    }
    [self.tableView reloadData];
}

- (void)setupUI
{
    self.tableView.scrollsToTop = NO;
    self.tableView.estimatedRowHeight = 0;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    self.tableView.rowHeight = 80;
    [self.tableView registerClass:[BFUserListCell class] forCellReuseIdentifier:@"userCell"];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BFUserListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
    [cell configWithInfo:self.dataArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BFChatViewController *vc = [[BFChatViewController alloc]init];
    vc.partner_id = self.dataArray[indexPath.row].user_id;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
