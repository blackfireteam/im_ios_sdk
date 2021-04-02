//
//  BFUploadManager.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/31.
//

#import <Foundation/Foundation.h>
#import "MSIMElem.h"


NS_ASSUME_NONNULL_BEGIN

@interface BFUploadManager : NSObject

///上传图片到cos
+ (void)uploadImageToCOS:(MSIMImageElem *)imageElem
          uploadProgress:(void(^)(CGFloat progress))progress
                 success:(void(^)(NSString *url))success
                  failed:(void(^)(NSInteger code,NSString *desc))failed;

///上传视频到cos
+ (void)uploadVideoToCOS:(MSIMVideoElem *)videoElem
          uploadProgress:(void(^)(CGFloat progress))progress
                 success:(void(^)(NSString *coverUrl,NSString *videoUrl))success
                  failed:(void(^)(NSInteger code,NSString *desc))failed;

@end

NS_ASSUME_NONNULL_END
