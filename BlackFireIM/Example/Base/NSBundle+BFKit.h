//
//  NSBundle+BFKit.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (BFKit)

#pragma mark - TUIKit 代码相关国际化
+ (NSString *)bf_localizedStringForKey:(NSString *)key value:(nullable NSString *)value;
+ (NSString *)bf_localizedStringForKey:(NSString *)key;


#pragma mark - TUIKit 内置表情相关国际化
+ (NSString *)bf_emojiLocalizedStringForKey:(NSString *)key value:(nullable NSString *)value;
+ (NSString *)bf_emojiLocalizedStringForKey:(NSString *)key;

+ (NSString *)bf_localizableLanguageKey;

@end

NS_ASSUME_NONNULL_END
