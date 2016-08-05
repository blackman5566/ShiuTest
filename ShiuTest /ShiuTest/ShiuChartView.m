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
#define YCoordinateHeight (self.frame.size.height - 40)
#define pointsNormalization(ARG) \
((YCoordinateHeight) - (ARG / (self.maxYValue + self.scale)) * (YCoordinateHeight))
// 決定 Y 軸 的位移量
typedef enum {
    DisplacementAmountUp = -6,
    DisplacementAmountDown = 5
} DisplacementAmount;

@interface ShiuChartView ()

@property (strong, nonatomic) NSArray *yValueRange;
@property (strong, nonatomic) NSMutableArray *xPoints;
@property (strong, nonatomic) NSMutableArray *yPoints;
@property (strong, nonatomic) NSMutableArray *yValueStrings;
@property (strong, nonatomic) NSDictionary *textStyleDictionary;

@property (assign, nonatomic) CGFloat leftLineMargin;
@property (assign, nonatomic) NSInteger maxYValue;
@property (assign, nonatomic) NSInteger pointCount;
@property (assign, nonatomic) CGFloat scale;

@end

@implementation ShiuChartView

#pragma mark - private instance method

#pragma mark * init

- (void)setupInitValues {
    // NSMutableArray 分配記憶體位置
    self.xPoints = [NSMutableArray array];
    self.yPoints = [NSMutableArray array];
    self.circleViewArray = [NSMutableArray array];
    self.yValueStrings = [NSMutableArray array];
    self.yValueRange = @[@"5", @"10", @"15", @"20", @"25", @"30", @"35", @"40", @"50", @"100", @"150", @"200", @"250", @"300"];
    
    // 設定顯示文字大小與相關參數設定
    UIFont *font = [UIFont systemFontOfSize:14];
    UIColor *stringColor = [UIColor blackColor];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    self.textStyleDictionary = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName:stringColor, NSStrokeColorAttributeName:stringColor };
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

#pragma mark * 將 X 軸上的文字出來

- (void)setupXaxisWithValues:(NSArray *)xValues {
    // 目前不管任何尺寸都是依照當前螢幕寬度畫19格，
    // 所以當參數數量不足19個時，就會自動塞空的值到數量 19 為止，
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

#pragma mark * 取的 Y 軸最大的值

- (void)setupYaxisWithValues:(NSArray *)values {
    // 計算 y 軸要顯示的文字的相對位置
    // yPoints 預設先加入 0.0 座標，主要是放 ml 字串的位置
    // count 由calculaterHorizontalLineCount方法計算總共要畫幾條橫線
    // value 要顯示的參數
    // xPoint 參數的 x 點
    // yPoint 參數的 y 點
    // size 計算參數大小
    // drawAtPointBlock 因為 y 軸的 view 是在外面，所以用此 Block 做更新。
    [self.yPoints addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
    NSInteger count = [self calculaterHorizontalLineCount:values];
    for (int i = 0; i < count; i++) {
        NSString *value =  self.yValueStrings[i];
        CGFloat xPoint = self.leftLineMargin;
        CGFloat yPoint = pointsNormalization([value floatValue]);
        CGSize size = [value boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:self.textStyleDictionary context:nil].size;
        self.drawAtPointBlock(xPoint, yPoint, size, value);
        [self.yPoints addObject:[NSValue valueWithCGPoint:CGPointMake(xPoint, yPoint)]];
    }
}

#pragma mark * 畫背景的顏色

- (void)drawDashLine {
    if (self.xPoints) {
        
        // 背景顏色初始化設定寬度透明度
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(ctx, 1);
        CGContextSetLineCap(ctx, kCGLineCapSquare);
        CGContextSetAlpha(ctx, 0.6);
        
        // index 將相對的背景顏色畫出來
        CGPoint minYPoint = [[self.yPoints firstObject] CGPointValue];
        NSMutableArray *localXpoints = [self.xPoints mutableCopy];
        for (NSInteger index = 0; index < localXpoints.count; index++) {
            [[UIColor lightGrayColor] setStroke];
            CGPoint xPoint = [localXpoints[index] CGPointValue];
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, nil, xPoint.x, xPoint.y);
            CGPathAddLineToPoint(path, nil, xPoint.x, minYPoint.y);
            CGContextAddPath(ctx, path);
            CGContextDrawPath(ctx, kCGPathEOFillStroke);
            CGPathRelease(path);
        }
        
        // 畫橫線
        CGPoint maxXPoint = [[self.xPoints lastObject] CGPointValue];
        CGFloat alilengths[2] = { 5, 3 };
        CGContextSetLineDash(ctx, 0, alilengths, 2);
        for (NSInteger index = 0; index < self.yPoints.count; index++) {
            NSValue *ypoint = self.yPoints[index];
            CGPoint yPoint = [ypoint CGPointValue];
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, nil, yPoint.x, yPoint.y);
            CGPathAddLineToPoint(path, nil, maxXPoint.x - 5, yPoint.y);
            CGContextAddPath(ctx, path);
            CGContextDrawPath(ctx, kCGPathEOFillStroke);
            CGPathRelease(path);
        }
    }
}

