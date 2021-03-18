//
//  NSString+Ext.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Ext)

- (NSDictionary *)el_convertToDictionary;

//通过图片Data数据第一个字节 来获取图片扩展名
+ (NSString *)contentTypeForImageData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
