//
//  PlanTableHeaderView.m
//  Underground
//
//  Created by 潘潇睿 on 2018/9/2.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "PlanTableHeaderView.h"
#import <Masonry/Masonry.h>
#import "Const.h"

@implementation PlanTableHeaderView


- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = LightGreyColor;
        
        self.stackView = [[UIStackView alloc] init];
        self.stackView.axis = UILayoutConstraintAxisVertical;
        self.stackView.alignment = UIStackViewAlignmentLeading;
        self.stackView.distribution = UIStackViewDistributionEqualSpacing;
        self.stackView.spacing = 10;
        [self addSubview:self.stackView];
        
        [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@20);
            make.centerY.equalTo(@0);
        }];
        
        self.metroLabel = [[MetroLabel alloc] init];
        [self.stackView addArrangedSubview:self.metroLabel];
        
        self.planInfoLabel = [[UILabel alloc] init];
        self.planInfoLabel.font = [UIFont systemFontOfSize:12];
        self.planInfoLabel.textColor = ThemeColor;
        [self.stackView addArrangedSubview:self.planInfoLabel];
        
        UIView *separator = [[UIView alloc] init];
        separator.backgroundColor = SeparatorColor;
        [self addSubview:separator];
        
        [separator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@0.5);
            make.leading.equalTo(@8);
            make.width.equalTo(@(ScreenWidth-8));
            make.bottom.equalTo(@(-0.5));
        }];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOpen)]];
        
    }
    return self;
}

- (void)tapOpen{
    if (self.plan.isOpen) {
        self.closeblock(self.section);
    }else{
        self.openblock(self.section);
    }
}


@end
