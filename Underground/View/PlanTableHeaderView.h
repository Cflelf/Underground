//
//  PlanTableHeaderView.h
//  Underground
//
//  Created by 潘潇睿 on 2018/9/2.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plan.h"
#import "MetroLabel.h"

typedef void(^openBlock)(NSInteger section);
typedef void(^closeBlock)(NSInteger section);

@interface PlanTableHeaderView : UITableViewHeaderFooterView
@property (strong, nonatomic) UIButton *downArrowButton;
@property (strong, nonatomic) UILabel *planInfoLabel;
@property (strong, nonatomic) UIButton *chooseButton;
@property (strong, nonatomic) UIStackView *stackView;
@property (strong, nonatomic) MetroLabel *metroLabel;
@property (nonatomic, strong) Plan *plan;
@property (copy, nonatomic) openBlock openblock;
@property (copy, nonatomic) closeBlock closeblock;
@property (assign, nonatomic) NSInteger section;

@end
