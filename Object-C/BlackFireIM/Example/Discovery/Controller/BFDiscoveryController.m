//
//  BFDiscoveryController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/24.
//

#import "BFDiscoveryController.h"
#import "MSIMSDK-UIKit.h"
#import "BFUserListCell.h"
#import "BFChatViewController.h"
#import <MSIMSDK/MSIMSDK.h>


@interface BFDiscoveryController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong) NSMutableArray<NSNumber *> *dataArray;

@property(nonatomic,strong) UICollectionView *myCollectionView;

@end

@implementation BFDiscoveryController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navView.navTitleL.text = @"Online";
    self.navView.leftButton.hidden = YES;
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

- (NSMutableArray<NSNumber *> *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)userOnline:(NSNotification *)note
{
    NSArray *uids = note.object;
    for (NSNumber *uid in uids) {
        if (![self.dataArray containsObject:uid]) {
            [self.dataArray addObject:uid];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.myCollectionView reloadData];
    });
}

- (void)userOffline:(NSNotification *)note
{
    NSArray *uids = note.object;
    for (NSNumber *uid in uids) {
        [self.dataArray removeObject:uid];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.myCollectionView reloadData];
    });
}

- (void)setupUI
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake((Screen_Width-15*3)*0.5, (Screen_Width-15*3)*0.5*1.3);
    layout.minimumLineSpacing = 15;
    layout.minimumInteritemSpacing = 15;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(StatusBar_Height + NavBar_Height + 15, 15, TabBar_Height + 15, 15);
    self.myCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height) collectionViewLayout:layout];
    self.myCollectionView.delegate = self;
    self.myCollectionView.dataSource = self;
    self.myCollectionView.alwaysBounceVertical = YES;
    self.myCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.myCollectionView.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:TController_Background_Color_Dark];
    [self.myCollectionView registerClass:[BFUserListCell class] forCellWithReuseIdentifier:@"userCell"];
    [self.view addSubview:self.myCollectionView];
}

#pragma mark - UICollection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BFUserListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"userCell" forIndexPath:indexPath];
    MSProfileInfo *info = [[MSProfileProvider provider]providerProfileFromLocal:[NSString stringWithFormat:@"%@",self.dataArray[indexPath.row]]];
    [cell configWithInfo:info];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BFChatViewController *vc = [[BFChatViewController alloc]init];
    vc.partner_id = [NSString stringWithFormat:@"%@",self.dataArray[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
