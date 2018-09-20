//
//  ChoosePlanVCViewController.m
//  Underground
//
//  Created by 潘潇睿 on 2018/8/27.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "ChoosePlanVC.h"
#import <UIKit/UIKit.h>
#import "PlanTableViewCell.h"
#import "MetroLabel.h"
#import "Plan.h"
#import "ChangePFButton.h"
#import "PlanTableHeaderView.h"
#import "Const.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <KVOMutableArray/KVOMutableArray.h>
#import "GeoFenceViewController.h"
#import "Mission.h"

#define ReuseSectionIdentifier @"planHeader"
#define ReuseCellIdentifier @"plan"
#define ArrayKeyPath @"selectedCells"
#define SegueIdentifer @"enterGeoFence"

@interface ChoosePlanVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIStackView *remindPFStackView;
@property (weak, nonatomic) IBOutlet UITableView *planTable;
@property (nonatomic,strong)NSMutableArray *sectionArray;
@property (nonatomic,strong)NSMutableArray<Plan *> *plans;
@property (nonatomic,assign)NSNumber *currentSection;
@property (nonatomic,strong)KVOMutableArray *selectedCells;
@end

@implementation ChoosePlanVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:true];
    
    [self addObserver:self forKeyPath:ArrayKeyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:false];
    
    [self removeObserver:self forKeyPath:ArrayKeyPath];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"选择路线";
    self.plans = [[NSMutableArray alloc] init];
    
    [self.planTable registerClass:PlanTableHeaderView.class forHeaderFooterViewReuseIdentifier:ReuseSectionIdentifier];
    [self generateSectionAndHeight];
    [self loadSectionsByPlans];
    
    self.planTable.tableFooterView = [UIView new];
    self.planTable.delegate = self;
    self.planTable.dataSource = self;
    self.planTable.allowsMultipleSelection = true;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [button setTitle:@"设置提醒" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    @weakify(self)
    [RACObserve(self, currentSection) subscribeNext:^(NSNumber *newNumber){
        @strongify(self)
        [self.navigationItem.rightBarButtonItem.customView setHidden:!newNumber];
        self.selectedCells = [[KVOMutableArray alloc] init];
    }];
    
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        @strongify(self)
        [self performSegueWithIdentifier:SegueIdentifer sender:nil];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [self.navigationItem.rightBarButtonItem.customView setHidden:[self mutableArrayValueForKey:keyPath].count == 0];
}

- (void)generateSectionAndHeight{
    self.sectionArray = [[NSMutableArray alloc] init];
    
    for(int j=0;j<self.route.transits.count;j++){
        NSMutableArray<NSMutableArray *> *array = [[NSMutableArray alloc] init];
        NSArray<AMapSegment *> *segs = self.route.transits[j].segments;
        for (int i=0; i<segs.count; i++) {
            if(segs[i].buslines.count>0){
                NSMutableArray *temp = [NSMutableArray arrayWithArray:segs[i].buslines];
                [array addObject:temp];

            }
        }
        
        NSMutableArray *allBusLines = [[NSMutableArray alloc] initWithCapacity:array.count];
        [self calculateCombination:array begin:0 array:allBusLines transit:self.route.transits[j]];
    }
}

- (void)openSection:(NSInteger)section{
    Plan *plan = self.plans[section];
    plan.isOpen = !plan.isOpen;
    NSMutableArray *indexArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < plan.viaPlatforms.count; i++) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:section];
        [indexArray addObject:indexpath];
    }
    [self.planTable insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
    [self.planTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:true];
}

