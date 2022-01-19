//
//  BFProfileEditController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/12/23.
//

#import "BFProfileEditController.h"
#import "MSIMSDK-UIKit.h"
#import <MSIMSDK/MSIMSDK.h>
#import "AppDelegate.h"
#import "BFTabBarController.h"
#import "BFLoginController.h"
#import "BFNavigationController.h"
#import <SDWebImage.h>
#import "BFProfileHeaderView.h"
#import "BFProfileService.h"
#import <TZImagePickerController.h>
#import "BFSelectorView.h"

@interface BFProfileEditController ()<UITableViewDelegate,UITableViewDataSource,TZImagePickerControllerDelegate>

@property(nonatomic,strong) UITableView *myTableView;

@property(nonatomic,strong) BFProfileHeaderView *headerView;

@property(nonatomic,strong) UISwitch *goldSwitch;

@property(nonatomic,strong) UISwitch *verifySwitch;

@property(nonatomic,strong) MSProfileInfo *info;

@end

@implementation BFProfileEditController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navView.navTitleL.text = @"编辑个人资料";
    [self setupUI];
    [self reloadData];
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
    self.myTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.myTableView.contentInset = UIEdgeInsetsMake(StatusBar_Height + NavBar_Height, 0, Bottom_SafeHeight, 0);
    self.myTableView.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:TPage_Color_Dark];
    [self.view addSubview:self.myTableView];
    
    self.headerView = [[BFProfileHeaderView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, StatusBar_Height+180)];
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTap)];
    [self.headerView.avatarIcon addGestureRecognizer:avatarTap];
    self.myTableView.tableHeaderView = self.headerView;

    self.goldSwitch = [[UISwitch alloc]init];
    [self.goldSwitch addTarget:self action:@selector(goldSwitchChange:) forControlEvents:UIControlEventValueChanged];
    self.verifySwitch = [[UISwitch alloc]init];
    [self.verifySwitch addTarget:self action:@selector(verifySwitchChange:) forControlEvents:UIControlEventValueChanged];
}

- (void)reloadData
{
    self.info = [[MSProfileProvider provider]providerProfileFromLocal:[MSIMTools sharedInstance].user_id];
    [self.headerView.avatarIcon sd_setImageWithURL:[NSURL URLWithString:self.info.avatar]];
    [self.myTableView reloadData];
}

- (void)goldSwitchChange:(UISwitch *)sw
{
    self.info.gold = sw.isOn;
    self.info.gold_exp = [MSIMTools sharedInstance].adjustLocalTimeInterval/1000/1000 + 7*24*60*60;
    [BFProfileService requestToEditProfile:self.info success:^(NSDictionary * _Nonnull dic) {
        
        [[MSProfileProvider provider]updateProfiles:@[self.info]];
        [MSHelper showToastSucc:@"修改成功"];
        
    } fail:^(NSError * _Nonnull error) {
        [MSHelper showToastFail:error.localizedDescription];
        sw.on = !sw.isOn;
    }];
}

- (void)verifySwitchChange:(UISwitch *)sw
{
    MSProfileInfo *info = [[MSProfileProvider provider]providerProfileFromLocal:[MSIMTools sharedInstance].user_id];
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
    self.info.nick_name = name;
    WS(weakSelf)
    [BFProfileService requestToEditProfile:self.info success:^(NSDictionary * _Nonnull dic) {
        
        [[MSProfileProvider provider]updateProfiles:@[self.info]];
        [weakSelf.myTableView reloadData];
        [MSHelper showToastSucc:@"修改成功"];
    } fail:^(NSError * _Nonnull error) {
        [MSHelper showToastFail:error.localizedDescription];
    }];
}

- (void)editGender:(NSInteger)gender
{
    self.info.gender = gender;
    WS(weakSelf)
    [BFProfileService requestToEditProfile:self.info success:^(NSDictionary * _Nonnull dic) {
        
        [[MSProfileProvider provider]updateProfiles:@[self.info]];
        [weakSelf.myTableView reloadData];
        [MSHelper showToastSucc:@"修改成功"];
    } fail:^(NSError * _Nonnull error) {
        [MSHelper showToastFail:error.localizedDescription];
    }];
}

