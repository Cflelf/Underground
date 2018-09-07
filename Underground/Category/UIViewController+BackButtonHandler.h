//
//  UIViewController+BackButtonHandler.h
//  Underground
//
//  Created by 潘潇睿 on 2018/9/6.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackButtonHandlerProtocol <NSObject>
@optional
// Override this method in UIViewController derived class to handle 'Back' button click
-(BOOL)navigationShouldPopOnBackButton;
@end

@interface UIViewController (BackButtonHandler)<BackButtonHandlerProtocol>

@end
