//
//  PlanTableViewCell.h
//  Underground
//
//  Created by 潘潇睿 on 2018/8/29.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetroLabel.h"
#import "Plan.h"

typedef enum _MetroPFType{
    MetroPFTypeStart = 0,
    MetroPFTypeChange,
    MetroPFTypeEnd
} MetroPFType;

@interface MetroPFTypeLabel : UILabel
- (instancetype)initWithStyle:(MetroPFType)type text:(NSString *)str;
@end

@interface PlanTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *chooseButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (strong,nonatomic) MetroPFTypeLabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *metroImage;
@property (strong,nonatomic) MyBusStop *stop;
@property (weak, nonatomic) IBOutlet UIImageView *finishImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end
