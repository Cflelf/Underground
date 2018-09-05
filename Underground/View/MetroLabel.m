//
//  MetroLabel.m
//  Underground
//
//  Created by 潘潇睿 on 2018/8/29.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "MetroLabel.h"
#import "Const.h"

@implementation MetroLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    self.textColor = UIColor.blackColor;
    self.font = [UIFont systemFontOfSize:14];
}

@end
