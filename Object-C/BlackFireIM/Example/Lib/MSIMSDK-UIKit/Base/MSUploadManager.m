//
//  BFUploadManager.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/31.
//

#import "MSUploadManager.h"
#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import <AFNetworking.h>


@interface MSUploadManager()<QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate>

@property (nonatomic,strong) QCloudCredentailFenceQueue* credentialFenceQueue;

@property(nonatomic,strong) MSCOSInfo *cosInfo;

@end
@implementation MSUploadManager

static MSUploadManager *_manager;
+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _manager = [[MSUploadManager alloc]init];
    });
    return _manager;
}

//配置cos @"ap-chengdu"
- (void)cosServiceConfig
{
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = self.cosInfo.region;
    endpoint.useHTTPS = true;
    configuration.endpoint = endpoint;
    configuration.signatureProvider = self;
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];
    self.credentialFenceQueue = [QCloudCredentailFenceQueue new];
    self.credentialFenceQueue.delegate = self;
}

- (void) fenceQueue:(QCloudCredentailFenceQueue * )queue requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock
{
  //这里同步从◊后台服务器获取临时密钥，强烈建议将获取临时密钥的逻辑放在这里，最大程度上保证密钥的可用性
    [[MSIMManager sharedInstance]getCOSToken:^(MSCOSInfo * _Nonnull cosInfo) {
        self.cosInfo = cosInfo;
        QCloudCredential* credential = [QCloudCredential new];
        credential.secretID = self.cosInfo.secretID;
        credential.secretKey = self.cosInfo.secretKey;
        credential.token = self.cosInfo.token;
        credential.startDate = [NSDate dateWithTimeIntervalSince1970:self.cosInfo.start_time]; // 单位是秒
        credential.expirationDate = [NSDate dateWithTimeIntervalSince1970:self.cosInfo.exp_time];// 单位是秒
        QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc]
           initWithCredential:credential];
        continueBlock(creator, nil);
    } failed:^(NSInteger code, NSString *desc) {
        MSLog(@"请求cos临时密钥错误。。%zd--%@",code,desc);
        continueBlock(nil,[[NSError alloc]initWithDomain:desc code:code userInfo:nil]);
    }];
}

- (void) signatureWithFields:(QCloudSignatureFields*)fileds
                   request:(QCloudBizHTTPRequest*)request
                urlRequest:(NSMutableURLRequest*)urlRequst
                 compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock
{
      [self.credentialFenceQueue performAction:^(QCloudAuthentationCreator *creator,
          NSError *error) {
          if (error) {
              continueBlock(nil, error);
          } else {
              QCloudSignature* signature =  [creator signatureForData:urlRequst];
              continueBlock(signature, nil);
          }
      }];
}

- (void)ms_uploadWithObject:(id)object
                   fileType:(MSUploadFileType)type
                   progress:(normalProgress)progress
                       succ:(normalSucc)succ
                       fail:(normalFail)fail
{
    if (object == nil) {
        if (fail) fail(-99,@"");
        return;
    }
    if (self.cosInfo == nil) {
        [[MSIMManager sharedInstance]getCOSToken:^(MSCOSInfo * _Nonnull cosInfo) {
            self.cosInfo = cosInfo;
            [self cosServiceConfig];
            [self ms_cosUploadWithObject:object fileType:type progress:progress succ:succ fail:fail];
        } failed:^(NSInteger code, NSString *desc) {
            MSLog(@"请求cos临时密钥错误。。%zd--%@",code,desc);
            if (fail) fail(code,desc);
        }];
        return;
    }
    [self ms_cosUploadWithObject:object fileType:type progress:progress succ:succ fail:fail];
}

- (void)ms_cosUploadWithObject:(id)object
                      fileType:(MSUploadFileType)type
                      progress:(normalProgress)progress
                          succ:(normalSucc)succ
                          fail:(normalFail)fail
{
    QCloudCOSXMLUploadObjectRequest *put = [[QCloudCOSXMLUploadObjectRequest alloc]init];
    if (type == MSUploadFileTypeImage || type == MSUploadFileTypeAvatar) {
        if ([object isKindOfClass:[UIImage class]]) {
            UIImage *image = object;
            NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
            put.body = imageData;
        }else {
            NSString *path = object;
            put.body = [NSURL fileURLWithPath:path];
        }
        if (type == MSUploadFileTypeAvatar) {
            put.object = [NSString stringWithFormat:@"%@%@.jpg",self.cosInfo.other_path,[NSString uuidString]];
        }else {
            put.object = [NSString stringWithFormat:@"%@im_image/%@.jpg",self.cosInfo.im_path,[NSString uuidString]];
        }
    }else if (type == MSUploadFileTypeVideo) {
        NSString *path = object;
        put.body = [NSURL fileURLWithPath:path];
        put.object = [NSString stringWithFormat:@"%@im_video/%@.mp4",self.cosInfo.im_path,[NSString uuidString]];
    }else if (type == MSUploadFileTypeVoice) {
        NSString *path = object;
        put.body = [NSURL fileURLWithPath:path];
        put.object = [NSString stringWithFormat:@"%@im_voice/%@",self.cosInfo.im_path,[path lastPathComponent]];
    }
    put.bucket = self.cosInfo.bucket;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) progress(totalBytesSent*1.0/totalBytesExpectedToSend*1.0);
        });
    }];
    [put setFinishBlock:^(QCloudUploadObjectResult *result, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                NSString *resultUrl = result.location;
                //@"https://msim-1252460681.cos.ap-chengdu.myqcloud.com/tmp/18030740093/im_video/765F012F-6F0D-45AB-A468-27441D411243.mp4";
                
                if (succ) succ(resultUrl);
            }else {
                if (fail) fail(error.code,error.localizedDescription);
            }
        });
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
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
    if (self.cosInfo == nil) {
        [[MSIMManager sharedInstance]getCOSToken:^(MSCOSInfo * _Nonnull cosInfo) {
            self.cosInfo = cosInfo;
            [self cosServiceConfig];
            [self ms_cosDownloadFromUrl:url toSavePath:savePath progress:progress succ:succ fail:fail];
        } failed:^(NSInteger code, NSString *desc) {
            MSLog(@"请求cos临时密钥错误。。%zd--%@",code,desc);
            if (fail) fail(code,desc);
        }];
        return;
    }
    [self ms_cosDownloadFromUrl:url toSavePath:savePath progress:progress succ:succ fail:fail];
}

- (void)ms_cosDownloadFromUrl:(NSString *)url
                toSavePath:(NSString *)savePath
                  progress:(normalProgress)progress
                      succ:(normalSucc)succ
                      fail:(normalFail)fail
{
    /* 创建网络下载对象 */
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) progress(downloadProgress.fractionCompleted);
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [NSURL fileURLWithPath:savePath];
                
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                if (succ) succ(savePath);
            }else {
                [[NSFileManager defaultManager]removeItemAtPath:savePath error:nil];
                if (fail) fail(error.code,error.localizedDescription);
            }
        });
    }];
     [downloadTask resume];
}

@end
