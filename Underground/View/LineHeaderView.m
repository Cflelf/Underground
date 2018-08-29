//
//  LineHeaderView.m
//  Underground
//
//  Created by 潘潇睿 on 2018/8/24.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "LineHeaderView.h"
#import <Masonry/Masonry.h>
#import "Const.h"

@implementation LineHeaderView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.titleLabel = [[UILabel alloc] init];
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.centerY.equalTo(@0);
    }];
    self.titleLabel.textColor = [UIColor darkGrayColor];
    self.titleLabel.userInteractionEnabled = true;
    
    return self;
}

@end