#pragma mark * 畫曲線圖

- (void)drawLineChart {
    NSMutableArray *pointNormalizationArrays = [self pointsNormalization];
    // 開始將折線圖畫出來 初始化 貝茲曲線
    UIBezierPath *lineChartPath = [UIBezierPath bezierPath];
    [lineChartPath moveToPoint:[[pointNormalizationArrays firstObject][@"points"] CGPointValue]];
    lineChartPath.lineCapStyle = kCGLineCapRound;
    lineChartPath.lineJoinStyle = kCGLineJoinRound;
    lineChartPath.lineWidth = 3.0;
    [[UIColor clearColor] set];
    for (int i = 1; i < pointNormalizationArrays.count; i++) {
        if ([pointNormalizationArrays[i][@"value"] floatValue]) {
            NSValue *pointValue = pointNormalizationArrays[i][@"points"];
            [lineChartPath addLineToPoint:[pointValue CGPointValue]];
            [lineChartPath moveToPoint:[pointValue CGPointValue]];
            [lineChartPath stroke];
        }
    }
    
    // 畫出每一個點，但是這裡用 Button 較彈性。
    [self addCircularButton:pointNormalizationArrays];
    
    // 初始化 CAShapeLayer 將線畫出來
    CAShapeLayer *lineLayer = [self setUpLineLayer];
    lineLayer.path = lineChartPath.CGPath;
    lineLayer.strokeEnd = 1.0;
    [self.layer insertSublayer:lineLayer atIndex:0];
}

#pragma mark * misc

