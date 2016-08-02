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
 */

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *barColor;
@property (nonatomic, strong) UIColor *labelTextColor;
@property (nonatomic, strong) UIFont *labelFont;
@property (nonatomic, strong) NSString *barText;
@property (nonatomic, strong) NSString *barTitle;
@property (nonatomic, assign) BOOL isAnimated;
@property (nonatomic, assign) float barProgress;
@property (nonatomic, assign) CGFloat barRadius;

@end
