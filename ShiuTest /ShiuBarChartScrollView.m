//
//  ShiuBarChartScrollView.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/8/8.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ShiuBarChartScrollView.h"
#import "ShiuBarChartDataSet.h"
#import "ShiuBarChartData.h"
#import "ShiuBarChartView.h"

@interface ShiuBarChartScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) ShiuBarChartView *shiuBarChartView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation ShiuBarChartScrollView

- (void)setupInitValue:(CGRect)frame {
    // 產生假資料 有多少數量就代表會產生幾筆資料
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
    double mult = 5 * 1000.f;
    for (int i = 0; i < 3; i++) {
        double val = (double)(arc4random_uniform(mult) + 3.0);
        [yVals1 addObject:@(val)];
        val = (double)(arc4random_uniform(mult) + 3.0);
        [yVals2 addObject:@(val)];
        val = (double)(arc4random_uniform(mult) + 3.0);
    }

    // ShiuBarChartDataSet 設定 Bar 有幾種顏色與代表的意思，像以下就設定三種 “次數” “喝水”
    // itemGap 設定每一個 bar 之間的距離，面前設為 0
    ShiuBarChartDataSet *barType1 = [[ShiuBarChartDataSet alloc] initWithYValues:yVals1 label:@"次數"];
    [barType1 setBarColor:[UIColor colorWithRed:77.0 / 255.0 green:186.0 / 255.0 blue:122.0 / 255.0 alpha:1.0f]];
    ShiuBarChartDataSet *barType2 = [[ShiuBarChartDataSet alloc] initWithYValues:yVals2 label:@"喝水量"];
    [barType2 setBarColor:[UIColor colorWithRed:245.0 / 255.0 green:94.0 / 255.0 blue:78.0 / 255.0 alpha:1.0f]];
    ShiuBarChartData *data = [[ShiuBarChartData alloc] initWithDataSets:@[barType1, barType2]];
    data.xLabels = @[@"貓貓一號", @"貓貓二號", @"貓貓三號"];
    data.barGap = 0;

    // 初始化 shiuBarChartView
    // chartMargin 設定四個邊界的距離
    // isAnimated 設定是否要動畫效果
    // isShowX 設定是否要顯示 X 軸資訊
    // isShowNumber 設定是否要顯示 bar 上的數字

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(frame), CGRectGetHeight(frame) - 10)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(frame.size.width * 2, CGRectGetHeight(frame) - 10);

    self.shiuBarChartView = [[ShiuBarChartView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, CGRectGetHeight(self.scrollView.frame))];
    self.shiuBarChartView.chartMargin = UIEdgeInsetsMake(30, 15, 30, 15);
    self.shiuBarChartView.data = data;
    self.shiuBarChartView.isAnimated = YES;
    self.shiuBarChartView.isShowX = YES;
    self.shiuBarChartView.isShowNumber = YES;
    [self.scrollView addSubview:self.shiuBarChartView];
    [self addSubview:self.scrollView];

    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 10)];
    self.pageControl.numberOfPages = 2;
    self.pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    [self addSubview:self.pageControl];
    [self.shiuBarChartView show];
}

#pragma mark - life cycle

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupInitValue:frame];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark * override

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //scrollView 轉換 page
    NSInteger currentPage = ((scrollView.contentOffset.x - CGRectGetWidth(self.frame) / 2) / CGRectGetWidth(self.frame)) + 1;
    self.pageControl.currentPage = currentPage;
    [self.delegate scrollViewDidScroll:currentPage];
}

@end
