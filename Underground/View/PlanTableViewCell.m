//
//  PlanTableViewCell.m
//  Underground
//
//  Created by 潘潇睿 on 2018/8/29.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "PlanTableViewCell.h"
#import "Const.h"
#import <Masonry/Masonry.h>

@implementation MetroPFTypeLabel

- (instancetype)initWithStyle:(MetroPFType)type text:(NSString *)str{
    if(self = [super init]){
        self.layer.cornerRadius = 5;
        self.textColor = UIColor.whiteColor;
        self.text = str;
        self.clipsToBounds = true;
        self.font = [UIFont systemFontOfSize:11];
        self.textAlignment = NSTextAlignmentCenter;
        [self setHidden:false];
        switch (type) {
            case MetroPFTypeStart:
                self.backgroundColor = PFStartColor;
                break;
            case MetroPFTypeChange:
                self.backgroundColor = ThemeColor;
                break;
            default:
                self.backgroundColor = PFEndColor;
                break;
        }
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size = CGSizeMake(size.width + 8, size.height);
    
    return size;
}

@end

@implementation PlanTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.typeLabel = [[MetroPFTypeLabel alloc] init];
    [self addSubview:self.typeLabel];
    [self.typeLabel setHidden:true];
    [self.chooseButton setImage:[UIImage imageNamed: @"radio_checked"] forState:UIControlStateSelected];
    [self.chooseButton setHidden:true];
    
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.titleLabel.mas_trailing).with.offset(8);
        make.centerY.equalTo(self.titleLabel.mas_centerY);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
