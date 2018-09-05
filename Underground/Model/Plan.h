//
//  Plan.h
//  Underground
//
//  Created by 潘潇睿 on 2018/8/29.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface MyBusStop : NSObject

@property(nonatomic,strong)AMapBusStop *stop;
@property(nonatomic,strong)NSString *line;

@end

@interface Plan : NSObject

@property(nonatomic,strong)NSMutableArray<NSString *> *viaLines;
@property(nonatomic,strong)NSMutableArray<AMapBusStop *> *changePlatforms;
@property(nonatomic,strong)NSMutableArray<MyBusStop *> *viaPlatforms;
@property(nonatomic,assign)long cost;
@property(nonatomic,assign)long duration;
@property(nonatomic,assign)long walkingDistance;
@property(nonatomic,assign)Boolean isOpen;

-(instancetype)initWithRoute:(NSMutableArray<AMapBusLine *> *)busLines transits:(AMapTransit *)transits;

@end
