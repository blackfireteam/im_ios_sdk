//
//  NSString+Ext.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/3.
//

#import "NSString+Ext.h"

@implementation NSString (Ext)

- (NSDictionary *)el_convertToDictionary
{
    if(self == nil || self.length == 0) {
        return nil;
    }
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if(error) {
        NSLog(@"json解析失败：%@",error);
        return nil;
    }
    return dic;
}

@end
