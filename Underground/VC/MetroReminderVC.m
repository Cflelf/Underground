//
//  MetroReminderVC.m
//  Underground
//
//  Created by 潘潇睿 on 2018/8/27.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "MetroReminderVC.h"
#import "UIView+Toast.h"
#import "Const.h"
#import "HistoryCollectionViewCell.h"
#import "ChoosePlanVC.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "APIKey.h"
#import "ChooseLineVC.h"
#import "Tools.h"

#define DefaultLocationTimeout 5
#define DefaultReGeocodeTimeout 5

@interface MetroReminderVC ()<UITextFieldDelegate,AMapSearchDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,AMapLocationManagerDelegate,AMapSearchDelegate>

@property(nonatomic,strong)AMapGeoPoint *startPoint;
@property(nonatomic,strong)AMapGeoPoint *endPoint;
@property(nonatomic,strong)AMapTransitRouteSearchRequest *navi;
@property(nonatomic,strong)AMapSearchAPI *search;
@property (weak, nonatomic) IBOutlet UIView *historyView;
@property (weak, nonatomic) IBOutlet UICollectionView *historyCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *remindButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic,assign) BOOL startRequest;
@property (nonatomic, strong)AMapLocationManager *locationManager;
@property (nonatomic, copy)AMapLocatingCompletionBlock completionBlock;
@property (weak, nonatomic) IBOutlet UILabel *currentCityLabel;
@property (nonatomic,strong)NSArray *sortedHistories;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;
@property (weak, nonatomic) IBOutlet UIView *remindRadiusView;
@property (weak, nonatomic) IBOutlet UILabel *remindRadiusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *locateIcon;
@property (weak, nonatomic) IBOutlet UILabel *remindWords;
@property (nonatomic, strong)NSMutableDictionary *metroInfoDic;
@end

@implementation MetroReminderVC

#pragma Life Cycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.startPoint = nil;
    self.endPoint = nil;
    
    self.sortedHistories = [Tools sortedDictionary:HISTORYS[CURRENT_CITY]];
    [self.historyCollectionView reloadData];
    
    if(self.sortedHistories.count > 0){
        [self.remindWords setHidden:false];
    }else{
        [self.remindWords setHidden:true];
    }
}

- (void)initCurrentCity{
    self.startRequest = true;
    self.currentCityLabel.text = @"定位当前城市中...";
    [self configLocationManager];
    [self initCompleteBlock];
    [self.locationManager requestLocationWithReGeocode:true completionBlock:self.completionBlock];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.startRequest = false;
    self.startPF.delegate = self;
    self.endPF.delegate = self;
    
    [self initCurrentCity];
    
    if(RADIUS){
        self.remindRadiusLabel.text = [NSString stringWithFormat:@"<%@米",[RADIUS stringValue] ];
    }else{
        [NSUserDefaults.standardUserDefaults setObject:[NSNumber numberWithInt:800] forKey:@"Radius"];
    }
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    self.historyCollectionView.delegate = self;
    self.historyCollectionView.dataSource = self;
    [self.historyCollectionView registerClass:HistoryCollectionViewCell.class forCellWithReuseIdentifier:@"History"];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.historyCollectionView setCollectionViewLayout:layout animated:true];
    
    @weakify(self)
    [[RACSignal combineLatest:(@[RACObserve(self, startRequest),RACObserve(self, currentCityLabel.text),RACObserve(self, metroInfoDic)])] subscribeNext:^(RACTuple *tuple) {
        @strongify(self)
        if([tuple.first integerValue]){
            [self.indicator startAnimating];
        }else{
            [self.indicator stopAnimating];
        }
        [self.locateIcon setUserInteractionEnabled:![tuple.first integerValue]];
        BOOL b = [tuple.first integerValue] || ([tuple.second containsString:@"定位"] || !tuple.third);
        [self.remindButton setBackgroundColor:b?[UIColor lightGrayColor]:ThemeColor];
        [self.remindButton setUserInteractionEnabled:!b];
        [self.startPF setUserInteractionEnabled:!b];
        [self.endPF setUserInteractionEnabled:!b];
        [self.historyCollectionView setUserInteractionEnabled:!b];
        [self.changeButton setUserInteractionEnabled:!b];
        [self.remindRadiusView setUserInteractionEnabled:!b];
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap.rac_gestureSignal subscribeNext:^(UITapGestureRecognizer *tap) {
        [self initCurrentCity];
    }];
    [self.locateIcon addGestureRecognizer:tap];
    [self.currentCityLabel setUserInteractionEnabled:true];
    [self.currentCityLabel addGestureRecognizer:tap];
    
    tap = [[UITapGestureRecognizer alloc] init];
    [tap.rac_gestureSignal subscribeNext:^(UITapGestureRecognizer *tap) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择提醒范围"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"800(默认)" style:UIAlertActionStyleDefault handler:^(id x){
            self.remindRadiusLabel.text = @"<800米(默认)";
            [NSUserDefaults.standardUserDefaults setObject:[NSNumber numberWithInt:800] forKey:@"Radius"];
        }];
        [alertController addAction:defaultAction];
        
        UIAlertAction *thousandAction = [UIAlertAction actionWithTitle:@"1000" style:UIAlertActionStyleDefault handler:^(id x){
            self.remindRadiusLabel.text = @"<1000米";
            [NSUserDefaults.standardUserDefaults setObject:[NSNumber numberWithInt:1000] forKey:@"Radius"];
        }];
        [alertController addAction:thousandAction];
        
        UIAlertAction *largestAction = [UIAlertAction actionWithTitle:@"1500" style:UIAlertActionStyleDefault handler:^(id x){
            self.remindRadiusLabel.text = @"<1500米";
            [NSUserDefaults.standardUserDefaults setObject:[NSNumber numberWithInt:1500] forKey:@"Radius"];
        }];
        [alertController addAction:largestAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    [self.remindRadiusView addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma CollectionView

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self sizingForRowAtIndexPath:indexPath];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 8.0f;
}

