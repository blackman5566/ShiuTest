//
//  ShiuBarChartDataSet.h
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/25.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShiuBarChartDataSet : NSObject

@property (nonatomic, strong) NSArray <NSNumber *> *yValues;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) UIColor *barColor;
@property (nonatomic, strong) UIColor *barbackGroudColor;

- (instancetype)initWithYValues:(NSArray <NSNumber *> *)yValues label:(NSString *)label;

@end
