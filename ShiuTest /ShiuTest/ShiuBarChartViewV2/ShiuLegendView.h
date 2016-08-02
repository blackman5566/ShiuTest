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
@property (nonatomic, strong) NSArray <ShiuLegendViewData *> *data;

- (instancetype)initWithData:(NSArray <ShiuLegendViewData *> *)data;

@end


/**
 @abstract  legendView
 @discussion 實際上也就是這個 app 中負責動態長出柱狀圖的 View。
 */

@interface ShiuLegendViewData : NSObject

@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) UIColor *color;

@end