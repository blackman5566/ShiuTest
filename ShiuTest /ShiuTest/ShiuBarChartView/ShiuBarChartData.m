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

#pragma mark - private instance method

#pragma mark * init

- (void)setupInitValue:(NSArray <ShiuBarChartDataSet *> *)dataSets {
    self.dataSets = dataSets;
    self.xLabelFontSize = 16;
    self.xLabelTextColor = [UIColor grayColor];
    self.barGap = 0;
    self.yMaxValue = 0;
}

- (void)setupMaxNumber:(NSArray <ShiuBarChartDataSet *> *)dataSets {
    for (ShiuBarChartDataSet *dataset in dataSets) {
        for (NSNumber *yValue in dataset.yValues) {
            if (yValue.floatValue > self.yMaxValue) {
                self.yMaxValue = yValue.floatValue;
            }
        }
    }
}

#pragma mark - life cycle

- (instancetype)initWithDataSets:(NSArray <ShiuBarChartDataSet *> *)dataSets {
    self = [super init];
    if (self) {
        [self setupInitValue:dataSets];
        [self setupMaxNumber:dataSets];
    }
    return self;
}

@end