- (NSArray *)organizeData:(NSArray *)values {
    // 假如參數數量不到 19 就塞到 19。
    NSMutableArray *newValues = [[NSMutableArray alloc] initWithArray:values copyItems:true];
    while (newValues.count < 19) {
        [newValues addObject:@""];
    }
    return newValues;
}
- (NSMutableArray *)pointsNormalization {
    // 將 X Y 軸的資料做最後的整理
    // 正規化 Y 軸，讓每一點根據目前所設定的畫面大小畫出相對的點，才不會跑出範圍外。
    NSMutableArray *finishPoints = [NSMutableArray array];
    for (int i = 0; i < self.pointCount; i++) {
        CGFloat funcXPoint = [self.xPoints[i] CGPointValue].x;
        CGFloat yValue = [self.yValues[i] floatValue];
        CGFloat funcYPoint = (YCoordinateHeight) - (yValue / (self.maxYValue + self.scale)) * (YCoordinateHeight);
        NSDictionary *pointsDictionary = @{ @"points": [NSValue valueWithCGPoint:CGPointMake(funcXPoint, funcYPoint)], @"value":self.yValues[i] };
        [finishPoints addObject:pointsDictionary];
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
        NSValue *point = finishPoints[i][@"points"];
        CGRect rect = CGRectMake([point CGPointValue].x - 10, [point CGPointValue].y - 10, 20, 20);
        ShiuCircleView *circle = [[ShiuCircleView alloc] init];
        circle.frame = rect;
        circle.value = finishPoints[i][@"value"];
        circle.borderColor = [UIColor grayColor];
        circle.borderWidth = 1;
        circle.holeColor = [UIColor grayColor];
        circle.isAnimationEnabled = NO;
        circle.alpha = [finishPoints[i][@"value"] floatValue];
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

- (NSInteger)calculaterHorizontalLineCount:(NSArray *)values {
    // calculaterMaxYValue 此方法負責計算最大值
    // count 會根據參數範圍回傳相對的數量
    // calculaterCount 計算要顯示的文字
    // scale 根據美工要求，最上面一塊不要畫任何點，所以計算每一塊的距離，點在畫的時候不會超過範圍。
    [self calculaterMaxYValue:values];
    NSInteger count = [self calculaterCount:self.maxYValue];
    self.scale = self.maxYValue / count;
    return count;
}

- (NSInteger)calculaterCount:(NSInteger)maxYValue {
    // yValueRange 自己定義好的間隔範圍 請看 52 行
    // 最多就只顯示 4 個參數
    // 使用迴圈去計算每一個 value * 4 的值
    // 讓最大值去減 value * 4
    // 這樣我就可以知道 哪一個間隔範圍最符合當前最大值
    // 找到之後 break
    NSInteger value = 0;
    for (int index = 0; index < self.yValueRange.count; index++) {
        value = [self.yValueRange[index] integerValue];
        if (1 > (maxYValue - (value * 4))) {
            break;
        }
    }
    
    // yValueStrings 負責存放要顯示的參數
    // 先將最大值與ml存起來
    // 接著計算利用迴圈開始倍數相減
    // 假如 yValue 沒有比 1 小就代表還可以繼續相減下去
    // 假設已經比 1 小 就代表已經超過參數範圍 就直接跳出迴圈
    // 根據 yValueStrings.count 就可知道要畫幾個參數
    [self.yValueStrings addObject:@"ml"];
    [self.yValueStrings addObject:[NSString stringWithFormat:@"%d", maxYValue]];
    for (int index = 1; index <= 4; index++) {
        NSInteger spacValue = value * index;
        NSInteger yValue = maxYValue - spacValue;
        if (1 > yValue) {
            break;
        }
        [self.yValueStrings addObject:[NSString stringWithFormat:@"%d", yValue]];
    }
    return self.yValueStrings.count;
}

- (void)calculaterMaxYValue:(NSArray *)values {
    // 為了要讓 y 軸的數值看起來較漂亮如 200 150 100 等延續下去，
    // 所以要做正規劃的計算
    // maxYValue 當前array 最大值
    // rangeValue 代表要正規劃的範圍，比如說 maxYValue 大於100 ， rangeValue會等於50
    // 接著條件判斷 maxYValue 除以 rangeValue 是否餘數為0
    // 當為 0 就代表此最大值數字是 50 的倍數，就不做正規劃
    // 當不為 0 時，就做正規劃的動作
    // 例如 maxYValue 為 235
    // self.maxYValue = (self.maxYValue + rangeValue) - (self.maxYValue % rangeValue);
    //   maxYValue    = (     235       +     50    ) - (     235       %     50    )
    // 最後 maxYValue 計算出來的值會是 250
    
    self.maxYValue = [[values valueForKeyPath:@"@max.intValue"] intValue];
    NSInteger rangeValue = 5;
    if (self.maxYValue > 100) {
        rangeValue = 50;
    }
    
    if ((self.maxYValue % rangeValue)) {
        self.maxYValue = (self.maxYValue + rangeValue) - (self.maxYValue % rangeValue);
    }
}

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

#pragma mark * override

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.xValues && self.yValues) {
        [self setupChartView];
    }
}

@end


