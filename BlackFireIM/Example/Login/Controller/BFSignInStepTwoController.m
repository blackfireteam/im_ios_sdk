//
//  BFSignInStepTwoController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/12.
//

#import "BFSignInStepTwoController.h"
#import "MSHeader.h"
#import "BFRegisterInfo.h"
#import "MSIMKit.h"
#import "AppDelegate.h"
#import "BFTabBarController.h"
#import "BFProfileService.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface BFSignInStepTwoController()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

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
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [NSArray arrayWithObjects: @"public.image", nil];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)nextBtnDidClick
{
    if (!self.info.avatarImage) {
        [MSHelper showToastString:@"请上传头像"];
        return;
    }
    [MSHelper showToast];
    MSIMImageElem *elem = [[MSIMImageElem alloc]init];
    elem.image = self.info.avatarImage;
    [[MSIMManager sharedInstance].uploadMediator ms_uploadWithObject:elem.image fileType:MSIM_MSG_TYPE_IMAGE progress:^(CGFloat progress) {
        
    } succ:^(NSString * _Nonnull url) {
        
        self.info.avatarUrl = url;
        [self reqeustToSignUp];
        
    } fail:^(NSInteger code, NSString * _Nonnull desc) {
        
        [MSHelper showToastFail:desc];
        
    }];
}

- (void)reqeustToSignUp
{
    WS(weakSelf)
    [BFProfileService userSignUp:self.info.phone nickName:self.info.nickName avatar:self.info.avatarUrl succ:^() {
        
        [[MSIMManager sharedInstance]getIMToken:weakSelf.info.phone succ:^(NSString * _Nonnull userToken) {
            //2.登录
            weakSelf.info.userToken = userToken;
            MSLog(@"获取userToKen = %@",userToken);
            [[MSIMManager sharedInstance]login:userToken succ:^{
                        
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                appDelegate.window.rootViewController = [[BFTabBarController alloc]init];
                    } failed:^(NSInteger code, NSString * _Nonnull desc) {
                        [MSHelper showToastFail:desc];
            }];
        } failed:^(NSInteger code, NSString * _Nonnull desc) {
            [MSHelper showToastFail:desc];
        }];
    } failed:^(NSError * _Nonnull error) {
        [MSHelper showToastFail:error.localizedDescription];
    }];
}

#pragma mark -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    picker.delegate = nil;
    WS(weakSelf)
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString *mediaType = info[UIImagePickerControllerMediaType];
        
        if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            UIImageOrientation imageOrientation = image.imageOrientation;
            if(imageOrientation != UIImageOrientationUp) {
                CGFloat aspectRatio = MIN ( 1920 / image.size.width, 1920 / image.size.height);
                CGFloat aspectWidth = image.size.width * aspectRatio;
                CGFloat aspectHeight = image.size.height * aspectRatio;

                UIGraphicsBeginImageContext(CGSizeMake(aspectWidth, aspectHeight));
                [image drawInRect:CGRectMake(0, 0, aspectWidth, aspectHeight)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            weakSelf.avatarIcon.image = image;
            weakSelf.info.avatarImage = image;
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
