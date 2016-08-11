//
//  ShiuChartTooltipView.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/29.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ShiuChartTooltipView.h"

@interface ShiuChartTooltipView ()

@property (nonatomic, strong) UILabel *infoLabel;

@end

@implementation ShiuChartTooltipView

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        [self setupInfoLabel];
    }
    return self;
}

#pragma mark * setup

- (void)setupInfoLabel {
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    self.infoLabel.backgroundColor = [UIColor clearColor];
    self.infoLabel.textColor = [UIColor whiteColor];
    self.infoLabel.adjustsFontSizeToFitWidth = YES;
    self.infoLabel.numberOfLines = 1;
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    self.infoLabel.text = @"23次/80ml";
    [self addSubview:self.infoLabel];
}

#pragma mark - Setter

- (void)setText:(NSString *)text {
    self.hidden = !text.floatValue;
    self.infoLabel.text = text;
    [self setNeedsLayout];
}

- (void)setTooltipColor:(UIColor *)tooltipColor {
    self.backgroundColor = tooltipColor;
    [self setNeedsDisplay];
}

#pragma mark - layoutSubviews

- (void)layoutSubviews {
    [super layoutSubviews];
    self.infoLabel.frame = self.bounds;
}

@end
