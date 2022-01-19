//
//  BFProfileViewController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import "BFProfileViewController.h"
#import "MSIMSDK-UIKit.h"
#import <MSIMSDK/MSIMSDK.h>
#import <SDWebImage.h>
#import "BFProfileEditController.h"
#import "BFProfileButton.h"
#import "BFProfileRowView.h"
#import "BFLikeListController.h"

@interface BFProfileViewController ()

@property(nonatomic,strong) UIScrollView *myScrollView;

@property(nonatomic,strong) UIImageView *avatarIcon;

@property(nonatomic,strong) UILabel *nickNameL;

@property(nonatomic,strong) UIButton *editBtn;

@property(nonatomic,strong) BFProfileButton *toLikeBtn;

@property(nonatomic,strong) BFProfileButton *likeToBtn;

@property(nonatomic,strong) BFProfileButton *previewBtn;

@end

@implementation BFProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navView.hidden = YES;
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)setupUI
{
    self.myScrollView  =  [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    self.myScrollView.showsVerticalScrollIndicator = NO;
    self.myScrollView.showsHorizontalScrollIndicator = NO;
    self.myScrollView.alwaysBounceVertical = YES;
    self.myScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.myScrollView.contentSize = CGSizeMake(Screen_Width, Screen_Height);
    [self.view addSubview:self.myScrollView];
    
    self.avatarIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, NavBar_Height + StatusBar_Height, 60, 60)];
    self.avatarIcon.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarIcon.layer.cornerRadius = 30;
    self.avatarIcon.layer.masksToBounds = YES;
    self.avatarIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarIcon.layer.borderWidth = 2;
    [self.myScrollView addSubview:self.avatarIcon];
    
    self.nickNameL = [[UILabel alloc]initWithFrame:CGRectMake(self.avatarIcon.maxX + 15, self.avatarIcon.centerY - 15, 200, 30)];
    self.nickNameL.font = [UIFont boldSystemFontOfSize:18];
    self.nickNameL.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
    [self.myScrollView addSubview:self.nickNameL];
    
    self.editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.editBtn setTitle:@"查看/编辑" forState:UIControlStateNormal];
    [self.editBtn setTitleColor:[UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark] forState:UIControlStateNormal];
    self.editBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    self.editBtn.layer.borderColor = TLine_Color.CGColor;
    self.editBtn.layer.borderWidth = 0.5;
    self.editBtn.layer.cornerRadius = 12.5;
    self.editBtn.layer.masksToBounds = YES;
    [self.editBtn addTarget:self action:@selector(editBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.editBtn.frame  = CGRectMake(Screen_Width - 15 - 75, self.nickNameL.centerY - 12.5, 75, 25);
    [self.myScrollView addSubview:self.editBtn];
    
    self.likeToBtn = [[BFProfileButton alloc]initWithFrame:CGRectMake(20, self.avatarIcon.maxY + 40, 80, 45)];
    [self.likeToBtn addTarget:self action:@selector(likeToBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.likeToBtn updateNum:0 title:@"我喜欢的"];
    [self.myScrollView addSubview:self.likeToBtn];
    
    self.toLikeBtn = [[BFProfileButton alloc]initWithFrame:CGRectMake(Screen_Width * 0.5 - self.likeToBtn.width * 0.5, self.likeToBtn.y, self.likeToBtn.width, self.likeToBtn.height)];
    [self.toLikeBtn addTarget:self action:@selector(toLikeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.toLikeBtn updateNum:0 title:@"喜欢我的"];
    [self.myScrollView addSubview:self.toLikeBtn];
    
    self.previewBtn = [[BFProfileButton alloc]initWithFrame:CGRectMake(Screen_Width - 20 - self.likeToBtn.width, self.likeToBtn.y, self.likeToBtn.width, self.likeToBtn.height)];
    [self.previewBtn addTarget:self action:@selector(previewBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.previewBtn updateNum:0 title:@"最近来访"];
    [self.myScrollView addSubview:self.previewBtn];
    
    BFProfileRowView *rowView = [[BFProfileRowView alloc]initWithFrame:CGRectMake(15, self.likeToBtn.maxY + 25, Screen_Width - 30, 180)];
    [self.myScrollView addSubview:rowView];
}

- (void)reloadData
{
    [[MSProfileProvider provider] providerProfile:[MSIMTools sharedInstance].user_id complete:^(MSProfileInfo * _Nonnull profile) {
        [self.avatarIcon sd_setImageWithURL:[NSURL URLWithString:profile.avatar]];
        self.nickNameL.text = profile.nick_name;
    }];
}

- (void)editBtnDidClick
{
    BFProfileEditController *vc = [[BFProfileEditController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)likeToBtnClick
{
    BFLikeListController *vc = [[BFLikeListController alloc]init];
    vc.type = 0;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)toLikeBtnClick
{
    BFLikeListController *vc = [[BFLikeListController alloc]init];
    vc.type = 1;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)previewBtnClick
{
    BFLikeListController *vc = [[BFLikeListController alloc]init];
    vc.type = 2;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
