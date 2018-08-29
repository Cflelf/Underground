//
//  ViewController.m
//  Underground
//
//  Created by 潘潇睿 on 2018/8/21.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "ChooseLineVC.h"
#import <AFNetworking/AFNetworking.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "APIKey.h"
#import "Const.h"
#import "LineHeaderView.h"
#import "LocateHeaderView.h"
#import "ChoosePlatformVC.h"

#define DefaultLocationTimeout 10
#define DefaultReGeocodeTimeout 5
#define ReuseSectionIdentifier @"LineName"
#define CurrentCity @"CurrentCity"

@interface ChooseLineVC () <AMapLocationManagerDelegate,AMapSearchDelegate,
                                UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)AMapLocationManager *locationManager;
@property (nonatomic, copy)AMapLocatingCompletionBlock completionBlock;
@property (nonatomic, strong)AMapSearchAPI* search;
@property (nonatomic, strong)LocateHeaderView* locateHeaderView;

@property (nonatomic, strong)NSMutableDictionary *metroInfoDic;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ChooseLineVC

- (void)initCompleteBlock{
    __weak ChooseLineVC *weakSelf = self;
    self.completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
    {
        if (error){
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            if (error.code == AMapLocationErrorLocateFailed){
                return;
            }
        }
        
        weakSelf.search = [[AMapSearchAPI alloc] init];
        weakSelf.search.delegate = weakSelf;
        AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
        regeo.location = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        regeo.requireExtension = YES;
        [weakSelf.search AMapReGoecodeSearch:regeo];
    };
}

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    if (response.regeocode != nil)
    {
        NSLog(@"%@",response.regeocode.addressComponent);
        
        NSString *city = response.regeocode.addressComponent.city;
        
        [NSUserDefaults.standardUserDefaults setValue:city forKey:CurrentCity];
        
        [self initMetroInfoDic:city];
    }
}

- (void)initMetroInfoDic:(NSString *)city{
    for (NSString* key in ALL_METRO_DIC.allKeys) {
        if([key containsString:city]||[city containsString:key]){
            self.metroInfoDic = [ALL_METRO_DIC objectForKey:key];
            self.locateHeaderView.label.text = [@"当前定位:" stringByAppendingString:city];
            [self.tableView reloadData];
            return;
        }
    }
    self.locateHeaderView.label.text = [NSString stringWithFormat:@"当前定位:%@,暂无地铁信息",city];
}

- (void)configLocationManager{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    //设置期望定位精度
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    //设置不允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    //设置允许在后台定位
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    //设置定位超时时间
    [self.locationManager setLocationTimeout:DefaultLocationTimeout];
    
    //设置逆地理超时时间
    [self.locationManager setReGeocodeTimeout:DefaultReGeocodeTimeout];
}

#pragma life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"选择线路";
    
    self.metroInfoDic = [[NSMutableDictionary alloc] init];
    self.locateHeaderView = [[LocateHeaderView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:LineHeaderView.class forCellReuseIdentifier:ReuseSectionIdentifier];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if([NSUserDefaults.standardUserDefaults objectForKey:CurrentCity]){
        [self initMetroInfoDic:[NSUserDefaults.standardUserDefaults objectForKey:CurrentCity]];
    }else{
        [self configLocationManager];
        [self initCompleteBlock];
        [self.locationManager requestLocationWithReGeocode:true completionBlock:self.completionBlock];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.metroInfoDic.allKeys.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.locateHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LineHeaderView *cell = [tableView dequeueReusableCellWithIdentifier:ReuseSectionIdentifier];
    
    if(!cell){
        cell = [tableView dequeueReusableCellWithIdentifier:ReuseSectionIdentifier forIndexPath:indexPath];
    }
    
    cell.titleLabel.text = self.metroInfoDic.allKeys[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showPlatforms" sender:[self.metroInfoDic objectForKey:self.metroInfoDic.allKeys[indexPath.row]]];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqual: @"showPlatforms"]){
        ChoosePlatformVC *controller = segue.destinationViewController;
        controller.platforms = sender;
    }
}


@end
