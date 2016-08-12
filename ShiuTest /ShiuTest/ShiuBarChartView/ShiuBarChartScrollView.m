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

@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign, readonly) NSInteger totalPage;
@property (nonatomic, assign) NSInteger originalIndex;

@end

@implementation ShiuBarChartScrollView

#pragma mark - private instance method

#pragma mark * init

- (void)setupInitValue {
    self.backgroundColor = [UIColor whiteColor];
    self.originalIndex = 0;
}

- (void)setupPageControl:(CGRect)frame {
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 10)];
    self.pageControl.numberOfPages = self.totalPage;
    self.pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.hidden = (self.totalPage <= 1);
    [self addSubview:self.pageControl];
}

- (void)setupScrollView:(CGRect)frame {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(frame), CGRectGetHeight(frame) - 10)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(frame.size.width * 2, CGRectGetHeight(frame) - 10);
    [self addSubview:self.scrollView];
}

- (void)setupShiuBarChartView:(CGRect)frame {
    // 產生假資料 有多少數量就代表會產生幾筆資料
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
    double mult = 5 * 500.f;
    for (int i = 0; i < 3; i++) {
        double val = (double)(arc4random_uniform(mult) + 3.0);
        [yVals1 addObject:@(val)];
        val = (double)(arc4random_uniform(mult) + 3.0);
        [yVals2 addObject:@(val)];
        val = (double)(arc4random_uniform(mult) + 3.0);
    }


    // 負責儲存每種 Bar 顏色與意義
    // barGap 設定每一個 bar 之間的距離，面前設為 0
    ShiuBarChartDataSet *barType1 = [[ShiuBarChartDataSet alloc] initWithYValues:yVals1 label:@"次數"];
    [barType1 setBarColor:[UIColor colorWithRed:77.0 / 255.0 green:186.0 / 255.0 blue:122.0 / 255.0 alpha:1.0f]];
    ShiuBarChartDataSet *barType2 = [[ShiuBarChartDataSet alloc] initWithYValues:yVals2 label:@"喝水量"];
    [barType2 setBarColor:[UIColor colorWithRed:245.0 / 255.0 green:94.0 / 255.0 blue:78.0 / 255.0 alpha:1.0f]];
    ShiuBarChartData *data = [[ShiuBarChartData alloc] initWithDataSets:@[barType1, barType2]];
    data.xLabels = @[@"貓貓一號", @"貓貓二號", @"貓貓三號"];
    data.barGap = 0;

    // 初始化 shiuBarChartView
    for (NSInteger indexPage = 0; indexPage < 2; indexPage++) {
        ShiuBarChartView *shiuBarChartView = [[ShiuBarChartView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) * indexPage, 0, CGRectGetWidth(frame), CGRectGetHeight(self.scrollView.frame))];
        shiuBarChartView.data = data;
        [self.scrollView addSubview:shiuBarChartView];
    }
    [self showBarWithPageIndex:0];
}

- (void)showBarWithPageIndex:(NSInteger)pageIndex {
    ShiuBarChartView *shiuBarChartView = self.scrollView.subviews[pageIndex];
    [shiuBarChartView showBar];
}

- (void)removePreviousView:(NSInteger)pageIndex {
    ShiuBarChartView *shiuBarChartView = self.scrollView.subviews[pageIndex];
    [shiuBarChartView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark - setter / getter

- (NSInteger)totalPage {
    return ceil(2);
}

#pragma mark * override

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentIndex = ((scrollView.contentOffset.x - CGRectGetWidth(self.frame) / 2) / CGRectGetWidth(self.frame)) + 1;
    if (currentIndex != self.originalIndex) {
        [self removePreviousView:self.originalIndex];
        [self showBarWithPageIndex:currentIndex];
        [self.delegate scrollViewDidScroll:currentIndex];
        self.pageControl.currentPage = currentIndex;
        self.originalIndex = currentIndex;
    }
}

#pragma mark - life cycle

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupInitValue];
        [self setupPageControl:frame];
        [self setupScrollView:frame];
        [self setupShiuBarChartView:frame];
    }
    return self;
}

@end
