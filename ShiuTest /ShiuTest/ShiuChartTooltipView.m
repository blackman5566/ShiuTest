//
//  ShiuChartTooltipView.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/29.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ShiuChartTooltipView.h"

@interface ShiuChartTooltipView ()

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation ShiuChartTooltipView

#pragma mark - Alloc/Init

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 60, 20)];
    if (self)
    {
        self.backgroundColor = [UIColor redColor];
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor =[UIColor whiteColor];
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.numberOfLines = 1;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.text = @"23次/80ml";
        [self addSubview:_textLabel];
    }
    return self;
}

#pragma mark - Setters

- (void)setText:(NSString *)text
{
    self.textLabel.text =text;
    [self setNeedsLayout];
}

- (void)setTooltipColor:(UIColor *)tooltipColor
{
    self.backgroundColor = tooltipColor;
    [self setNeedsDisplay];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    _textLabel.frame = self.bounds;
}

@end
