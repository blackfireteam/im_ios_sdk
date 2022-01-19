//
//  BFSignInStepOneController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/12.
//

#import "BFSignInStepOneController.h"
#import "MSIMSDK-UIKit.h"
#import "BFRegisterInfo.h"
#import "BFSignInStepTwoController.h"
#import "BFSelectorView.h"


@interface BFSignInStepOneController()

@property(nonatomic,strong) UITextField *nickNameTF;

@property(nonatomic,strong) UILabel *departL;

@property(nonatomic,strong) UILabel *addressL;

@property(nonatomic,strong) UITextField *inviteTF;

@property(nonatomic,strong) UIButton *nextBtn;

@property(nonatomic,strong) UIButton *maleBtn;

@property(nonatomic,strong) UIButton *femaleBtn;

@end

@implementation BFSignInStepOneController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *titleL = [[UILabel alloc]initWithFrame:CGRectMake(35, StatusBar_Height+NavBar_Height + 35, Screen_Width-70, 30)];
    titleL.text = @"MY NICKNAME IS";
    titleL.font = [UIFont boldSystemFontOfSize:21];
    titleL.textColor = [UIColor d_colorWithColorLight:[UIColor blackColor] dark:[UIColor whiteColor]];
    [self.view addSubview:titleL];
    
    self.nickNameTF = [[UITextField alloc]initWithFrame:CGRectMake(35, titleL.maxY+30, Screen_Width-70, 50)];
    self.nickNameTF.placeholder = TUILocalizableString(You-englishname);
    self.nickNameTF.font = [UIFont systemFontOfSize:15];
    self.nickNameTF.textColor = [UIColor d_colorWithColorLight:[UIColor blackColor] dark:[UIColor whiteColor]];
    self.nickNameTF.clearButtonMode = UITextFieldViewModeAlways;
    [self.nickNameTF becomeFirstResponder];
    self.nickNameTF.text = self.info.nickName;
    [self.view addSubview:self.nickNameTF];
    
    UIView *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(35, self.nickNameTF.maxY, Screen_Width-70, 0.5)];
    lineView1.backgroundColor = [UIColor d_colorWithColorLight:TCell_separatorColor dark:TCell_separatorColor_Dark];
    [self.view addSubview:lineView1];
    
    self.departL = [[UILabel alloc]initWithFrame:CGRectMake(self.nickNameTF.x, lineView1.maxY+15, self.nickNameTF.width, self.nickNameTF.height)];
    self.departL.font = [UIFont systemFontOfSize:15];
    if (self.info.department) {
        self.departL.text = self.info.department;
        self.departL.textColor = [UIColor d_colorWithColorLight:[UIColor blackColor] dark:[UIColor whiteColor]];
    }else {
        self.departL.text = TUILocalizableString(You-depart);
        self.departL.textColor = [UIColor lightGrayColor];
    }
    self.departL.userInteractionEnabled = YES;
    [self.view addSubview:self.departL];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(departmentDidClick)];
    [self.departL addGestureRecognizer:tap];
    
    UIView *lineView2 = [[UIView alloc]initWithFrame:CGRectMake(self.nickNameTF.x, self.departL.maxY, self.nickNameTF.width, 0.5)];
    lineView2.backgroundColor = [UIColor d_colorWithColorLight:TCell_separatorColor dark:TCell_separatorColor_Dark];
    [self.view addSubview:lineView2];

    self.addressL = [[UILabel alloc]initWithFrame:CGRectMake(self.nickNameTF.x, lineView2.maxY+15, self.nickNameTF.width, self.nickNameTF.height)];
    self.addressL.font = [UIFont systemFontOfSize:15];
    if (self.info.workPlace) {
        self.addressL.text = self.info.workPlace;
        self.addressL.textColor = [UIColor d_colorWithColorLight:[UIColor blackColor] dark:[UIColor whiteColor]];
    }else {
        self.addressL.text = TUILocalizableString(You-location);
        self.addressL.textColor = [UIColor lightGrayColor];
    }
    self.addressL.userInteractionEnabled = YES;
    [self.view addSubview:self.addressL];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(workPlaceDidClick)];
    [self.addressL addGestureRecognizer:tap1];
    
    UIView *lineView3 = [[UIView alloc]initWithFrame:CGRectMake(self.nickNameTF.x, self.addressL.maxY, self.nickNameTF.width, 0.5)];
    lineView3.backgroundColor = [UIColor d_colorWithColorLight:TCell_separatorColor dark:TCell_separatorColor_Dark];
    [self.view addSubview:lineView3];
    
    self.inviteTF = [[UITextField alloc]initWithFrame:CGRectMake(self.nickNameTF.x, lineView3.maxY + 15, self.nickNameTF.width, self.nickNameTF.height)];
    self.inviteTF.placeholder = TUILocalizableString(You-invite-code);
    self.inviteTF.font = [UIFont systemFontOfSize:15];
    self.inviteTF.textColor = [UIColor d_colorWithColorLight:[UIColor blackColor] dark:[UIColor whiteColor]];
    self.inviteTF.clearButtonMode = UITextFieldViewModeAlways;
    self.inviteTF.text = self.info.inviteCode;
    [self.view addSubview:self.inviteTF];
    
    UIView *lineView4 = [[UIView alloc]initWithFrame:CGRectMake(self.nickNameTF.x, self.inviteTF.maxY, self.nickNameTF.width, 0.5)];
    lineView4.backgroundColor = [UIColor d_colorWithColorLight:TCell_separatorColor dark:TCell_separatorColor_Dark];
    [self.view addSubview:lineView4];
    
    self.maleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.maleBtn setTitle:@"Male" forState:UIControlStateNormal];
    self.maleBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.maleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.maleBtn setBackgroundImage:[UIImage bf_imageWithColor:UIColor.lightGrayColor] forState:UIControlStateNormal];
    [self.maleBtn setBackgroundImage:[UIImage bf_imageWithColor:UIColor.systemBlueColor] forState:UIControlStateSelected];
    self.maleBtn.layer.cornerRadius = 5;
    self.maleBtn.layer.masksToBounds = YES;
    self.maleBtn.frame = CGRectMake(self.nickNameTF.x, lineView4.maxY + 15, 70, 40);
    [self.maleBtn addTarget:self action:@selector(maleBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.maleBtn];
    self.maleBtn.selected = YES;
    
    self.femaleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.femaleBtn setTitle:@"Female" forState:UIControlStateNormal];
    self.femaleBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.femaleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.femaleBtn setBackgroundImage:[UIImage bf_imageWithColor:UIColor.lightGrayColor] forState:UIControlStateNormal];
    [self.femaleBtn setBackgroundImage:[UIImage bf_imageWithColor:UIColor.systemPinkColor] forState:UIControlStateSelected];
    self.femaleBtn.layer.cornerRadius = 5;
    self.femaleBtn.layer.masksToBounds = YES;
    self.femaleBtn.frame = CGRectMake(self.maleBtn.maxX + 20, self.maleBtn.y, 70, 40);
    [self.femaleBtn addTarget:self action:@selector(femaleBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.femaleBtn];
    
    self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextBtn setTitle:TUILocalizableString(Next-button) forState:UIControlStateNormal];
    [self.nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nextBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    self.nextBtn.backgroundColor = RGBA(45, 45, 45, 1);
    self.nextBtn.layer.cornerRadius = 2;
    self.nextBtn.layer.masksToBounds = YES;
    [self.nextBtn addTarget:self action:@selector(nextBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.nextBtn.frame = CGRectMake(35, self.maleBtn.maxY+40, Screen_Width-70, 50);
    [self.view addSubview:self.nextBtn];
}

- (void)nextBtnDidClick
{
    [self.view endEditing:YES];
    NSString *nickname = [self.nickNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (nickname.length < 3) {
        [MSHelper showToastString:@"english name must contain at least 3 characters."];
        return;
    }
    if (self.info.department.length == 0) {
        [MSHelper showToastString:@"Department is nil."];
        return;
    }
    if (self.info.workPlace.length == 0) {
        [MSHelper showToastString:@"Workplace is nil."];
        return;
    }
    NSString *inviteCode = [self.inviteTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (inviteCode == nil || ![[inviteCode uppercaseString] isEqualToString:kAppInviteCode]) {
        [MSHelper showToastString:@"invite code is error."];
        return;
    }
    self.info.nickName = nickname;
    self.info.inviteCode = [inviteCode uppercaseString];
    BFSignInStepTwoController *vc = [[BFSignInStepTwoController alloc]init];
    vc.info = self.info;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)maleBtnDidClick
{
    self.maleBtn.selected = YES;
    self.femaleBtn.selected = NO;
    self.info.gender = 1;
}

- (void)femaleBtnDidClick
{
    self.femaleBtn.selected = YES;
    self.maleBtn.selected = NO;
    self.info.gender = 2;
}

- (void)departmentDidClick
{
    WS(weakSelf)
    [BFSelectorView showSelectView:0 submitAction:^(NSString * _Nonnull text) {
        weakSelf.info.department = text;
        weakSelf.departL.text = text;
        weakSelf.departL.textColor = [UIColor d_colorWithColorLight:[UIColor blackColor] dark:[UIColor whiteColor]];
    } cancel:^{
        
    }];
}

- (void)workPlaceDidClick
{
    WS(weakSelf)
    [BFSelectorView showSelectView:1 submitAction:^(NSString * _Nonnull text) {
        weakSelf.info.workPlace = text;
        weakSelf.addressL.text = text;
        weakSelf.addressL.textColor = [UIColor d_colorWithColorLight:[UIColor blackColor] dark:[UIColor whiteColor]];
    } cancel:^{
        
    }];
}

#pragma mark -- UIPickerViewDataSource<NSObject>



@end