- (CGSize)sizingForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryCollectionViewCell *sizingCell = nil;
    sizingCell = [[HistoryCollectionViewCell alloc] init];
    
    sizingCell.label.text = self.sortedHistories[indexPath.row];
    [sizingCell.label sizeToFit];
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    CGSize cellSize = CGSizeMake(sizingCell.label.frame.size.width+12, 30);
    return cellSize;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSMutableArray *array = HISTORYS[CURRENT_CITY];
    return array ? array.count : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HistoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"History" forIndexPath:indexPath];
    cell.label.text = self.sortedHistories[indexPath.row];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    return cell;
}

- (IBAction)exchange:(UIButton *)sender {
    NSString *temp = self.startPF.text;
    self.startPF.text = self.endPF.text;
    self.endPF.text = temp;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.type = textField == self.startPF ? 0:1;
    [self performSegueWithIdentifier:@"chooseLine" sender:nil];
    return false;
}

- (IBAction)setReminder:(UIButton *)sender {
    NSString *start = self.startPF.text;
    NSString *end = self.endPF.text;
    
    if (start.length == 0 || end.length == 0) {
        [self.view showMyToast:@"请填写完整"];
        return;
    }else if([start isEqualToString:end]){
        [self.view showMyToast:@"起始站和终点站不能一致"];
        return;
    }
    self.startRequest = true;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
            request.city                = CURRENT_CITY;
            request.types               = @"地铁站";
            request.requireExtension    = YES;
            request.cityLimit           = YES;
            request.keywords = [[CURRENT_CITY stringByAppendingString:start] stringByAppendingString:@"(地铁站)"];
            [self.search AMapPOIKeywordsSearch:request];
        });
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
            request.city                = CURRENT_CITY;
            request.types               = @"地铁站";
            request.requireExtension    = YES;
            request.cityLimit           = YES;
            request.keywords = [[CURRENT_CITY stringByAppendingString:end] stringByAppendingString:@"(地铁站)"];
            [self.search AMapPOIKeywordsSearch:request];
        });
    });
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    if (response.pois.count > 0) {
        double lat = response.pois[0].location.latitude;
        double lon = response.pois[0].location.longitude;
        if (self.startPoint == nil) {
            self.navi = [[AMapTransitRouteSearchRequest alloc] init];
            self.navi.requireExtension = YES;
            self.startPoint = [AMapGeoPoint locationWithLatitude:lat
                                                       longitude:lon];
            self.navi.origin = self.startPoint;
        }else if((lat!=self.startPoint.latitude&&lon!=self.startPoint.longitude)&&self.endPoint == nil){
            self.endPoint = [AMapGeoPoint locationWithLatitude:lat
                                                     longitude:lon];
            self.navi.destination = self.endPoint;
            self.navi.city = [NSUserDefaults.standardUserDefaults objectForKey:@"CurrentCity"];
            [self.search AMapTransitRouteSearch:self.navi];
        }
        
    }else{
        self.startRequest = false;
        [self.view showMyToast:@"查找位置失败"];
    }
}


- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response{
    self.startRequest = false;
    if (response && response.route.transits.count > 0 && response.route.transits[0].segments.count > 0) {
        
        [self saveHistory];
        
        [self performSegueWithIdentifier:@"choosePlan" sender:response.route];
    }
}

