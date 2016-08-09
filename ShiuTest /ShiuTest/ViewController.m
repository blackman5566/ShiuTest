//
//  ViewController.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/18.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ViewController.h"
#import "ShiuChartScrollView.h"
#import "ShiuBarChartScrollView.h"

@interface ViewController () <ShiuBarChartScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *barView;

@property (nonatomic, strong) ShiuBarChartScrollView *shiuBarChartScrollView;
@property (nonatomic, strong) ShiuChartScrollView *shiuChartScrollView;

@end

@implementation ViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // 第一版
    //[self setupShiuBarChartView];
    // 第二版
    [self setupShiuBarChartView];
    // 折線圖
    [self setupShiuChartView];
}

- (void)setupShiuChartView {
    // 使用方法

    self.shiuChartScrollView = [[ShiuChartScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.shiuBarChartScrollView.frame), [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - CGRectGetHeight(self.shiuBarChartScrollView.frame) - 64)];
    self.shiuChartScrollView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.shiuChartScrollView];

}

- (void)setupShiuBarChartView {
    self.shiuBarChartScrollView = [[ShiuBarChartScrollView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 200)];
    self.shiuBarChartScrollView.delegate = self;
    [self.view addSubview:self.shiuBarChartScrollView];
}

- (void)scrollViewDidScroll:(NSInteger)pageIndex {

}

@end
