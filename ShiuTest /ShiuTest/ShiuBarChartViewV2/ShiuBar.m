//
//  ShiuBar.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/25.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ShiuBar.h"
#define XLabelFontSize 14
#define BarTextFont 10
#define BarAnimationDuration 1.0
#define TextAnimationDuration 2.0

@interface ShiuBar ()

@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, strong) UIBezierPath *backgroundPath;
@property (nonatomic, strong) CAShapeLayer *barLayer;
@property (nonatomic, strong) UIBezierPath *barPath;
@property (nonatomic, strong) CATextLayer *textLayer;
@property (nonatomic, assign) CGFloat barWidth;

@end

@implementation ShiuBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupBarLayer];
        [self setupInitValue];
    }
    return self;
}

- (void)setupInitValue {
    self.barWidth = CGRectGetWidth(self.bounds);
}

- (void)setupBarLayer {
    self.barLayer = [CAShapeLayer new];
    self.barLayer.strokeColor = [UIColor greenColor].CGColor;
    self.barLayer.lineCap = kCALineCapButt;
    self.barLayer.frame = self.bounds;
    [self.layer addSublayer:self.barLayer];
}

- (void)show {
    if (_textLayer) {
        _textLayer.position = CGPointMake(self.bounds.size.width / 2, _backgroundLayer ? -BarTextFont : self.bounds.size.height * (1 - _barProgress) - BarTextFont);
    }
    if (_isAnimated) {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = BarAnimationDuration;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.fromValue = @0.0f;
        pathAnimation.toValue = @1.0f;
        [_barLayer addAnimation:pathAnimation forKey:nil];

        if (_textLayer) {
            CABasicAnimation *fade = [self fadeAnimation];
            [self.textLayer addAnimation:fade forKey:nil];
        }
    }

}

- (CABasicAnimation *)fadeAnimation {
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeAnimation.toValue = [NSNumber numberWithFloat:1.0];
    fadeAnimation.duration = TextAnimationDuration;
    return fadeAnimation;
}

// 設定百分比（顯示動畫）
- (void)setProgress {
    _barPath = [UIBezierPath bezierPath];
    [_barPath moveToPoint:CGPointMake(self.bounds.origin.x + self.bounds.size.width / 2, self.bounds.size.height)];
    [_barPath addLineToPoint:CGPointMake(self.bounds.origin.x + self.bounds.size.width / 2, self.bounds.size.height * (1 - _barProgress))];
    [_barPath setLineWidth:_barWidth];
    [_barPath setLineCapStyle:kCGLineCapSquare];

    _barLayer.strokeEnd = 1.0;
    _barLayer.path = _barPath.CGPath;
}

- (void)setIsAnimated:(BOOL)isAnimated {
    _isAnimated = isAnimated;
}

// 設定 bar 寬度
- (void)setBarWidth:(CGFloat)barWidth {
    _barWidth = barWidth;
    _barLayer.lineWidth = barWidth;
    [self setProgress];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    // 設定背景顏色
    if (backgroundColor && ![backgroundColor isEqual:[UIColor clearColor]]) {
        self.backgroundLayer.strokeColor = backgroundColor.CGColor;
    }
}

// 設定 bar 颜色
- (void)setBarColor:(UIColor *)barColor {
    _barLayer.strokeColor = barColor.CGColor;
}

- (void)setBarRadius:(CGFloat)barRadius {
    _barLayer.cornerRadius = barRadius;
}
// 設定 bar 進度
- (void)setBarProgress:(float)progress {
    _barProgress = progress;
    [self setProgress];
}

- (CATextLayer *)textLayer {
    if (!_textLayer) {
        _textLayer = [CATextLayer layer];
        _textLayer.foregroundColor = _barLayer.strokeColor;
        _textLayer.fontSize = BarTextFont;
        _textLayer.alignmentMode = kCAAlignmentCenter;
        _textLayer.contentsScale = [[UIScreen mainScreen] scale];
        CGRect bounds = _barLayer.bounds;
        bounds.size.height = BarTextFont;
        bounds.size.width *= 2;
        _textLayer.bounds = bounds;

        [self.layer addSublayer:_textLayer];
    }
    return _textLayer;
}

- (CAShapeLayer *)backgroundLayer {
    if (!_backgroundLayer) {
        _backgroundLayer = [CAShapeLayer new];
        [self.layer insertSublayer:_backgroundLayer below:_barLayer];
        _backgroundLayer.frame = self.bounds;
        _backgroundLayer.lineWidth = _barWidth;
        _backgroundPath = [UIBezierPath bezierPath];
        [_backgroundPath moveToPoint:CGPointMake(self.bounds.origin.x + self.bounds.size.width / 2, self.bounds.size.height)];
        [_backgroundPath addLineToPoint:CGPointMake(self.bounds.origin.x + self.bounds.size.width / 2, self.bounds.origin.y)];
        [_backgroundPath setLineWidth:_barWidth];
        [_backgroundPath setLineCapStyle:kCGLineCapSquare];
        _backgroundLayer.path = _backgroundPath.CGPath;
    }
    return _backgroundLayer;
}

- (void)setBarText:(NSString *)text {
    self.textLayer.string = text;
}

@end
