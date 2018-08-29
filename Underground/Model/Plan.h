//
//  Plan.h
//  Underground
//
//  Created by 潘潇睿 on 2018/8/29.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "location.h"

@interface Plan : NSObject

@property(nonatomic,strong)NSMutableArray<NSString *> *viaLines;
@property(nonatomic,strong)NSMutableArray<location *> *changePlatforms;
@property(nonatomic,strong)NSMutableArray<location *> *viaPlatforms;

@end