- (void)closeSection:(NSInteger)section{
    Plan *plan = self.plans[section];
    plan.isOpen = !plan.isOpen;
    NSMutableArray *indexArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < plan.viaPlatforms.count; i++) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:section];
        [indexArray addObject:indexpath];
    }
    [self.planTable deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)loadSectionsByPlans{
    for(int j=0;j<self.plans.count;j++){
        Plan *plan = self.plans[j];
        PlanTableHeaderView *header = [self.planTable dequeueReusableHeaderFooterViewWithIdentifier:ReuseSectionIdentifier];
        header.plan = plan;
        
        @weakify(self)
        header.openblock =^(NSInteger section){
            @strongify(self)
            if(self.currentSection && [self.currentSection integerValue] != section){
                [self closeSection:[self.currentSection integerValue]];
            }
            self.currentSection = [NSNumber numberWithInteger:section] ;
            [self openSection:section];
        };
        header.closeblock = ^(NSInteger section){
            @strongify(self)
            if (self.currentSection && [self.currentSection integerValue] == section) {
                self.currentSection = nil;
                [self closeSection:section];
                [self.planTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:true];
            }else{
                [self closeSection:section];
            }
        };
        header.section = j;
        
        header.metroLabel.text = plan.viaLines[0];
        [header.metroLabel sizeToFit];
        for(int i = 1;i<plan.viaLines.count;i++){
            MetroLabel *label = [[MetroLabel alloc] init];
            [header.stackView insertArrangedSubview:label atIndex:header.stackView.arrangedSubviews.count-1];
                
            label.text = plan.viaLines[i];
            [label sizeToFit];
        }
        header.planInfoLabel.text = [NSString stringWithFormat:@"%ld元 - %ld分钟 - 步行%ld米",plan.cost,plan.duration,plan.walkingDistance];
    
        [self.sectionArray addObject:header];
        [self.sectionArray addObject:[NSNumber numberWithDouble:([header.stackView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height+24)]];
    }
}

- (void)calculateCombination:(NSMutableArray<NSMutableArray *> *)input begin:(int)index array:(NSMutableArray *)array transit:(AMapTransit *)transit{
    if(index == input.count){
        Plan *plan = [[Plan alloc] initWithRoute:array transits:transit];
        [self.plans addObject:plan];
        return;
    }
    for(int i=0;i<input[index].count;i++){
        array[index] = input[index][i];
        [self calculateCombination:input begin:index+1 array:array transit:transit];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    PlanTableHeaderView *view = self.sectionArray[section*2];
    
    if(!view.plan.isOpen){
        [view.downArrowImage setHighlighted:false];
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return [self.sectionArray[section*2+1] doubleValue];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionArray.count / 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    Plan *plan = self.plans[section];
    return plan.isOpen ? plan.viaPlatforms.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PlanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseCellIdentifier];
    
    if(!cell){
        cell = [tableView dequeueReusableCellWithIdentifier:ReuseCellIdentifier forIndexPath:indexPath];
    }
    
    Plan *plan = self.plans[indexPath.section];
    
    cell.titleLabel.text = plan.viaPlatforms[indexPath.row].name;
    cell.subTitle.text = plan.viaPlatforms[indexPath.row].line;
    cell.stop = plan.viaPlatforms[indexPath.row];
    
    if(indexPath.row == 0){
        [cell.chooseButton setHidden:true];
        cell.typeLabel = [cell.typeLabel initWithStyle:MetroPFTypeStart text:@"起始站"];
    }else if(indexPath.row == plan.viaPlatforms.count-1){
        cell.typeLabel = [cell.typeLabel initWithStyle:MetroPFTypeEnd text:@"终点站"];
        [cell.chooseButton setHidden:false];
    }else{
        [cell.chooseButton setHidden:true];
        [cell.typeLabel setHidden:true];
    }
    
    for(AMapBusStop *stop in plan.changePlatforms){
        if([stop.name isEqualToString:plan.viaPlatforms[indexPath.row].name]){
            cell.typeLabel = [cell.typeLabel initWithStyle:MetroPFTypeChange text:@"换乘"];
            [cell.chooseButton setHidden:false];
            break;
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PlanTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(!cell.chooseButton.isHidden){
        [[self mutableArrayValueForKey:ArrayKeyPath] addObject:cell];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    PlanTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(!cell.chooseButton.isHidden){
        [[self mutableArrayValueForKey:ArrayKeyPath] removeObject:cell];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:SegueIdentifer]) {
        GeoFenceViewController *vc = segue.destinationViewController;
        vc.remindMissions = [NSMutableArray new];
        for (PlanTableViewCell *cell in self.selectedCells) {
            [vc.remindMissions addObject:[[Mission alloc] initWithStop:cell.stop]];
        }
        vc.plan = ((PlanTableHeaderView *)self.sectionArray[[self.currentSection intValue]*2]).plan;
        vc.startDate = [NSDate date];
    }
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
