//
//  BFProfileViewController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import "BFProfileViewController.h"
#import "BFHeader.h"
#import "MSIMSDK.h"
#import <SVProgressHUD.h>
#import "AppDelegate.h"
#import "BFTabBarController.h"
#import "BFLoginController.h"
#import "BFNavigationController.h"
#import "UIButton+positon.h"
#import "UIView+Frame.h"
#import <SDWebImage.h>


@interface BFProfileViewController ()

@property(nonatomic,strong) UIImageView *avatarIcon;

@property(nonatomic,strong) UILabel *nickNameL;

@end

@implementation BFProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = [NSString stringWithFormat:@"user_%@",[MSIMTools sharedInstance].user_id];
    
    [self setupUI];
    
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    logoutBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    logoutBtn.backgroundColor = [UIColor blueColor];
    [logoutBtn addTarget:self action:@selector(logoutBtnClick) forControlEvents:UIControlEventTouchUpInside];
    logoutBtn.frame = CGRectMake(Screen_Width*0.5-50, Screen_Height-150, 100, 40);
    [self.view addSubview:logoutBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)setupUI
{
    self.avatarIcon = [[UIImageView alloc]init];
    self.avatarIcon.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarIcon.layer.cornerRadius = 57;
    self.avatarIcon.layer.masksToBounds = YES;
    self.avatarIcon.frame = CGRectMake(Screen_Width*0.5-57, StatusBar_Height+30, 114, 114);
    self.avatarIcon.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.avatarIcon];
    
    self.nickNameL = [[UILabel alloc]init];
    self.nickNameL.textColor = [UIColor blackColor];
    self.nickNameL.font = [UIFont boldSystemFontOfSize:20];
    self.nickNameL.textAlignment = NSTextAlignmentCenter;
    self.nickNameL.frame = CGRectMake(Screen_Width*0.5-100, self.avatarIcon.maxY+10, 200, 27);
    [self.view addSubview:self.nickNameL];
    
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoBtn setTitle:@"Photos" forState:UIControlStateNormal];
    [photoBtn setImage:[UIImage imageNamed:@"icon_creama"] forState:UIControlStateNormal];
    [photoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    photoBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    photoBtn.frame = CGRectMake(Screen_Width*0.5-55*0.5, self.nickNameL.maxY+48, 55, 76);
    [photoBtn addTarget:self action:@selector(photoBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photoBtn];
    [photoBtn verticalImageAndTitle:8];
    
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [editBtn setTitle:@"Edit" forState:UIControlStateNormal];
    [editBtn setImage:[UIImage imageNamed:@"icon_edit"] forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    editBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    editBtn.frame = CGRectMake(photoBtn.x-70-55, photoBtn.y-26, 55, 68);
    [editBtn addTarget:self action:@selector(editBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editBtn];
    [editBtn verticalImageAndTitle:8];
    
    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingBtn setTitle:@"Settings" forState:UIControlStateNormal];
    [settingBtn setImage:[UIImage imageNamed:@"icon_edit"] forState:UIControlStateNormal];
    [settingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    settingBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    settingBtn.frame = CGRectMake(photoBtn.maxX+70, editBtn.y, editBtn.width, editBtn.height);
    [settingBtn addTarget:self action:@selector(settingBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingBtn];
    [settingBtn verticalImageAndTitle:8];
}

- (void)reloadData
{
    [[MSProfileProvider provider] providerProfile:[[MSIMTools sharedInstance].user_id integerValue] complete:^(MSProfileInfo * _Nonnull profile) {
        [self.avatarIcon sd_setImageWithURL:[NSURL URLWithString:profile.avatar]];
        self.nickNameL.text = profile.nick_name;
    }];
}

- (void)photoBtnDidClick
{
    
}

- (void)editBtnDidClick
{
    
}

- (void)settingBtnDidClick
{
    
}


- (void)logoutBtnClick
{
    [[MSIMManager sharedInstance]logout:^{
            
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.window.rootViewController = [[BFNavigationController alloc]initWithRootViewController:[BFLoginController new]];
        
        } failed:^(NSInteger code, NSString * _Nonnull desc) {
            [SVProgressHUD showInfoWithStatus:desc];
    }];
}

@end
