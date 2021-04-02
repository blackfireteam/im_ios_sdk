//
//  BFChatViewController+More.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/23.
//

#import "BFChatViewController+More.h"
#import "BFHeader.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MSIMSDK.h"
#import <SVProgressHUD.h>
#import "NSFileManager+filePath.h"
#import "NSString+Ext.h"
#import <TZImagePickerController.h>


@interface BFChatViewController()<TZImagePickerControllerDelegate>


@end
@implementation BFChatViewController (More)

- (void)selectPhotoForSend
{
    TZImagePickerController *picker = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
    picker.allowPickingImage = YES;
    picker.allowPickingVideo = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)selectVideoForSend
{
    TZImagePickerController *picker = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
    picker.allowPickingImage = NO;
    picker.allowPickingVideo = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    UIImage *image = photos.firstObject;
    PHAsset *asset = assets.firstObject;
    if (image.size.width > 1920 || image.size.height > 1920) {
        CGFloat aspectRatio = MIN ( 1920 / image.size.width, 1920 / image.size.height );
        CGFloat aspectWidth = image.size.width * aspectRatio;
        CGFloat aspectHeight = image.size.height * aspectRatio;

        UIGraphicsBeginImageContext(CGSizeMake(aspectWidth, aspectHeight));
        [image drawInRect:CGRectMake(0, 0, aspectWidth, aspectHeight)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    NSData *data = UIImageJPEGRepresentation(image, 0.75);
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[NSString uuidString]];
    NSString *path = [[NSFileManager pathForIMImage]stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
    
    MSIMImageElem *imageElem = [[MSIMImageElem alloc]init];
    imageElem.type = BFIM_MSG_TYPE_IMAGE;
    imageElem.image = image;
    imageElem.width = image.size.width;
    imageElem.height = image.size.height;
    imageElem.path = path;
    imageElem.uuid = asset.localIdentifier;
    [self sendImage:imageElem];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset
{
    if (coverImage.size.width > 1920 || coverImage.size.height > 1920) {
        CGFloat aspectRatio = MIN ( 1920 / coverImage.size.width, 1920 / coverImage.size.height );
        CGFloat aspectWidth = coverImage.size.width * aspectRatio;
        CGFloat aspectHeight = coverImage.size.height * aspectRatio;

        UIGraphicsBeginImageContext(CGSizeMake(aspectWidth, aspectHeight));
        [coverImage drawInRect:CGRectMake(0, 0, aspectWidth, aspectHeight)];
        coverImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    NSData *data = UIImageJPEGRepresentation(coverImage, 0.75);
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[NSString uuidString]];
    NSString *path = [[NSFileManager pathForIMImage]stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
    
    [[TZImageManager manager]getVideoOutputPathWithAsset:asset presetName:AVAssetExportPresetMediumQuality success:^(NSString *outputPath) {
            
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
        MSIMVideoElem *videoElem = [[MSIMVideoElem alloc]init];
        videoElem.type = BFIM_MSG_TYPE_VIDEO;
        videoElem.coverImage = coverImage;
        videoElem.width = asset.pixelWidth;
        videoElem.height = asset.pixelHeight;
        videoElem.coverPath = path;
        videoElem.videoPath = outputPath;
        videoElem.duration = asset.duration;
        videoElem.uuid = asset.localIdentifier;
        [self sendVideo:videoElem];
        
        } failure:^(NSString *errorMessage, NSError *error) {
            NSLog(@"视频导出失败:%@,error:%@",errorMessage, error);
            [SVProgressHUD showInfoWithStatus:errorMessage];
    }];
}


- (void)sendImage:(MSIMImageElem *)elem
{
    MSIMImageElem *imageElem = [[MSIMManager sharedInstance]createImageMessage:elem];
    [[MSIMManager sharedInstance]sendC2CMessage:imageElem toReciever:self.partner_id successed:^(NSInteger msg_id) {
            
        } failed:^(NSInteger code, NSString * _Nonnull desc) {
            NSLog(@"code = %zd,desc = %@",code,desc);
            [SVProgressHUD showInfoWithStatus:desc];
    }];
}

- (void)sendVideo:(MSIMVideoElem *)elem
{
    MSIMVideoElem *videoElem = [[MSIMManager sharedInstance]createVideoMessage:elem];
    [[MSIMManager sharedInstance]sendC2CMessage:videoElem toReciever:self.partner_id successed:^(NSInteger msg_id) {
            
        } failed:^(NSInteger code, NSString * _Nonnull desc) {
            NSLog(@"code = %zd,desc = %@",code,desc);
            [SVProgressHUD showInfoWithStatus:desc];
    }];
}

@end
