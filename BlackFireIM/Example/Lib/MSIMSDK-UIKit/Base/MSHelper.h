//
//  MSHelper.h
//  BlackFireIM
//
//  Created by benny wang on 2021/5/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSHelper : NSObject

+ (void)showToast;

+ (void)showToastString:(NSString *)text;

+ (void)showToastSucc:(NSString *)text;

+ (void)showToastFail:(NSString *)text;

+ (void)dismissToast;

@end

NS_ASSUME_NONNULL_END
