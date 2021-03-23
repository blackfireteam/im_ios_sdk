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


@interface BFChatViewController()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>


@end
@implementation BFChatViewController (More)

- (void)selectPhotoForSend
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)takePictureForSend
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 快速点的时候会回调多次
//    WS(weakSelf)
    picker.delegate = nil;
    [picker dismissViewControllerAnimated:YES completion:^{
//        STRONG_SELF(strongSelf)
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            UIImageOrientation imageOrientation = image.imageOrientation;
            if(imageOrientation != UIImageOrientationUp)
            {
                CGFloat aspectRatio = MIN ( 1920 / image.size.width, 1920 / image.size.height );
                CGFloat aspectWidth = image.size.width * aspectRatio;
                CGFloat aspectHeight = image.size.height * aspectRatio;

                UIGraphicsBeginImageContext(CGSizeMake(aspectWidth, aspectHeight));
                [image drawInRect:CGRectMake(0, 0, aspectWidth, aspectHeight)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }

//            NSData *data = UIImageJPEGRepresentation(image, 0.75);
//            NSString *path = [TUIKit_Image_Path stringByAppendingString:[THelper genImageName:nil]];
//            [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
//
//            TUIImageMessageCellData *uiImage = [[TUIImageMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
//            uiImage.path = path;
//            uiImage.length = data.length;
//            [self sendMessage:uiImage];
//
//            if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
//                [self.delegate chatController:self didSendMessage:uiImage];
//            }
        }else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
            
            NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
            
            if(![url.pathExtension  isEqual: @"mp4"]) {
                NSString* tempPath = NSTemporaryDirectory();
                NSURL *urlName = [url URLByDeletingPathExtension];
                NSURL *newUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@%@.mp4", tempPath,[urlName.lastPathComponent stringByRemovingPercentEncoding]]];
                // mov to mp4
                AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
                AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
                 exportSession.outputURL = newUrl;
                 exportSession.outputFileType = AVFileTypeMPEG4;
                 exportSession.shouldOptimizeForNetworkUse = YES;

                 [exportSession exportAsynchronouslyWithCompletionHandler:^{
                 switch ([exportSession status])
                 {
                      case AVAssetExportSessionStatusFailed:
                           NSLog(@"Export session failed");
                           break;
                      case AVAssetExportSessionStatusCancelled:
                           NSLog(@"Export canceled");
                           break;
                      case AVAssetExportSessionStatusCompleted:
                      {
                           //Video conversion finished
                           NSLog(@"Successful!");
                          dispatch_async(dispatch_get_main_queue(), ^{
//                              [self sendVideoWithUrl:newUrl];
                          });
                      }
                           break;
                      default:
                           break;
                  }
                 }];
            } else {
//                [self sendVideoWithUrl:url];
            }
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendVideoWithUrl:(NSURL*)url
{
//    NSData *videoData = [NSData dataWithContentsOfURL:url];
//    NSString *videoPath = [NSString stringWithFormat:@"%@%@.mp4", TUIKit_Video_Path, [THelper genVideoName:nil]];
//    [[NSFileManager defaultManager] createFileAtPath:videoPath contents:videoData attributes:nil];
//
//    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
//    AVURLAsset *urlAsset =  [AVURLAsset URLAssetWithURL:url options:opts];
//    NSInteger duration = (NSInteger)urlAsset.duration.value / urlAsset.duration.timescale;
//    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
//    gen.appliesPreferredTrackTransform = YES;
//    gen.maximumSize = CGSizeMake(192, 192);
//    NSError *error = nil;
//    CMTime actualTime;
//    CMTime time = CMTimeMakeWithSeconds(0.0, 10);
//    CGImageRef imageRef = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
//    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
//    CGImageRelease(imageRef);
//
//    NSData *imageData = UIImagePNGRepresentation(image);
//    NSString *imagePath = [TUIKit_Video_Path stringByAppendingString:[THelper genSnapshotName:nil]];
//    [[NSFileManager defaultManager] createFileAtPath:imagePath contents:imageData attributes:nil];
//
//    TUIVideoMessageCellData *uiVideo = [[TUIVideoMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
//    uiVideo.snapshotPath = imagePath;
//    uiVideo.snapshotItem = [[TUISnapshotItem alloc] init];
//    UIImage *snapshot = [UIImage imageWithContentsOfFile:imagePath];
//    uiVideo.snapshotItem.size = snapshot.size;
//    uiVideo.snapshotItem.length = imageData.length;
//    uiVideo.videoPath = videoPath;
//    uiVideo.videoItem = [[TUIVideoItem alloc] init];
//    uiVideo.videoItem.duration = duration;
//    uiVideo.videoItem.length = videoData.length;
//    uiVideo.videoItem.type = url.pathExtension;
//    uiVideo.uploadProgress = 0;
//    [self sendMessage:uiVideo];
//
//    if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
//        [self.delegate chatController:self didSendMessage:uiVideo];
//    }
}

@end
