//
//  MSLocationController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/11/29.
//

#import "MSLocationController.h"
#import "MSLocationListCell.h"
#import "MSIMSDK-UIKit.h"
#import <MJRefresh.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <MSIMSDK/MSIMSDK.h>


@interface MSLocationController ()<UITableViewDelegate,UITableViewDataSource,AMapSearchDelegate,MAMapViewDelegate>

@property(nonatomic,strong) UIView *navView;

@property(nonatomic,strong) MAMapView *mapView;

@property(nonatomic,strong) AMapSearchAPI *searchAPI;

@property(nonatomic,strong) AMapPOIAroundSearchRequest *poiRequest;

@property(nonatomic,strong) CLLocation *userLocation;

@property(nonatomic,assign) NSInteger page;

@property(nonatomic,strong) UITableView *myTableView;

@property(nonatomic,strong) UIButton *myLocationBtn;

@property(nonatomic,strong) NSMutableArray<MSLocationInfo *> *listArr;

@property(nonatomic,strong) MSLocationInfo *selectInfo;

@property(nonatomic,strong) MAPointAnnotation *annotation;

@end

@implementation MSLocationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];

    [self setupNavView];
    [AMapServices sharedServices].apiKey = GaodeAPIKey;
    [AMapSearchAPI updatePrivacyShow:AMapPrivacyShowStatusDidShow privacyInfo:AMapPrivacyInfoStatusDidContain];
    [AMapSearchAPI updatePrivacyAgree:AMapPrivacyAgreeStatusDidAgree];
    [AMapServices sharedServices].enableHTTPS = YES;

    [self.view addSubview:self.mapView];
    [self.view addSubview:self.myTableView];
    [self.view addSubview:self.myLocationBtn];
}

- (void)dealloc
{
    MSLog(@"%@ dealloc",self.class);
}

static inline CGFloat kTableViewMaxY() {
    return Screen_Height*0.6;
}

static inline CGFloat kTableViewMinY() {
    return Screen_Height*0.4;
}

- (UITableView *)myTableView
{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kTableViewMaxY(), Screen_Width, Screen_Height - kTableViewMaxY()) style:UITableViewStylePlain];
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        _myTableView.tableFooterView = [UIView new];
        _myTableView.backgroundColor = self.view.backgroundColor;
        [_myTableView registerClass:[MSLocationListCell class] forCellReuseIdentifier:@"locationCell"];
        _myTableView.rowHeight = 70;
        _myTableView.separatorColor = [UIColor d_colorWithColorLight:TCell_separatorColor dark:TCell_separatorColor_Dark];
        _myTableView.layer.cornerRadius = 16;
        _myTableView.clipsToBounds = YES;
        WS(weakSelf)
        _myTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [weakSelf loadMorePOI];
        }];
    }
    return _myTableView;
}

- (MAMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, kTableViewMaxY())];
        _mapView.showsUserLocation = YES;
        _mapView.userTrackingMode = MAUserTrackingModeFollow;
//        _mapView.language = MAMapLanguageEn;
        _mapView.showsCompass = NO;
        _mapView.showsScale = NO;
        _mapView.zoomLevel = 17;
        _mapView.delegate = self;
    }
    return _mapView;
}

- (AMapSearchAPI *)searchAPI
{
    if (!_searchAPI) {
        _searchAPI = [[AMapSearchAPI alloc]init];
        _searchAPI.delegate = self;
    }
    return _searchAPI;
}

