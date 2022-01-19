//
//  MSLocationManager.m
//  BlackFireIM
//
//  Created by benny wang on 2022/1/11.
//

#import "MSLocationManager.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MAMapKit/MAMapKit.h>

@implementation MSLocationManager


///单例
static MSLocationManager *instance;
+ (instancetype)shareInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[MSLocationManager alloc]init];
    });
    return instance;
}

/// 将高德地图坐标转换成wgs84标准坐标
- (CLLocationCoordinate2D)AMapCoordinateConvertToGPS:(CLLocationCoordinate2D)coordinate
{
    double lat = coordinate.latitude;
    double lon = coordinate.longitude;
    if ([self outOfChinalat:lat lon:lon]){
        return coordinate;
    }
    NSArray<NSNumber *> *latlon = [self deltalat:lat lon:lon];
    return CLLocationCoordinate2DMake(latlon.firstObject.doubleValue, latlon.lastObject.doubleValue);
}

- (BOOL)outOfChinalat:(double)lat lon:(double)lon
{
    if (lon < 72.004 || lon > 137.8347)
        return true;
    if (lat < 0.8293 || lat > 55.8271)
        return true;
    return false;
}

- (NSArray<NSNumber *> *)deltalat:(double)wgLat lon:(double)wgLon
{
    double OFFSET = 0.00669342162296594323;
    double AXIS = 6378245.0;
    
    double dLat = [self transformLatx:(wgLon - 105.0) lon:(wgLat - 35.0)];
    double dLon = [self transformLonx:(wgLon - 105.0) lon:(wgLat - 35.0)];
    double radLat = wgLat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - OFFSET * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((AXIS * (1 - OFFSET)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (AXIS / sqrtMagic * cos(radLat) * M_PI);
    return @[[NSNumber numberWithDouble:(wgLat - dLat)],[NSNumber numberWithDouble:(wgLon - dLon)]];
}

- (double)transformLatx:(double)x lon:(double)y
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

- (double)transformLonx:(double)x lon:(double)y
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

/// 将wgs84标准坐标转换成高德坐标
- (CLLocationCoordinate2D)gPSCoordinateConvertToAMap:(CLLocationCoordinate2D)coordinate
{
    return AMapCoordinateConvert(coordinate, AMapCoordinateTypeGPS);
}


@end
