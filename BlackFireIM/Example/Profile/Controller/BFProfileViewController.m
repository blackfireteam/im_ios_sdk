//
//  BFProfileViewController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import "BFProfileViewController.h"
#import "MSHeader.h"
#import "MSIMSDK.h"
#import "AppDelegate.h"
#import "BFTabBarController.h"
#import "BFLoginController.h"
#import "BFNavigationController.h"
#import <SDWebImage.h>
#import "BFProfileHeaderView.h"
#import "BFProfileService.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface BFProfileViewController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property(nonatomic,strong) UITableView *myTableView;

@property(nonatomic,strong) BFProfileHeaderView *headerView;

@property(nonatomic,strong) UISwitch *goldSwitch;

@property(nonatomic,strong) UISwitch *verifySwitch;

@end

@implementation BFProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
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
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height) style:UITableViewStylePlain];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.myTableView.rowHeight = 70;
    self.myTableView.estimatedSectionFooterHeight = 0;
    self.myTableView.estimatedSectionHeaderHeight = 0;
    self.myTableView.estimatedRowHeight = 0;
    [self.myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.myTableView];
    
    self.headerView = [[BFProfileHeaderView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, StatusBar_Height+250)];
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTap)];
    [self.headerView.avatarIcon addGestureRecognizer:avatarTap];
    self.myTableView.tableHeaderView = self.headerView;
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, 140)];
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    logoutBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    logoutBtn.backgroundColor = RGB(220, 220, 220);
    logoutBtn.layer.cornerRadius = 5;
    logoutBtn.layer.masksToBounds = YES;
    [logoutBtn addTarget:self action:@selector(logoutBtnClick) forControlEvents:UIControlEventTouchUpInside];
    logoutBtn.frame = CGRectMake(Screen_Width*0.5-100, 50, 200, 40);
    [footerView addSubview:logoutBtn];
    self.myTableView.tableFooterView = footerView;
    
    self.goldSwitch = [[UISwitch alloc]init];
    [self.goldSwitch addTarget:self action:@selector(goldSwitchChange:) forControlEvents:UIControlEventValueChanged];
    self.verifySwitch = [[UISwitch alloc]init];
    [self.verifySwitch addTarget:self action:@selector(verifySwitchChange:) forControlEvents:UIControlEventValueChanged];
}

- (void)reloadData
{
    [[MSProfileProvider provider] providerProfile:[[MSIMTools sharedInstance].user_id integerValue] complete:^(MSProfileInfo * _Nonnull profile) {
        [self.headerView.avatarIcon sd_setImageWithURL:[NSURL URLWithString:profile.avatar]];
        self.headerView.nickNameL.text = profile.nick_name;
        self.goldSwitch.on = profile.gold;
        self.verifySwitch.on = profile.verified;
    }];
}

- (void)goldSwitchChange:(UISwitch *)sw
{
    MSProfileInfo *info = [[MSProfileProvider provider]providerProfileFromLocal:[MSIMTools sharedInstance].user_id.integerValue];
    info.gold = sw.isOn;
    info.gold_exp = [MSIMTools sharedInstance].adjustLocalTimeInterval/1000/1000 + 7*24*60*60;
    [BFProfileService requestToEditProfile:info success:^(NSDictionary * _Nonnull dic) {
        
        [[MSProfileProvider provider]updateProfiles:@[info]];
        [MSHelper showToastSucc:@"修改成功"];
        
    } fail:^(NSError * _Nonnull error) {
        [MSHelper showToastFail:error.localizedDescription];
        sw.on = !sw.isOn;
    }];
}

- (void)verifySwitchChange:(UISwitch *)sw
{
    MSProfileInfo *info = [[MSProfileProvider provider]providerProfileFromLocal:[MSIMTools sharedInstance].user_id.integerValue];
    info.verified = sw.isOn;
    [BFProfileService requestToEditProfile:info success:^(NSDictionary * _Nonnull dic) {
        
        [[MSProfileProvider provider]updateProfiles:@[info]];
        [MSHelper showToastSucc:@"修改成功"];
    } fail:^(NSError * _Nonnull error) {
        [MSHelper showToastFail:error.localizedDescription];
        sw.on = !sw.isOn;
    }];
}

