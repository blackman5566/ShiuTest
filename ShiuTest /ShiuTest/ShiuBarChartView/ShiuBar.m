//
//  ShiuBar.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/25.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ShiuBar.h"
#define BarTextFont 14
#define BarAnimationDuration 1.0
#define TextAnimationDuration 2.0

// ShiuBar 設計模式因應需要時才載入，所有變數全部用底線開頭，這樣程式流程比較直覺。
@interface ShiuBar ()

@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, strong) UIBezierPath *backgroundPath;
@property (nonatomic, strong) CAShapeLayer *barLayer;
@property (nonatomic, strong) UIBezierPath *barPath;
@property (nonatomic, strong) CATextLayer *textLayer;
@property (nonatomic, assign) CGFloat barWidth;

@end

@implementation ShiuBar

#pragma mark - public instance method

- (void)show {
    // 設定 bar 動畫
    CABasicAnimation *pathAnimation = [self setupPathAnimation];
    [_barLayer addAnimation:pathAnimation forKey:nil];

    if (_textLayer) {
        // 設定 position
        // 新增動畫效果
        CGFloat movePoint = (_labelTextDirection == LabelTextDirectionLeft ? [self calculateLeftBarPoint] : [self calculateRightBarPoint]);
        _textLayer.position = CGPointMake(movePoint, _backgroundLayer ? -BarTextFont : [self calculateProgress]);
        CABasicAnimation *fade = [self setupFadeAnimation];
        [_textLayer addAnimation:fade forKey:nil];
    }
}

#pragma mark - private instance method

#pragma mark * init

- (void)setupInitValue {
    self.barWidth = CGRectGetWidth(self.bounds);
}

- (void)setupBarLayer {
    _barLayer = [CAShapeLayer new];
    [self.layer addSublayer:_barLayer];
    _barLayer.strokeColor = [UIColor greenColor].CGColor;
    _barLayer.lineCap = kCALineCapButt;
    _barLayer.frame = self.bounds;
}

- (void)setupProgress {
    // 設定百分比（顯示動畫）
    _barPath = [UIBezierPath bezierPath];
    [_barPath moveToPoint:CGPointMake(self.bounds.origin.x + self.bounds.size.width / 2, self.bounds.size.height)];
    [_barPath addLineToPoint:CGPointMake(self.bounds.origin.x + self.bounds.size.width / 2, self.bounds.size.height * (1 - _barProgress))];
    [_barPath setLineWidth:_barWidth];
    [_barPath setLineCapStyle:kCGLineCapSquare];

    _barLayer.strokeEnd = 1.0;
    _barLayer.path = _barPath.CGPath;
}

- (CABasicAnimation *)setupPathAnimation {
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = BarAnimationDuration;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = @0.0f;
    pathAnimation.toValue = @1.0f;
    return pathAnimation;
}

- (CABasicAnimation *)setupFadeAnimation {
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeAnimation.toValue = [NSNumber numberWithFloat:1.0];
    fadeAnimation.duration = TextAnimationDuration;
    return fadeAnimation;
}

- (CGFloat)calculateLeftBarPoint {
    CGFloat point =  CGRectGetWidth(_textLayer.frame) - CGRectGetWidth(self.bounds);
    if (point < 1) {
        return CGRectGetWidth(self.bounds) / 2;
    }
    point = CGRectGetWidth(_textLayer.frame) / 2 - point;
    return point;
}

- (CGFloat)calculateRightBarPoint {
    return CGRectGetWidth(_textLayer.frame) / 2;
}

- (CGFloat)calculateProgress {
    return CGRectGetHeight(self.bounds) * (1 - _barProgress) - BarTextFont;
}

#pragma mark - setter / getter

- (void)setBarWidth:(CGFloat)barWidth {
    // 設定 bar 寬度
    _barWidth = barWidth;
    _barLayer.lineWidth = barWidth;
    [self setupProgress];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    // 設定背景顏色
    if (backgroundColor && ![backgroundColor isEqual:[UIColor clearColor]]) {
        self.backgroundLayer.strokeColor = backgroundColor.CGColor;
    }
}

- (void)setBarColor:(UIColor *)barColor {
    // 設定 bar 颜色
    _barLayer.strokeColor = barColor.CGColor;
}

- (void)setBarRadius:(CGFloat)barRadius {
    _barLayer.cornerRadius = barRadius;
}

- (void)setBarProgress:(float)progress {
    // 設定 bar 進度
    _barProgress = progress;
    [self setupProgress];
}

- (CATextLayer *)textLayer {
    if (!_textLayer) {
        _textLayer = [CATextLayer layer];
        _textLayer.foregroundColor = _barLayer.strokeColor;
        _textLayer.fontSize = BarTextFont;
        _textLayer.alignmentMode = kCAAlignmentCenter;
        _textLayer.contentsScale = [[UIScreen mainScreen] scale];
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
    // 設定顯示文字大小與相關參數設定
    UIFont *font = [UIFont systemFontOfSize:BarTextFont];
    UIColor *stringColor = [UIColor blackColor];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    NSDictionary *textStyleDictionary = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName:stringColor, NSStrokeColorAttributeName:stringColor };
    CGSize size = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:textStyleDictionary context:nil].size;
    CGRect bounds = _barLayer.bounds;
    bounds.size.height = size.height;
    bounds.size.width = size.width;
    self.textLayer.frame = bounds;
    self.textLayer.string = text;
}

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupBarLayer];
        [self setupInitValue];
    }
    return self;
}

@end
