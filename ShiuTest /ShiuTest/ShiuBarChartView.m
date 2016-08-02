//
//  ShiuBarChartView.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/19.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ShiuBarChartView.h"

@interface ShiuBarChartView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *squareTopLayoutConstraint;
@property (assign, nonatomic) BOOL isUpDate;
@property (assign, nonatomic) CGFloat originHeight;
@property (assign, nonatomic) CGRect cacheFrame;
@property (strong, nonatomic) NSTimer *timer;


@end

@implementation ShiuBarChartView

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        self = arrayOfViews[0];
        self.isUpDate = NO;
        self.originHeight = CGRectGetHeight(self.frame);
        self.label.text = @"0";
    }
    return self;
}

- (void)timerMethod {
    CGFloat frameHeight = CGRectGetHeight(self.frame) - ((1 - self.squareValue / self.maxValue) * CGRectGetHeight(self.frame));
    CALayer *layer = [self.squareView.layer presentationLayer];
    CGRect animationViewFrame = layer.frame;
    if (!CGRectEqualToRect(animationViewFrame, self.cacheFrame)) {
        self.cacheFrame = animationViewFrame;
        NSNumber *value =  @(CGRectGetHeight(animationViewFrame) / (frameHeight / self.squareValue));
        self.label.text = [NSString stringWithFormat:@"%td", value.integerValue];
    }
    else {
        self.label.text = [NSString stringWithFormat:@"%td", @(self.squareValue).integerValue];
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)updateUI {
    self.isUpDate = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
    self.squareTopLayoutConstraint.constant += CGRectGetHeight(self.frame) - self.originHeight;
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isUpDate) {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:2.0f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations: ^{
            weakSelf.squareTopLayoutConstraint.constant = (1 - weakSelf.squareValue / weakSelf.maxValue) * CGRectGetHeight(weakSelf.frame);
            [weakSelf layoutIfNeeded];
        } completion:nil];
    }
}

- (void)dealloc {
    [self.squareView removeObserver:self forKeyPath:@"frame"];
}

@end
