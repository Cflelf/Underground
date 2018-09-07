//
//  Tools.h
//  Underground
//
//  Created by 潘潇睿 on 2018/8/29.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Tools : NSObject

+ (UIViewController *)getCurrentVC;

+ (NSData *)toJSONData:(id)theData;

+ (id)toArrayOrNSDictionary:(NSData *)jsonData;

+ (NSArray *)sortedDictionary:(NSDictionary *)dict;

@end
