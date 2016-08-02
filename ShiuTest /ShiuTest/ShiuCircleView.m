//
//  CircleView.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/28.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ShiuCircleView.h"

@interface ShiuCircleView ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAShapeLayer *outSideCircleLayer;
@property (nonatomic, strong) UIView *highLightView;
@property (nonatomic, assign) BOOL isDouble;

@end

@implementation ShiuCircleView

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isDouble = NO;
        self.holeColor = [UIColor blackColor];
    }
    return self;
}

#pragma mark - setter / getter

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
        _isDouble = YES;
    }
    else {
        _isDouble = NO;
    }
    [self setNeedsDisplay];
}

- (CAShapeLayer *)circleLayer {
    if (!_circleLayer) {
        _circleLayer = [[CAShapeLayer alloc] init];
        _circleLayer.strokeColor = self.borderColor.CGColor;
        _circleLayer.lineWidth = self.borderWidth;
    }
    return _circleLayer;
}

- (CAShapeLayer *)outSideCircleLayer {
    if (!_outSideCircleLayer) {
        _outSideCircleLayer = [[CAShapeLayer alloc] init];
        _outSideCircleLayer.fillColor = [self.holeColor colorWithAlphaComponent:0.2].CGColor;
        _outSideCircleLayer.strokeColor = self.borderColor.CGColor;
        _outSideCircleLayer.lineWidth = self.borderWidth / 2.0;
        _outSideCircleLayer.anchorPoint = CGPointMake(0.5, 0.5);
        _outSideCircleLayer.backgroundColor = [UIColor redColor].CGColor;
    }
    return _outSideCircleLayer;
}

#pragma mark - drawRect

- (void)drawRect:(CGRect)rect {
    // 開始將 button 畫成圓
    [self drawCircle:rect doubleCircle:_isDouble];

    // 判斷是否要呈現動畫
    if (self.isAnimationEnabled) {
        [self drawOutSideCircle:rect touchAnimateOpen:YES];
    }
}

#pragma mark - 開始畫圓

- (void)drawCircle:(CGRect)rect doubleCircle:(BOOL)isDouble {

    // 設定圓角邊源
    self.circleLayer.cornerRadius = CGRectGetHeight(rect) / 2.0;

    // 設定內圓
    CGRect insideCircleRect = CGRectMake(CGRectGetMinX(rect) + CGRectGetWidth(rect) / 4.0, CGRectGetMinY(rect) + CGRectGetHeight(rect) / 4.0, CGRectGetWidth(rect) / 2.0, CGRectGetHeight(rect) / 2.0);

    // 設定中心點
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));

    // 開始使用 初始化 貝茲曲線
    UIBezierPath *path = [UIBezierPath bezierPath];
    self.circleLayer.fillColor = self.holeColor.CGColor;

    //開始將按鈕畫出來
    [path moveToPoint:CGPointMake(centerPoint.x + CGRectGetWidth(rect) / 4, centerPoint.y)];
    [path addArcWithCenter:centerPoint radius:CGRectGetHeight(insideCircleRect) / 2.0  startAngle:0 endAngle:M_PI * 2 clockwise:YES];

    self.circleLayer.bounds = rect;
    self.circleLayer.path = path.CGPath;
    self.circleLayer.position = centerPoint;

    [self.layer addSublayer:self.circleLayer];

}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    self.circleClickBlock(self);
    return YES;
}

- (void)drawOutSideCircle:(CGRect)rect touchAnimateOpen:(BOOL)open {
    // 初始化外圍
    self.outSideCircleLayer.cornerRadius = CGRectGetHeight(rect) / 2;
    self.outSideCircleLayer.position =  CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGRect insideCircleRect = CGRectMake(0, 0, CGRectGetWidth(rect) / 2.0, CGRectGetHeight(rect) / 2.0);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointZero radius:CGRectGetHeight(insideCircleRect) / 2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    self.outSideCircleLayer.path = path.CGPath;
    [self.layer addSublayer:_outSideCircleLayer];
    NSString *animationKey = @"key";
    [self.outSideCircleLayer removeAnimationForKey:animationKey];

    if (open) {
        CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.keyTimes = @[@0, @0.618, @1];
        scaleAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity],
                                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.5, 2.5, 1)],
                                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.0, 2.0, 1)]];
        scaleAnimation.duration = 2.0f;
        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaAnimation.fromValue = @1;
        alphaAnimation.toValue = @0;

        CAAnimationGroup *animation = [CAAnimationGroup animation];
        animation.animations = @[scaleAnimation, alphaAnimation];
        animation.duration = 2.0f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animation.repeatCount = MAXFLOAT;
        [_outSideCircleLayer addAnimation:animation forKey:animationKey];
    }
}

@end
