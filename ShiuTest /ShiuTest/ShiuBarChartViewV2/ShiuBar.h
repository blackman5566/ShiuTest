//
//  ShiuBar.h
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/25.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShiuBar : UIView

/**
 @abstract  backgroundColor
 @discussion 設定背景顏色
 */

@property (nonatomic, strong) UIColor *backgroundColor;

/**
 @abstract  barColor
 @discussion 設定 bar 的顏色
 */

@property (nonatomic, strong) UIColor *barColor;

/**
 @abstract  labelTextColor
 @discussion 設定 labelText 的顏色
 */

@property (nonatomic, strong) UIColor *labelTextColor;

/**
 @abstract  labelFont
 @discussion 設定 labelText 的字的大小
 */

@property (nonatomic, strong) UIFont *labelFont;

/**
 @abstract  barText
 @discussion 設定要顯示的字
 */

@property (nonatomic, strong) NSString *barText;

/**
 @abstract  barTitle
 @discussion 設定要顯示的字，一開始就直接顯示在bar的頂端
 */

@property (nonatomic, strong) NSString *barTitle;

/**
 @abstract  barTitle
 @discussion 設定要顯示的字，一開始就直接顯示在bar的頂端
 */

@property (nonatomic, assign) BOOL isAnimated;

/**
 @abstract  barTitle
 @discussion 設定要顯示的字，一開始就直接顯示在bar的頂端
 */
@property (nonatomic, assign) float barProgress;

/**
 @abstract  barTitle
 @discussion 設定要顯示的字，一開始就直接顯示在bar的頂端
 */
@property (nonatomic, assign) CGFloat barRadius;

@end
