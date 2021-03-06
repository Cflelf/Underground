//
//  Const.h
//  Underground
//
//  Created by 潘潇睿 on 2018/8/23.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//
#import "UIColor+Hex.h"

#ifndef Const_h
#define Const_h

#define isIPHONEX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define ScreenWidth [[UIScreen mainScreen] bounds].size.width

#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

#define ThemeColor [UIColor colorWithHexString:@"#5AC8FA"]

#define LightGreyColor [UIColor colorWithHexString:@"#FBFBFB"]

#define PFStartColor [UIColor colorWithHexString:@"#bae2be"]

#define PFEndColor [UIColor colorWithHexString:@"#ff5959"] 

#define SeparatorColor [UIColor colorWithHexString:@"#D1D1D1"]

#define ALL_METRO_DIC [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MetroInfo" ofType:@"plist"]]

#define HISTORYS [NSUserDefaults.standardUserDefaults objectForKey:@"History"]
#define CURRENT_CITY [NSUserDefaults.standardUserDefaults objectForKey:@"CurrentCity"]
#define RADIUS [NSUserDefaults.standardUserDefaults objectForKey:@"Radius"]

#endif /* Const_h */
