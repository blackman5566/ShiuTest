//
//  ShiuVerticalSelectionView.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/8/2.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ShiuVerticalSelectionView.h"

@implementation ShiuVerticalSelectionView

#pragma mark - init

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] set];
    CGContextFillRect(context, rect);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 0.0 };

    NSArray *colors = @[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[[UIColor redColor] colorWithAlphaComponent:0.0].CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);

    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));

    CGContextSaveGState(context);
    {
        CGContextAddRect(context, rect);
        CGContextClip(context);
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    }
    CGContextRestoreGState(context);

    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

#pragma mark - Setters

- (void)setBgColor:(UIColor *)bgColor {
    _bgColor = bgColor;
    [self setNeedsDisplay];
}

@end
