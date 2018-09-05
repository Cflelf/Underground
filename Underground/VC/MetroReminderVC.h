//
//  MetroReminderVC.h
//  Underground
//
//  Created by 潘潇睿 on 2018/8/27.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum _PlatformType{
    START = 0,
    END = 1
}PlatformType;

@interface MetroReminderVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *startPF;

@property (weak, nonatomic) IBOutlet UITextField *endPF;

@property (nonatomic, assign) PlatformType type;

@property (nonatomic,strong) UIButton *rubbishButton;

- (void)deleteHistory:(NSString *)name;

@end
