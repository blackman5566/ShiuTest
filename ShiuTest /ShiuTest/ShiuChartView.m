//
//  ShiuChartView.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/26.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ShiuChartView.h"
#import "ShiuCircleView.h"
#import "ShiuChartTooltipView.h"

#define RandomColor [UIColor colorWithRed:arc4random_uniform(255) / 155.0 green:arc4random_uniform(255) / 155.0 blue:arc4random_uniform(255) / 155.0 alpha:0.7]

#define BottomLineMargin 20
#define XCoordinateWidth (self.frame.size.width - self.leftLineMargin)
#define YCoordinateHeight (self.frame.size.height - 30 - 5)

@interface ShiuChartView ()

// 透過 get/set 去初始化
@property (strong, nonatomic) NSMutableArray *xPoints;
@property (strong, nonatomic) NSMutableArray *yPoints;
@property (strong, nonatomic) NSDictionary *textStyleDict;
@property (assign, nonatomic) CGFloat maxYValue;

// 設定距離左邊界的距離
@property (assign, nonatomic) CGFloat leftLineMargin;
@property (nonatomic, assign) NSInteger pointCount;

@end

@implementation ShiuChartView

#pragma mark - public class method

+ (instancetype)initCharView:(CGRect)frame {

    ShiuChartView *chartView = [[self alloc] init];
    chartView.frame = frame;
    return chartView;
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.leftLineMargin = 0;
    }
    return self;
}

#pragma mark - 懶惰的方式加載新物件

#pragma mark * get

- (NSMutableArray *)xPoints {
    if (!_xPoints) {
        _xPoints = [NSMutableArray array];
    }
    return _xPoints;
}

- (NSMutableArray *)yPoints {
    if (!_yPoints) {
        _yPoints = [NSMutableArray array];
    }
    return _yPoints;
}

- (NSMutableArray *)circleViewArray {
    if (!_circleViewArray) {
        _circleViewArray = [NSMutableArray array];
    }
    return _circleViewArray;
}

- (NSDictionary *)textStyleDict {
    if (!_textStyleDict) {
        // 設定文字的樣式
        UIFont *font = [UIFont systemFontOfSize:14];
        UIColor *stringColor = [UIColor blackColor];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentCenter;
        _textStyleDict = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName:stringColor, NSStrokeColorAttributeName:stringColor };
    }
    return _textStyleDict;
}

#pragma mark - drawRect 系統會自動調用這個方法

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // 開始畫座標與背景的顏色
    [self drawCoorPointAndDashLine];
}

- (void)drawCoorPointAndDashLine {
    [self setUpXcoorWithValues:self.xValues];
    [self setUpYcoorWithValues:self.yValues];
    [self drawDashLine];
    [self drawLineChart];
}

#pragma mark - 將 X 軸上的文字出來

- (void)setUpXcoorWithValues:(NSArray *)values {
    self.pointCount = values.count;
    if (values.count) {
        values = [self organizeData:values];
        for (NSInteger i = 0; i < values.count; i++) {
            CGFloat cX = 0;
            if (i == 0) {
                cX = DashLineWidth / 2;
            }
            else {
                cX = (DashLineWidth / 2) + ((DashLineWidth) * i) + self.leftLineMargin;
            }
            CGFloat cY = self.frame.size.height - BottomLineMargin;
            // 收集坐标点
            [self.xPoints addObject:[NSValue valueWithCGPoint:CGPointMake(cX, self.frame.size.height)]];

            // 將字畫上去
            NSString *xValue = values[i];
            CGSize size = [xValue boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:self.textStyleDict context:nil].size;

            if ((i % 2 == 0)) {
                [xValue drawAtPoint:CGPointMake(cX - size.width * 0.5, cY - 6) withAttributes:self.textStyleDict];
            }
            else {
                [xValue drawAtPoint:CGPointMake(cX - size.width * 0.5, cY + 5) withAttributes:self.textStyleDict];
            }
        }
    }
}

- (NSArray *)organizeData:(NSArray *)values {
    NSMutableArray *newValues = [[NSMutableArray alloc] initWithArray:values copyItems:true];
    while (newValues.count < 20) {
        [newValues addObject:@""];
    }
    return newValues;
}

#pragma mark - 取的 Y 軸最大的值

- (void)setUpYcoorWithValues:(NSArray *)values {
    if (values.count) {
        self.maxYValue = [[values valueForKeyPath:@"@max.intValue"] intValue];
        NSLog(@"self.maxYValue = %f", self.maxYValue);
        for (int i = 0; i < values.count; i++) {
            CGFloat cX = self.leftLineMargin;
            CGFloat cY = i * (YCoordinateHeight / values.count) + 5;
            [self.yPoints addObject:[NSValue valueWithCGPoint:CGPointMake(cX, cY)]];
        }
    }
}

#pragma mark - 畫背景的顏色

