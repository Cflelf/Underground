//
//  GeoFenceViewController.m
//  Underground
//
//  Created by 潘潇睿 on 2018/9/4.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "GeoFenceViewController.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <MAMapKit/MAMapKit.h>
#import "Const.h"
#import <Masonry/Masonry.h>
#import <UserNotifications/UserNotifications.h>
#import "AppDelegate.h"
#import "Const.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Tools.h"

@interface GeoFenceViewController ()<AMapGeoFenceManagerDelegate,MAMapViewDelegate, AMapLocationManagerDelegate>
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic,strong) AMapGeoFenceManager *geoFenceManager;
@property (weak, nonatomic) IBOutlet MAMapView *mapView;
@property (nonatomic,assign) Boolean enterBackground;
@property (nonatomic,assign) Boolean missionComplete;
@end

@implementation GeoFenceViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:true];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:false];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"行驶中";
    self.missionComplete = false;
    [AMapServices sharedServices].enableHTTPS = true;
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = true;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    [self.mapView setZoomLevel:12 animated:false];
    
    self.geoFenceManager = [[AMapGeoFenceManager alloc] init];
    self.geoFenceManager.delegate = self;
    self.geoFenceManager.activeAction = AMapGeoFenceActiveActionInside;
    self.geoFenceManager.allowsBackgroundLocationUpdates = true;  //允许后台定位
    
    //创建地理围栏
    for(AMapBusStop *stop in self.remindPFs){
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(stop.location.latitude, stop.location.longitude);
        [self.geoFenceManager addCircleRegionForMonitoringWithCenter:coordinate radius:300 customID:stop.name];
    }
    
    [self configLocationManager];
    
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter]
       rac_addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(NSNotification *notification) {
         @strongify(self)
         self.enterBackground = true;
     }];
    
    [[[[NSNotificationCenter defaultCenter]
       rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(NSNotification *notification) {
         @strongify(self)
         self.enterBackground = false;
     }];
    
    [self saveInfo];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.locationManager startUpdatingLocation];
}

- (void)configLocationManager{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    //设置不允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    //设置允许在后台定位
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    //设置允许连续定位逆地理
    [self.locationManager setLocatingWithReGeocode:YES];
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MACircle class]])
    {
        MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        circleRenderer.lineWidth = 2.0f;
        circleRenderer.strokeColor = ThemeColor;
        circleRenderer.fillColor = ThemeColor;
        circleRenderer.alpha = 0.5;
        return circleRenderer;
    }
    return nil;
}

- (void)amapGeoFenceManager:(AMapGeoFenceManager *)manager didAddRegionForMonitoringFinished:(NSArray<AMapGeoFenceRegion *> *)regions customID:(NSString *)customID error:(NSError *)error{
    AMapGeoFenceCircleRegion *circleRegion = (AMapGeoFenceCircleRegion *)regions.firstObject;
    //构造圆
    MACircle *circle = [MACircle circleWithCenterCoordinate:circleRegion.center radius:500];
    //在地图上添加圆
    [self.mapView addOverlay:circle];
}

- (void)amapGeoFenceManager:(AMapGeoFenceManager *)manager didGeoFencesStatusChangedForRegion:(AMapGeoFenceRegion *)region customID:(NSString *)customID error:(NSError *)error{
    if (error) {
        NSLog(@"status changed error %@",error);
    }else{
        if(region.fenceStatus == AMapGeoFenceRegionStatusInside){
            [AppDelegate registerNotification:1 title:@"到站提醒!" body:[NSString stringWithFormat:@"%@快到了，赶紧下车啦",customID]];
        }
        
        if ([customID isEqualToString:((AMapBusStop *)self.remindPFs.firstObject).name]) {
            self.missionComplete = true;
            [self saveInfo];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    if(!self.enterBackground){
        [self.mapView setCenterCoordinate:userLocation.coordinate];
    }
    
}

- (void)saveInfo{
    [[NSUserDefaults standardUserDefaults] setBool:self.missionComplete forKey:@"missonComplete"];
    [[NSUserDefaults standardUserDefaults] setObject:[Tools toJSONData:self.remindPFs] forKey:@"remindPFS"];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