- (UIButton *)myLocationBtn
{
    if (!_myLocationBtn) {
        _myLocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_myLocationBtn setImage:[UIImage imageNamed:TUIKitResource(@"location_my")] forState:UIControlStateNormal];
        [_myLocationBtn addTarget:self action:@selector(myLocationBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _myLocationBtn.frame = CGRectMake(Screen_Width - 60 - 15, kTableViewMaxY() - 60 - 15, 60, 60);
    }
    return _myLocationBtn;
}

- (NSMutableArray<MSLocationInfo *> *)listArr
{
    if (!_listArr) {
        _listArr = [NSMutableArray array];
    }
    return _listArr;
}

- (void)setUserLocation:(CLLocation *)userLocation
{
    _userLocation = userLocation;
    [self addAnnotation:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
}

- (AMapPOIAroundSearchRequest *)poiRequest
{
    if (!_poiRequest) {
        _poiRequest = [[AMapPOIAroundSearchRequest alloc]init];
        _poiRequest.sortrule = 0;
        _poiRequest.requireExtension = YES;
        _poiRequest.types = @"汽车销售|餐饮服务|购物服务|生活服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|地名地址信息|公共设施";
    }
    return _poiRequest;
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
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setTitle:TUILocalizableString(Send) forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sendBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    sendBtn.backgroundColor = [UIColor d_systemBlueColor];
    sendBtn.layer.cornerRadius = 4;
    sendBtn.layer.masksToBounds = YES;
    [sendBtn addTarget:self action:@selector(sendBtnClick) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.frame = CGRectMake(Screen_Width - 10 - 60, StatusBar_Height + 7, 60, 30);
    [self.navView addSubview:sendBtn];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.view bringSubviewToFront:self.navView];
}

#pragma mark - button event

- (void)cancelBtnClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendBtnClick
{
    if (self.selectInfo == nil) {
        return;
    }
    if (self.selectLocation) {
        self.selectInfo.zoom = self.mapView.zoomLevel;
        self.selectLocation(self.selectInfo);
    }
    [self cancelBtnClick];
}

- (void)myLocationBtnClick
{
    self.userLocation = self.mapView.userLocation.location;
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    self.page = 1;
    [self.listArr removeAllObjects];
    [self.myTableView reloadData];
    [self searchPOI];
}

- (void)loadMorePOI
{
    self.page++;
    [self searchPOI];
}

- (void)searchPOI
{
    self.poiRequest.page = self.page;
    self.poiRequest.location = [AMapGeoPoint locationWithLatitude:self.userLocation.coordinate.latitude longitude:self.userLocation.coordinate.longitude];
    [self.searchAPI AMapPOIAroundSearch:self.poiRequest];
}

- (void)addAnnotation:(double)latitude longitude:(double)longitude
{
    [self.mapView removeAnnotation:self.annotation];
    self.annotation = [[MAPointAnnotation alloc] init];
    self.annotation.title = @"pointReuseIndentifier";
    self.annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    [self.mapView addAnnotation:self.annotation];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSLocationListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell" forIndexPath:indexPath];
    [cell configCell:self.listArr[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectInfo.isSelect = NO;
    MSLocationInfo *info = self.listArr[indexPath.row];
    info.isSelect = YES;
    self.selectInfo = info;
    [self.myTableView reloadData];
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(info.latitude, info.longitude) animated:YES];
    [self addAnnotation:info.latitude longitude:info.longitude];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGPoint point = [scrollView.panGestureRecognizer velocityInView:scrollView];
    if (point.y > 0) {//下滑
        if ((NSInteger)self.myTableView.y == (NSInteger)kTableViewMinY() && self.myTableView.contentOffset.y <= 0.f) {
            [UIView animateWithDuration:0.4 animations:^{
                self.myTableView.y = kTableViewMaxY();
                self.myLocationBtn.maxY = kTableViewMaxY() - 15;
                self.mapView.y = 0;
            } completion:^(BOOL finished) {
                self.myTableView.height = Screen_Height - kTableViewMaxY();
            }];
            self.myTableView.scrollEnabled = NO;
        }
    }else {//上滑
        if ((NSInteger)self.myTableView.y == (NSInteger)kTableViewMaxY() && self.myTableView.contentOffset.y <= 0.f) {
            self.myTableView.height = Screen_Height - kTableViewMinY();
            [UIView animateWithDuration:0.4 animations:^{
                self.myTableView.y = kTableViewMinY();
                self.mapView.y = -(kTableViewMaxY() - kTableViewMinY()) * 0.5;
                self.myLocationBtn.maxY = kTableViewMinY() - 15;
            } completion:^(BOOL finished) {
               
            }];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.myTableView.scrollEnabled = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        scrollView.contentOffset = CGPointZero;
    }
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (self.userLocation == nil) {
        self.userLocation = userLocation.location;
        self.page = 1;
        [self.listArr removeAllObjects];
        [self.myTableView reloadData];
        [self searchPOI];
    }
}

- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction
{
    if (wasUserAction) {
        self.page = 1;
        self.userLocation = [[CLLocation alloc]initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
        [self.listArr removeAllObjects];
        [self.myTableView reloadData];
        [self searchPOI];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation.title isEqualToString:@"pointReuseIndentifier"]) {
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

#pragma mark - AMapSearchDelegate

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    [self.myTableView.mj_footer endRefreshing];
    if (response.pois.count == 0) {
        [self.myTableView.mj_footer endRefreshingWithNoMoreData];
    }
    for (AMapPOI *poi in response.pois) {
        MSLocationInfo *info = [[MSLocationInfo alloc]init];
        info.name = poi.name;
        info.address = poi.address;
        info.detail = [NSString stringWithFormat:@"%@%@%@%@",XMNoNilString(poi.province),XMNoNilString(poi.city),XMNoNilString(poi.district),XMNoNilString(poi.address)];
        info.distance = poi.distance;
        info.city = poi.city;
        info.province = poi.province;
        info.district = poi.district;
        info.latitude = poi.location.latitude;
        info.longitude = poi.location.longitude;
        [self.listArr addObject:info];
    }
    if (self.page == 1) {
        self.selectInfo = self.listArr.firstObject;
        self.selectInfo.isSelect = YES;
    }
    [self.myTableView reloadData];
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    MSLog(@"AMapSearchRequest failed: %@",error);
    [self.myTableView.mj_footer endRefreshing];
}

@end