- (void)drawDashLine {
    if (self.xPoints.count != 0 && self.yPoints.count != 0) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGPoint minYPoint = [[self.yPoints firstObject] CGPointValue];

        // 背景顏色初始化 一個畫面就20格
        //CGFloat dashLineWidth = self.frame.size.width / self.xValues.count;
        //CGFloat dashLineWidth = [UIScreen mainScreen].bounds.size.width / 20;
        CGContextSetLineWidth(ctx, DashLineWidth);
        CGContextSetLineCap(ctx, kCGLineCapSquare);
        CGContextSetAlpha(ctx, 0.6);
        CGFloat alilengths[2] = { 5, 3 };
        CGContextSetLineDash(ctx, 0, alilengths, 2);

        // 畫背景顏色
        NSMutableArray *localXpoints = [self.xPoints mutableCopy];
        for (int i = 0; i < localXpoints.count; i++) {
            NSValue *xp = localXpoints[i];
            [[UIColor lightGrayColor] setStroke];
            if (i % 2 == 0) {
                [[UIColor whiteColor] setStroke];
            }
            CGPoint xPoint = [xp CGPointValue];
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, nil, xPoint.x, xPoint.y);
            CGPathAddLineToPoint(path, nil, xPoint.x, minYPoint.y);
            CGContextAddPath(ctx, path);
            CGContextDrawPath(ctx, kCGPathEOFillStroke);
            CGPathRelease(path);
        }
    }
}

#pragma mark - 畫曲線圖

- (void)drawLineChart {
    if (self.xValues && self.yValues) {
        NSMutableArray *finishPoints = [NSMutableArray array];
        //        // 判斷是否 Ｘ 軸的值 或 Y 軸的值 有少，假如有少就取少的數量，防止程式崩潰
        //        if (self.xValues.count != self.yValues.count) {
        //            pointCount = (self.xValues.count < self.yValues.count ? self.xValues.count : self.yValues.count);
        //        }

        for (int i = 0; i < self.pointCount; i++) {
            // 將 x y 軸的資料做最後的整理
            CGFloat funcXPoint = [self.xPoints[i] CGPointValue].x;
            CGFloat yValue = [self.yValues[i] floatValue];
            // y 軸根據目前 所設定的畫面大小，去計算每一點出來的位置。()
            CGFloat funcYPoint = (YCoordinateHeight) - (yValue / (self.maxYValue + 30)) * (YCoordinateHeight);
            [finishPoints addObject:[NSValue valueWithCGPoint:CGPointMake(funcXPoint, funcYPoint)]];
        }
        [[UIColor clearColor] set];

        // 開始將折線圖畫出來 初始化 貝茲曲線
        UIBezierPath *lineChartPath = [UIBezierPath bezierPath];
        [lineChartPath moveToPoint:[[finishPoints firstObject] CGPointValue]];
        [lineChartPath setLineCapStyle:kCGLineCapRound];
        [lineChartPath setLineJoinStyle:kCGLineJoinRound];

        for (int i = 1; i < finishPoints.count; i++) {
            NSValue *pointValue = finishPoints[i];
            [lineChartPath addLineToPoint:[pointValue CGPointValue]];
            [lineChartPath moveToPoint:[pointValue CGPointValue]];
            [lineChartPath stroke];
        }

        // 畫出每一個點，但是這裡用 Button 較彈性。
        [self addCircularButton:finishPoints];

        // 初始化 CAShapeLayer ，用來跑動畫效果
        CAShapeLayer *lineLayer = [self setUpLineLayer];
        lineLayer.path = lineChartPath.CGPath;
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = 1.0;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        pathAnimation.autoreverses = NO;
        [lineLayer addAnimation:pathAnimation forKey:@"lineLayerAnimation"];
        lineLayer.strokeEnd = 1.0;
        [self.layer insertSublayer:lineLayer atIndex:0];
    }
}

- (CAShapeLayer *)setUpLineLayer {
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.lineCap = kCALineCapRound;
    lineLayer.lineJoin = kCALineJoinBevel;
    lineLayer.strokeEnd   = 0.0;

    if (self.chartColor) {
        lineLayer.strokeColor = self.chartColor.CGColor;
    }
    else {
        lineLayer.strokeColor = RandomColor.CGColor;
    }
    if (self.chartWidth) {
        lineLayer.lineWidth   = self.chartWidth;
    }
    else {
        lineLayer.lineWidth   = 3.0;
    }
    return lineLayer;
}

#pragma mark - mise

- (void)drawPathWithLine:(UIBezierPath *)line movePoint:(CGPoint)movePoint toPoint:(CGPoint)toPoint {
    [line moveToPoint:movePoint];
    [[UIColor redColor] setFill];
    [line addLineToPoint:toPoint];
    [line stroke];
}

- (UIBezierPath *)drawCircleWithOvalInRect:(CGRect)frame {
    UIBezierPath *circleDot = [UIBezierPath bezierPathWithOvalInRect:frame];
    [[UIColor blueColor] setFill];
    [circleDot fill];
    return circleDot;
}

- (void)addCircularButton:(NSArray *)finishPoints {
    for (NSInteger i = 0; i < finishPoints.count; i++) {
        NSValue *point = finishPoints[i];
        CGRect rect = CGRectMake([point CGPointValue].x - 10, [point CGPointValue].y - 10, 20, 20);
        ShiuCircleView *circle = [[ShiuCircleView alloc] init];
        circle.frame = rect;
        circle.value = self.yValues[i];
        circle.borderColor = [UIColor grayColor];
        circle.borderWidth = 1;
        circle.holeColor = [UIColor grayColor];
        circle.isAnimationEnabled = NO;
        //__weak ShiuChartView *weakSelf = self;
//        circle.circleClickBlock = ^(ShiuCircleView *circleView){
//            // __strong CBChartView *strongSelf = weakSelf;
//            //             [strongSelf selectCircleIndex:idx];
//
//        };
        [self.circleViewArray addObject:circle];
        [self addSubview:circle];
    }
}



@end