- (void)editNickName:(NSString *)name
{
    MSProfileInfo *info = [[MSProfileProvider provider]providerProfileFromLocal:[MSIMTools sharedInstance].user_id.integerValue];
    info.nick_name = name;
    [BFProfileService requestToEditProfile:info success:^(NSDictionary * _Nonnull dic) {
        
        [[MSProfileProvider provider]updateProfiles:@[info]];
        self.headerView.nickNameL.text = name;
        [MSHelper showToastSucc:@"修改成功"];
    } fail:^(NSError * _Nonnull error) {
        [MSHelper showToastFail:error.localizedDescription];
    }];
}

- (void)editAvatar:(NSString *)url
{
    MSProfileInfo *info = [[MSProfileProvider provider]providerProfileFromLocal:[MSIMTools sharedInstance].user_id.integerValue];
    info.avatar = url;
    [BFProfileService requestToEditProfile:info success:^(NSDictionary * _Nonnull dic) {
        
        [[MSProfileProvider provider]updateProfiles:@[info]];
        [self.headerView.avatarIcon sd_setImageWithURL:[NSURL URLWithString:url]];
        [MSHelper showToastSucc:@"修改成功"];
        
    } fail:^(NSError * _Nonnull error) {
        [MSHelper showToastFail:error.localizedDescription];
    }];
}

- (void)avatarTap
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    cell.textLabel.textColor = TText_Color;
    if (indexPath.row == 0) {
        cell.textLabel.text = @"CHANGE NICKE NAME";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if (indexPath.row == 1) {
        cell.textLabel.text = @"GOLD";
        cell.accessoryView = self.goldSwitch;
    }else if (indexPath.row == 2) {
        cell.textLabel.text = @"VERIFIED";
        cell.accessoryView = self.verifySwitch;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WS(weakSelf)
    if (indexPath.row == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改昵称" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = weakSelf.headerView.nickNameL.text;
        }];
        [alert addAction: [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *tf = alert.textFields.firstObject;
            NSString *nickname = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (nickname.length < 3) {
                [MSHelper showToastFail:@"Nickname must contain at least 3 characters."];
                return;
            }
            [weakSelf editNickName:nickname];
        }]];
        [alert addAction: [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    picker.delegate = nil;
    WS(weakSelf)
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString *mediaType = info[UIImagePickerControllerMediaType];
        PHAsset *imageAsset = info[UIImagePickerControllerPHAsset];
        
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
            MSIMImageElem *imageElem = [[MSIMImageElem alloc]init];
            imageElem.type = MSIM_MSG_TYPE_IMAGE;
            imageElem.image = image;
            imageElem.width = image.size.width;
            imageElem.height = image.size.height;
            imageElem.uuid = imageAsset.localIdentifier;
            
            [[MSIMManager sharedInstance].uploadMediator ms_uploadWithObject:imageElem.image fileType:MSIM_MSG_TYPE_IMAGE progress:^(CGFloat progress) {
                
            } succ:^(NSString * _Nonnull url) {
                
                [weakSelf editAvatar:url];
                
            } fail:^(NSInteger code, NSString * _Nonnull desc) {
                
                [MSHelper showToastFail:desc];
                
            }];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)logoutBtnClick
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"退出登录" message:@"确定要退出吗？" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction: [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [MSHelper showToast];
        [[MSIMManager sharedInstance]logout:^{
                
            [MSHelper dismissToast];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            appDelegate.window.rootViewController = [[BFNavigationController alloc]initWithRootViewController:[BFLoginController new]];
            
            } failed:^(NSInteger code, NSString * _Nonnull desc) {
                [MSHelper showToastFail:desc];
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
}

@end
