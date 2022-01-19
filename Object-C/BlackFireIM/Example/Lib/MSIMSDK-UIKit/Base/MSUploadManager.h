//
//  BFUploadManager.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/31.
//

#import <Foundation/Foundation.h>
#import <MSIMSDK/MSIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSUploadManager : NSObject<MSUploadMediator>

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
