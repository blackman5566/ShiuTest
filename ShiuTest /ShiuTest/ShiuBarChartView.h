//
//  ShiuBarChartView.h
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/19.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShiuBarChartView : UIView

@property (weak, nonatomic) IBOutlet UIView *squareView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (assign, nonatomic) CGFloat maxValue;
@property (assign, nonatomic) CGFloat squareValue;

- (void)updateUI;

@end
