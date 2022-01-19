//
//  MSLocationManager.h
//  BlackFireIM
//
//  Created by benny wang on 2022/1/11.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface MSLocationManager : NSObject

+ (instancetype)shareInstance;

/// 将高德地图坐标转换成wgs84标准坐标
- (CLLocationCoordinate2D)AMapCoordinateConvertToGPS:(CLLocationCoordinate2D)coordinate;

/// 将wgs84标准坐标转换成高德坐标
- (CLLocationCoordinate2D)gPSCoordinateConvertToAMap:(CLLocationCoordinate2D)coordinate;

@end

NS_ASSUME_NONNULL_END
