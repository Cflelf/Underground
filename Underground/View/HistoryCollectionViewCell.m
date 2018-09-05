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
#import "HistoryLabel.h"

@interface HistoryCollectionViewCell ()

@property(nonatomic,strong)UILabel *copylabel;
@property(nonatomic,assign)CGPoint startPoint;
@property(nonatomic,strong)UISelectionFeedbackGenerator *feed;
@property(nonatomic,strong)UIButton *trashButton;

@end

@implementation HistoryCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    [self setUserInteractionEnabled:true];
    
    self.label = [[HistoryLabel alloc] init];
    [self.contentView addSubview:self.label];
    
    UILongPressGestureRecognizer *rec = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    rec.minimumPressDuration = 0.3;
    [self addGestureRecognizer:rec];
    
    self.trashButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [self.trashButton setImage:[UIImage imageNamed:@"trash_close"] forState:UIControlStateNormal];
    [self.trashButton setImage:[UIImage imageNamed:@"trash_open"] forState:UIControlStateSelected];
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    __weak typeof(self) weakSelf = self;
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
        make.width.equalTo(weakSelf.contentView.mas_width);
    }];
}


- (void)longPress:(UILongPressGestureRecognizer *)gesture   {
    if(gesture.state == UIGestureRecognizerStateBegan){
        if(!self.copylabel){
            self.copylabel = [[HistoryLabel alloc] init];
            self.copylabel.frame = [self.label convertRect:self.label.frame toView:nil];
            self.copylabel.text = self.label.text;
            
            CGPoint center = self.copylabel.center;
            center.x += 5;
            center.y -= 5;
            self.copylabel.center = center;
            
            [self.window addSubview:self.copylabel];
            
            self.feed = [[UISelectionFeedbackGenerator alloc] init];
            
            [self.feed selectionChanged];
            [self.feed prepare];
            
            MetroReminderVC *vc = (MetroReminderVC *)[Tools getCurrentVC];
            vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.trashButton];
        }
        
        self.startPoint = [gesture locationInView:self.superview];
    }else if(gesture.state == UIGestureRecognizerStateChanged){
        self.feed = nil;
        // 当前触摸点
        CGPoint currentPoint = [gesture locationInView:self.superview];
        // 上一个触摸点
        CGPoint previousPoint = self.startPoint;
        
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
        
        rect = [self.trashButton convertRect:self.trashButton.frame toView:vc.view];
        if (CGRectIntersectsRect(rect, self.copylabel.frame)) {
            [self.trashButton setSelected:true];
        }else{
            [self.trashButton setSelected:false];
        }
        
        self.startPoint = currentPoint;
    }else if(gesture.state == UIGestureRecognizerStateEnded){
        MetroReminderVC *vc = (MetroReminderVC *)[Tools getCurrentVC];
        CGRect rect = [vc.startPF convertRect:vc.startPF.frame toView:vc.view];
        if (CGRectIntersectsRect(rect, self.copylabel.frame)) {
            vc.startPF.text = self.copylabel.text;
        }
        
        rect = [vc.endPF convertRect:vc.startPF.frame toView:vc.view];
        if (CGRectIntersectsRect(rect, self.copylabel.frame)) {
            vc.endPF.text = self.copylabel.text;
        }
        
        rect = [self.trashButton convertRect:self.trashButton.frame toView:vc.view];
        if (CGRectIntersectsRect(rect, self.copylabel.frame)) {
            [vc deleteHistory:self.label.text];
        }
        
        vc.navigationItem.rightBarButtonItem = nil;
        vc.endPF.layer.borderWidth = 0;
        vc.startPF.layer.borderWidth = 0;
        [self.copylabel removeFromSuperview];
        self.copylabel = nil;
    }else if(gesture.state == UIGestureRecognizerStateCancelled){
        MetroReminderVC *vc = (MetroReminderVC *)[Tools getCurrentVC];
        vc.navigationItem.rightBarButtonItem = nil;
        vc.endPF.layer.borderWidth = 0;
        vc.startPF.layer.borderWidth = 0;
        [self.copylabel removeFromSuperview];
        self.copylabel = nil;
    }
}

@end
