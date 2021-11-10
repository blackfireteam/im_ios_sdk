//
//  BFChatRoomMemberListController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/10/29.
//

#import "BFChatRoomMemberListController.h"
#import "MSIMSDK-UIKit.h"
#import "BFGroupMemberCell.h"

@interface BFChatRoomMemberListController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong) UICollectionView *myCollectionView;

@property(nonatomic,strong) NSMutableArray<MSGroupMemberItem *> *users;

@end

@implementation BFChatRoomMemberListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Member List";
    [self.view addSubview:self.myCollectionView];
    [self loadData];
    [self addNotifications];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MSHelper showToastString:@"长按头像更多操作"];
}

- (void)loadData
{
    [[MSIMManager sharedInstance]chatRoomMembers:self.roomInfo.room_id.integerValue successed:^(NSArray<MSGroupMemberItem *> * users) {
        [self.users removeAllObjects];
        [self.users addObjectsFromArray:users];
        [self.myCollectionView reloadData];
        
    } failed:^(NSInteger code, NSString *desc) {
        [MSHelper showToastFail:desc];
    }];
}

- (void)addNotifications
{
    WS(weakSelf)
    [[NSNotificationCenter defaultCenter]addObserverForName:MSUIKitNotification_ProfileUpdate object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf profileUpdate: note];
    }];
}

- (UICollectionView *)myCollectionView
{
    if (!_myCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake((Screen_Width-15*3)*0.5, (Screen_Width-15*3)*0.5*1.3);
        layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
        layout.minimumLineSpacing = 15;
        layout.minimumInteritemSpacing = 15;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _myCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height) collectionViewLayout:layout];
        _myCollectionView.delegate = self;
        _myCollectionView.dataSource = self;
        _myCollectionView.alwaysBounceVertical = YES;
        _myCollectionView.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
        [_myCollectionView registerClass:[BFGroupMemberCell class] forCellWithReuseIdentifier:@"memnberCell"];
    }
    return _myCollectionView;
}

- (NSMutableArray<MSGroupMemberItem *> *)users
{
    if (!_users) {
        _users = [NSMutableArray array];
    }
    return _users;
}

- (void)profileUpdate:(NSNotification *)note
{
//    NSArray *profiles = note.object;
    [self.myCollectionView reloadData];
}

#pragma mark - UICollection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.users.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BFGroupMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"memnberCell" forIndexPath:indexPath];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(userLongPress:)];
    [cell addGestureRecognizer:longPress];
    MSGroupMemberItem *item = self.users[indexPath.row];
    cell.info = item;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
 
}

- (void)userLongPress:(UILongPressGestureRecognizer *)ges
{
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            BFGroupMemberCell *cell = (BFGroupMemberCell *)ges.view;
            MSGroupMemberItem *item = cell.info;
            [self showMoreAction:item];
        }
            break;
        default:
            break;
    }
}

- (void)showMoreAction:(MSGroupMemberItem *)item
{
    WS(weakSelf)
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSString *showTitle1 = item.role == 0 ? @"设置Ta为临时管理员" : @"取消Ta的管理员身份";
    [alert addAction:[UIAlertAction actionWithTitle:showTitle1 style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf changeUserRole: item];
    }]];
    NSString *showTitle2 = item.is_mute == NO ? @"禁言" : @"取消禁言";
    [alert addAction:[UIAlertAction actionWithTitle:showTitle2 style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf changeUserMute: item];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)changeUserRole:(MSGroupMemberItem *)item
{
    if (self.roomInfo.action_assign == NO) {
        [MSHelper showToastString:@"exceed your authority"];
        return;
    }
    //当uid是正值时 是任命， 当为负值时是 取消任命
    WS(weakSelf)
    [[MSIMManager sharedInstance] editChatroomManagerAccess:self.roomInfo.room_id uids:@[item.role == 0 ? @(item.uid.integerValue) : @(-item.uid.integerValue)] duration:1 reason:@"good job!" successed:^{
        
        [MSHelper showToastSucc:@"Success"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.myCollectionView reloadData];
        });
        
    } failed:^(NSInteger code, NSString *desc) {
        [MSHelper showToastFail:desc];
    }];
}

- (void)changeUserMute:(MSGroupMemberItem *)item
{
    if (self.roomInfo.action_mute == NO) {
        [MSHelper showToastString:@"exceed your authority"];
        return;
    }
    //当uid是正值是禁言，当uid为负值时是取消禁言
    WS(weakSelf)
    [[MSIMManager sharedInstance] muteMembers:self.roomInfo.room_id uids:@[item.is_mute ? @(-item.uid.integerValue) : @(item.uid.integerValue)] duration:1 reason:@"Don`t like a good guy" successed:^{
        
        [MSHelper showToastSucc:@"Success"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.myCollectionView reloadData];
        });
        
    } failed:^(NSInteger code, NSString *desc) {
        [MSHelper showToastFail:desc];
    }];
}

@end
