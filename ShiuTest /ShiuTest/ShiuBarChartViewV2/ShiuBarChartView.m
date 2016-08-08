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
#define XAxisMarginLeft 10
#define XAxisMarginRight 10
#define YAxisMarginTop 10
#define LegendTextSize 10

@interface ShiuBarChartView ()

@property (nonatomic, strong) NSMutableArray <ShiuBar *> *bars;
@property (nonatomic, strong) ShiuLegendView *legendView;

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
    CGFloat groupWidth = 60;

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
    if (_data.xLabels) {
        NSUInteger xLabelCount = _data.xLabels.count;
        CGFloat xLabelWidth = (self.bounds.size.width - _chartMargin.left - _chartMargin.right) / xLabelCount;
        CGFloat xLabelHeight = _chartMargin.bottom - XLabelMarginTop;
        UIFont *font = [UIFont systemFontOfSize:_data.xLabelFontSize]; //设置
        [_data.xLabels enumerateObjectsUsingBlock: ^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
             CGRect rect = CGRectMake(_chartMargin.left + idx * (xLabelWidth), self.bounds.size.height - _chartMargin.bottom + XLabelMarginTop, xLabelWidth, xLabelHeight);
             NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
             style.lineBreakMode = NSLineBreakByWordWrapping;
             style.alignment = NSTextAlignmentCenter;
             [obj drawWithRect:rect options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:font, NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName:_data.xLabelTextColor } context:nil];

         }];
    }

    // 判斷 y 軸的 xLabels 是否有資料，有的話就將字串畫出來
    if (_data.yLabels) {
        NSUInteger yLabelCount = _data.yLabels.count;
        CGFloat yLabelWidth = _chartMargin.left - XAxisMarginLeft;
        CGFloat yLabelHeight = _data.yLabelFontSize;

        CGFloat yLabelSpace = (self.bounds.size.height - _chartMargin.top - _chartMargin.bottom + YAxisMarginTop - (yLabelCount * yLabelHeight)) / (yLabelCount - 1);

        UIFont *font = [UIFont systemFontOfSize:_data.yLabelFontSize]; //设置
        [_data.yLabels enumerateObjectsUsingBlock: ^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
             CGRect rect = CGRectMake(0, _chartMargin.top - YAxisMarginTop + idx * (yLabelHeight + yLabelSpace), yLabelWidth - YLabelMarginRight, yLabelHeight);

             NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
             style.alignment = NSTextAlignmentRight;
             [obj drawWithRect:rect options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:font, NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName: _data.yLabelTextColor } context:nil];
         }];
    }

    // 設定線寬度與預設是灰色顏色
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);

    // 開始畫 y 軸嚕
    if (self.isShowY) {
        // 設定線的起始點
        CGContextMoveToPoint(context, _chartMargin.left - XAxisMarginLeft - 0.5, _chartMargin.top - YAxisMarginTop);
        // 設定線的中間點
        CGContextAddLineToPoint(context, _chartMargin.left - XAxisMarginLeft, self.bounds.size.height - _chartMargin.bottom + 0.5);
        //直接把所有的點連起来
        CGContextStrokePath(context);
    }

    // 開始畫 x 軸嚕
    if (self.isShowX) {
        CGContextMoveToPoint(context, _chartMargin.left - XAxisMarginLeft, self.bounds.size.height - _chartMargin.bottom + 0.5);
        CGContextAddLineToPoint(context, self.bounds.size.width - _chartMargin.right + XAxisMarginRight, self.bounds.size.height - _chartMargin.bottom + 0.5);
        CGContextStrokePath(context);
    }

}


@end