- (void)editAvatar:(NSString *)url
{
    self.info.avatar = url;
    [BFProfileService requestToEditProfile:self.info success:^(NSDictionary * _Nonnull dic) {
        
        [[MSProfileProvider provider]updateProfiles:@[self.info]];
        [self.headerView.avatarIcon sd_setImageWithURL:[NSURL URLWithString:url]];
        [MSHelper showToastSucc:@"修改成功"];
        
    } fail:^(NSError * _Nonnull error) {
        [MSHelper showToastFail:error.localizedDescription];
    }];
}

- (void)editDepartment:(NSString *)text
{
    WS(weakSelf)
    NSMutableDictionary *dic = [self.info.custom el_convertToDictionary].mutableCopy;
    dic[@"department"] = text;
    self.info.custom = dic.el_convertJsonString;
    [BFProfileService requestToEditProfile:self.info success:^(NSDictionary * _Nonnull dic) {
        
        [[MSProfileProvider provider]updateProfiles:@[self.info]];
        [weakSelf.myTableView reloadData];
        [MSHelper showToastSucc:@"修改成功"];
        
    } fail:^(NSError * _Nonnull error) {
        [MSHelper showToastFail:error.localizedDescription];
    }];
}

- (void)editWorkplace:(NSString *)text
{
    WS(weakSelf)
    NSMutableDictionary *dic = [self.info.custom el_convertToDictionary].mutableCopy;
    dic[@"workplace"] = text;
    self.info.custom = dic.el_convertJsonString;
    [BFProfileService requestToEditProfile:self.info success:^(NSDictionary * _Nonnull dic) {
        
        [[MSProfileProvider provider]updateProfiles:@[self.info]];
        [weakSelf.myTableView reloadData];
        [MSHelper showToastSucc:@"修改成功"];
        
    } fail:^(NSError * _Nonnull error) {
        [MSHelper showToastFail:error.localizedDescription];
    }];
}

- (void)avatarTap
{
    TZImagePickerController *picker = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
    picker.allowPickingVideo = NO;
    picker.allowPickingImage = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
    cell.detailTextLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    NSDictionary *dic = [self.info.custom el_convertToDictionary];
    if (indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"昵称";
        cell.detailTextLabel.text = self.info.nick_name;
        
    }else if (indexPath.row == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"性别";
        cell.detailTextLabel.text = self.info.gender == 1 ? @"男" : @"女";
    }else if (indexPath.row == 2) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"部门";
        cell.detailTextLabel.text = dic[@"department"];
    }else if (indexPath.row == 3) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"办公地";
        cell.detailTextLabel.text = dic[@"workplace"];
    }else if (indexPath.row == 4) {
        cell.textLabel.text = @"GOLD";
        cell.accessoryView = self.goldSwitch;
    }else if (indexPath.row == 5) {
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
            textField.text = weakSelf.info.nick_name;
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
    }else if (indexPath.row == 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction: [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf editGender:1];
        }]];
        [alert addAction: [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf editGender:2];
        }]];
        [alert addAction: [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }else if (indexPath.row == 2) {
        [BFSelectorView showSelectView:0 submitAction:^(NSString * _Nonnull text) {
            [weakSelf editDepartment:text];
        } cancel:nil];
    }else if (indexPath.row == 3) {
        [BFSelectorView showSelectView:1 submitAction:^(NSString * _Nonnull text) {
            [weakSelf editWorkplace:text];
        } cancel:nil];
    }
}

#pragma mark - TZImagePickerControllerDelegate

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos
{
    UIImage *image = photos.firstObject;
    PHAsset *asset = assets.firstObject;
    MSIMImageElem *imageElem = [[MSIMImageElem alloc]init];
    imageElem.type = MSIM_MSG_TYPE_IMAGE;
    imageElem.image = image;
    imageElem.width = image.size.width;
    imageElem.height = image.size.height;
    imageElem.uuid = asset.localIdentifier;
    
    WS(weakSelf)
    [[MSIMManager sharedInstance].uploadMediator ms_uploadWithObject:imageElem.image fileType:MSUploadFileTypeAvatar progress:^(CGFloat progress) {
        
    } succ:^(NSString * _Nonnull url) {
        
        [weakSelf editAvatar:url];
        
    } fail:^(NSInteger code, NSString * _Nonnull desc) {
        
        [MSHelper showToastFail:desc];
        
    }];
}


@end
