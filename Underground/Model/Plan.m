//
//  Plan.m
//  Underground
//
//  Created by 潘潇睿 on 2018/8/29.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "Plan.h"
#import <AMapSearchKit/AMapSearchKit.h>

@implementation MyBusStop

-(instancetype)initWithBusStop:(AMapBusStop *)busStop line:(NSString *)line{
    if(self = [self init]){
        self.name = busStop.name;
        self.location = busStop.location;
        self.line = line;
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.line = [coder decodeObjectForKey:@"line"];
        self.time = [coder decodeInt64ForKey:@"time"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.location = [coder decodeObjectForKey:@"location"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.line forKey:@"line"];
    [coder encodeInteger:self.time forKey:@"time"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.location forKey:@"location"];
}

@end

@implementation Plan

-(instancetype)initWithRoute:(NSMutableArray<AMapBusLine *> *)busLines transits:(AMapTransit *)transits{
    if(self = [self init]){
        self.cost = (long)transits.cost;
        self.duration = transits.duration / 60;
        self.walkingDistance = (long)transits.walkingDistance;
        
        self.viaLines = [[NSMutableArray alloc] init];
        self.viaPlatforms = [[NSMutableArray alloc] init];
        self.changePlatforms = [[NSMutableArray alloc] init];
        
        for(int i=0;i<busLines.count;i++){
            NSString *str = [busLines[i].name componentsSeparatedByString:@"("][0];
            
            [self.viaLines addObject:str];
            
            [self.viaPlatforms addObject:[[MyBusStop alloc]initWithBusStop:busLines[i].departureStop line:str]];
            
            for(AMapBusStop *stop in busLines[i].viaBusStops){
                [self.viaPlatforms addObject:[[MyBusStop alloc]initWithBusStop:stop line:str]];
            }
            
            if (i != busLines.count - 1) {
                 [self.changePlatforms addObject:busLines[i].arrivalStop];
            }
           
            if(i == busLines.count - 1){
                [self.viaPlatforms addObject:[[MyBusStop alloc] initWithBusStop:busLines[i].arrivalStop line:str]];
            }
        }
        
        
        self.isOpen = false;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.changePlatforms forKey:@"changePlatforms"];
    [coder encodeObject:self.viaLines forKey:@"viaLines"];
    [coder encodeObject:self.viaPlatforms forKey:@"viaPlatforms"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.changePlatforms = [coder decodeObjectForKey:@"changePlatforms"];
        self.viaLines = [coder decodeObjectForKey:@"viaLines"];
        self.viaPlatforms = [coder decodeObjectForKey:@"viaPlatforms"];
    }
    return self;
}

@end
