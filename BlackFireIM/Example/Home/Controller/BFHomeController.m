//
//  BFHomeController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/8.
//

#import "BFHomeController.h"
#import "BFHeader.h"
#import "UIView+Frame.h"
#import "MSIMSDK.h"
#import <SVProgressHUD.h>
#import <Lottie/Lottie.h>
#import "BFSparkCardView.h"
#import "BFSparkCardCell.h"
#import "BFChatViewController.h"
#import "MSIMSDK.h"

@interface BFHomeController()<BFSparkCardViewDelegate,BFSparkCardViewDataSource,BFSparkCardCellDelegate>

@property(nonatomic,strong) BFSparkCardView *containter;

@property(nonatomic,strong) LOTAnimationView *loadingView;

@property(nonatomic,strong) UIButton *likeBtn;

@property(nonatomic,strong) UIButton *dislikeBtn;

@property(nonatomic,strong) NSMutableArray *dataList;

@end
@implementation BFHomeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
}

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNetworkChanged:) name:MSUIKitNotification_ConnListener object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (LOTAnimationView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [LOTAnimationView animationNamed:@"spark_loading"];
        _loadingView.loopAnimation = YES;
    }
    return _loadingView;
}

- (void)setupUI
{
    self.likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.likeBtn setImage:[UIImage imageNamed:@"card_like"] forState:UIControlStateNormal];
    [self.likeBtn addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
    self.likeBtn.frame = CGRectMake(Screen_Width*0.5+30, Screen_Height-TabBar_Height-15-60, 60, 60);
    self.likeBtn.hidden = YES;
    [self.view addSubview:self.likeBtn];
    
    self.dislikeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dislikeBtn setImage:[UIImage imageNamed:@"card_dislike"] forState:UIControlStateNormal];
    [self.dislikeBtn addTarget:self action:@selector(dislikeAction:) forControlEvents:UIControlEventTouchUpInside];
    self.dislikeBtn.frame = CGRectMake(Screen_Width*0.5-30-60, Screen_Height-TabBar_Height-15-60, 60, 60);
    self.dislikeBtn.hidden = YES;
    [self.view addSubview:self.dislikeBtn];
    
    CGFloat cardW = Screen_Width-30;
    CGFloat cardH = cardW/0.6;
    self.containter = [[BFSparkCardView alloc]initWithFrame:CGRectMake(15, StatusBar_Height + 10, cardW, cardH)];
    self.containter.delegate = self;
    self.containter.dataSource = self;
    self.containter.visibleCount = 3;
    self.containter.lineSpacing = 10;
    self.containter.interitemSpacing = 10;
    self.containter.maxAngle = 15;
    self.containter.maxRemoveDistance = 100;
    [self.containter registerClass:[BFSparkCardCell class] forCellReuseIdentifier:@"cardCell"];
    [self.view addSubview:self.containter];
    
    self.loadingView.frame = self.containter.frame;
    [self.view addSubview:self.loadingView];
    [self.loadingView play];
    
    self.dataList = [NSMutableArray array];
}

- (void)loadParksData
{
    [[MSIMManager sharedInstance] getSparks:^(NSArray<MSProfileInfo *> * sparks) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.dataList addObjectsFromArray:sparks];
            [self.containter reloadData];
            [self.loadingView stop];
            self.loadingView.hidden = YES;
            self.likeBtn.hidden = NO;
            self.dislikeBtn.hidden = NO;
        });
        } fail:^(NSInteger code, NSString * _Nonnull desc) {
            [SVProgressHUD showInfoWithStatus:desc];
    }];
}

- (void)onNetworkChanged:(NSNotification *)notification
{
    BFIMNetStatus status = [notification.object intValue];
    switch (status) {
        case IMNET_STATUS_SUCC:
        {
            if (self.dataList.count == 0) {
                [self loadParksData];
            }
        }
            break;
        case IMNET_STATUS_CONNECTING:
            
            break;
        case IMNET_STATUS_DISCONNECT:
            
            break;
        case IMNET_STATUS_CONNFAILED:
            
            break;
        default:
            break;
    }
}

#pragma mark -- BFSparkCardViewDelegate,BFSparkCardViewDataSource
- (NSInteger)numberOfCountInCardView:(BFSparkCardView *)cardView
{
    return self.dataList.count;
}

- (BFCardViewCell *)cardView:(BFSparkCardView *)cardView cellForRowAtIndex:(NSInteger)index
{
    BFSparkCardCell *cell = [cardView dequeueReusableCellWithIdentifier:@"cardCell"];
    [cell configItem:self.dataList[index]];
    cell.delegate = self;
    return cell;
}

- (void)cardView:(BFSparkCardView *)cardView didRemoveCell:(BFSparkCardCell *)cell forRowAtIndex:(NSInteger)index direction:(CardCellSwipeDirection)direction
{
    cell.like.alpha = 0;
    cell.dislike.alpha = 0;
}

- (void)cardView:(BFSparkCardView *)cardView didRemoveLastCell:(BFSparkCardCell *)cell forRowAtIndex:(NSInteger)index
{
    
}

- (void)cardView:(BFSparkCardView *)cardView didDisplayCell:(BFSparkCardCell *)cell forRowAtIndex:(NSInteger)index
{
    
}

- (void)cardView:(BFSparkCardView *)cardView didMoveCell:(BFSparkCardCell *)cell forMovePoint:(CGPoint)point direction:(CardCellSwipeDirection)direction
{
    if (direction == CardCellSwipeDirectionLeft) {
        cell.like.alpha = 0.0f;
        cell.dislike.alpha = 1.0f;
        cell.dislike.transform = CGAffineTransformMakeRotation(45*M_PI / 180.0);
    }else if (direction == CardCellSwipeDirectionRight) {
        cell.dislike.alpha = 0.0f;
        cell.like.alpha = 1.0f;
        cell.like.transform = CGAffineTransformMakeRotation(-45*M_PI / 180.0);
    }else {
        cell.like.alpha = 0.0f;
        cell.dislike.alpha = 0.0f;
    }
}


#pragma mark - Action Methods
- (void)dislikeAction:(UIButton *)sender
{
    [self.containter removeTopCardViewFromSwipe:CardCellSwipeDirectionLeft];
}

- (void)likeAction:(UIButton *)sender
{
    [self.containter removeTopCardViewFromSwipe:CardCellSwipeDirectionRight];
}

- (void)winkBtnDidClick:(BFSparkCardCell *)cell
{
    if (cell.user.user_id) {
        NSString *text = @"wink";
        MSIMCustomElem *customElem = [[MSIMManager sharedInstance]createCustomMessage:[text dataUsingEncoding:NSUTF8StringEncoding]];
        [[MSIMManager sharedInstance]sendC2CMessage:customElem toReciever:cell.user.user_id successed:^(NSInteger msg_id) {
                    
                } failed:^(NSInteger code, NSString * _Nonnull desc) {
                    
        }];
    }
}

- (void)chatBtnDidClick:(BFSparkCardCell *)cell
{
    if (cell.user.user_id) {
        BFChatViewController *vc = [[BFChatViewController alloc]init];
        vc.partner_id = cell.user.user_id;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
