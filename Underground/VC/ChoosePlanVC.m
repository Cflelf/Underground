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

@interface ChoosePlanVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *planTable;
@end

@implementation ChoosePlanVC

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
    self.title = @"选择出行方案";
    
    self.planTable.delegate = self;
    self.planTable.dataSource = self;
    UINib *nib = [UINib nibWithNibName:@"PlanTableViewCell" bundle:nil];
    [self.planTable registerNib:nib forCellReuseIdentifier:@"plan"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray<AMapSegment *> *segs = self.route.transits[0].segments;
    int count = 1;
    for (int i=0; i<segs.count; i++) {
        count *= segs[i].buslines.count;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PlanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"plan"];
    
    if(!cell){
        cell = [tableView dequeueReusableCellWithIdentifier:@"plan" forIndexPath:indexPath];
    }
    NSArray<AMapSegment *> *segs = self.route.transits[0].segments;
    for (int i=0; i<segs.count; i++) {
        NSArray<AMapBusLine *> *busLines = segs[i].buslines;
        
        for (int j=0; j<busLines.count; j++) {
            
        }
    }
    
    return cell;
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
