//
//  ShiuChartView.h
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/26.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DashLineWidth ([UIScreen mainScreen].bounds.size.width / 20)

@interface ShiuChartView : UIView

+ (instancetype)initCharView:(CGRect)frame;

/**
 @abstract 設定 xValues 的資料。
 */
@property (strong, nonatomic) NSArray *xValues;

/**
 @abstract 設定 yValues 的資料。
 */
@property (strong, nonatomic) NSArray *yValues;

/**
 @abstract 設定 折線圖的線寬 的資料。
 */
@property (assign, nonatomic) CGFloat chartWidth;

/**
 @abstract 設定 折線圖的顏色
 */
@property (strong, nonatomic) UIColor *chartColor;

@end
