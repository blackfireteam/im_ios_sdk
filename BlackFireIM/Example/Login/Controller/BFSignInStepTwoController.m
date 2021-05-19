//
//  BFSignInStepTwoController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/12.
//

#import "BFSignInStepTwoController.h"
#import "BFHeader.h"
#import "UIView+Frame.h"
#import "NSBundle+BFKit.h"
#import <TZImagePickerController.h>
#import "BFRegisterInfo.h"
#import <SVProgressHUD.h>
#import "MSIMSDK.h"
#import "MSIMKit.h"
#import "AppDelegate.h"
#import "BFTabBarController.h"


@interface BFSignInStepTwoController()<TZImagePickerControllerDelegate>

@property(nonatomic,strong) UIImageView *avatarIcon;

@property(nonatomic,strong) UIButton *nextBtn;

@end
@implementation BFSignInStepTwoController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *titleL = [[UILabel alloc]initWithFrame:CGRectMake(35, StatusBar_Height+NavBar_Height + 35, Screen_Width-70, 30)];
    titleL.text = @"MY PROFILE IS";
    titleL.font = [UIFont boldSystemFontOfSize:21];
    titleL.textColor = RGB(15, 15, 15);
    [self.view addSubview:titleL];
    
    self.avatarIcon = [[UIImageView alloc]initWithFrame:CGRectMake(Screen_Width*0.5-112, titleL.maxY+40, 224, 218)];
    self.avatarIcon.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarIcon.layer.cornerRadius = 8;
    self.avatarIcon.layer.masksToBounds = YES;
    self.avatarIcon.userInteractionEnabled = YES;
    self.avatarIcon.image = self.info.avatarImage ? self.info.avatarImage : [UIImage imageNamed:@"register_add"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarDidTap)];
    [self.avatarIcon addGestureRecognizer:tap];
    [self.view addSubview:self.avatarIcon];
    
    self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextBtn setTitle:TUILocalizableString(Next-button) forState:UIControlStateNormal];
    [self.nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nextBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    self.nextBtn.backgroundColor = RGBA(45, 45, 45, 1);
    self.nextBtn.layer.cornerRadius = 2;
    self.nextBtn.layer.masksToBounds = YES;
    [self.nextBtn addTarget:self action:@selector(nextBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.nextBtn.frame = CGRectMake(35, self.avatarIcon.maxY+60, Screen_Width-70, 50);
    [self.view addSubview:self.nextBtn];
}

- (void)avatarDidTap
{
    TZImagePickerController *picker = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
    picker.allowPickingImage = YES;
    picker.allowPickingVideo = NO;
    picker.autoDismiss = YES;
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void)nextBtnDidClick
{
    if (!self.info.avatarImage) {
        [SVProgressHUD showInfoWithStatus:@"请上传头像"];
        return;
    }
    [SVProgressHUD show];
    MSIMImageElem *elem = [[MSIMImageElem alloc]init];
    elem.image = self.info.avatarImage;
    [[MSIMManager sharedInstance].uploadMediator ms_uploadWithObject:elem.image fileType:BFIM_MSG_TYPE_IMAGE progress:^(CGFloat progress) {
        
    } succ:^(NSString * _Nonnull url) {
        
        self.info.avatarUrl = url;
        [self reqeustToSignUp];
        
    } fail:^(NSInteger code, NSString * _Nonnull desc) {
        
        [SVProgressHUD showErrorWithStatus:desc];
        
    }];
}

- (void)reqeustToSignUp
{
    WS(weakSelf)
    [[MSIMManager sharedInstance]userSignUp:self.info.phone nickName:self.info.nickName avatar:self.info.avatarUrl succ:^(NSString * _Nonnull userToken) {
        [SVProgressHUD showSuccessWithStatus:@"注册成功"];
        weakSelf.info.userToken = userToken;
        
        [[MSIMManager sharedInstance]login:weakSelf.info.userToken succ:^{
                    
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            appDelegate.window.rootViewController = [[BFTabBarController alloc]init];
                } failed:^(NSInteger code, NSString * _Nonnull desc) {
                    [SVProgressHUD showInfoWithStatus:desc];
        }];
        } failed:^(NSInteger code, NSString * _Nonnull desc) {
            
            [SVProgressHUD showErrorWithStatus:desc];
    }];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    UIImage *image = photos.firstObject;
    self.avatarIcon.image = image;
    self.info.avatarImage = image;
}

@end
