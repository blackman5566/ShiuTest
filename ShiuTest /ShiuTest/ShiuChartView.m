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
#define YCoordinateHeight (self.frame.size.height - 50)

// 決定 Y 軸 的位移量
typedef enum {
    DisplacementAmountUp = -6,
    DisplacementAmountDown = 5
} DisplacementAmount;

@interface ShiuChartView ()

@property (strong, nonatomic) NSMutableArray *xPoints;
@property (strong, nonatomic) NSMutableArray *yPoints;
@property (strong, nonatomic) NSDictionary *textStyleDictionary;

@property (assign, nonatomic) CGFloat leftLineMargin;
@property (assign, nonatomic) CGFloat maxYValue;
@property (assign, nonatomic) NSInteger pointCount;

@end

@implementation ShiuChartView

#pragma mark * init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupInitValues];
        
        // 設定距離左邊界的距離
        self.leftLineMargin = 0;
    }
    return self;
}

- (void)setupInitValues {
    // NSMutableArray 分配記憶體位置
    self.xPoints = [NSMutableArray array];
    self.yPoints = [NSMutableArray array];
    self.circleViewArray = [NSMutableArray array];
    
    // 設定顯示文字大小與相關參數設定
    UIFont *font = [UIFont systemFontOfSize:14];
    UIColor *stringColor = [UIColor blackColor];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    self.textStyleDictionary = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName:stringColor, NSStrokeColorAttributeName:stringColor };
}

#pragma mark - drawRect 系統會自動調用這個方法

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.xValues && self.yValues) {
        [self setupChartView];
    }
}

- (void)setupChartView {
    // 將 x 軸上的值畫出來
    [self setupXaxisWithValues:self.xValues];
    
    // 將 y 軸上最大的值取出來，之後要正規劃，讓點不超出範圍。
    [self setupYaxisWithValues:self.yValues];
    
    // 將背景畫出來
    [self drawDashLine];
    
    // 將可愛的線畫出來嚕
    [self drawLineChart];
}

#pragma mark - 將 X 軸上的文字出來

- (void)setupXaxisWithValues:(NSArray *)xValues {
    // 目前不管任何尺寸都是依照當前螢幕寬度畫20格，
    // 所以當參數數量不足20個時，就會自動塞空的值到數量 20 為止，
    // 所以需要先將原始資料的數量存在 self.pointCount
    self.pointCount = xValues.count;
    xValues = [self organizeData:xValues];
    CGFloat calculateXPoint = 0;
    for (NSInteger index = 0; index < xValues.count; index++) {
        // 開始計算每一個點的 Ｘ 軸位置
        // DashLineWidth: 每一格的寬度
        // calculateXPoint: 計算每一個 X 位置
        // xValue: X 軸上要顯示的值
        // calculateYPoint: 計算後的 Y 位置 (當前View的高 - 預留下方空間)
        // size : 參數顯示寬度大小
        // displacementAmount: X 軸顯示的參數需要上下位置變化，所以需要改變 yDisplacementAmount 來做 y 位移。
        CGFloat fristGap = DashLineWidth / 2;
        CGFloat widthGap = (DashLineWidth * index) + self.leftLineMargin;
        calculateXPoint = fristGap + widthGap;
        
        CGFloat calculateYPoint = self.frame.size.height - BottomLineMargin;
        NSString *xValue = xValues[index];
        CGSize size = [xValue boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:self.textStyleDictionary context:nil].size;
        NSInteger displacementAmount = 0;
        displacementAmount = (index % 2) ? DisplacementAmountDown : DisplacementAmountUp;
        [xValue drawAtPoint:CGPointMake(calculateXPoint - size.width * 0.5, calculateYPoint + displacementAmount) withAttributes:self.textStyleDictionary];
        
        // 最後將 xPoint 存起來
        // calculateXPoint: 計算後的 X 位置
        // self.frame.size.height: 當畫背景時需要 Y 的參數，所以直接取當前畫面的高直接畫到滿。
        [self.xPoints addObject:[NSValue valueWithCGPoint:CGPointMake(calculateXPoint, self.frame.size.height)]];
    }
}

- (NSArray *)organizeData:(NSArray *)values {
    // 假如參數數量不到 20 就塞到 20。
    NSMutableArray *newValues = [[NSMutableArray alloc] initWithArray:values copyItems:true];
    while (newValues.count < 20) {
        [newValues addObject:@""];
    }
    return newValues;
}

