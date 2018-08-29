//
//  location.m
//  Underground
//
//  Created by 潘潇睿 on 2018/8/29.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "location.h"

@implementation location

-(instancetype)initWithInfo:(NSString *)name lat:(double)lat lon:(double)lon{
    if (self = [super init]) {
        self.name = name;
        self.lat = lat;
        self.lon = lon;
    }
    
    return self;
}

@end
