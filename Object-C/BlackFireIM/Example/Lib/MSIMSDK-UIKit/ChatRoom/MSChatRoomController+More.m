//
//  MSChatRoomController+More.m
//  BlackFireIM
//
//  Created by benny wang on 2021/10/29.
//

#import "MSChatRoomController+More.h"
#import "MSIMSDK-UIKit.h"
#import <TZImagePickerController.h>
#import <MSIMSDK/MSIMSDK.h>
#import "MSLocationManager.h"


@interface MSChatRoomController()<TZImagePickerControllerDelegate>


@end
@implementation MSChatRoomController (More)

- (void)selectPhotoForSend
{
    TZImagePickerController *picker = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
    picker.allowPickingVideo = NO;
    picker.allowPickingImage = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)selectVideoForSend
{
    TZImagePickerController *picker = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
    picker.allowPickingVideo = YES;
    picker.allowPickingImage = NO;
    picker.autoDismiss = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)selectLocationForSend
{
    MSLocationController *vc  = [[MSLocationController alloc]init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
    WS(weakSelf)
    vc.selectLocation = ^(MSLocationInfo * _Nonnull info) {
        [weakSelf sendLocationMessage: info];
    };
}

- (void)sendLocationMessage:(MSLocationInfo *)info
{
    // 为了兼容，先将高德地图坐标转换成gps坐标
    CLLocationCoordinate2D n_coor = [[MSLocationManager shareInstance]AMapCoordinateConvertToGPS:CLLocationCoordinate2DMake(info.latitude, info.longitude)];
    MSIMLocationElem *elem = [[MSIMLocationElem alloc]init];
    elem.title = info.name;
    elem.detail = info.detail;
    elem.longitude = n_coor.longitude;
    elem.latitude = n_coor.latitude;
    MSIMMessage *message = [[MSIMManager sharedInstance]createLocationMessage:elem];
    [[MSIMManager sharedInstance] sendChatRoomMessage:message toRoomID:self.roomInfo.room_id successed:^(NSInteger msg_id) {
        
    } failed:^(NSInteger code, NSString *desc) {
        
    }];
}

#pragma mark - TZImagePickerControllerDelegate

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos
{
    if (isSelectOriginalPhoto) {
        for (NSInteger i = 0; i < photos.count; i++) {
            PHAsset *asset = assets[i];
            [[TZImageManager manager] getOriginalPhotoWithAsset:asset newCompletion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                if (!isDegraded) {
                    NSString *imagePath = [NSString stringWithFormat:@"%@%@.jpg",[NSFileManager pathForIMImage],[NSString uuidString]];
                    NSData *imageData = UIImagePNGRepresentation(photo);
                    [imageData writeToFile:imagePath atomically:YES];
                    MSIMMessage *message = [[MSIMManager sharedInstance]createImageMessage:imagePath identifierID:asset.localIdentifier];
                    [self sendMessage:message];
                }
            }];
        }
    }else {
        for (NSInteger i = 0; i < photos.count; i++) {
            UIImage *image = photos[i];
            PHAsset *asset = assets[i];
            NSString *imagePath = [NSString stringWithFormat:@"%@%@.jpg",[NSFileManager pathForIMImage],[NSString uuidString]];
            NSData *imageData = UIImagePNGRepresentation(image);
            [imageData writeToFile:imagePath atomically:YES];
            MSIMMessage *message = [[MSIMManager sharedInstance]createImageMessage:imagePath identifierID:asset.localIdentifier];
            [self sendMessage:message];
        }
    }
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset
{
    [MSHelper showToast];
    [[TZImageManager manager] getVideoOutputPathWithAsset:asset success:^(NSString *outputPath) {
        
        NSString *coverPath = [NSString stringWithFormat:@"%@%@.jpg",[NSFileManager pathForIMVideo],[NSString uuidString]];
        NSData *coverData = UIImagePNGRepresentation(coverImage);
        [coverData writeToFile:coverPath atomically:YES];
        MSIMMessage *message = [[MSIMManager sharedInstance]createVideoMessage:outputPath type:@"mp4" duration:asset.duration snapshotPath:coverPath identifierID:asset.localIdentifier];
        [self sendMessage:message];
        [MSHelper dismissToast];
        [picker dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSString *errorMessage, NSError *error) {
        MSLog(@"%@",error);
        [MSHelper showToastFail:error.localizedDescription];
    }];
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendEnotionMessage:(BFFaceCellData *)data
{
    MSIMEmotionElem *emotionElem = [[MSIMEmotionElem alloc]init];
    emotionElem.emotionID = data.e_id;
    emotionElem.emotionName = data.name;
    MSIMMessage *message = [[MSIMManager sharedInstance]createEmotionMessage:emotionElem];
    [self sendMessage:message];
}

@end
