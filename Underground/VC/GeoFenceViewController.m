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
#import "UIViewController+BackButtonHandler.h"

@interface GeoFenceViewController ()<AMapGeoFenceManagerDelegate,MAMapViewDelegate, AMapLocationManagerDelegate,BackButtonHandlerProtocol,UIGestureRecognizerDelegate>
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic,strong) AMapGeoFenceManager *geoFenceManager;
@property (weak, nonatomic) IBOutlet MAMapView *mapView;
@property (nonatomic,assign) Boolean enterBackground;
@property (weak, nonatomic) IBOutlet UIImageView *metroImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingConstraint;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation GeoFenceViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.metroImage setHidden:false];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.metroImage setHidden:true];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"行驶中";
    [AMapServices sharedServices].enableHTTPS = true;
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = true;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    self.geoFenceManager = [[AMapGeoFenceManager alloc] init];
    self.geoFenceManager.delegate = self;
    self.geoFenceManager.activeAction = AMapGeoFenceActiveActionInside;
    self.geoFenceManager.allowsBackgroundLocationUpdates = true;  //允许后台定位
    
    //创建地理围栏
    for(Mission *mission in self.remindMissions){
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(mission.stop.location.latitude, mission.stop.location.longitude);
        [self.geoFenceManager addCircleRegionForMonitoringWithCenter:coordinate radius:[RADIUS doubleValue] customID:mission.stop.name];
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
         if(![self checkAllMissionComplete]){
             [self MetroAnimate];
         }
     }];
    
    [self saveInfo];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.locationManager startUpdatingLocation];
    
    [self MetroAnimate];
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (void)MetroAnimate{
    [UIView animateWithDuration:3 delay:0.5 options: UIViewAnimationOptionCurveEaseIn animations:^{
        self.trailingConstraint.constant += ScreenWidth*4.8/5;
        [self.metroImage.superview layoutIfNeeded];
    } completion:^(BOOL b){
        if (![self checkAllMissionComplete]) {
            [UIView animateWithDuration:3 delay:2 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.trailingConstraint.constant += 1500 - ScreenWidth*4.8/5;
                [self.metroImage.superview layoutIfNeeded];
            } completion:^(BOOL finished) {
                if(finished && ![self checkAllMissionComplete]){
                    self.trailingConstraint.constant = 0;
                    [self.metroImage.superview layoutIfNeeded];
                    [self MetroAnimate];
                }
            }];
        }
    }];
}



- (void)configLocationManager{
    self.locationManager = [[AMapLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    [self.locationManager setLocatingWithReGeocode:YES];
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay{
    if ([overlay isKindOfClass:[MACircle class]])
    {
        MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        circleRenderer.lineWidth = 2.0f;
        circleRenderer.strokeColor = ThemeColor;
        circleRenderer.fillColor = [UIColor redColor];
        circleRenderer.alpha = 0.5;
        return circleRenderer;
    }
    return nil;
}

- (void)amapGeoFenceManager:(AMapGeoFenceManager *)manager didAddRegionForMonitoringFinished:(NSArray<AMapGeoFenceRegion *> *)regions customID:(NSString *)customID error:(NSError *)error{
    AMapGeoFenceCircleRegion *circleRegion = (AMapGeoFenceCircleRegion *)regions.firstObject;
    //构造圆
    MACircle *circle = [MACircle circleWithCenterCoordinate:circleRegion.center radius:[RADIUS doubleValue]];
    //在地图上添加圆
    [self.mapView addOverlay:circle];
}

- (void)amapGeoFenceManager:(AMapGeoFenceManager *)manager didGeoFencesStatusChangedForRegion:(AMapGeoFenceRegion *)region customID:(NSString *)customID error:(NSError *)error{
    if (error) {
        NSLog(@"status changed error %@",error);
    }else{
        if(region.fenceStatus == AMapGeoFenceRegionStatusInside && ![self getMission:customID].completed){
            [AppDelegate registerNotification:1 title:@"到站提醒!" body:[NSString stringWithFormat:@"%@快到了，赶紧下车啦",customID]];
            [self getMission:customID].completed = true;
            [manager removeGeoFenceRegionsWithCustomID:customID];
            
            if([self checkAllMissionComplete]){
                [self.locationManager stopUpdatingLocation];
            }
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
    [[NSUserDefaults standardUserDefaults] setBool:[self checkAllMissionComplete] forKey:@"missonComplete"];
    [[NSUserDefaults standardUserDefaults] setObject:[Tools toJSONData:self.remindMissions] forKey:@"remindMissions"];
}

- (Mission *)getMission:(NSString *)name{
    for (Mission *mission in self.remindMissions) {
        if ([mission.stop.name isEqualToString:name]) {
            return mission;
        }
    }
    return nil;
}

- (Boolean)checkAllMissionComplete{
    for (Mission *mission in self.remindMissions) {
        if (!mission.completed) {
            return false;
        }
    }
    self.title = @"当前行程已完成";
    return true;
}

- (BOOL)navigationShouldPopOnBackButton{
    if(![self checkAllMissionComplete]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"这次行程还未完成,你确定要离开吗" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:true];
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:nil];
        return false;
    }else{
        return true;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return [self checkAllMissionComplete];
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
