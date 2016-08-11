//
//  ShiuBarChartViewV2.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/25.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ShiuBarChartView.h"
#import "ShiuBar.h"

#define XLabelMarginTop 5
#define XAxisMarginLeft 0
#define XAxisMarginRight 0

@interface ShiuBarChartView ()

@property (nonatomic, strong) NSMutableArray <ShiuBar *> *bars;
@property (nonatomic, strong) NSMutableArray *stringPointX;

@end

@implementation ShiuBarChartView

#pragma mark - public method

- (void)showBar {
    // 將所有的 bar 重新長出來
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setupShiuBar];
    [self setupPetName];
    for (ShiuBar *bar in self.bars) {
        [bar show];
    }
}

#pragma mark - private instance method

#pragma mark * init

- (void)setupShiuBar {
    // petCount 寵物的數量
    // itemCount barType 的數量
    // groupWidth 每一個寵物所有 bar 的總寬度
    // barHeight 計算bar的高
    // CGRectGetHeight(self.bounds) - self.chartMargin.top - self.chartMargin.bottom
    //            總高              -         上邊界        -            下邊界

    // barWidth 計算bar的寬
    // (groupWidth        +  self.data.barGap) / itemCount    - self.data.barGap
    // (所有bar的總寬度     +    每一個bar間距   ) / barType的數量 - 每一個bar間距

    // widthGap 計算每一個寵物之間的距離
    //(CGRectGetWidth(self.bounds) - (   groupWidth   * petCount))  / (petCount + 1)
    //(            總寬             - ( 所有bar的總寬度  *  寵物數量 )) / (  總共的 gap)

    CGFloat petCount = [self.data.dataSets[0].yValues count];
    CGFloat itemCount = [self.data.dataSets count];
    CGFloat groupWidth = 40;
    CGFloat barHeight = CGRectGetHeight(self.bounds) - self.chartMargin.top - self.chartMargin.bottom;
    CGFloat barWidth = (groupWidth + self.data.barGap) / itemCount - self.data.barGap;
    CGFloat widthGap = (CGRectGetWidth(self.bounds) - (groupWidth * petCount)) / (petCount + 1);
    // 位置計算
    for (NSInteger barTypeIndex = 0; barTypeIndex < self.data.dataSets.count; barTypeIndex++) {
        // 將第一種類型的 bar 開始畫出來
        ShiuBarChartDataSet *dataset = self.data.dataSets[barTypeIndex];
        for (NSInteger drawIndex = 0; drawIndex < dataset.yValues.count; drawIndex++) {
            CGFloat barX = widthGap + (drawIndex * (groupWidth + widthGap)) + (barTypeIndex * (barWidth + self.data.barGap));
            ShiuBar *bar = [[ShiuBar alloc] initWithFrame:CGRectMake(barX, self.chartMargin.top, barWidth, barHeight)];
            NSNumber *yValue = dataset.yValues[drawIndex];
            bar.barProgress = isnan(yValue.floatValue / self.data.yMaxValue) ? 0 : (yValue.floatValue / self.data.yMaxValue);
            bar.barColor = dataset.barColor;
            bar.backgroundColor = dataset.barbackGroudColor;
            bar.isAnimated = self.isAnimated;
            bar.barRadius = 40;
            [self isShowLegendView:bar value:yValue barTypeIndex:barTypeIndex];
            [self.bars addObject:bar];
            [self addSubview:bar];
            [self isStringPointXWithShiuBar:bar barTypeIndex:barTypeIndex];
        }
    }
}

- (void)setupPetName {
    // 初始化 Ｘ軸 文字
    if (self.data.xLabels) {
        UIFont *font = [UIFont systemFontOfSize:self.data.xLabelFontSize];
        UIColor *stringColor = [UIColor blackColor];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentCenter;
        NSDictionary *textStyleDictionary = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName:stringColor, NSStrokeColorAttributeName:stringColor };

        [self.data.xLabels enumerateObjectsUsingBlock: ^(NSString *_Nonnull petName, NSUInteger index, BOOL *_Nonnull stop) {
             // size 取得當前 petName 的文字大小
             // xLabelHeight 計算每一個 Label 高度
             // stringFrame 計算整個label 大小
             // bar 會根據 stringPointX 取得每一組第一個 bar
             // newPoint 取得當前 label 的中心點，再根據 CGRectGetMaxX(bar.frame) 取得Ｘ點，
             //          讓每一個 label 的中心點對準 bar。
             CGSize size = [petName boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:textStyleDictionary context:nil].size;
             CGFloat xLabelHeight = self.chartMargin.bottom - XLabelMarginTop;
             CGRect stringFrame = CGRectMake(0, self.bounds.size.height - xLabelHeight, size.width, xLabelHeight);
             UILabel *valueLabel = [[UILabel alloc] initWithFrame:stringFrame];
             ShiuBar *bar = self.stringPointX[index];
             CGPoint newPoint = valueLabel.center;
             newPoint.x = CGRectGetMaxX(bar.frame);
             valueLabel.center = newPoint;
             valueLabel.font = [UIFont systemFontOfSize:14];
             valueLabel.textAlignment = NSTextAlignmentCenter;
             valueLabel.text = petName;
             [self addSubview:valueLabel];
         }];
    }
}

- (void)setupInitValue {
    self.bars = [NSMutableArray array];
    self.stringPointX = [NSMutableArray array];
    self.chartMargin = UIEdgeInsetsMake(30, 15, 30, 15);
    self.isShowX = YES;
    self.isShowNumber = YES;
    self.isAnimated = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
}

#pragma mark * misc

- (void)isStringPointXWithShiuBar:(ShiuBar *)bar barTypeIndex:(NSInteger)barTypeIndex {
    if (barTypeIndex == 0) {
        [self.stringPointX addObject:bar];
    }
}

- (void)isShowLegendView:(ShiuBar *)bar value:(NSNumber *)yValue barTypeIndex:(NSInteger)barTypeIndex {
    if (self.isShowNumber) {
        NSString *string = [NSString stringWithFormat:@"%@次", yValue.stringValue];
        if (barTypeIndex) {
            string = [NSString stringWithFormat:@"%@ml", yValue.stringValue];
        }
        bar.barText = string;
    }
}

#pragma mark - override

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // 設定線寬度與預設是灰色顏色
    // 開始畫 X 軸嚕
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextMoveToPoint(context, self.chartMargin.left - XAxisMarginLeft, self.bounds.size.height - self.chartMargin.bottom + 0.5);
    CGContextAddLineToPoint(context, self.bounds.size.width - self.chartMargin.right + XAxisMarginRight, self.bounds.size.height - self.chartMargin.bottom + 0.5);
    CGContextStrokePath(context);

}

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInitValue];
    }
    return self;
}

@end
