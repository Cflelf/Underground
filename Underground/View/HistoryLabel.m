//
//  HistoryLabel.m
//  Underground
//
//  Created by 潘潇睿 on 2018/8/30.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "HistoryLabel.h"
#import "Const.h"

@implementation HistoryLabel

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
        self.font = [UIFont systemFontOfSize:13];
        self.textColor = UIColor.whiteColor;
        self.backgroundColor = ThemeColor;
        self.layer.cornerRadius = 8;
        self.clipsToBounds = true;
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size = CGSizeMake(size.width + 8, size.height + 2);
    
    return size;
}

@end
