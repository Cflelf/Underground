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

#define ThemeColor [UIColor colorWithHexString:@"#5AC8FA"]

#define SeparatorColor [UIColor colorWithHexString:@"#D1D1D1"]

#define ALL_METRO_DIC [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MetroInfo" ofType:@"plist"]]

#define HISTORYS [NSUserDefaults.standardUserDefaults objectForKey:@"History"]



#endif /* Const_h */
