//
//  MSLocationDetailController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/12/1.
//

#import "MSLocationDetailController.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MAMapKit/MAMapKit.h>
#import "MSIMSDK-UIKit.h"
#import <MapKit/MapKit.h>


@interface MSLocationDetailController ()<MAMapViewDelegate>

@property(nonatomic,strong) UIView *navView;

@property(nonatomic,strong) MAMapView *mapView;

@property(nonatomic,strong) CLLocation *userLocation;

@property(nonatomic,strong) UIButton *myLocationBtn;

@property(nonatomic,strong) MAPointAnnotation *annotation;

@property(nonatomic,strong) UILabel *bottomTitleL;

@property(nonatomic,strong) UILabel *bottomDetailL;

@end

@implementation MSLocationDetailController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AMapServices sharedServices].apiKey = GaodeAPIKey;
    [AMapServices sharedServices].enableHTTPS = YES;

    [self.view addSubview:self.mapView];
    [self.view addSubview:self.myLocationBtn];
    
    [self setupNavView];
    [self setupBottomView];
    self.bottomTitleL.text = self.locationInfo.name;
    self.bottomDetailL.text  = self.locationInfo.detail;
    
    [self addLocationAnnotation];
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.locationInfo.latitude, self.locationInfo.longitude) animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)dealloc
{
    MSLog(@"%@ dealloc",self.class);
}

- (MAMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
        _mapView.showsUserLocation = YES;
        _mapView.userTrackingMode = MAUserTrackingModeFollow;
//        _mapView.language = MAMapLanguageEn;
        _mapView.showsCompass = NO;
        _mapView.showsScale = NO;
        _mapView.zoomLevel = self.locationInfo.zoom;
        _mapView.delegate = self;
    }
    return _mapView;
}

- (UIButton *)myLocationBtn
{
    if (!_myLocationBtn) {
        _myLocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_myLocationBtn setImage:[UIImage imageNamed:TUIKitResource(@"location_my")] forState:UIControlStateNormal];
        [_myLocationBtn addTarget:self action:@selector(myLocationBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _myLocationBtn.frame = CGRectMake(Screen_Width - 60 - 15, Screen_Height - Bottom_SafeHeight - 80 - 60 - 15, 60, 60);
    }
    return _myLocationBtn;
}

- (void)setupNavView
{
    self.navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,Screen_Width , StatusBar_Height + NavBar_Height)];
    [self.view addSubview:self.navView];
    [self.navView setGradientLayer:[[UIColor blackColor]colorWithAlphaComponent:0.5] endColor:[[UIColor blackColor]colorWithAlphaComponent:0.0]];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:TUILocalizableString(Cancel) forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = CGRectMake(6, StatusBar_Height, 60, NavBar_Height);
    [self.navView addSubview:cancelBtn];
}

- (void)setupBottomView
{
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, Screen_Height - Bottom_SafeHeight - 80, Screen_Width, Bottom_SafeHeight + 80)];
    bottomView.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    [self.view addSubview:bottomView];
    
    self.bottomTitleL = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, Screen_Width - 30 - 60, 20)];
    self.bottomTitleL.font = [UIFont boldSystemFontOfSize:17];
    self.bottomTitleL.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
    [bottomView addSubview:self.bottomTitleL];
    
    self.bottomDetailL = [[UILabel alloc]initWithFrame:CGRectMake(15, self.bottomTitleL.maxY + 6, Screen_Width - 30 - 60, 14)];
    self.bottomDetailL.font = [UIFont systemFontOfSize:14];
    self.bottomDetailL.textColor = [UIColor grayColor];
    [bottomView addSubview:self.bottomDetailL];
    
    UIButton *navigatorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [navigatorBtn setImage:[UIImage imageNamed:TUIKitResource(@"location_navigator")] forState:UIControlStateNormal];
    [navigatorBtn addTarget:self action:@selector(navigatorClick) forControlEvents:UIControlEventTouchUpInside];
    navigatorBtn.frame = CGRectMake(Screen_Width - 15 - 60, 10, 60, 60);
    [bottomView addSubview:navigatorBtn];
}

#pragma mark - button event

- (void)cancelBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)myLocationBtnClick
{
    self.userLocation = self.mapView.userLocation.location;
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

- (void)navigatorClick
{
    WS(weakSelf)
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Google Map" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf navigatorAtIndex: 0];
        }]] ;
    [alert addAction:[UIAlertAction actionWithTitle:@"Gaode Map" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf navigatorAtIndex: 1];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Baidu Map" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf navigatorAtIndex: 2];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Apple Map" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf navigatorAtIndex: 3];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:TUILocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)navigatorAtIndex:(NSInteger)index
{
    if (index == 0) {// google map
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
            NSString *urlString = [NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",@"MSIM-NORMAL",@"MSIMNORMAL",self.locationInfo.latitude,self.locationInfo.longitude];
            NSURL *mapUrl = [NSURL URLWithString:urlString];
            [[UIApplication sharedApplication]openURL:mapUrl options:@{} completionHandler:nil];
        }else {
            [MSHelper showToastFail:@"未安装谷歌地图"];
        }
    }else if(index == 1) {//gaode map
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
            NSString *urlString = [NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2",@"MSIM-NORMAL",@"MSIMNORMAL",self.locationInfo.latitude,self.locationInfo.longitude];
            NSURL *mapUrl = [NSURL URLWithString:urlString];
            [[UIApplication sharedApplication]openURL:mapUrl options:@{} completionHandler:nil];
        }else {
            [MSHelper showToastFail:@"未安装高德地图"];
        }
    }else if(index == 2) {//baidu map
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
            NSString *urlString = [NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|mode=driving&coord_type=gcj02",self.locationInfo.latitude,self.locationInfo.longitude];
            NSURL *mapUrl = [NSURL URLWithString:urlString];
            [[UIApplication sharedApplication]openURL:mapUrl options:@{} completionHandler:nil];
        }else {
            [MSHelper showToastFail:@"未安装百度地图"];
        }
    }else if(index == 3) {//apple map
        //终点坐标
        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(self.locationInfo.latitude, self.locationInfo.longitude);
        //用户位置
        MKMapItem *currentLoc = [MKMapItem mapItemForCurrentLocation];
        //终点位置
        MKMapItem *toLocation = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:loc addressDictionary:nil]];
        
        NSArray *items = @[currentLoc,toLocation];
        //第一个
        NSDictionary *dic = @{
            MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
            MKLaunchOptionsMapTypeKey : @(MKMapTypeStandard),
            MKLaunchOptionsShowsTrafficKey : @(YES)
        };
        [MKMapItem openMapsWithItems:items launchOptions:dic];
    }
}

- (void)addLocationAnnotation
{
    [self.mapView removeAnnotation:self.annotation];
    self.annotation = [[MAPointAnnotation alloc] init];
    self.annotation.coordinate = CLLocationCoordinate2DMake(self.locationInfo.latitude, self.locationInfo.longitude);
    [self.mapView addAnnotation:self.annotation];
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (self.userLocation == nil) {
        self.userLocation = userLocation.location;
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil) {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.pinColor = MAPinAnnotationColorRed;
        return annotationView;
    }
    return nil;
}

@end
