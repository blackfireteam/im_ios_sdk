//
//  BFSignInStepTwoController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/12.
//

#import "BFSignInStepTwoController.h"
#import "MSIMSDK-UIKit.h"
#import "BFRegisterInfo.h"
#import "AppDelegate.h"
#import "BFTabBarController.h"
#import "BFProfileService.h"
#import <TZImagePickerController.h>



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
    titleL.textColor = [UIColor d_colorWithColorLight:[UIColor blackColor] dark:[UIColor whiteColor]];
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
    picker.allowPickingVideo = NO;
    picker.allowPickingImage = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)nextBtnDidClick
{
    [MSHelper showToast];
    //先给个默认的头像，注册成功后再上传头像
    self.info.avatarUrl = @"https://msim-test-1252460681.cos.na-siliconvalley.myqcloud.com/pers/612FA7A3-144E-4978-A75C-9D9277167292.jpeg";
    [self reqeustToSignUp];
}

- (void)reqeustToSignUp
{
    WS(weakSelf)
    [BFProfileService userSignUp:self.info succ:^{
        [BFProfileService requestIMToken:weakSelf.info.phone success:^(NSDictionary * _Nonnull dic) {
            
            NSString *userToken = dic[@"token"];
            NSString *im_url = dic[@"url"];
            weakSelf.info.userToken = userToken;
            weakSelf.info.imUrl = im_url;
            // 配置聊天室
            [MSChatRoomManager.sharedInstance loginChatRoom:kChatRoomID];
            [[MSIMManager sharedInstance] login:weakSelf.info.userToken imUrl:weakSelf.info.imUrl subAppID:1 succ:^{
                            
                STRONG_SELF(strongSelf)
                            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                            appDelegate.window.rootViewController = [[BFTabBarController alloc]init];
                            
                            [strongSelf uploadAvatar];
                        } failed:^(NSInteger code, NSString *desc) {
                            [MSHelper showToastFail:desc];
            }];
            
        } fail:^(NSError * _Nonnull error) {
            [MSHelper showToastFail:error.localizedDescription];
        }];
    } failed:^(NSError * _Nonnull error) {
        [MSHelper showToastFail:error.localizedDescription];
    }];
}

- (void)uploadAvatar
{
    if (self.info.avatarImage == nil) return;
    MSIMImageElem *elem = [[MSIMImageElem alloc]init];
    elem.image = self.info.avatarImage;
    [[MSIMManager sharedInstance].uploadMediator ms_uploadWithObject:elem.image fileType:MSUploadFileTypeAvatar progress:^(CGFloat progress) {

    } succ:^(NSString * _Nonnull url) {

        MSProfileInfo *info = [[MSProfileProvider provider]providerProfileFromLocal:[MSIMTools sharedInstance].user_id];
        info.avatar = url;
        NSMutableDictionary *dic = [info.custom el_convertToDictionary].mutableCopy;
        dic[@"pic"] = url;
        info.custom = [dic el_convertJsonString];
        [BFProfileService requestToEditProfile:info success:^(NSDictionary * _Nonnull dic) {
            
            [[MSProfileProvider provider]updateProfiles:@[info]];
            
        } fail:^(NSError * _Nonnull error) {
            
        }];

    } fail:^(NSInteger code, NSString * _Nonnull desc) {

    }];
}

#pragma mark - TZImagePickerControllerDelegate

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos
{
    self.avatarIcon.image = photos.firstObject;
    self.info.avatarImage = photos.firstObject;
}

@end
