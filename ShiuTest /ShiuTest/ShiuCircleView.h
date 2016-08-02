//
//  CircleView.h
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/28.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CircleClickBlock)(id);

@interface ShiuCircleView : UIButton
/**
   @abstract 設定 外圍線條 的顏色。
 */
@property (nonatomic, strong) UIColor *borderColor;

/**
   @abstract 點擊外圍線條寬度。
 */
@property (nonatomic, assign) CGFloat borderWidth;

/**
   @abstract 設定 按鈕 的顏色。
 */
@property (nonatomic, strong) UIColor *holeColor;

/**
   @abstract 點擊按鈕的事件 Block。
 */
@property (nonatomic, copy) CircleClickBlock circleClickBlock;

/**
   @abstract 用來記錄是否已點擊。
 */
@property (nonatomic, assign) BOOL isSelected;

/**
   @abstract 是否要顯示由內向外的動畫效果。
 */
@property (nonatomic, assign) BOOL isAnimationEnabled;

/**
   @abstract 記錄 value 。
 */
@property (nonatomic, assign) CGFloat value;

@end

