//
//  BFLoginController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/30.
//

#import "BFLoginController.h"
#import "MSIMSDK-UIKit.h"
#import <MSIMSDK/MSIMSDK.h>
#import "BFTabBarController.h"
#import "AppDelegate.h"
#import "BFSignInStepOneController.h"
#import "BFRegisterInfo.h"
#import "BFProfileService.h"


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
    self.navView.navTitleL.text = TUILocalizableString(WelcomeBack);
    self.navView.leftButton.hidden = YES;
    
    self.phoneTF = [[UITextField alloc]initWithFrame:CGRectMake(35, StatusBar_Height+NavBar_Height + 80, Screen_Width-70, 50)];
    self.phoneTF.placeholder = TUILocalizableString(You-phone-number);
    self.phoneTF.font = [UIFont systemFontOfSize:15];
    self.phoneTF.textColor = [UIColor d_colorWithColorLight:[UIColor blackColor] dark:[UIColor whiteColor]];
    self.phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneTF.clearButtonMode = UITextFieldViewModeAlways;
    [self.phoneTF becomeFirstResponder];
    [self.view addSubview:self.phoneTF];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(35, self.phoneTF.maxY, Screen_Width-30, 0.5)];
    lineView.backgroundColor = [UIColor d_colorWithColorLight:TCell_separatorColor dark:TCell_separatorColor_Dark];
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
    self.serverL.font = [UIFont systemFontOfSize:15];
    self.serverL.textColor = [UIColor d_colorWithColorLight:[UIColor blackColor] dark:[UIColor whiteColor]];
    self.serverL.frame = CGRectMake(self.serverSwitch.maxX+10, self.serverSwitch.y, self.loginBtn.width, self.serverSwitch.height);
    [self.view addSubview:self.serverL];

    self.serverSwitch.on = ![[NSUserDefaults standardUserDefaults]boolForKey:@"ms_Test"];
    self.serverL.text = [BFProfileService postUrl];
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
        [MSHelper showToastFail:@"请输入正确的手机号"];
        return;
    }
    self.registerInfo.phone = phone;
    //1.获取IM—token
    WS(weakSelf)
    [MSHelper showToast];
    [BFProfileService requestIMToken:phone success:^(NSDictionary * _Nonnull dic) {
        NSString *userToken = dic[@"token"];
        NSString *im_url = dic[@"url"];
        MSLog(@"im token: %@,im_url: %@",userToken,im_url);
        //2.登录
        weakSelf.registerInfo.userToken = userToken;
        weakSelf.registerInfo.imUrl = im_url;
        
        // 配置聊天室
        [MSChatRoomManager.sharedInstance loginChatRoom:kChatRoomID];
        
        //子应用id = 1,用于demo测试，使用方根据需要设置自己的子应用id
        [[MSIMManager sharedInstance] login:userToken imUrl:im_url subAppID:1 succ:^{
                    
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    appDelegate.window.rootViewController = [[BFTabBarController alloc]init];
                    
                } failed:^(NSInteger code, NSString *desc) {
                    [MSHelper showToastFail:desc];
        }];
    } fail:^(NSError * _Nonnull error) {
        [MSHelper dismissToast];
        if (error.code == ERR_USER_NOT_REGISTER) {//未注册，起注册流程
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"手机号未注册，现在注册吗?" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf needToSignIn];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [weakSelf presentViewController:alert animated:YES completion:nil];
        }else {
            [MSHelper showToastFail:error.localizedDescription];
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
    [[NSUserDefaults standardUserDefaults]setBool:!sw.isOn forKey:@"ms_Test"];
    
    self.serverL.text = [BFProfileService postUrl];
    [[MSDBManager sharedInstance] accountChanged];
}

@end
