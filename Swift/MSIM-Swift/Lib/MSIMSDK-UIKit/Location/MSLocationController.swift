//
//  MSLocationController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/12/9.
//

import UIKit
import MJRefresh
import MAMapKit
import AMapFoundationKit
import AMapSearchKit
import MSIMSDK


class MSLocationController: UIViewController {

    /// 点击发送位置回调
    var didSendLocation: ((_ info: MSLocationInfo) -> Void)?
    
    private var listArr: [MSLocationInfo] = []
    
    private var userLocation: CLLocation? {
        didSet {
            if userLocation != nil {
                self.addAnnotation(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
            }
        }
    }
    
    private var selectInfo: MSLocationInfo?
    
    private var page: Int = 1
    
    private var annotation: MAPointAnnotation?
    
    lazy private var myTableView: UITableView = {
        let myTableView = UITableView(frame: CGRect(x: 0, y: kTableViewMaxY, width: UIScreen.width, height: UIScreen.height - kTableViewMaxY), style: .plain)
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        myTableView.backgroundColor = self.view.backgroundColor
        myTableView.register(MSLocationListCell.self, forCellReuseIdentifier: "locationCell")
        myTableView.rowHeight = 70
        myTableView.separatorColor = UIColor.d_color(light: MSMcros.TCell_separatorColor, dark: MSMcros.TCell_separatorColor_Dark)
        myTableView.layer.cornerRadius = 16
        myTableView.clipsToBounds = true
        myTableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMorePOI))
        return myTableView
    }()

    private let kTableViewMaxY = UIScreen.height * 0.6
    private let kTableViewMinY = UIScreen.height * 0.4

    lazy private var mapVeiw: MAMapView = {
        let mapView = MAMapView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: kTableViewMaxY))
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.zoomLevel = 17
        mapView.delegate = self
        return mapView
    }()
    
    lazy private var searchAPI: AMapSearchAPI = {
        let api = AMapSearchAPI()!
        api.delegate = self
        return api
    }()
    
    lazy private var myLocationBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage.bf_imageNamed(name: "location_my"), for: .normal)
        btn.addTarget(self, action: #selector(myLocationBtnClick), for: .touchUpInside)
        btn.frame = CGRect(x: UIScreen.width - 60 - 15, y: kTableViewMaxY - 60 - 15, width: 60, height: 60)
        return btn
    }()
    
    lazy private var poiRequest: AMapPOIAroundSearchRequest = {
        let request = AMapPOIAroundSearchRequest()
        request.sortrule = 0
        request.requireExtension = true
        request.types = "汽车销售|餐饮服务|购物服务|生活服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|地名地址信息|公共设施"
        return request
    }()
    
    lazy private var navView: UIView = {
        let navView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height:UIScreen.status_navi_height))
        return navView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.d_color(light: MSMcros.TController_Background_Color, dark: MSMcros.TController_Background_Color_Dark)
        
        setupNavView()
        AMapServices.shared().apiKey = MSMcros.GaodeAPIKey
        AMapSearchAPI.updatePrivacyShow(.didShow, privacyInfo: .didContain)
        AMapSearchAPI.updatePrivacyAgree(.didAgree)
        AMapServices.shared().enableHTTPS = true
        
        view.addSubview(mapVeiw)
        view.addSubview(myTableView)
        view.addSubview(myLocationBtn)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(self.navView)
    }
    
    deinit {
        print("%@ dealloc",self)
    }
}

extension MSLocationController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! MSLocationListCell
        cell.locationInfo = listArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.selectInfo?.isSelect = false
        let info = self.listArr[indexPath.row]
        info.isSelect = true
        self.selectInfo = info
        self.myTableView.reloadData()
        self.mapVeiw.setCenter(CLLocationCoordinate2DMake(info.latitude, info.longitude), animated: true)
        self.addAnnotation(latitude: info.latitude, longitude: info.longitude)
    }
}

extension MSLocationController {
    
    // MARK: --- private event
    
    private func setupNavView() {
        view.addSubview(navView)
        navView.addGradientLayer(startColor: UIColor.black.withAlphaComponent(0.5), endColor: UIColor.black.withAlphaComponent(0.0))
        
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitle(Bundle.bf_localizedString(key: "Cancel"), for: .normal)
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 16)
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        cancelBtn.frame = CGRect(x: 6, y: UIScreen.statusbarHeight, width: 60, height: UIScreen.navBarHeight)
        navView.addSubview(cancelBtn)
        
