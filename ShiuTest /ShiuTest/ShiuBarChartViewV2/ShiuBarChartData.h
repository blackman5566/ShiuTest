//
//  ShiuBarChartData.h
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/25.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShiuBarChartDataSet.h"

@interface ShiuBarChartData : UIView

@property (nonatomic, strong) NSArray <NSString *> *xLabels;

/**
 @abstract  xLabelTextColor
 @discussion 負責儲存每種 Bar 顏色與意義。
 */
@property (nonatomic, strong) NSArray <ShiuBarChartDataSet *> *dataSets;

/**
 @abstract  xLabelTextColor
 @discussion x 軸參數字的顏色。
 */
@property (nonatomic, strong) UIColor *xLabelTextColor;

/**
 @abstract  xLabelFontSize
 @discussion x軸參數字的大小。
 */
@property (nonatomic, assign) CGFloat xLabelFontSize;

/**
 @abstract  barGap
 @discussion 每一個 bar 之間的距離。
 */
@property (nonatomic, assign) CGFloat barGap;

/**
 @abstract  yMaxValue
 @discussion y 軸上最大的值，正規劃每一個 bar 的值。
 */
@property (nonatomic, assign) CGFloat yMaxValue;

/**
 @abstract  initWithDataSets
 @discussion 初始化方法。
 */
- (instancetype)initWithDataSets:(NSArray <ShiuBarChartDataSet *> *)dataSets;

@end

