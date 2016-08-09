//
//  ShiuBarChartScrollView.h
//  ShiuTest
//
//  Created by AllenShiu on 2016/8/8.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShiuBarChartScrollViewDelegate;

@interface ShiuBarChartScrollView : UIView

@property (nonatomic, weak) id <ShiuBarChartScrollViewDelegate> delegate;

@end

@protocol ShiuBarChartScrollViewDelegate <NSObject>
- (void)scrollViewDidScroll:(NSInteger)pageIndex;

@end

