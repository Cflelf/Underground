//
//  HistoryCollectionViewCell.m
//  Underground
//
//  Created by 潘潇睿 on 2018/8/28.
//  Copyright © 2018年 潘潇睿. All rights reserved.
//

#import "HistoryCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import "Const.h"
#import "MetroReminderVC.h"
#import <QuartzCore/QuartzCore.h>
#import "Tools.h"

@interface HistoryCollectionViewCell ()

@property(nonatomic,strong)UILabel *copylabel;
//@property(nonatomic,assign)Boolean isLongPress;

@end

@implementation HistoryCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    [self setUserInteractionEnabled:true];

    self.label = [[UILabel alloc] init];
    self.label.font = [UIFont systemFontOfSize:13];
    self.label.textColor = ThemeColor;
    [self.contentView addSubview:self.label];
    
    self.label.layer.borderColor = UIColor.lightGrayColor.CGColor;
    self.label.layer.borderWidth = 0.5f;
    self.label.layer.cornerRadius = 5;
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
    }];
    
//    UILongPressGestureRecognizer *rec = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
//    rec.minimumPressDuration = 0.5;
//    [self addGestureRecognizer:rec];
    
    return self;
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture   {
    if(gesture.state == UIGestureRecognizerStateBegan){
        NSLog(@"长按开始");
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
        if(!self.copylabel){
            self.copylabel = [[UILabel alloc] init];
            self.copylabel.font = [UIFont systemFontOfSize:13];
            self.copylabel.textColor = ThemeColor;
            self.copylabel.frame = [self.label convertRect:self.label.frame toView:nil];
            self.copylabel.text = self.label.text;
            
            CGPoint center = self.copylabel.center;
            center.x += 5;
            center.y -= 5;
            self.copylabel.center = center;
            
            [self.window addSubview:self.copylabel];
        }
        
        UITouch *touch = [touches anyObject];
        
        // 当前触摸点
        CGPoint currentPoint = [touch locationInView:self.superview];
        // 上一个触摸点
        CGPoint previousPoint = [touch previousLocationInView:self.superview];
        
        // 当前view的中点
        CGPoint center = self.copylabel.center;
        
        center.x += (currentPoint.x - previousPoint.x);
        center.y += (currentPoint.y - previousPoint.y);
        
        
        
        self.copylabel.center = center;
        
        MetroReminderVC *vc = (MetroReminderVC *)[Tools getCurrentVC];
        CGRect rect = [vc.startPF convertRect:vc.startPF.frame toView:vc.view];
        if (CGRectIntersectsRect(rect, self.copylabel.frame)) {
            vc.startPF.layer.borderColor = [ThemeColor CGColor];
            vc.startPF.layer.borderWidth = 1.0f;
            vc.startPF.layer.cornerRadius = 3;
        }else{
            vc.startPF.layer.borderWidth = 0;
        }
        
        rect = [vc.endPF convertRect:vc.startPF.frame toView:vc.view];
        if (CGRectIntersectsRect(rect, self.copylabel.frame)) {
            vc.endPF.layer.borderColor = [ThemeColor CGColor];
            vc.endPF.layer.borderWidth = 1.0f;
            vc.endPF.layer.cornerRadius = 3;
        }else{
            vc.endPF.layer.borderWidth = 0;
        }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    MetroReminderVC *vc = (MetroReminderVC *)[Tools getCurrentVC];
    CGRect rect = [vc.startPF convertRect:vc.startPF.frame toView:vc.view];
    if (CGRectIntersectsRect(rect, self.copylabel.frame)) {
        vc.startPF.text = self.copylabel.text;
    }
        
    rect = [vc.endPF convertRect:vc.startPF.frame toView:vc.view];
    if (CGRectIntersectsRect(rect, self.copylabel.frame)) {
        vc.endPF.text = self.copylabel.text;
    }
        
    vc.endPF.layer.borderWidth = 0;
    vc.startPF.layer.borderWidth = 0;
    [self.copylabel removeFromSuperview];
    self.copylabel = nil;
    
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    MetroReminderVC *vc = (MetroReminderVC *)[Tools getCurrentVC];
    vc.endPF.layer.borderWidth = 0;
    vc.startPF.layer.borderWidth = 0;
    [self.copylabel removeFromSuperview];
    self.copylabel = nil;
}



@end
