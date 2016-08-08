//
//  ShiuBarChartData.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/25.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ShiuBarChartData.h"
#import "ShiuBarChartDataSet.h"

@implementation ShiuBarChartData

- (instancetype)initWithDataSets:(NSArray <ShiuBarChartDataSet *> *)dataSets {
    self = [super init];
    if (self) {
        self.dataSets = dataSets;
        self.groupSpace = 20;
        self.xLabelFontSize = 16;
        self.yLabelFontSize = 16;
        self.xLabelTextColor = [UIColor grayColor];
        self.yLabelTextColor = [UIColor grayColor];
        self.itemGap = 20;
        self.yMaxNum = 0;
        [self findMaxNumber:dataSets];
    }
    return self;
}

- (BOOL)isGrouped {
    return _dataSets.count > 1;
}

- (void)findMaxNumber:(NSArray <ShiuBarChartDataSet *> *)dataSets {
    for (ShiuBarChartDataSet *dataset in dataSets) {
        for (NSNumber *yValue in dataset.yValues) {
            if (yValue.floatValue > self.yMaxNum) {
                self.yMaxNum = yValue.floatValue;
            }
        }
    }
}

@end

