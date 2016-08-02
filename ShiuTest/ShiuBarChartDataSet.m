//
//  ShiuBarChartDataSet.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/25.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ShiuBarChartDataSet.h"

@implementation ShiuBarChartDataSet

- (instancetype)initWithYValues:(NSArray <NSNumber *> *)yValues label:(NSString *)label {
    self = [super init];
    if (self) {
        self.yValues = yValues;
        self.label = label;
        self.barColor = [UIColor blueColor];
        self.barbackGroudColor = nil;
    }
    return self;
}

@end
