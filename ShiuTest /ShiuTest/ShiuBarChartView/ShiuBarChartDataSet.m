//
//  ShiuBarChartDataSet.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/25.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ShiuBarChartDataSet.h"

@implementation ShiuBarChartDataSet

#pragma mark - private instance method

#pragma mark * init

- (void)setupInitValue:(NSArray <NSNumber *> *)yValues label:(NSString *)typeString {
    self.yValues = yValues;
    self.typeString = typeString;
    self.barColor = [UIColor blueColor];
    self.barbackGroudColor = nil;
}

#pragma mark - life cycle

- (instancetype)initWithYValues:(NSArray <NSNumber *> *)yValues label:(NSString *)typeString {
    self = [super init];
    if (self) {
        [self setupInitValue:yValues label:typeString];
    }
    return self;
}

@end
