//
//  ShiuBarChartViewV2.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/25.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ShiuBarChartViewV2.h"
#import "ShiuBar.h"

#define XLabelMarginTop 5
#define YLabelMarginRight 5
#define XAxisMarginLeft 10
#define XAxisMarginRight 10
#define YAxisMarginTop 10
#define LegendTextSize 10

@interface ShiuBarChartViewV2 ()

@property (nonatomic, strong) NSMutableArray <ShiuBar *> *bars;
@property (nonatomic, strong) ShiuLegendView *legendView;

@end

@implementation ShiuBarChartViewV2

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
    // 總共有幾組資料
    CGFloat groupCount = [_data.dataSets[0].yValues count];
    // 一組有幾個 bar
    CGFloat itemCount = [_data.dataSets count];

    // 開始計算每組bar之間的間隔距離
    CGFloat groupWidth = (self.bounds.size.width - self.chartMargin.left - self.chartMargin.right + self.data.groupSpace) / groupCount - self.data.groupSpace;

    // 設定每個 bar 的高與寬
    CGFloat barHeight = self.bounds.size.height - _chartMargin.top - _chartMargin.bottom;
    CGFloat barWidth = (groupWidth + _data.itemGap) / itemCount - _data.itemGap;

    // 說明
    // 喵喵一號與喵喵二號兩隻貓的資料，每隻喵有三種資訊可以知道，喝水次數，喝水量，吃藥
    // _data.dataSets.count 會等於 3（三種資訊）
    // dataset.yValues.count 會等於 2 （兩隻貓）
    // 先將一種顏色畫完，再畫下一種顏色

    // 開始長出來嚕
    for (NSInteger barTypeIndex = 0; barTypeIndex < _data.dataSets.count; barTypeIndex++) {
        // 先取得第一種的 bar
        ShiuBarChartDataSet *dataset = _data.dataSets[barTypeIndex];
        // 將第一種類型的 bar 開始畫出來
        for (NSInteger barIndex = 0; barIndex < dataset.yValues.count; barIndex++) {
            CGFloat barX = _chartMargin.left + (barIndex * (groupWidth + _data.groupSpace)) + (barTypeIndex * (barWidth + _data.itemGap));
            ShiuBar *bar = [[ShiuBar alloc] initWithFrame:CGRectMake(barX, _chartMargin.top, barWidth, barHeight)];
            
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
                  bar.barText = [NSString stringWithFormat:@"%@ml",yValue.stringValue];
                }
            }
            
            // 根據使用者設定，判斷是否要顯示動畫效果
            bar.isAnimated = self.isAnimated;
            
            [self.bars addObject:bar];
            [self addSubview:bar];
        }
    }
    // 設定每個bar 顏色所代表的意思
    if (self.data.isGrouped) {
        [self setupLegendView];
    }
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
        CGFloat xLabelWidth = (self.bounds.size.width - _chartMargin.left - _chartMargin.right + _data.groupSpace) / xLabelCount - _data.groupSpace;
        CGFloat xLabelHeight = _chartMargin.bottom - XLabelMarginTop;
        UIFont *font = [UIFont systemFontOfSize:_data.xLabelFontSize]; //设置
        [_data.xLabels enumerateObjectsUsingBlock: ^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
             CGRect rect = CGRectMake(_chartMargin.left + idx * (xLabelWidth + _data.groupSpace), self.bounds.size.height - _chartMargin.bottom + XLabelMarginTop, xLabelWidth, xLabelHeight);
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
