//
//  MSChatViewController+More.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/23.
//

#import "MSChatViewController+More.h"
#import "MSHeader.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MSIMSDK.h"
#import "NSFileManager+filePath.h"
#import <Photos/Photos.h>

@interface MSChatViewController()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>


@end
@implementation MSChatViewController (More)

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

- (void)selectVideoForSend
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
//        picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        [picker setVideoMaximumDuration:15];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    picker.delegate = nil;
    WS(weakSelf)
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString *mediaType = info[UIImagePickerControllerMediaType];
        NSURL *referenceURL = info[UIImagePickerControllerReferenceURL];
        NSString *identifier = referenceURL.absoluteString;
        
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

            NSData *data = UIImageJPEGRepresentation(image, 0.75);
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[NSString uuidString]];
            NSString *path = [[NSFileManager pathForIMImage]stringByAppendingPathComponent:fileName];
            [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
          
            MSIMImageElem *imageElem = [[MSIMImageElem alloc]init];
            imageElem.type = MSIM_MSG_TYPE_IMAGE;
            imageElem.image = image;
            imageElem.width = image.size.width;
            imageElem.height = image.size.height;
            imageElem.path = path;
            imageElem.uuid = identifier;
            [weakSelf sendImage:imageElem];
            
        } else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
            NSURL *url = info[UIImagePickerControllerMediaURL];
            NSURL *referenceURL = info[UIImagePickerControllerReferenceURL];
            NSString *identifier = referenceURL.absoluteString;
            
            if(![url.pathExtension isEqual: @"mp4"]) {
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
                              [weakSelf sendVideoWithUrl:newUrl identifier:identifier];
                          });
                      }
                           break;
                      default:
                           break;
                  }
                 }];
            } else {
                [weakSelf sendVideoWithUrl:url identifier:identifier];
            }
        }
    }];
}

- (void)sendVideoWithUrl:(NSURL*)url identifier:(NSString *)identifier
{
    NSData *videoData = [NSData dataWithContentsOfURL:url];
    NSString *videoPath = [NSString stringWithFormat:@"%@%@.mp4", [NSFileManager pathForIMVideo], [NSString uuidString]];
    [[NSFileManager defaultManager] createFileAtPath:videoPath contents:videoData attributes:nil];
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset =  [AVURLAsset URLAssetWithURL:url options:opts];
    AVAssetTrack *videoTrack = [urlAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    CGSize videoSize = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
    
    NSInteger duration = MAX((NSInteger)urlAsset.duration.value / urlAsset.duration.timescale, 1);
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
    gen.appliesPreferredTrackTransform = YES;
    gen.maximumSize = CGSizeMake(192, 192);
    NSError *error = nil;
    CMTime actualTime;
    CMTime time = CMTimeMakeWithSeconds(0.0, 10);
    CGImageRef imageRef = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *coverFileName = [NSString stringWithFormat:@"%@.jpg",[NSString uuidString]];
    NSString *coverPath = [[NSFileManager pathForIMImage]stringByAppendingPathComponent:coverFileName];
    [[NSFileManager defaultManager] createFileAtPath:coverPath contents:imageData attributes:nil];
    
    MSIMVideoElem *videoElem = [[MSIMVideoElem alloc]init];
    videoElem.type = MSIM_MSG_TYPE_VIDEO;
    videoElem.coverImage = image;
    videoElem.width = ABS(videoSize.width);
    videoElem.height = ABS(videoSize.height);
    videoElem.coverPath = coverPath;
    videoElem.videoPath = videoPath;
    videoElem.duration = duration;
    videoElem.uuid = identifier;
    [self sendVideo:videoElem];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
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
