//
//  BFChatRoomMemberListController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/10/29.
//

#import "BFChatRoomMemberListController.h"
#import "MSIMSDK-UIKit.h"
#import "BFUserListCell.h"

@interface BFChatRoomMemberListController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong) UICollectionView *myCollectionView;

@property(nonatomic,strong) NSMutableArray<MSProfileInfo *> *users;

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

- (void)loadData
{
    [[MSIMManager sharedInstance]chatRoomMembers:self.roomInfo.room_id.integerValue successed:^(NSArray<MSProfileInfo *> * users) {
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
        [_myCollectionView registerClass:[BFUserListCell class] forCellWithReuseIdentifier:@"userCell"];
    }
    return _myCollectionView;
}

- (NSMutableArray<MSProfileInfo *> *)users
{
    if (!_users) {
        _users = [NSMutableArray array];
    }
    return _users;
}

- (void)profileUpdate:(NSNotification *)note
{
    NSArray *profiles = note.object;
    for (MSProfileInfo *info in profiles) {
        if ([self.roomInfo.uids containsObject: @(info.user_id.integerValue)]) {
            [self.users addObject:info];
        }
    }
    [self.myCollectionView reloadData];
}

#pragma mark - UICollection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.users.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BFUserListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"userCell" forIndexPath:indexPath];
    MSProfileInfo *info = self.users[indexPath.row];
    [cell configWithInfo:info];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
 
}

@end
