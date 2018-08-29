//
//  PlanTableViewCell.h
//  Underground
//
//  Created by 潘潇睿 on 2018/8/29.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetroLabel.h"
#import <AMapSearchKit/AMapSearchKit.h>

@interface PlanTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *chooseButton;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet MetroLabel *metroLabel;
@property (nonatomic, strong) NSArray<AMapSegment *> *segments;
@end
