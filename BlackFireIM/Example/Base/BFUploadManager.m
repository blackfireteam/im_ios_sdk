//
//  BFUploadManager.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/31.
//

#import "BFUploadManager.h"
#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import <QCloudCOSXML/QCloudCOSXMLDownloadObjectRequest.h>



@interface BFUploadManager()


@end
@implementation BFUploadManager

static BFUploadManager *_manager;
+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _manager = [[BFUploadManager alloc]init];
    });
    return _manager;
}

- (void)ms_uploadWithObject:(id)object
                   fileType:(BFIMMessageType)type
                   progress:(normalProgress)progress
                       succ:(normalSucc)succ
                       fail:(normalFail)fail
{
    if (object == nil || (type != BFIM_MSG_TYPE_IMAGE && type != BFIM_MSG_TYPE_VIDEO && type != BFIM_MSG_TYPE_VOICE)) {
        fail(-99,@"");
        return;
    }
    QCloudCOSXMLUploadObjectRequest *put = [QCloudCOSXMLUploadObjectRequest new];
    if (type == BFIM_MSG_TYPE_IMAGE) {
        if ([object isKindOfClass:[UIImage class]]) {
            UIImage *image = object;
            NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
            put.body = imageData;
        }else {
            NSString *path = object;
            put.body = [NSURL fileURLWithPath:path];
        }
        put.object = [NSString stringWithFormat:@"im_image/%@.jpg",[NSString uuidString]];
    }else if (type == BFIM_MSG_TYPE_VIDEO) {
        NSString *path = object;
        put.body = [NSURL fileURLWithPath:path];
        put.object = [NSString stringWithFormat:@"im_video/%@.mp4",[NSString uuidString]];
    }else if (type == BFIM_MSG_TYPE_VOICE) {
        NSString *path = object;
        put.body = [NSURL fileURLWithPath:path];
        put.object = [NSString stringWithFormat:@"im_voice/%@",[path lastPathComponent]];
    }
    put.bucket = @"msim-1252460681";
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) progress(totalBytesSent*1.0/totalBytesExpectedToSend*1.0);
        });
    }];
    [put setFinishBlock:^(QCloudUploadObjectResult * _Nullable result, NSError * _Nullable error) {
            
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                if (succ) succ(result.location);
            }else {
                if (fail) fail(error.code,error.localizedDescription);
            }
        });
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager]UploadObject:put];
}



- (void)ms_downloadFromUrl:(NSString *)url
                toSavePath:(NSString *)savePath
                  progress:(normalProgress)progress
                      succ:(normalSucc)succ
                      fail:(normalFail)fail
{
    if (![url hasPrefix:@"http"] || savePath.length == 0) {
        fail(-99,@"待下载的文件地址非法");
        return;
    }
    QCloudCOSXMLDownloadObjectRequest *request = [QCloudCOSXMLDownloadObjectRequest new];
    request.bucket = @"msim-1252460681";
    request.object = [NSURL URLWithString:url].path;
    request.downloadingURL = [NSURL fileURLWithPath:savePath];
    [request setFinishBlock:^(id  _Nullable outputObject, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                if (succ) succ(savePath);
            }else {
                if (fail) fail(error.code,error.localizedDescription);
            }
        });
    }];
    [request setDownProcessBlock:^(int64_t bytesDownload, int64_t totalBytesDownload, int64_t totalBytesExpectedToDownload) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) progress(totalBytesDownload*1.0/totalBytesExpectedToDownload*1.0);
        });
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager]DownloadObject:request];
}


@end