- (void)saveHistory{
    NSMutableDictionary *dic;
    NSMutableDictionary *cityDic;
    //如果存储过历史
    if (HISTORYS) {
        dic = [[NSMutableDictionary alloc] initWithDictionary:HISTORYS];
        //如果已存在城市记录
        if([dic objectForKey:self.currentCityLabel.text]){
            cityDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:self.currentCityLabel.text]];
            //如果已存在站点记录，直接在数量上加一
            if ([cityDic objectForKey:self.startPF.text]) {
                [cityDic setObject:[NSNumber numberWithInt:([[cityDic objectForKey:self.startPF.text] intValue] + 1)] forKey:self.startPF.text];
            }else{
                [cityDic setObject:[NSNumber numberWithInt:1] forKey:self.startPF.text];
            }
            
            if ([cityDic objectForKey:self.endPF.text]) {
                [cityDic setObject:[NSNumber numberWithInt:([[cityDic objectForKey:self.endPF.text] intValue] + 1)] forKey:self.endPF.text];
            }else{
                [cityDic setObject:[NSNumber numberWithInt:1] forKey:self.endPF.text];
            }
        }else{
            cityDic = [[NSMutableDictionary alloc] init];
            [cityDic setObject:[NSNumber numberWithInt:1] forKey:self.startPF.text];
            [cityDic setObject:[NSNumber numberWithInt:1] forKey:self.endPF.text];
        }
    }else{
        dic = [[NSMutableDictionary alloc] initWithDictionary:HISTORYS];
        cityDic = [[NSMutableDictionary alloc] init];
        [cityDic setObject:[NSNumber numberWithInt:1] forKey:self.startPF.text];
        [cityDic setObject:[NSNumber numberWithInt:1] forKey:self.endPF.text];
    }
    [dic setObject:cityDic forKey:CURRENT_CITY];
    
    [NSUserDefaults.standardUserDefaults setObject:dic forKey:@"History"];
}

- (void)deleteHistory:(NSString *)name{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:HISTORYS];
    
    if ([dic objectForKey:CURRENT_CITY]) {
        NSMutableDictionary *cityDic = [NSMutableDictionary dictionaryWithDictionary:HISTORYS[CURRENT_CITY]];
        [cityDic removeObjectForKey:name];
        [dic setObject:cityDic forKey:CURRENT_CITY];
    }
    
    [NSUserDefaults.standardUserDefaults setObject:dic forKey:@"History"];
    self.sortedHistories = [Tools sortedDictionary:HISTORYS[CURRENT_CITY]];
    [self.historyCollectionView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"choosePlan"]) {
        ChoosePlanVC *vc = segue.destinationViewController;
        vc.route = sender;
    }else if([segue.identifier isEqualToString:@"chooseLine"]){
        ChooseLineVC *vc = segue.destinationViewController;
        vc.metroInfoDic = self.metroInfoDic;
    }
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    NSLog(@"Error: %@", error);
}

- (void)initCompleteBlock{
    __weak MetroReminderVC *weakSelf = self;
    self.completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error){
        if (error){
            weakSelf.startRequest = false;
            weakSelf.currentCityLabel.text = @"定位错误,请重新定位";
            return;
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
    if (response.regeocode != nil){
        NSLog(@"%@",response.regeocode.addressComponent);
        
        NSString *city = response.regeocode.addressComponent.city;
        self.startRequest = false;
        self.currentCityLabel.text = city;
        [[NSUserDefaults standardUserDefaults] setObject:city forKey:@"CurrentCity"];
        
        for (NSString* key in ALL_METRO_DIC.allKeys) {
            if([key containsString:CURRENT_CITY]||[CURRENT_CITY containsString:key]){
                self.metroInfoDic = [ALL_METRO_DIC objectForKey:key];
                self.sortedHistories = [Tools sortedDictionary:HISTORYS[CURRENT_CITY]];
                if(self.sortedHistories.count >= 2){
                    self.startPF.text = self.sortedHistories[0];
                    self.endPF.text = self.sortedHistories[1];
                }
                [self.historyCollectionView reloadData];
                return;
            }
        }
        [self.view showMyToast:@"当前城市暂未开通地铁"];
    }
}

- (void)configLocationManager{
    self.locationManager = [[AMapLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    [self.locationManager setAllowsBackgroundLocationUpdates:NO];
    [self.locationManager setLocationTimeout:DefaultLocationTimeout];
    [self.locationManager setReGeocodeTimeout:DefaultReGeocodeTimeout];
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
