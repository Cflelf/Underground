//
//  LocateHeaderView.m
//  Underground
//
//  Created by 潘潇睿 on 2018/8/24.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "LocateHeaderView.h"
#import "Const.h"
#import <Masonry/Masonry.h>

@implementation LocateHeaderView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, frame.size.height)];
    [self addSubview:containerView];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setImage:[UIImage imageNamed:@"locate"]];
    [containerView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@15);
        make.centerY.equalTo(@0);
        make.width.equalTo(@28);
        make.height.equalTo(@28);
    }];
    
    self.label = [[UILabel alloc] init];
    [containerView addSubview:self.label];
    self.label.text = @"选择所在城市";
    self.label.textColor = ThemeColor;
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.mas_right).with.offset(8);
        make.centerY.equalTo(@0);
    }];
    
    return self;
}

@end
