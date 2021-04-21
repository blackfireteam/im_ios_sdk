//
//  BFUploadManager.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/31.
//

#import "BFUploadManager.h"
#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import "NSString+Ext.h"


@implementation BFUploadManager


+ (void)uploadImageToCOS:(MSIMImageElem *)imageElem
          uploadProgress:(void(^)(CGFloat progress))progress
                 success:(void(^)(NSString *url))success
                  failed:(void(^)(NSInteger code,NSString *desc))failed
{
    if (imageElem == nil) {
        failed(0,@"待上传文件为空");
        return;
    }
    QCloudCOSXMLUploadObjectRequest *put = [QCloudCOSXMLUploadObjectRequest new];
    if([[NSFileManager defaultManager]fileExistsAtPath:imageElem.path]) {
        NSURL *url = [NSURL fileURLWithPath:imageElem.path];
        put.body = url;
    }else if (imageElem.image) {
        NSData *imageData = UIImageJPEGRepresentation(imageElem.image, 0.7);
        put.body = imageData;
    }else {
        failed(0,@"待上传文件不存在");
        return;
    }
    put.bucket = @"msim-1252460681";
    put.object = [NSString stringWithFormat:@"im_image/%@.jpg",[NSString uuidString]];
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) progress(totalBytesSent*1.0/totalBytesExpectedToSend*1.0);
        });
    }];
    [put setFinishBlock:^(QCloudUploadObjectResult * _Nullable result, NSError * _Nullable error) {
            
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                if (success) success(result.location);
            }else {
                if (failed) failed(error.code,error.localizedDescription);
            }
        });
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager]UploadObject:put];
}

///上传视频到cos
+ (void)uploadVideoToCOS:(MSIMVideoElem *)videoElem
          uploadProgress:(void(^)(CGFloat progress))progress
                 success:(void(^)(NSString *coverUrl,NSString *videoUrl))success
                  failed:(void(^)(NSInteger code,NSString *desc))failed
{
    if (videoElem == nil) {
        failed(0,@"待上传文件为空");
        return;
    }
    BOOL isVideoFinish = [videoElem.videoUrl hasPrefix:@"http"];
    BOOL isCoverFinish = [videoElem.coverUrl hasPrefix:@"http"];
    if (isVideoFinish && isCoverFinish) {
        success(videoElem.coverUrl,videoElem.videoUrl);
        return;
    }
    if (!isCoverFinish) {//先上传封面图片
        MSIMImageElem *imageElem = [[MSIMImageElem alloc]init];
        imageElem.path = videoElem.coverPath;
        imageElem.image = videoElem.coverImage;
        WS(weakSelf)
        [self uploadImageToCOS:imageElem uploadProgress:^(CGFloat coverProgress) {
                    
            progress(isVideoFinish ? coverProgress : coverProgress*0.2);
            
                } success:^(NSString * _Nonnull url) {
                    
                    videoElem.coverUrl = url;
                    if (isVideoFinish) {
                        success(videoElem.coverUrl,videoElem.videoUrl);
                    }else {
                        //上传视频文件
                        [weakSelf uploadVideoFileToCOS:videoElem uploadProgress:^(CGFloat videoProgress) {
                            if (progress) progress(0.2 + videoProgress*0.8);
                            
                        } success:^(NSString *videoUrl) {
                            
                            videoElem.videoUrl = videoUrl;
                            success(videoElem.coverUrl,videoElem.videoUrl);
                            
                        } failed:^(NSInteger code, NSString *desc) {
                            
                            failed(code,desc);
                        }];
                    }
                } failed:^(NSInteger code, NSString * _Nonnull desc) {
                    failed(code,desc);
        }];
    }else {
        //上传视频文件
        [self uploadVideoFileToCOS:videoElem uploadProgress:^(CGFloat videoProgress) {
            
            if (progress) progress(videoProgress);
            
        } success:^(NSString *videoUrl) {
            
            videoElem.videoUrl = videoUrl;
            success(videoElem.coverUrl,videoElem.videoUrl);
            
        } failed:^(NSInteger code, NSString *desc) {
            failed(code,desc);
        }];
    }
}

+ (void)uploadVideoFileToCOS:(MSIMVideoElem *)videoElem
              uploadProgress:(void(^)(CGFloat progress))videoProgress
                     success:(void(^)(NSString *videoUrl))videoSuccess
                      failed:(void(^)(NSInteger code,NSString *desc))videoFailed
{
    QCloudCOSXMLUploadObjectRequest *put = [QCloudCOSXMLUploadObjectRequest new];
    if([[NSFileManager defaultManager]fileExistsAtPath:videoElem.videoPath]) {
        NSURL *url = [NSURL fileURLWithPath:videoElem.videoPath];
        put.body = url;
    }else {
        videoFailed(0,@"待上传的视频文件不存在");
        return;
    }
    put.bucket = @"msim-1252460681";
    put.object = [NSString stringWithFormat:@"im_video/%@.mp4",[NSString uuidString]];
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (videoProgress) videoProgress(totalBytesSent*1.0/totalBytesExpectedToSend*1.0);
        });
    }];
    [put setFinishBlock:^(QCloudUploadObjectResult * _Nullable result, NSError * _Nullable error) {
            
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                if (videoSuccess) videoSuccess(result.location);
            }else {
                if (videoFailed) videoFailed(error.code,error.localizedDescription);
            }
        });
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager]UploadObject:put];
}

///上传音频到cos
+ (void)uploadVoiceToCOS:(MSIMVoiceElem *)voiceElem
          uploadProgress:(void(^)(CGFloat progress))progress
                 success:(void(^)(NSString *url))success
                  failed:(void(^)(NSInteger code,NSString *desc))failed
{
    QCloudCOSXMLUploadObjectRequest *put = [QCloudCOSXMLUploadObjectRequest new];
    if([[NSFileManager defaultManager]fileExistsAtPath:voiceElem.path]) {
        NSURL *url = [NSURL fileURLWithPath:voiceElem.path];
        put.body = url;
    }else {
        failed(0,@"待上传的音频文件不存在");
        return;
    }
    put.bucket = @"msim-1252460681";
    put.object = [NSString stringWithFormat:@"im_voice/%@",[voiceElem.path lastPathComponent]];
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) progress(totalBytesSent*1.0/totalBytesExpectedToSend*1.0);
        });
    }];
    [put setFinishBlock:^(QCloudUploadObjectResult * _Nullable result, NSError * _Nullable error) {
            
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                if (success) success(result.location);
            }else {
                if (failed) failed(error.code,error.localizedDescription);
            }
        });
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager]UploadObject:put];
}

@end
