//
//  ViewController.m
//  Underground
//
//  Created by 潘潇睿 on 2018/8/21.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "ChooseLineVC.h"
#import "Const.h"
#import "LineHeaderView.h"
#import "ChoosePlatformVC.h"

#define ReuseSectionIdentifier @"LineName"
#define SegueIdentifier @"showPlatforms"

@interface ChooseLineVC () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *sortedArray;

@end

@implementation ChooseLineVC

#pragma life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"选择线路";
    NSString *regex = @"^[0-9]+.*";
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    self.sortedArray = [self.metroInfoDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        if ([pre evaluateWithObject:obj1] && [pre evaluateWithObject:obj2]) {
            NSInteger i1 = [[[obj1 componentsSeparatedByString:@"号"] objectAtIndex:0] integerValue];
            NSInteger i2 = [[[obj2 componentsSeparatedByString:@"号"] objectAtIndex:0] integerValue];
            return i1 >= i2 ? NSOrderedDescending:NSOrderedAscending;
        }else if(![pre evaluateWithObject:obj1]&&![pre evaluateWithObject:obj2]){
            return [obj1 compare:obj2];
        }else if(![pre evaluateWithObject:obj1]&&[pre evaluateWithObject:obj2]){
            return NSOrderedDescending;
        }else{
            return NSOrderedAscending;
        }
        
    }];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:LineHeaderView.class forCellReuseIdentifier:ReuseSectionIdentifier];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.metroInfoDic.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LineHeaderView *cell = [tableView dequeueReusableCellWithIdentifier:ReuseSectionIdentifier];
    
    if(!cell){
        cell = [tableView dequeueReusableCellWithIdentifier:ReuseSectionIdentifier forIndexPath:indexPath];
    }
    
    cell.titleLabel.text = self.sortedArray[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:SegueIdentifier sender:[self.metroInfoDic objectForKey:self.sortedArray[indexPath.row]]];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqual: SegueIdentifier]){
        ChoosePlatformVC *controller = segue.destinationViewController;
        controller.platforms = sender;
    }
}


@end
