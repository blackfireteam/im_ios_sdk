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

+ (void)uploadImageToCOS:(MSIMImageElem *)imageElem
          uploadProgress:(void(^)(CGFloat progress))progress
                 success:(void(^)(NSString *url))success
                  failed:(void(^)(NSInteger code,NSString *desc))failed;

@end

NS_ASSUME_NONNULL_END
