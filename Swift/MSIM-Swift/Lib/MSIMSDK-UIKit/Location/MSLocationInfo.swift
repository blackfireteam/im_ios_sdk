//
//  MSLocationInfo.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/12/9.
//

import Foundation
import AMapSearchKit
import MSIMSDK

class MSLocationInfo {
    
    var name: String = ""
    var detail: String = ""
    var zoom: Int = 0
    var distance: Int = 0
    var latitude: Double = 0
    var longitude: Double = 0
    var city: String = ""
    var province: String = ""
    var district: String = ""
    var address: String = ""
    var isSelect: Bool = false
    
    init(poi: AMapPOI) {
        self.name = poi.name
        self.address = poi.address
        self.detail = poi.province + poi.city + poi.district + poi.address
        self.distance = poi.distance
        self.city = poi.city
        self.province = poi.province
        self.district = poi.district
        self.latitude = poi.location.latitude
        self.longitude = poi.location.longitude
    }
    
    init(locationMsg: MSIMLocationElem) {
        self.name = locationMsg.title
        self.detail = locationMsg.detail ?? ""
        self.latitude = locationMsg.latitude
        self.longitude = locationMsg.longitude
        self.zoom = locationMsg.zoom
    }
}
