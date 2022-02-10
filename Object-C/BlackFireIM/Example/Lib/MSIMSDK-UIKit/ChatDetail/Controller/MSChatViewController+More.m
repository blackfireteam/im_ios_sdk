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
    picker.autoDismiss = NO;
    [self presentViewController:picker animated:YES completion:nil];
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

@end
