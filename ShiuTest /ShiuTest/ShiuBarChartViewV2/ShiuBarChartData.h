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
@property (nonatomic, strong) NSArray <NSString *> *yLabels;
@property (nonatomic, strong) NSArray <ShiuBarChartDataSet *> *dataSets;
@property (nonatomic, assign) CGFloat yMaxNum;

@property (nonatomic, assign) CGFloat barGap;
@property (nonatomic, assign, readonly) BOOL isGrouped;

@property (nonatomic, strong) UIColor *xLabelTextColor;
@property (nonatomic, strong) UIColor *yLabelTextColor;
@property (nonatomic, assign) CGFloat xLabelFontSize;
@property (nonatomic, assign) CGFloat yLabelFontSize;

- (instancetype)initWithDataSets:(NSArray <ShiuBarChartDataSet *> *)dataSets;

@end

