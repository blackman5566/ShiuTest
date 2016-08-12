//
//  ShiuBarChartDataSet.h
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/25.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShiuBarChartDataSet : NSObject

/**
   @abstract  yValues
   @discussion 負責存放 y 軸所有值。
 */
@property (nonatomic, strong) NSArray <NSNumber *> *yValues;

/**
   @abstract  typeLabel
   @discussion 負責存放每個 bar 的 type。
 */
@property (nonatomic, strong) NSString *typeString;

/**
   @abstract  barColor
   @discussion 設定 barColor 顏色。
 */
@property (nonatomic, strong) UIColor *barColor;

/**
   @abstract  barbackGroudColor
   @discussion 設定 barbackGroudColor 顏色。
 */
@property (nonatomic, strong) UIColor *barbackGroudColor;

/**
   @abstract  initWithYValues
   @discussion 初始化方法。
 */
- (instancetype)initWithYValues:(NSArray <NSNumber *> *)yValues label:(NSString *)typeString;

@end
