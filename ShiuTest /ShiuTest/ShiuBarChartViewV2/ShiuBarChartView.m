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
#define YLabelMarginRight 5
#define XAxisMarginLeft 0
#define XAxisMarginRight 0
#define YAxisMarginTop 10
#define LegendTextSize 10

@interface ShiuBarChartView ()

@property (nonatomic, strong) NSMutableArray <ShiuBar *> *bars;
@property (nonatomic, strong) ShiuLegendView *legendView;
@property (nonatomic, strong) NSMutableArray *stringPointX;

@end

@implementation ShiuBarChartView

#pragma mark - life cycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInitValue];
    }
    return self;
}

- (void)setupInitValue {
    self.chartMargin = UIEdgeInsetsMake(30, 30, 30, 30);
    self.isShowX = YES;
    self.isShowY = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    self.bars = [NSMutableArray array];
    self.stringPointX = [NSMutableArray array];
}

#pragma mark - public method

- (void)show {



    // 位置計算, 假設現在是 i = 9
    // pageIndex 當前 item 在第 1 個分頁 (從 0 開始計)
    // itemIndexInPage 當前 item 在這個分頁中的第 1 個
    // itemAtRow 當前 item 在這個分頁中的第 0 列
    // itemAtColumn 當前 item 在這個分頁的第 1 行 (從 0 開始計)
    //
    // 0 1 2 3   8 9 <- 這邊
    //
    // 4 5 6 7
//    NSInteger pageIndex = i / 8;
//    NSInteger itemIndexInPage = i % 8;
//    NSInteger itemAtRow = itemIndexInPage / 4;
//    NSInteger itemAtColumn = itemIndexInPage % 4;
//    CGFloat x = (pageIndex * CGRectGetWidth(self.bounds)) + widthGap + (square + widthGap) * itemAtColumn;
//    CGFloat y = heightGap + (square + heightGap) * itemAtRow;



    // 位置計算, 假設現在是 i = 6
    // groupCount 當前 item 在第 1 個分頁 (從 0 開始計)
    // itemIndexInPage 當前 item 在這個分頁中的第 1 個
    // itemAtRow 當前 item 在這個分頁中的第 0 列
    // itemAtColumn 當前 item 在這個分頁的第 1 行 (從 0 開始計)
    //
    //  0 1 2  | 3 4 5 |  6  <- 這邊



    // 一個寵物有幾個資訊
    CGFloat groupCount = [_data.dataSets[0].yValues count];
    CGFloat itemCount = [self.data.dataSets count];

    // 開始計算每組的總寬度
    CGFloat groupWidth = 40;

    // 設定每個 bar 的高與寬

    CGFloat barHeight = self.bounds.size.height - _chartMargin.top - _chartMargin.bottom;
    CGFloat barWidth = (groupWidth + self.data.itemGap) / itemCount - self.data.itemGap;
    CGFloat widthGap = (self.bounds.size.width - (groupWidth * groupCount)) / (groupCount + 1);

    // 開始長出來嚕
    for (NSInteger barTypeIndex = 0; barTypeIndex < self.data.dataSets.count; barTypeIndex++) {
        // 先取得第一種的 bar
        ShiuBarChartDataSet *dataset = self.data.dataSets[barTypeIndex];
        // 將第一種類型的 bar 開始畫出來
        for (NSInteger barIndex = 0; barIndex < dataset.yValues.count; barIndex++) {
            CGFloat barX1 = widthGap + (barIndex * (groupWidth + widthGap)) + (barTypeIndex * (barWidth + self.data.itemGap));
            ShiuBar *bar = [[ShiuBar alloc] initWithFrame:CGRectMake(barX1, self.chartMargin.top, barWidth, barHeight)];
            if (barTypeIndex == 0) {
                [self.stringPointX addObject:bar];
                NSLog(@"bar  = %@", NSStringFromCGRect(bar.frame));
            }
            // 取得要顯示的數字
            NSNumber *yValue = dataset.yValues[barIndex];
            // 使用 isnan 判斷是否為數字，當不是數字時直接帶0。
            bar.barProgress = isnan(yValue.floatValue / _data.yMaxNum) ? 0 : (yValue.floatValue / _data.yMaxNum);
            // 設定 bar 顏色
            bar.barColor = dataset.barColor;
            // 設定 bar 背景色
            bar.backgroundColor = dataset.barbackGroudColor;

            // 根據使用者設定，判斷是否要顯示數值
            if (self.isShowNumber) {
                bar.barText = yValue.stringValue;
                if (barTypeIndex) {
                    bar.barText = [NSString stringWithFormat:@"%@ml", yValue.stringValue];
                }
            }

            // 根據使用者設定，判斷是否要顯示動畫效果
            bar.isAnimated = self.isAnimated;

            [self.bars addObject:bar];
            [self addSubview:bar];
        }
    }
    // 設定每個bar 顏色所代表的意思
//    if (self.data.isGrouped) {
//        [self setupLegendView];
//    }
}

