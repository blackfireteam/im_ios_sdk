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


@interface BFDiscoveryController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong) NSMutableArray<MSProfileInfo *> *dataArray;

@property(nonatomic,strong) UICollectionView *myCollectionView;

@end

@implementation BFDiscoveryController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"DISCOVERY";
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
    [self.myCollectionView reloadData];
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
    [self.myCollectionView reloadData];
}

- (void)setupUI
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake((Screen_Width-15*3)*0.5, (Screen_Width-15*3)*0.5*1.3);
    layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    layout.minimumLineSpacing = 15;
    layout.minimumInteritemSpacing = 15;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.myCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height) collectionViewLayout:layout];
    self.myCollectionView.delegate = self;
    self.myCollectionView.dataSource = self;
    self.myCollectionView.alwaysBounceVertical = YES;
    self.myCollectionView.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
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
    [cell configWithInfo:self.dataArray[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BFChatViewController *vc = [[BFChatViewController alloc]init];
    vc.partner_id = self.dataArray[indexPath.row].user_id;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
