//
//  MSLocationManager.swift
//  MSIM-Swift
//
//  Created by benny wang on 2022/1/19.
//

import Foundation
import CoreLocation
import MAMapKit


class MSLocationManager: NSObject {
    
    static let shared: MSLocationManager = MSLocationManager()
    
    /// 将高德地图坐标转换成wgs84标准坐标
    func AMapCoordinateConvertToGPS(coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        
        if self.outOfChinalat(lat: coordinate.latitude, lon: coordinate.longitude) {
            return coordinate
        }
        let arr = self.deltalat(wgLat: coordinate.latitude, wgLon: coordinate.longitude)
        return CLLocationCoordinate2D(latitude: arr.first ?? 0.0, longitude: arr.last ?? 0.0)
    }
    
    
    /// 将wgs84标准坐标转换成高德坐标
    func gPSCoordinateConvertToAMap(coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return AMapCoordinateConvert(coordinate, .GPS)
    }
    
    private func outOfChinalat(lat: Double,lon: Double) -> Bool {
        if lon < 72.004 || lon > 137.8347 {
            return true
        }
        if lat < 0.8293 || lat > 55.8271 {
            return true
        }
        return false
    }
    
    private func transformLonx(x: Double, y: Double) -> Double {
        var ret: Double = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x))
        ret += (20.0 * sin(6.0 * x * .pi) + 20.0 * sin(2.0 * x * .pi)) * 2.0 / 3.0
        ret += (20.0 * sin(x * .pi) + 40.0 * sin(x / 3.0 * .pi)) * 2.0 / 3.0
        ret += (150.0 * sin(x / 12.0 * .pi) + 300.0 * sin(x / 30.0 * .pi)) * 2.0 / 3.0
        return ret
    }
    
    private func transformLatx(x: Double, y: Double) -> Double {
        var ret: Double = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x))
        ret += (20.0 * sin(6.0 * x * .pi) + 20.0 * sin(2.0 * x * .pi)) * 2.0 / 3.0
        ret += (20.0 * sin(y * .pi) + 40.0 * sin(y / 3.0 * .pi)) * 2.0 / 3.0
        ret += (160.0 * sin(y / 12.0 * .pi) + 320.0 * sin(y * .pi / 30.0)) * 2.0 / 3.0
        return ret
    }
    
    private func deltalat(wgLat: Double, wgLon: Double) -> [Double] {
        
        let OFFSET: Double = 0.00669342162296594323
        let AXIS: Double = 6378245.0
        var dLat: Double = self.transformLatx(x: wgLon - 105.0, y: wgLat - 35.0)
        var dLon: Double = self .transformLonx(x: wgLon - 105.0, y: wgLat - 35.0)
        let radLat = wgLat / 180.0 * .pi
        var magic = sin(radLat)
        magic = 1 - OFFSET * magic * magic
        let sqrtMagic = sqrt(magic)
        dLat = (dLat * 180.0) / ((AXIS * (1 - OFFSET)) / (magic * sqrtMagic) * .pi)
        dLon = (dLon * 180.0) / (AXIS / sqrtMagic * cos(radLat) * .pi)
        return [(wgLat - dLat),(wgLon - dLon)]
    }
}