        let sendBtn = UIButton(type: .custom)
        sendBtn.setTitle(Bundle.bf_localizedString(key: "Send"), for: .normal)
        sendBtn.setTitleColor(.white, for: .normal)
        sendBtn.titleLabel?.font = .systemFont(ofSize: 16)
        sendBtn.backgroundColor = .systemBlue
        sendBtn.layer.cornerRadius = 4
        sendBtn.layer.masksToBounds = true
        sendBtn.addTarget(self, action: #selector(SendBtnClick), for: .touchUpInside)
        sendBtn.frame = CGRect(x: UIScreen.width - 10 - 60, y: UIScreen.statusbarHeight + 7, width: 60, height: 30)
        navView.addSubview(sendBtn)
    }
    
    @objc func loadMorePOI() {
        self.page += 1
        
    }
    
    @objc func myLocationBtnClick() {
        self.userLocation = self.mapVeiw.userLocation.location
        self.mapVeiw.setCenter(self.mapVeiw.userLocation.coordinate, animated: true)
        self.page = 1
        self.listArr.removeAll()
        self.myTableView.reloadData()
        self.searchPOI()
    }
    
    @objc func cancelBtnClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func SendBtnClick() {
        if self.selectInfo == nil {return}
        if self.didSendLocation != nil {
            self.selectInfo?.zoom = Int(self.mapVeiw.zoomLevel)
            self.didSendLocation?(self.selectInfo!)
        }
        self.cancelBtnClick()
    }
    
    private func searchPOI() {
        self.poiRequest.page = self.page
        if self.userLocation != nil {
            self.poiRequest.location = AMapGeoPoint.location(withLatitude: self.userLocation!.coordinate.latitude, longitude: self.userLocation!.coordinate.longitude)
            self.searchAPI.aMapPOIAroundSearch(self.poiRequest)
        }
    }
    
    private func addAnnotation(latitude: Double,longitude: Double) {
        if self.annotation != nil {
            self.mapVeiw.removeAnnotation(self.annotation!)
        }
        self.annotation = MAPointAnnotation()
        self.annotation?.title = "pointReuseIndentifier"
        self.annotation?.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        self.mapVeiw.addAnnotation(self.annotation!)
    }
}

// MARK: MAMapViewDelegate
extension MSLocationController: MAMapViewDelegate {
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if self.userLocation == nil {
            self.userLocation = userLocation.location
            self.page = 1
            self.listArr.removeAll()
            self.myTableView.reloadData()
            self.searchPOI()
        }
    }
    
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if wasUserAction {
            self.page = 1
            self.userLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
            self.listArr.removeAll()
            self.myTableView.reloadData()
            self.searchPOI()
        }
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView? {
        if annotation.title == "pointReuseIndentifier" {
            let pointReuseIndentifier = "pointReuseIndentifier"
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndentifier) as? MAPinAnnotationView {
                annotationView.pinColor = .red
                return annotationView
            }
            let annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndentifier)!
            annotationView.pinColor = .red
            return annotationView
        }
        return nil
    }
}

// MARK: AMapSearchDelegate
extension MSLocationController: AMapSearchDelegate {
    
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        
        self.myTableView.mj_footer?.endRefreshing()
        if response.pois.count == 0 {
            self.myTableView.mj_footer?.endRefreshingWithNoMoreData()
        }
        for poi in response.pois {
            
            let info = MSLocationInfo(poi: poi)
            self.listArr.append(info)
        }
        if self.page == 1 {
            self.selectInfo = self.listArr.first
            self.selectInfo?.isSelect = true
        }
        self.myTableView.reloadData()
    }
       
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        print("AMapSearchRequest failed: \(String(describing: error))")
        self.myTableView.mj_footer?.endRefreshing()
    }
}

extension MSLocationController {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let point = scrollView.panGestureRecognizer.velocity(in: scrollView)
        if point.y > 0 {//下滑
            
            if self.myTableView.top == kTableViewMinY && self.myTableView.contentOffset.y <= 0 {
                UIView.animate(withDuration: 0.4) {
                    self.myTableView.top = self.kTableViewMaxY
                    self.myLocationBtn.bottom = self.kTableViewMaxY - 15
                    self.mapVeiw.top = 0
                } completion: { _ in
                    self.myTableView.height = UIScreen.height - self.kTableViewMaxY
                }
                self.myTableView.isScrollEnabled = false
            }
        }else {//上滑
            if self.myTableView.top == kTableViewMaxY && self.myTableView.contentOffset.y <= 0 {
                self.myTableView.height = UIScreen.height - kTableViewMinY
                UIView.animate(withDuration: 0.4) {
                    self.myTableView.top = self.kTableViewMinY
                    self.mapVeiw.top = -(self.kTableViewMaxY - self.kTableViewMinY) * 0.5
                    self.myLocationBtn.bottom = self.kTableViewMinY - 15
                } completion: { _ in
                    
                }

            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.myTableView.isScrollEnabled = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset = .zero
        }
    }
}
