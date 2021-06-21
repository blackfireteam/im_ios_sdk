//
//  MSFaceUtil.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSFaceUtil : NSObject

@property(nonatomic,strong) NSMutableArray *defaultFace;

+ (MSFaceUtil *)defaultConfig;

@end

NS_ASSUME_NONNULL_END
