//
//  ViewController.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/18.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ViewController.h"
#import "ShiuBarChartView.h"
#import "ShiuBarChartViewV2.h"
#import "ShiuChartScrollView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *barView;

@property (nonatomic, strong) ShiuBarChartViewV2 *shiuBarChartViewV2;

@end

@implementation ViewController

#pragma mark - init

- (void)setupShiuBarChartView {
    // 第一版
    for (int i = 0; i < 2; i++) {
        ShiuBarChartView *barChartView = [ShiuBarChartView new];
        CGRect newFrame = self.barView.bounds;
        newFrame.size.width = CGRectGetWidth(self.barView.bounds) / 2;
        newFrame.origin.x = newFrame.size.width * i;
        barChartView.frame = newFrame;
        barChartView.squareView.backgroundColor = (i == 0) ? [UIColor redColor] : [UIColor blueColor];
        barChartView.maxValue = 22.0f;
        if (i == 0) {
            barChartView.squareValue = 22.0f;
        }
        else {
            barChartView.squareValue = 5.0f;
        }
        [self.barView addSubview:barChartView];
        [barChartView updateUI];
    }
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // 第一版
    //[self setupShiuBarChartView];
    // 第二版
    //[self setupShiuBarChartViewV2];
    
    // 折線圖
    [self setupShiuChartView];
}
-(void)setupShiuChartView{
    // 使用方法
    
    ShiuChartScrollView *shiuChartScrollView = [[ShiuChartScrollView alloc] initWithFrame:CGRectMake(0, 60, [UIScreen mainScreen].bounds.size.width, 250)];
    shiuChartScrollView.backgroundColor = [UIColor redColor];
    [self.view addSubview:shiuChartScrollView];

}

- (void)setupShiuBarChartViewV2 {
    // 產生參數 有多少數量就代表會產生幾筆資料
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals3 = [[NSMutableArray alloc] init];
    double mult = 5 * 1000.f;
    for (int i = 0; i < 2; i++) {
        double val = (double)(arc4random_uniform(mult) + 3.0);
        [yVals1 addObject:@(val)];
        val = (double)(arc4random_uniform(mult) + 3.0);
        [yVals2 addObject:@(val)];
        val = (double)(arc4random_uniform(mult) + 3.0);
        [yVals3 addObject:@(val)];

    }

    // 設定 Bar 有幾種顏色與代表的意思，像以下就設定三種 “次數” “喝水” “吃藥”
    ShiuBarChartDataSet *barType1 = [[ShiuBarChartDataSet alloc] initWithYValues:yVals1 label:@"次數"];
    [barType1 setBarColor:[UIColor colorWithRed:77.0 / 255.0 green:186.0 / 255.0 blue:122.0 / 255.0 alpha:1.0f]];
    ShiuBarChartDataSet *barType2 = [[ShiuBarChartDataSet alloc] initWithYValues:yVals2 label:@"喝水量"];
    [barType2 setBarColor:[UIColor colorWithRed:245.0 / 255.0 green:94.0 / 255.0 blue:78.0 / 255.0 alpha:1.0f]];
    ShiuBarChartDataSet *barType3 = [[ShiuBarChartDataSet alloc] initWithYValues:yVals2 label:@"吃藥"];
    [barType3 setBarColor:[UIColor colorWithRed:100.0 / 255.0 green:94.0 / 255.0 blue:78.0 / 255.0 alpha:1.0f]];
    NSArray *dataSets = @[barType1, barType2];

    // 設定每一個 Bar 的資料
    ShiuBarChartData *data = [[ShiuBarChartData alloc] initWithDataSets:dataSets];
    // 設定 x 軸要顯示的文字
    data.xLabels = @[@"貓貓一號", @"貓貓二號"];
    // 設定群組內每一個bar之間的 Gap
    data.itemGap = 0;
    data.groupSpace = 40;

    // 初始化 shiuBarChartViewV2
    self.shiuBarChartViewV2 = [[ShiuBarChartViewV2 alloc] initWithFrame:CGRectMake(0, 10, [UIScreen mainScreen].bounds.size.width, 200)];
    // 設定 Bar View 與四個邊界的距離
    self.shiuBarChartViewV2.chartMargin = UIEdgeInsetsMake(45, 15, 40, 15);
    // 設定 資料
    self.shiuBarChartViewV2.data = data;
    // 設定是否要動畫效果
    self.shiuBarChartViewV2.isAnimated = YES;
    // 設定是否要顯示x軸資訊
    self.shiuBarChartViewV2.isShowX = YES;
    //設定是否要顯示y軸資訊
    self.shiuBarChartViewV2.isShowY = NO;
    // 設定是否要顯示每個bar 上的數字
    self.shiuBarChartViewV2.isShowNumber = YES;
    // 設定 種類的右上角view的顯示方式，直式的或是橫式的。
    self.shiuBarChartViewV2.legendView.alignment = LegendAlignmentHorizontal;
    [self.view addSubview:self.shiuBarChartViewV2];
    // 顯示 view
    [self.shiuBarChartViewV2 show];

    // 根據計算取得 legendCenter 讓顯示在右上角
    CGPoint legendCenter = CGPointMake([UIScreen mainScreen].bounds.size.width - self.shiuBarChartViewV2.legendView.bounds.size.width / 2, self.shiuBarChartViewV2.legendView.bounds.size.height / 2);
    self.shiuBarChartViewV2.legendView.center = legendCenter;
}

@end
