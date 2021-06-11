//
//  BFLoginController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/30.
//

#import "BFLoginController.h"
#import "MSHeader.h"
#import "MSIMSDK.h"
#import "BFTabBarController.h"
#import "AppDelegate.h"
#import "MSIMKit.h"
#import "BFSignInStepOneController.h"
#import "BFRegisterInfo.h"

@interface BFLoginController ()

@property(nonatomic,strong) UITextField *phoneTF;

@property(nonatomic,strong) UIButton *loginBtn;

@property(nonatomic,strong) BFRegisterInfo *registerInfo;

@property(nonatomic,strong) UISwitch *serverSwitch;

@property(nonatomic,strong) UILabel *serverL;
@end

@implementation BFLoginController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = TUILocalizableString(WelcomeBack);
    
    self.phoneTF = [[UITextField alloc]initWithFrame:CGRectMake(35, StatusBar_Height+NavBar_Height + 80, Screen_Width-70, 50)];
    self.phoneTF.placeholder = TUILocalizableString(You-phone-number);
    self.phoneTF.font = [UIFont systemFontOfSize:16];
    self.phoneTF.textColor = [UIColor blackColor];
    self.phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneTF.clearButtonMode = UITextFieldViewModeAlways;
    [self.phoneTF becomeFirstResponder];
    [self.view addSubview:self.phoneTF];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(35, self.phoneTF.maxY, Screen_Width-30, 0.5)];
    lineView.backgroundColor = TCell_separatorColor;
    [self.view addSubview:lineView];
    
    self.loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginBtn setTitle:TUILocalizableString(LOGIN) forState:UIControlStateNormal];
    [self.loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loginBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    self.loginBtn.backgroundColor = RGBA(45, 45, 45, 1);
    self.loginBtn.layer.cornerRadius = 2;
    self.loginBtn.layer.masksToBounds = YES;
    [self.loginBtn addTarget:self action:@selector(loginBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.loginBtn.frame = CGRectMake(35, lineView.maxY+60, Screen_Width-70, 50);
    [self.view addSubview:self.loginBtn];
    
    self.serverSwitch = [[UISwitch alloc]init];
    self.serverSwitch.frame = CGRectMake(self.loginBtn.x, self.loginBtn.maxY+30, 60, 30);
    [self.serverSwitch addTarget:self action:@selector(serverSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.serverSwitch];
    
    self.serverL = [[UILabel alloc]init];
    self.serverL.font = [UIFont systemFontOfSize:16];
    self.serverL.textColor = [UIColor blackColor];
    self.serverL.text = @"正式环境";
    self.serverL.frame = CGRectMake(self.serverSwitch.maxX+10, self.serverSwitch.y, 100, self.serverSwitch.height);
    [self.view addSubview:self.serverL];
    
    self.serverSwitch.on = (MSIMTools.sharedInstance.serverType == MSIMServerTypeProduct);
    self.serverL.text = self.serverSwitch.isOn ? @"正式环境" : @"测试环境";
}

- (BFRegisterInfo *)registerInfo
{
    if (!_registerInfo) {
        _registerInfo = [[BFRegisterInfo alloc]init];
    }
    return _registerInfo;
}

- (void)loginBtnDidClick
{
    [self.view endEditing:YES];
    NSString *phone = [self.phoneTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (phone.length <= 0) {
        [MSHelper showToastFail:@"输入内容不能为空"];
        return;
    }
    self.registerInfo.phone = phone;
    //1.获取IM—token
    WS(weakSelf)
    if ([MSIMManager sharedInstance].connStatus != IMNET_STATUS_SUCC) {
        [MSHelper showToastFail:@"正在建立TCP连接"];
        [[MSIMManager sharedInstance].socket disConnectTCP];
        return;
    }
    [MSHelper showToast];
    [[MSIMManager sharedInstance]getIMToken:phone succ:^(NSString * _Nonnull userToken) {
        [MSHelper dismissToast];
        //2.登录
        weakSelf.registerInfo.userToken = userToken;
        [[MSIMManager sharedInstance]login:userToken succ:^{

            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            appDelegate.window.rootViewController = [[BFTabBarController alloc]init];
                } failed:^(NSInteger code, NSString * _Nonnull desc) {
                    [MSHelper showToastFail:desc];
        }];
    } failed:^(NSInteger code, NSString * _Nonnull desc) {
        [MSHelper dismissToast];
        if (code == 9) {//未注册，起注册流程
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"手机号未注册，现在注册吗?" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf needToSignIn];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [weakSelf presentViewController:alert animated:YES completion:nil];
        }else {
            [MSHelper showToastFail:desc];
        }
    }];
}

- (void)needToSignIn
{
    BFSignInStepOneController *vc = [[BFSignInStepOneController alloc]init];
    vc.info = self.registerInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)serverSwitchChanged:(UISwitch *)sw
{
    NSLog(@"switch: %d",sw.isOn);
    self.serverL.text = sw.isOn ? @"正式环境" : @"测试环境";
    MSIMTools.sharedInstance.serverType = sw.isOn ? MSIMServerTypeProduct : MSIMServerTypeTest;
    [[MSDBManager sharedInstance] accountChanged];
    [[MSIMManager sharedInstance].socket disConnectTCP];
}

@end
