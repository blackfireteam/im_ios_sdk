//
//  BFSignInStepOneController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/12.
//

#import "BFSignInStepOneController.h"
#import "BFHeader.h"
#import "BFRegisterInfo.h"
#import "BFSignInStepTwoController.h"

@interface BFSignInStepOneController()

@property(nonatomic,strong) UITextField *nickNameTF;

@property(nonatomic,strong) UIButton *nextBtn;

@property(nonatomic,strong) UILabel *errL;

@end

@implementation BFSignInStepOneController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *titleL = [[UILabel alloc]initWithFrame:CGRectMake(35, StatusBar_Height+NavBar_Height + 35, Screen_Width-70, 30)];
    titleL.text = @"MY NICKNAME IS";
    titleL.font = [UIFont boldSystemFontOfSize:21];
    titleL.textColor = RGB(15, 15, 15);
    [self.view addSubview:titleL];
    
    self.nickNameTF = [[UITextField alloc]initWithFrame:CGRectMake(35, titleL.maxY+30, Screen_Width-70, 50)];
    self.nickNameTF.placeholder = TUILocalizableString(You-nickname);
    self.nickNameTF.font = [UIFont systemFontOfSize:16];
    self.nickNameTF.textColor = [UIColor blackColor];
    self.nickNameTF.clearButtonMode = UITextFieldViewModeAlways;
    [self.nickNameTF becomeFirstResponder];
    self.nickNameTF.text = self.info.nickName;
    [self.view addSubview:self.nickNameTF];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(35, self.nickNameTF.maxY, Screen_Width-70, 0.5)];
    lineView.backgroundColor = TCell_separatorColor;
    [self.view addSubview:lineView];
    
    self.errL = [[UILabel alloc]initWithFrame:CGRectMake(self.nickNameTF.x, lineView.maxY+8, self.nickNameTF.width, 20)];
    self.errL.font = [UIFont systemFontOfSize:15];
    self.errL.textColor = [UIColor redColor];
    [self.view addSubview:self.errL];
    
    self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextBtn setTitle:TUILocalizableString(Next-button) forState:UIControlStateNormal];
    [self.nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nextBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    self.nextBtn.backgroundColor = RGBA(45, 45, 45, 1);
    self.nextBtn.layer.cornerRadius = 2;
    self.nextBtn.layer.masksToBounds = YES;
    [self.nextBtn addTarget:self action:@selector(nextBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.nextBtn.frame = CGRectMake(35, lineView.maxY+60, Screen_Width-70, 50);
    [self.view addSubview:self.nextBtn];
}

- (void)nextBtnDidClick
{
    [self.view endEditing:YES];
    NSString *nickname = [self.nickNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (nickname.length < 3) {
        self.errL.text = @"Nickname must contain at least 3 characters.";
        return;
    }
    self.info.nickName = nickname;
    BFSignInStepTwoController *vc = [[BFSignInStepTwoController alloc]init];
    vc.info = self.info;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
