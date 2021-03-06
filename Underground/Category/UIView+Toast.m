//
//  UIView+Toast.m
//  Underground
//
//  Created by 潘潇睿 on 2018/8/27.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "UIView+Toast.h"
#import <UIKit/UIKit.h>
#import <Toast/Toast.h>
#import "Const.h"

@implementation UIView(Toast)

- (void)showMyToast:(NSString *)str position:(NSString *)position{
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.backgroundColor = ThemeColor;
    style.messageColor = UIColor.whiteColor;
    style.shadowRadius = 0.5;
    [self makeToast:str duration:1 position:position style:style];
}

@end
