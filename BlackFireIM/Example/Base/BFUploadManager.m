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

@end
