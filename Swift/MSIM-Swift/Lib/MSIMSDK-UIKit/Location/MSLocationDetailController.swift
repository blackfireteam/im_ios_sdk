//
//  MSLocationDetailController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/12/9.
//

import UIKit
import AMapFoundationKit
import  MAMapKit
import MapKit


class MSLocationDetailController: UIViewController {

    
    private var userLocation: CLLocation?
    
    private var locationInfo: MSLocationInfo
    
    private var page: Int = 1
    
    private var annotation: MAPointAnnotation?

    lazy private var mapVeiw: MAMapView = {
        let mapView = MAMapView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height))
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.zoomLevel = CGFloat(self.locationInfo.zoom)
        mapView.delegate = self
        return mapView
    }()
    
    lazy private var myLocationBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage.bf_imageNamed(name: "location_my"), for: .normal)
        btn.addTarget(self, action: #selector(myLocationBtnClick), for: .touchUpInside)
        btn.frame = CGRect(x: UIScreen.width - 60 - 15, y: UIScreen.height - UIScreen.safeAreaBottomHeight - 80 - 60 - 15, width: 60, height: 60)
        return btn
    }()
    
    lazy private var navView: UIView = {
        let navView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height:UIScreen.status_navi_height))
        return navView
    }()
    
    private var bottomTitleL: UILabel!
    
    private var bottomDetailL: UILabel!
    
    init(location: MSLocationInfo) {
        self.locationInfo = location
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AMapServices.shared().apiKey = MSMcros.GaodeAPIKey
        AMapServices.shared().enableHTTPS = true
        
        view.addSubview(self.mapVeiw)
        view.addSubview(self.myLocationBtn)
        
        setupNavView()
        setupBottomView()
        self.bottomTitleL.text = self.locationInfo.name
        self.bottomDetailL.text = self.locationInfo.detail
        
        addLocationAnnotation()
        self.mapVeiw.setCenter(CLLocationCoordinate2DMake(self.locationInfo.latitude, self.locationInfo.longitude), animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    deinit {
        print("%@ dealloc",self)
    }
}

//MARK: PRIVATE EVENT
extension MSLocationDetailController {
    
    private func setupNavView() {
        view.addSubview(self.navView)
        self.navView.addGradientLayer(startColor: UIColor.black.withAlphaComponent(0.5), endColor: UIColor.black.withAlphaComponent(0.0))
        
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitle(Bundle.bf_localizedString(key: "Cancel"), for: .normal)
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 16)
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        cancelBtn.frame = CGRect(x: 6, y: UIScreen.statusbarHeight, width: 60, height: UIScreen.navBarHeight)
        navView.addSubview(cancelBtn)
    }
    
    private func setupBottomView() {
        let bottomView = UIView(frame: CGRect(x: 0, y: UIScreen.height - UIScreen.safeAreaBottomHeight - 80, width: UIScreen.width, height: UIScreen.safeAreaBottomHeight + 80))
        bottomView.backgroundColor = UIColor.d_color(light: MSMcros.TController_Background_Color, dark: MSMcros.TController_Background_Color_Dark)
        view.addSubview(bottomView)
        
        bottomTitleL = UILabel(frame: CGRect(x: 15, y: 10, width: UIScreen.width - 30 - 60, height: 20))
        bottomTitleL.font = .boldSystemFont(ofSize: 17)
        bottomTitleL.textColor = UIColor.d_color(light: MSMcros.TText_Color, dark: MSMcros.TText_Color_Dark)
        bottomView.addSubview(bottomTitleL)
        
        bottomDetailL = UILabel(frame: CGRect(x: 15, y: bottomTitleL.bottom + 6, width: UIScreen.width - 30 - 60, height: 14))
        bottomDetailL.font = .systemFont(ofSize: 14)
        bottomDetailL.textColor = .gray
        bottomView.addSubview(bottomDetailL)
        
        let navigatorBtn = UIButton(type: .custom)
        navigatorBtn.setImage(UIImage.bf_imageNamed(name: "location_navigator"), for: .normal)
        navigatorBtn.addTarget(self, action: #selector(navigatorClick), for: .touchUpInside)
        navigatorBtn.frame = CGRect(x: UIScreen.width - 15 - 60, y: 10, width: 60, height: 60)
        bottomView.addSubview(navigatorBtn)
    }
    
    @objc func cancelBtnClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func myLocationBtnClick() {
        self.userLocation = self.mapVeiw.userLocation.location
        self.mapVeiw.setCenter(self.mapVeiw.userLocation.coordinate, animated: true)
    }
    
    private func addLocationAnnotation() {
        if self.annotation != nil {
            self.mapVeiw.removeAnnotation(self.annotation!)
        }
        self.annotation = MAPointAnnotation()
        self.annotation?.coordinate = CLLocationCoordinate2DMake(self.locationInfo.latitude, self.locationInfo.longitude)
        self.mapVeiw.addAnnotation(self.annotation!)
    }
    
    @objc func navigatorClick() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Google Map", style: .default, handler: {[weak self] _ in
            self?.navigatorAtIndex(at: 0)
        }))
        alert.addAction(UIAlertAction(title: "Gaode Map", style: .default, handler: {[weak self] _ in
            self?.navigatorAtIndex(at: 1)
        }))
        alert.addAction(UIAlertAction(title: "Baidu Map", style: .default, handler: {[weak self] _ in
            self?.navigatorAtIndex(at: 2)
        }))
        alert.addAction(UIAlertAction(title: "Apple Map", style: .default, handler: {[weak self] _ in
            self?.navigatorAtIndex(at: 3)
        }))
        alert.addAction(UIAlertAction(title: Bundle.bf_localizedString(key: "Cancel"), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func navigatorAtIndex(at index: Int) {
        if index == 0 {
            if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                let urlString = "comgooglemaps://?x-source=MSIM-NORMAL&x-success=MSIMNORMAL&saddr=&daddr=\(self.locationInfo.latitude),\(self.locationInfo.longitude)&directionsmode=driving"
                UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
            }else {
                MSHelper.showToastWithText(text: "google map is unavailable")
            }
        }else if index == 1 {
            if UIApplication.shared.canOpenURL(URL(string: "iosamap://")!) {
                let urlString = "iosamap://navi?sourceApplication=MSIM-NORMAL&backScheme=MSIMNORMAL&lat=\(self.locationInfo.latitude)&lon=\(self.locationInfo.longitude)&dev=0&style=2"
                UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
            }else {
                MSHelper.showToastWithText(text: "gaode map is unavailable")
            }
        }else if index == 2 {
            if UIApplication.shared.canOpenURL(URL(string: "baidumap://")!) {
                let urlString = "baidumap://map/direction?origin={{}}&destination=latlng:\(self.locationInfo.latitude),\(self.locationInfo.longitude)|mode=driving&coord_type=gcj02"
                UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
            }else {
                MSHelper.showToastWithText(text: "baidu map is unavailable")
            }
        }else if index == 3 {
            let loc = CLLocationCoordinate2DMake(self.locationInfo.latitude, self.locationInfo.longitude)
            let currentLoc = MKMapItem.forCurrentLocation()
            let toLocation = MKMapItem(placemark: MKPlacemark(coordinate: loc))
            let items = [currentLoc,toLocation]
            let dic = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsMapTypeKey: MKMapType.standard,MKLaunchOptionsShowsTrafficKey: true] as [String : Any]
            MKMapItem.openMaps(with: items, launchOptions: dic)
        }
    }
}


// MARK: MAMapViewDelegate
extension MSLocationDetailController: MAMapViewDelegate {
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if self.userLocation == nil {
            self.userLocation = userLocation.location
        }
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView? {
        if annotation.isKind(of: MAPinAnnotationView.self) {
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
