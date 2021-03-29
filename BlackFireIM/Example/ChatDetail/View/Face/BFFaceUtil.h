//
//  BFFaceUtil.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFFaceUtil : NSObject

@property(nonatomic,strong) NSMutableArray *defaultFace;

+ (BFFaceUtil *)defaultConfig;

@end

NS_ASSUME_NONNULL_END
