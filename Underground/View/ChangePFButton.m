//
//  ChangePFButton.m
//  Underground
//
//  Created by 潘潇睿 on 2018/8/31.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "ChangePFButton.h"
#import "Const.h"

@implementation ChangePFButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setTitleColor:ThemeColor forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        [self setImage:[UIImage imageNamed:@"radio_unchecked"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"radio_checked"] forState:UIControlStateSelected];
        
        self.layer.borderColor = [ThemeColor CGColor];
        self.layer.borderWidth = 0.5;
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    }
    return self;
}

@end
