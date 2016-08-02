//
//  ShiuBarChartViewV2.h
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/25.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShiuLegendView.h"
#import "ShiuBarChartData.h"

@interface ShiuBarChartViewV2 : UIView

/**
   @abstract  legendView
   @discussion 實際上也就是這個 app 中負責顯示長出柱狀圖各個顏色代表的 View。
 */

@property (nonatomic, strong, readonly) ShiuLegendView *legendView;


/**
   @abstract  chartMargin
   @discussion 設定 Bar View 與四個邊界的距離。
 */

@property (nonatomic, assign) UIEdgeInsets chartMargin;

/**
   @abstract  ShiuBarChartData
   @discussion 負責儲存每個 Bar 的所有資訊。
 */

@property (nonatomic, strong) ShiuBarChartData *data;

/**
   @abstract  isShowNumber
   @discussion 控制是否顯示 Bar 上面的數字顯示。
 */

@property (nonatomic, assign) BOOL isShowNumber;

/**
   @abstract  isShowY
   @discussion 控制是否顯示 Y 軸。
 */

@property (nonatomic, assign) BOOL isShowY;

/**
   @abstract  isShowX
   @discussion 控制是否顯示 Ｘ 軸。
 */

@property (nonatomic, assign) BOOL isShowX;

/**
   @abstract  isAnimated
   @discussion 控制是否顯示動畫效果。
 */

@property (nonatomic, assign) BOOL isAnimated;

/**
   @abstract  show
   @discussion 開始顯示柱狀圖。
 */

- (void)show;

@end
