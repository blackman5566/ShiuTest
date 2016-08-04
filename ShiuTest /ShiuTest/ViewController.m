//
//  ViewController.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/18.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ViewController.h"
#import "ShiuBarChartView.h"
#import "ShiuBarChartView.h"
#import "ShiuChartScrollView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *barView;

@property (nonatomic, strong) ShiuBarChartView *shiuBarChartView;

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

-(void)setupShiuChartView{
    // 使用方法
    
    ShiuChartScrollView *shiuChartScrollView = [[ShiuChartScrollView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(self.shiuBarChartView.frame) , [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-CGRectGetHeight(self.shiuBarChartView.frame))];
    shiuChartScrollView.backgroundColor = [UIColor redColor];
    [self.view addSubview:shiuChartScrollView];

}

- (void)setupShiuBarChartView {
    // 產生參數 有多少數量就代表會產生幾筆資料
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals3 = [[NSMutableArray alloc] init];
    double mult = 5 * 1000.f;
    for (int i = 0; i < 1; i++) {
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
    data.xLabels = @[@"貓貓一號", @"貓貓二號",@"貓貓三號"];
    // 設定群組內每一個bar之間的 Gap
    data.itemGap = 0;
    data.groupSpace = 40;

    // 初始化 shiuBarChartViewV2
    self.shiuBarChartView = [[ShiuBarChartView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 200)];
    // 設定 Bar View 與四個邊界的距離
    self.shiuBarChartView.chartMargin = UIEdgeInsetsMake(45, 15, 40, 15);
    // 設定 資料
    self.shiuBarChartView.data = data;
    // 設定是否要動畫效果
    self.shiuBarChartView.isAnimated = YES;
    // 設定是否要顯示x軸資訊
    self.shiuBarChartView.isShowX = YES;
    //設定是否要顯示y軸資訊
    self.shiuBarChartView.isShowY = NO;
    // 設定是否要顯示每個bar 上的數字
    self.shiuBarChartView.isShowNumber = YES;
    // 設定 種類的右上角view的顯示方式，直式的或是橫式的。
    self.shiuBarChartView.legendView.alignment = LegendAlignmentHorizontal;
    [self.view addSubview:self.shiuBarChartView];
    // 顯示 view
    [self.shiuBarChartView show];

    // 根據計算取得 legendCenter 讓顯示在右上角
    CGPoint legendCenter = CGPointMake([UIScreen mainScreen].bounds.size.width - self.shiuBarChartView.legendView.bounds.size.width / 2, self.shiuBarChartView.legendView.bounds.size.height / 2);
    self.shiuBarChartView.legendView.center = legendCenter;
}

@end
