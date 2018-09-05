//
//  MetroReminderVC.m
//  Underground
//
//  Created by 潘潇睿 on 2018/8/27.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "MetroReminderVC.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "UIView+Toast.h"
#import "Const.h"
#import "HistoryCollectionViewCell.h"
#import "ChoosePlanVC.h"

@interface MetroReminderVC ()<UITextFieldDelegate,AMapSearchDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong)AMapGeoPoint *startPoint;
@property(nonatomic,strong)AMapGeoPoint *endPoint;
@property(nonatomic,strong)AMapTransitRouteSearchRequest *navi;
@property(nonatomic,strong)AMapSearchAPI *search;
@property (weak, nonatomic) IBOutlet UIView *historyView;
@property (weak, nonatomic) IBOutlet UICollectionView *historyCollectionView;

@end

@implementation MetroReminderVC

#pragma Life Cycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.startPoint = nil;
    self.endPoint = nil;
    
    if (HISTORYS && ((NSArray *)HISTORYS).count) {
        [self.historyView setHidden:false];
        [self.historyCollectionView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.startPF.delegate = self;
    self.endPF.delegate = self;
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    self.historyCollectionView.delegate = self;
    self.historyCollectionView.dataSource = self;
    [self.historyCollectionView registerClass:HistoryCollectionViewCell.class forCellWithReuseIdentifier:@"History"];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.historyCollectionView setCollectionViewLayout:layout animated:true];
    
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
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:HISTORYS];
    sizingCell.label.text = array[indexPath.row];
    [sizingCell.label sizeToFit];
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    CGSize cellSize = CGSizeMake(sizingCell.label.frame.size.width+12, 30);
    return cellSize;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSMutableArray *array = HISTORYS;
    return array ? array.count : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HistoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"History" forIndexPath:indexPath];
    cell.label.text = HISTORYS[indexPath.row];
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
    [self performSegueWithIdentifier:@"ChooseLine" sender:nil];
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
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
            request.city                = [NSUserDefaults.standardUserDefaults objectForKey:@"CurrentCity"];
            request.types               = @"地铁站";
            request.requireExtension    = YES;
            request.cityLimit           = YES;
            request.keywords = [[[NSUserDefaults.standardUserDefaults objectForKey:@"CurrentCity"] stringByAppendingString:start] stringByAppendingString:@"(地铁站)"];
            [self.search AMapPOIKeywordsSearch:request];
        });
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
            request.city                = [NSUserDefaults.standardUserDefaults objectForKey:@"CurrentCity"];
            request.types               = @"地铁站";
            request.requireExtension    = YES;
            request.cityLimit           = YES;
            request.keywords = [[[NSUserDefaults.standardUserDefaults objectForKey:@"CurrentCity"] stringByAppendingString:end] stringByAppendingString:@"(地铁站)"];
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
        [self.view showMyToast:@"查找位置失败"];
    }
}


- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response{
    if (response && response.route.transits.count > 0 && response.route.transits[0].segments.count > 0) {
        if (HISTORYS) {
            NSMutableArray *array = [[NSMutableArray alloc] initWithArray:HISTORYS];
            
            if(![array containsObject:self.startPF.text]){
                [array addObject:self.startPF.text];
            }
            
            if(![array containsObject:self.endPF.text]){
                [array addObject:self.endPF.text];
            }
            
            [NSUserDefaults.standardUserDefaults setObject:array forKey:@"History"];
        }else{
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:self.startPF.text,self.endPF.text,nil];
            [NSUserDefaults.standardUserDefaults setObject:array forKey:@"History"];
        }
        
        [self performSegueWithIdentifier:@"choosePlan" sender:response.route];
    }
}

- (void)deleteHistory:(NSString *)name{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:HISTORYS];
    
    if ([array containsObject:name]) {
        [array removeObject:name];
    }
    
    [NSUserDefaults.standardUserDefaults setObject:array forKey:@"History"];
    [self.historyCollectionView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"choosePlan"]) {
        ChoosePlanVC *vc = segue.destinationViewController;
        vc.route = sender;
    }
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    NSLog(@"Error: %@", error);
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