- (void)setupLegendView {
    NSMutableArray *array = [NSMutableArray array];
    [_data.dataSets enumerateObjectsUsingBlock: ^(ShiuBarChartDataSet *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
         ShiuLegendViewData *data = [ShiuLegendViewData new];
         data.color = obj.barColor;
         data.label = obj.label;
         [array addObject:data];
     }];

    self.legendView.data = array;
    if (CGPointEqualToPoint(_legendView.center, CGPointZero)) {
        _legendView.center = CGPointMake(self.bounds.size.width - _legendView.bounds.size.width / 2, _legendView.bounds.size.height / 2);
    }
}

- (ShiuLegendView *)legendView {
    if (!_legendView) {
        _legendView = [[ShiuLegendView alloc] init];
        [self addSubview:_legendView];
    }
    return _legendView;
}

#pragma mark - override

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();

    // 判斷 Ｘ 軸的 xLabels 是否有資料，有的話就將字串畫出來
    if (self.data.xLabels) {
        CGFloat xLabelHeight = _chartMargin.bottom - XLabelMarginTop;
        // 設定顯示文字大小與相關參數設定
        UIFont *font = [UIFont systemFontOfSize:self.data.xLabelFontSize];
        UIColor *stringColor = [UIColor blackColor];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentCenter;
        NSDictionary *textStyleDictionary = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName:stringColor, NSStrokeColorAttributeName:stringColor };

        [self.data.xLabels enumerateObjectsUsingBlock: ^(NSString *_Nonnull obj, NSUInteger index, BOOL *_Nonnull stop) {
             CGSize size = [obj boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:textStyleDictionary context:nil].size;
             ShiuBar *bar = self.stringPointX[index];
             CGRect stringFrame = CGRectMake(0, self.bounds.size.height - _chartMargin.bottom + XLabelMarginTop, size.width, xLabelHeight);
             UILabel *valueLabel = [[UILabel alloc] initWithFrame:stringFrame];
             CGPoint newPoint = valueLabel.center;
             newPoint.x = CGRectGetMaxX(bar.frame);
             valueLabel.center = newPoint;
             valueLabel.font = [UIFont systemFontOfSize:14];
             valueLabel.textAlignment = NSTextAlignmentCenter;
             valueLabel.text = obj;
             [self addSubview:valueLabel];

         }];
    }

    // 設定線寬度與預設是灰色顏色
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);

    // 開始畫 x 軸嚕
    if (self.isShowX) {
        CGContextMoveToPoint(context, _chartMargin.left - XAxisMarginLeft, self.bounds.size.height - _chartMargin.bottom + 0.5);
        CGContextAddLineToPoint(context, self.bounds.size.width - _chartMargin.right + XAxisMarginRight, self.bounds.size.height - _chartMargin.bottom + 0.5);
        CGContextStrokePath(context);
    }

}


@end
