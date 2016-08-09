//
//  ShiuLegendView.h
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/25.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, LegendAlignment) {
    LegendAlignmentVertical = 0,
    LegendAlignmentHorizontal,
};

@class ShiuLegendViewData;

@interface ShiuLegendView : UIView

@property (nonatomic, assign) LegendAlignment alignment;
@property (nonatomic, strong) NSArray <ShiuLegendViewData *> *datas;

@end

@interface ShiuLegendViewData : NSObject

@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) UIColor *color;

@end