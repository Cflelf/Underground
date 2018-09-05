//
//  AppDelegate.h
//  Underground
//
//  Created by 潘潇睿 on 2018/8/21.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(void)registerNotification:(NSInteger )alerTime title:(NSString *)title body:(NSString *)body;

@end

