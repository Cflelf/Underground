//
//  ChoosePlatformVCViewController.m
//  Underground
//
//  Created by 潘潇睿 on 2018/8/27.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "ChoosePlatformVC.h"
#import <UIKit/UIKit.h>
#import "LineHeaderView.h"
#import "MetroReminderVC.h"
#import <Toast/Toast.h>
#import "Const.h"
#import "UIView+Toast.h"

#define ReuseCellIdentifier @"PlatformName"

@interface ChoosePlatformVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *platformTable;

@end

@implementation ChoosePlatformVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.platformTable.delegate = self;
    self.platformTable.dataSource = self;
    self.platformTable.tableFooterView = [UIView new];
    [self.platformTable registerClass:LineHeaderView.class forCellReuseIdentifier:ReuseCellIdentifier];
    
    self.navigationItem.title = @"选择站点";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.platforms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LineHeaderView *cell = [tableView dequeueReusableCellWithIdentifier:ReuseCellIdentifier];
    
    if(!cell){
        cell = [tableView dequeueReusableCellWithIdentifier:ReuseCellIdentifier forIndexPath:indexPath];
    }
    
    cell.titleLabel.text = self.platforms[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([self.platforms[indexPath.row] containsString:@"未开通"]) {
        [self.view showMyToast:@"该线路暂未开通"];
        return;
    }
    
    
    MetroReminderVC *metroVC = self.navigationController.viewControllers.firstObject;
    
    if (metroVC.type == 0) {
        metroVC.startPF.text = self.platforms[indexPath.row];
    }else{
        metroVC.endPF.text = self.platforms[indexPath.row];
    }
    
    [self.navigationController popToRootViewControllerAnimated:true];
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
