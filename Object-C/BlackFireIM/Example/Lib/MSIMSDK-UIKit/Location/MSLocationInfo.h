//
//  MSLocationInfo.h
//  BlackFireIM
//
//  Created by benny wang on 2021/11/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSLocationInfo : NSObject

@property(nonatomic,copy) NSString *name;

@property(nonatomic,copy) NSString *detail;

@property(nonatomic,assign) NSInteger zoom;

@property(nonatomic,assign) NSInteger distance;

///纬度（垂直方向）
@property (nonatomic,assign) double latitude;
///经度（水平方向）
@property (nonatomic,assign) double longitude;

@property(nonatomic,copy) NSString *city;

@property(nonatomic,copy) NSString *province;

@property(nonatomic,copy) NSString *district;

@property(nonatomic,copy) NSString *address;

@property(nonatomic,assign) BOOL isSelect;

@end

NS_ASSUME_NONNULL_END
