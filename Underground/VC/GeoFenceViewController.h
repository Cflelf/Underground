//
//  GeoFenceViewController.h
//  Underground
//
//  Created by 潘潇睿 on 2018/9/4.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mission.h"
#import "Plan.h"

@interface GeoFenceViewController : UIViewController

@property(nonatomic,strong)NSMutableArray *remindMissions;
@property(nonatomic,strong)Plan *plan;

@end