#pragma mark - 取的 Y 軸最大的值

- (void)setupYaxisWithValues:(NSArray *)values {
    // 取的 Y 軸最大的值
    // calculateXPoint: Y 軸距離左邊界的距離
    // calculateYPoint: 按照比例計算 Y 距離上邊界的距離。
    if (values) {
        self.maxYValue = [[values valueForKeyPath:@"@max.intValue"] intValue];
        for (int i = 0; i < values.count; i++) {
            CGFloat calculateXPoint = self.leftLineMargin;
            CGFloat calculateYPoint = i * (YCoordinateHeight / values.count) + 5;
            [self.yPoints addObject:[NSValue valueWithCGPoint:CGPointMake(calculateXPoint, calculateYPoint)]];
        }
    }
}

#pragma mark - 畫背景的顏色

- (void)drawDashLine {
    if (self.xPoints) {
        
        // 背景顏色初始化設定寬度透明度
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(ctx, DashLineWidth);
        CGContextSetLineCap(ctx, kCGLineCapSquare);
        CGContextSetAlpha(ctx, 0.6);
        
        // index 將相對的背景顏色畫出來
        CGPoint minYPoint = [[self.yPoints firstObject] CGPointValue];
        NSMutableArray *localXpoints = [self.xPoints mutableCopy];
        for (NSInteger index = 0; index < localXpoints.count; index++) {
            (index % 2 == 0) ? [[UIColor whiteColor] setStroke] : [[UIColor lightGrayColor] setStroke];
            CGPoint xPoint = [localXpoints[index] CGPointValue];
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
    
    NSMutableArray *pointNormalizationArrays = [self pointsNormalization];
    // 開始將折線圖畫出來 初始化 貝茲曲線
    UIBezierPath *lineChartPath = [UIBezierPath bezierPath];
    [lineChartPath moveToPoint:[[pointNormalizationArrays firstObject] CGPointValue]];
    lineChartPath.lineCapStyle = kCGLineCapRound;
    lineChartPath.lineJoinStyle = kCGLineJoinRound;
    lineChartPath.lineWidth = 3.0;
    [[UIColor clearColor] set];
    for (int i = 1; i < pointNormalizationArrays.count; i++) {
        NSValue *pointValue = pointNormalizationArrays[i];
        [lineChartPath addLineToPoint:[pointValue CGPointValue]];
        [lineChartPath moveToPoint:[pointValue CGPointValue]];
        [lineChartPath stroke];
    }
    
    // 畫出每一個點，但是這裡用 Button 較彈性。
    [self addCircularButton:pointNormalizationArrays];
    
    // 初始化 CAShapeLayer 將線畫出來
    CAShapeLayer *lineLayer = [self setUpLineLayer];
    lineLayer.path = lineChartPath.CGPath;
    lineLayer.strokeEnd = 1.0;
    [self.layer insertSublayer:lineLayer atIndex:0];
}

- (NSMutableArray *)pointsNormalization {
    // 將 X Y 軸的資料做最後的整理
    // 正規化 Y 軸，讓每一點根據目前所設定的畫面大小畫出相對的點，才不會跑出範圍外。
    NSMutableArray *finishPoints = [NSMutableArray array];
    for (int i = 0; i < self.pointCount; i++) {
        CGFloat funcXPoint = [self.xPoints[i] CGPointValue].x;
        CGFloat yValue = [self.yValues[i] floatValue];
        CGFloat funcYPoint = (YCoordinateHeight) - (yValue / (self.maxYValue + 100)) * (YCoordinateHeight);
        [finishPoints addObject:[NSValue valueWithCGPoint:CGPointMake(funcXPoint, funcYPoint)]];
    }
    return finishPoints;
}

- (CAShapeLayer *)setUpLineLayer {
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.lineCap = kCALineCapRound;
    lineLayer.lineJoin = kCALineJoinBevel;
    lineLayer.strokeEnd = 0.0;
    lineLayer.strokeColor = self.chartColor ? self.chartColor.CGColor : RandomColor.CGColor;
    lineLayer.lineWidth = self.chartWidth ? self.chartWidth : 3.0f;
    return lineLayer;
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
        //circle.circleClickBlock = ^(ShiuCircleView *circleView){
            //            // __strong CBChartView *strongSelf = weakSelf;
            //            //             [strongSelf selectCircleIndex:idx];
            //
        //};
        [self.circleViewArray addObject:circle];
        [self addSubview:circle];
    }
}



@end


