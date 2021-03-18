//
//  MSDBImageFileStore.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import "MSDBBaseStore.h"


@class MSImageInfo;
NS_ASSUME_NONNULL_BEGIN

@interface MSDBImageFileStore : MSDBBaseStore

///向数据库中添加一条记录
- (BOOL)addRecord:(MSImageInfo *)info;

///查找某一条记录
- (MSImageInfo *)searchRecord:(NSString *)key;

///删除某一条记录
- (BOOL)deleteRecord:(NSString *)key;


@end

@interface MSImageInfo: NSObject

@property(nonatomic,copy) NSString *uuid;

@property(nonatomic,copy) NSString *url;

@property(nonatomic,copy) NSString *path;

@property(nonatomic,assign) NSInteger width;

@property(nonatomic,assign) NSInteger height;

@property(nonatomic,assign) NSInteger size;



@end
NS_ASSUME_NONNULL_END
