//
//  NSBundle+BFKit.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import "NSBundle+BFKit.h"

@implementation NSBundle (BFKit)

static NSBundle *resourceBundle = nil;
+ (instancetype)bf_resourceBundle
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        resourceBundle = [NSBundle bundleWithURL: [[NSBundle mainBundle] URLForResource:@"TUIKitResource" withExtension: @"bundle"]];
    });
    return resourceBundle;
}

+ (NSString *)bf_localizedStringForKey:(NSString *)key value:(nullable NSString *)value
{
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        NSString *language = [self bf_localizableLanguageKey];
        language = [@"Localizable" stringByAppendingPathComponent:language];
        bundle = [NSBundle bundleWithPath:[self.bf_resourceBundle pathForResource:language ofType:@"lproj"]];
    }
    return [bundle localizedStringForKey:key value:value table:nil];
}

+ (NSString *)bf_localizedStringForKey:(NSString *)key
{
    return [self bf_localizedStringForKey:key value:nil];
}

// 表情相关的国际化
+ (instancetype)bf_emojiBundle
{
    static NSBundle *emojiBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        emojiBundle = [NSBundle bundleWithURL: [[NSBundle mainBundle] URLForResource:@"TUIKitFace" withExtension: @"bundle"]];
    });
    return emojiBundle;
}

+ (NSString *)bf_emojiLocalizedStringForKey:(NSString *)key value:(nullable NSString *)value
{
//    static NSBundle *bundle = nil;
//    if (bundle == nil) {
//        NSString *language = [self bf_localizableLanguageKey];
//        language = [@"Localizable" stringByAppendingPathComponent:language];
//
//        // 从bundle中查找资源
//        bundle = [NSBundle bundleWithPath:[[NSBundle tk_emojiBundle] pathForResource:language ofType:@"lproj"]];
//    }
//    value = [bundle localizedStringForKey:key value:value table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

+ (NSString *)bf_emojiLocalizedStringForKey:(NSString *)key
{
    return [self bf_emojiLocalizedStringForKey:key value:nil];
}

+ (NSString *)bf_localizableLanguageKey
{
    // 默认跟随系统
    // todo: 外部可配置
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if ([language hasPrefix:@"en"]) {
        language = @"en";
    } else if ([language hasPrefix:@"zh"]) {
        if ([language rangeOfString:@"Hans"].location != NSNotFound) {
            language = @"zh-Hans"; // 简体中文
        } else { // zh-Hant\zh-HK\zh-TW
            language = @"zh-Hant"; // 繁體中文
        }
    } else if ([language hasPrefix:@"ko"]) {
        language = @"ko";
    } else if ([language hasPrefix:@"ru"]) {
        language = @"ru";
    } else if ([language hasPrefix:@"uk"]) {
        language = @"uk";
    } else {
        language = @"en";
    }
    return language;
}

@end
