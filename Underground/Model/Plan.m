//
//  Plan.m
//  Underground
//
//  Created by 潘潇睿 on 2018/8/29.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "Plan.h"
#import <AMapSearchKit/AMapSearchKit.h>

@implementation Plan

-(instancetype)initWithRoute:(AMapBusLine *) busLine{
    if(self = [self init]){
        self.viaLines = [[NSMutableArray alloc] init];
        self.viaPlatforms = [[NSMutableArray alloc] init];
        self.changePlatforms = [[NSMutableArray alloc] init];
        
        if([busLine.type isEqualToString:@"地铁线路"]){
            
        }
    }
    
    return self;
}

@end
