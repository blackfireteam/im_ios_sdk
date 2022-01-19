//
//  BFHomeController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/8.
//

#import "BFHomeController.h"
#import "MSIMSDK-UIKit.h"
#import <MSIMSDK/MSIMSDK.h>
#import "BFSparkCardView.h"
#import "BFSparkCardCell.h"
#import "BFChatViewController.h"
#import "BFSparkLoadingView.h"
#import "BFSparkEmptyView.h"
#import "BFAnimationView.h"


@interface BFHomeController()<BFSparkCardViewDelegate,BFSparkCardViewDataSource,BFSparkCardCellDelegate>

@property(nonatomic,strong) BFSparkCardView *containter;

@property(nonatomic,strong) BFSparkLoadingView *loadingView;

@property(nonatomic,strong) BFSparkEmptyView *emptyView;

@property(nonatomic,strong) UIButton *likeBtn;

@property(nonatomic,strong) UIButton *dislikeBtn;

@property(nonatomic,strong) NSMutableArray *dataList;

@end
@implementation BFHomeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadParksData];
    });
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

- (BFSparkLoadingView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[BFSparkLoadingView alloc]init];
    }
    return _loadingView;
}

- (void)setupUI
{
    self.navView.hidden = YES;
//    self.likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.likeBtn setImage:[UIImage imageNamed:@"card_like"] forState:UIControlStateNormal];
//    [self.likeBtn addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
//    self.likeBtn.frame = CGRectMake(Screen_Width*0.5+30, Screen_Height-TabBar_Height-15-60, 60, 60);
//    self.likeBtn.hidden = YES;
//    [self.view addSubview:self.likeBtn];
//
//    self.dislikeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.dislikeBtn setImage:[UIImage imageNamed:@"card_dislike"] forState:UIControlStateNormal];
//    [self.dislikeBtn addTarget:self action:@selector(dislikeAction:) forControlEvents:UIControlEventTouchUpInside];
//    self.dislikeBtn.frame = CGRectMake(Screen_Width*0.5-30-60, Screen_Height-TabBar_Height-15-60, 60, 60);
//    self.dislikeBtn.hidden = YES;
//    [self.view addSubview:self.dislikeBtn];
    
    self.loadingView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
    [self.view addSubview:self.loadingView];
    [self.loadingView beginAnimating];
    
    CGFloat maxH = Screen_Height-StatusBar_Height-10-TabBar_Height-10;
    CGFloat cardW = Screen_Width-30;
    CGFloat cardH = MIN(cardW/0.6, maxH);
    self.containter = [[BFSparkCardView alloc]initWithFrame:CGRectMake(15, StatusBar_Height + 10 + (maxH-cardH)*0.5, cardW, cardH)];
    self.containter.delegate = self;
    self.containter.dataSource = self;
    self.containter.visibleCount = 3;
    self.containter.lineSpacing = 10;
    self.containter.interitemSpacing = 10;
    self.containter.maxAngle = 15;
    self.containter.maxRemoveDistance = 100;
    [self.containter registerClass:[BFSparkCardCell class] forCellReuseIdentifier:@"cardCell"];
    [self.view addSubview:self.containter];
    
    self.emptyView = [[BFSparkEmptyView alloc]initWithFrame:CGRectMake(0, Screen_Height*0.35, Screen_Width, 235)];
    self.emptyView.hidden = YES;
    [self.emptyView.retryBtn addTarget:self action:@selector(retryButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.emptyView];
    
    self.dataList = [NSMutableArray array];
}

- (void)loadParksData
{
    [[MSIMManager sharedInstance] getSparks:^(NSArray<MSProfileInfo *> * sparks) {
        [self.dataList removeAllObjects];
        [self.dataList addObjectsFromArray:sparks];
        [self bf_reloadData];
        } fail:^(NSInteger code, NSString * _Nonnull desc) {
            [MSHelper showToastFail:desc];
            [self.loadingView stopAnimating];
            self.emptyView.hidden = NO;
    }];
}

- (void)bf_reloadData
{
    self.containter.alpha = 0;
    self.likeBtn.alpha = 0;
    self.dislikeBtn.alpha = 0;
    self.emptyView.hidden = YES;
    [UIView animateWithDuration:0.5 animations:^{
        self.containter.alpha = 1;
        self.likeBtn.alpha = 1;
        self.dislikeBtn.alpha = 1;
        
    } completion:^(BOOL finished) {
        [self.loadingView stopAnimating];
        self.emptyView.hidden = self.dataList.count != 0;
    }];
    [self.containter reloadData];
}

- (void)retryButtonClick
{
    [self loadParksData];
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
    self.emptyView.hidden = NO;
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
    if (cell.user.user_id && cell.winkBtn.isSelected == NO) {
        MSIMEmotionElem *elem = [[MSIMEmotionElem alloc]init];
        elem.emotionID = @"001";
        elem.emotionName = @"emotion_01";
        elem = [[MSIMManager sharedInstance]createEmotionMessage:elem];
        [[MSIMManager sharedInstance]sendC2CMessage:elem toReciever:cell.user.user_id successed:^(NSInteger msg_id) {
                    
             cell.winkBtn.selected = YES;
            [BFAnimationView showAnimation:@"spark_like" size:CGSizeMake(200, 200) isLoop:NO];
            
            } failed:^(NSInteger code, NSString * _Nonnull desc) {
                [MSHelper showToastFail:desc];
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
