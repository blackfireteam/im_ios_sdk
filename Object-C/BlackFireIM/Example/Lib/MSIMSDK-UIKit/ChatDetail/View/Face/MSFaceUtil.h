//
//  MSFaceUtil.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MSFaceGroup;
@interface MSFaceUtil : NSObject

@property(nonatomic,strong) NSArray<MSFaceGroup *> *faceGroups;

+ (MSFaceUtil *)config;

- (nullable MSFaceGroup *)defaultEmojiGroup;

@end

NS_ASSUME_NONNULL_END
