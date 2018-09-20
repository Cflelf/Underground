//
//  Mission.m
//  Underground
//
//  Created by 潘潇睿 on 2018/9/6.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "Mission.h"

//@interface Mission () <NSCoding>
//
//@end

@implementation Mission

- (instancetype)initWithStop:(MyBusStop *)stop
{
    self = [super init];
    if (self) {
        self.stop = stop;
        self.completed = false;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.stop forKey:@"stop"];
    [aCoder encodeBool:false forKey:@"completed"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.completed = [coder decodeBoolForKey:@"completed"];
        self.stop = [coder decodeObjectForKey:@"stop"];
    }
    return self;
}

@end
