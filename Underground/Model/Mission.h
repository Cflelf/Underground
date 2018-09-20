//
//  Mission.h
//  Underground
//
//  Created by 潘潇睿 on 2018/9/6.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "Plan.h"

@interface Mission : NSObject

@property(nonatomic,strong)MyBusStop *stop;
@property(nonatomic,assign)BOOL completed;

- (instancetype)initWithStop:(MyBusStop *)stop;

@end
