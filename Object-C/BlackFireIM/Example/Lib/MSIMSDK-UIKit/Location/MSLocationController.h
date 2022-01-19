//
//  MSLocationController.h
//  BlackFireIM
//
//  Created by benny wang on 2021/11/29.
//

#import <UIKit/UIKit.h>
#import "MSLocationInfo.h"

NS_ASSUME_NONNULL_BEGIN


@interface MSLocationController : UIViewController

@property(nonatomic,copy) void (^selectLocation)(MSLocationInfo *info);

@end

NS_ASSUME_NONNULL_END
