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
#import "PlanTableViewCell.h"

#define Max(a,b) ( ((a) > (b)) ? (a) : (b) )
#define Min(a,b) ( ((a) < (b)) ? (a) : (b) )

@interface GeoFenceViewController ()<AMapGeoFenceManagerDelegate,MAMapViewDelegate, AMapLocationManagerDelegate,BackButtonHandlerProtocol,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic,strong) AMapGeoFenceManager *geoFenceManager;
@property (weak, nonatomic) IBOutlet MAMapView *mapView;
@property (nonatomic,assign) Boolean enterBackground;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (assign,nonatomic) Boolean isUp;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong,nonatomic) NSMutableArray *cellArrays;
@property (strong,nonatomic) UIPanGestureRecognizer *pan;
@property (weak, nonatomic) IBOutlet UILabel *startEndLabel;
@property (weak, nonatomic) IBOutlet UIView *remindView;

@end

@implementation GeoFenceViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = false;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = true;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"行驶中";
    
    [self generateCells];
    
    self.remindView.layer.cornerRadius = 3;
    
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.tableFooterView = [UIView new];
    self.table.estimatedRowHeight = 0;
    self.table.estimatedSectionHeaderHeight = 0;
    self.table.estimatedSectionFooterHeight = 0;
    
    [AMapServices sharedServices].enableHTTPS = true;
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = true;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    self.geoFenceManager = [[AMapGeoFenceManager alloc] init];
    self.geoFenceManager.delegate = self;
    self.geoFenceManager.activeAction = AMapGeoFenceActiveActionInside;
    self.geoFenceManager.allowsBackgroundLocationUpdates = true;  //允许后台定位
    
    //创建地理围栏
    for(MyBusStop *bus in self.plan.viaPlatforms){
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(bus.stop.location.latitude, bus.stop.location.longitude);
        [self.geoFenceManager addCircleRegionForMonitoringWithCenter:coordinate radius:[RADIUS doubleValue] customID:bus.stop.name];
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
    
    self.pan = [UIPanGestureRecognizer new];
    self.pan.delegate = self;
    [self.pan.rac_gestureSignal subscribeNext:^(UIPanGestureRecognizer *rec) {
        @strongify(self)
        CGPoint point = [rec translationInView:rec.view];
        if(point.y<-3){
            self.isUp = true;
            self.topConstraint.constant = Max(self.topConstraint.constant + point.y, -self.mapView.frame.size.height);
        }else if(point.y>3){
            self.isUp = false;
            self.topConstraint.constant = Min(self.topConstraint.constant + point.y, 0);
        }
        
        [self.view layoutIfNeeded];
        [rec setTranslation:CGPointMake(0, 0) inView:rec.view];
        
        if(rec.state == UIGestureRecognizerStateEnded){
            if (self.isUp) {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.topConstraint.constant = -self.mapView.frame.size.height;
                    [self.view layoutIfNeeded];
                } completion:nil];
            }else{
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.topConstraint.constant = 0;
                    [self.view layoutIfNeeded];
                } completion:nil];
            }
        }
    }];
    [self.table addGestureRecognizer:self.pan];

    [RACObserve(self, topConstraint.constant) subscribeNext:^(NSNumber *num) {
        @strongify(self)
        if ([num integerValue] == -self.mapView.frame.size.height) {
            [self.table setScrollEnabled:true];
        }
    }];
    
    [self saveInfo];
    
    self.startEndLabel.text = [NSString stringWithFormat:@"%@ -> %@",self.plan.viaPlatforms[0].stop.name,self.plan.viaPlatforms.lastObject.stop.name];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.locationManager startUpdatingLocation];
    
//    [self MetroAnimate];
    
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

- (void)configLocationManager{
    self.locationManager = [[AMapLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setPausesLocationUpdatesAutomatically:YES];
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
    if ([self getMission:customID] && ![self getMission:customID].completed) {
        AMapGeoFenceCircleRegion *circleRegion = (AMapGeoFenceCircleRegion *)regions.firstObject;
        //构造圆
        MACircle *circle = [MACircle circleWithCenterCoordinate:circleRegion.center radius:[RADIUS doubleValue]];
        //在地图上添加圆
        [self.mapView addOverlay:circle];
    }
}

- (void)amapGeoFenceManager:(AMapGeoFenceManager *)manager didGeoFencesStatusChangedForRegion:(AMapGeoFenceRegion *)region customID:(NSString *)customID error:(NSError *)error{
    if (error) {
        NSLog(@"status changed error %@",error);
    }else{
        if(region.fenceStatus == AMapGeoFenceRegionStatusInside){
            if([self getMission:customID] && ![self getMission:customID].completed){
                [AppDelegate registerNotification:1 title:@"到站提醒!" body:[NSString stringWithFormat:@"%@快到了，赶紧下车啦",customID]];
                [self getMission:customID].completed = true;
                [manager removeGeoFenceRegionsWithCustomID:customID];
                
                if([self checkAllMissionComplete]){
                    [self.locationManager stopUpdatingLocation];
                }
            }
            for(int i=0;i<self.cellArrays.count;i++) {
                PlanTableViewCell *cell = self.cellArrays[i];
                [cell.metroImage setHidden:true];
                if ([cell.titleLabel.text isEqualToString:customID]) {
                    [self.table setContentOffset:CGPointMake(0, Max(0, i-3)*44) animated:true];
                    [UIView animateWithDuration:1 animations:^{
                        [cell.metroImage setHidden:false];
                        cell.constraint.constant = 200;
                        [cell layoutIfNeeded];
                    }];
                    if([self getMission:customID]){
                        [cell.finishImage setHighlighted:true];
                    }
                    break;
                }
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
    if (gestureRecognizer == self.pan) {
        return true;
    }
    return [self checkAllMissionComplete];
}

- (void)generateCells{
    self.cellArrays = [[NSMutableArray alloc] init];
    
    for (int i=0; i<self.plan.viaPlatforms.count; i++) {
        MyBusStop *bus = self.plan.viaPlatforms[i];
        PlanTableViewCell *cell = [self.table dequeueReusableCellWithIdentifier:@"plan"];
        
        if(!cell){
            cell = [self.table dequeueReusableCellWithIdentifier:@"plan" forIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        }
        
        cell.titleLabel.text = bus.stop.name;
        cell.subTitle.text = bus.line;
        
        if(i == 0){
            cell.typeLabel = [cell.typeLabel initWithStyle:MetroPFTypeStart text:@"起始站"];
        }else if(i == self.plan.viaPlatforms.count-1){
            cell.typeLabel = [cell.typeLabel initWithStyle:MetroPFTypeEnd text:@"终点站"];
        }
        
        for(AMapBusStop *stop in self.plan.changePlatforms){
            if([stop.name isEqualToString:bus.stop.name]){
                cell.typeLabel = [cell.typeLabel initWithStyle:MetroPFTypeChange text:@"换乘"];
                break;
            }
        }
        
        [cell.finishImage setHidden:true];
        for(Mission *m in self.remindMissions){
            if([cell.titleLabel.text isEqualToString:m.stop.name]){
                [cell.finishImage setHidden:false];
                break;
            }
        }
        
        [self.cellArrays addObject:cell];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.cellArrays.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.cellArrays[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y <= 0){
        [self.table setScrollEnabled:false];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if(self.topConstraint.constant == -self.mapView.frame.size.height){
        return true;
    }
    return false;
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
