//
//  MSChatViewController+More.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/23.
//

#import "MSChatViewController+More.h"
#import "MSIMSDK-UIKit.h"
#import <TZImagePickerController.h>
#import <MSIMSDK/MSIMSDK.h>



@interface MSChatViewController()<TZImagePickerControllerDelegate>


@end
@implementation MSChatViewController (More)

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
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - TZImagePickerControllerDelegate

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos
{
    for (NSInteger i = 0; i < photos.count; i++) {
        UIImage *image = photos[i];
        PHAsset *asset = assets[i];
        MSIMImageElem *imageElem = [[MSIMImageElem alloc]init];
        imageElem.type = MSIM_MSG_TYPE_IMAGE;
        imageElem.image = image;
        imageElem.width = image.size.width;
        imageElem.height = image.size.height;
        imageElem.uuid = asset.localIdentifier;
        [self sendImage:imageElem];
    }
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset
{
    [[TZImageManager manager] getVideoOutputPathWithAsset:asset success:^(NSString *outputPath) {
        MSIMVideoElem *videoElem = [[MSIMVideoElem alloc]init];
        videoElem.type = MSIM_MSG_TYPE_VIDEO;
        videoElem.coverImage = coverImage;
        videoElem.width = ABS(asset.pixelWidth);
        videoElem.height = ABS(asset.pixelHeight);
        videoElem.videoPath = outputPath;
        videoElem.duration = asset.duration;
        [self sendVideo:videoElem];
    } failure:^(NSString *errorMessage, NSError *error) {
        MSLog(@"视频导出错误.");
    }];
}

- (void)sendImage:(MSIMImageElem *)elem
{
    MSIMImageElem *imageElem = [[MSIMManager sharedInstance]createImageMessage:elem];
    [self sendMessage:imageElem];
}

- (void)sendVideo:(MSIMVideoElem *)elem
{
    MSIMVideoElem *videoElem = [[MSIMManager sharedInstance]createVideoMessage:elem];
    [self sendMessage:videoElem];
}

@end
