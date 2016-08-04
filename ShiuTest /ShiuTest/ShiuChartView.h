//
//  ShiuChartView.h
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/26.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DashLineWidth ([UIScreen mainScreen].bounds.size.width / 20)

typedef void (^DrawAtPointBlock)(CGFloat cX, CGFloat cY, CGSize size, NSString *yValue);

@interface ShiuChartView : UIView

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

/**
   @abstract 設定 折線圖的顏色
 */
@property (strong, nonatomic) NSMutableArray *circleViewArray;

/**
   @abstract 畫出 Y 軸上每一個間距的點
 */
@property(copy, nonatomic) DrawAtPointBlock drawAtPointBlock;

@end
