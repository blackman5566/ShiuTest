//
//  ShiuChartScrollView.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/8/1.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ShiuChartScrollView.h"
#import "ShiuChartTooltipView.h"
#import "ShiuVerticalSelectionView.h"

@interface ShiuChartScrollView ()

@property (strong, nonatomic) ShiuVerticalSelectionView *verticalSelectionView;
@property (nonatomic, assign) BOOL verticalSelectionViewVisible;
@property (nonatomic, strong) ShiuChartTooltipView *tooltipView;
@property (nonatomic, assign) BOOL tooltipVisible;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat displacementAmount;
@property (nonatomic, strong) ShiuChartView *chartView;

@property (nonatomic, strong) NSArray *xValue;
@property (nonatomic, strong) NSArray *yValue;

@end

@implementation ShiuChartScrollView

#pragma mark - life cycle

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.xValue = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26"];
        self.yValue = @[@"10", @"16", @"14", @"40", @"0", @"4", @"80", @"39", @"4",
                        @"6", @"7", @"25", @"40", @"0", @"4", @"80", @"39", @"4", @"6",
                        @"7", @"25", @"10", @"40", @"60", @"23", @"25"];
        [self setupInitValue:frame];
    }
    return self;
}

- (void)setupInitValue:(CGRect)frame {
    CGRect graphViewFrame = frame;
    graphViewFrame.origin.x = 0;
    graphViewFrame.origin.y = 0;
    graphViewFrame.size.height = frame.size.height - 20;

    //        NSArray *x = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"];
    //        NSArray *y = @[@"10", @"16", @"14", @"40", @"0", @"4", @"80", @"39", @"4", @"6"];

    self.scrollView = [[UIScrollView alloc] initWithFrame:graphViewFrame];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.scrollEnabled = NO;
    CGFloat width = MAX([UIScreen mainScreen].bounds.size.width, (self.xValue.count * DashLineWidth));
    graphViewFrame.size.width = width;

    self.chartView = [ShiuChartView initCharView:graphViewFrame];
    self.chartView.xValues = self.xValue;
    self.chartView.yValues = self.yValue;
    self.chartView.chartColor = [UIColor blueColor];
    self.scrollView.contentSize = CGSizeMake(self.chartView.frame.size.width, graphViewFrame.size.height);
    [self.scrollView addSubview:self.chartView];
    [self addSubview:self.scrollView];
    [self sendSubviewToBack:self.scrollView];
    self.displacementAmount = 0;
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self addVerticalSelectionView];
}

- (void)addVerticalSelectionView {
    self.verticalSelectionView = [[ShiuVerticalSelectionView alloc] initWithFrame:CGRectMake(30, 0, 1, self.frame.size.height)];
    self.verticalSelectionView.alpha = 0.0;
    self.verticalSelectionView.hidden = NO;
    [self addSubview:self.verticalSelectionView];

    self.tooltipView = [[ShiuChartTooltipView alloc] init];
    self.tooltipView.alpha = 0.0;
    [self addSubview:self.tooltipView];
}

#pragma mark - Responder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setVerticalSelectionViewVisible:NO animated:NO];
    [self touchesBeganOrMovedWithTouches:touches];
    [self changeScrollViewDisplacementAmount:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesBeganOrMovedWithTouches:touches];
    [self changeScrollViewDisplacementAmount:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEndedOrCancelledWithTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEndedOrCancelledWithTouches:touches];
}

- (void)changeScrollViewDisplacementAmount:(NSSet *)touches {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    // 判斷是否靠近螢幕的右邊邊緣
    if (touchPoint.x > ([UIScreen mainScreen].bounds.size.width - (DashLineWidth + 10))) {
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateRightDisplacementAmount) userInfo:nil repeats:YES];
        }
    }
    else if (touchPoint.x < (DashLineWidth + 10)) {
        // 計算是否為左邊 兩秒就跟後端要新資料
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateLeftDisplacementAmount) userInfo:nil repeats:YES];
        }
    }
    else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayRequest) object:nil];
    }
}

- (void)updateRightDisplacementAmount {
    // 開始向右滑動
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat contentYoffset = self.scrollView.contentOffset.x;
    CGFloat distanceFromRight = self.scrollView.contentSize.width - contentYoffset;
    if (roundf(distanceFromRight) == width) {
        [self.timer invalidate];
        self.timer = nil;
    }
    else {
        self.displacementAmount += DashLineWidth;
        CGPoint position = CGPointMake(self.displacementAmount, 0);
        [self.scrollView setContentOffset:position animated:NO];
    }
}

- (void)updateLeftDisplacementAmount {
    // 開始向左滑動
    CGFloat contentYoffset = self.scrollView.contentOffset.x;
    // 判斷為一輛是否為0 當為0時就代表已經到頂了，當不是為0時就繼續滑動
    if (contentYoffset) {
        self.displacementAmount -= DashLineWidth;
        CGPoint position = CGPointMake(self.displacementAmount, 0);
        [self.scrollView setContentOffset:position animated:NO];
    }
    else {
        [self.timer invalidate];
        self.timer = nil;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayRequest) object:nil];
        [self performSelector:@selector(delayRequest) withObject:nil afterDelay:2.0f];
    }
}

- (void)delayRequest {
    NSLog(@"delayRequest");
    self.xValue = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"];
    self.yValue = @[@"71", @"26", @"35", @"44", @"51", @"64", @"37", @"18", @"92", @"29"];
    [self.scrollView removeFromSuperview];
    [self setupInitValue:self.frame];
}

- (void)setVerticalSelectionViewVisible:(BOOL)verticalSelectionViewVisible animated:(BOOL)animated {
    _verticalSelectionViewVisible = verticalSelectionViewVisible;

    if (animated) {
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations: ^{
             self.verticalSelectionView.alpha = self.verticalSelectionViewVisible ? 1.0 : 0.0;
         } completion:nil];
    }
    else {
        self.verticalSelectionView.alpha = _verticalSelectionViewVisible ? 1.0 : 0.0;
    }
}

- (void)touchesBeganOrMovedWithTouches:(NSSet *)touches {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
    CGFloat xOffset = fmin(self.frame.size.width - self.verticalSelectionView.frame.size.width, fmax(0, touchPoint.x - (self.verticalSelectionView.frame.size.width * 0.5)));
    self.verticalSelectionView.frame = CGRectMake(xOffset, 0, self.verticalSelectionView.frame.size.width, self.verticalSelectionView.frame.size.height);
    [self setVerticalSelectionViewVisible:YES animated:YES];
    [self showLabelSetText];
}

- (void)touchesEndedOrCancelledWithTouches:(NSSet *)touches {
    [self setTooltipVisible:NO animated:YES];
    [self setVerticalSelectionViewVisible:NO animated:YES];
    [self showLabelSetText];
}

- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated atTouchPoint:(CGPoint)touchPoint {
    _tooltipVisible = tooltipVisible;

    // 將資訊 view 新增進來
    [self addSubview:self.tooltipView];
    // 將兩個 view 都放到畫面最上面
    [self bringSubviewToFront:self.tooltipView];

    // 更新資訊view的位置
    dispatch_block_t updatePosition = ^{
        CGPoint convertedTouchPoint = touchPoint;
        CGFloat minChartX = (self.frame.origin.x + ceil(self.tooltipView.frame.size.width * 0.5));
        if (convertedTouchPoint.x < minChartX) {
            convertedTouchPoint.x = minChartX;
        }
        CGFloat maxChartX = (self.frame.origin.x + self.frame.size.width - ceil(self.tooltipView.frame.size.width * 0.5));
        if (convertedTouchPoint.x > maxChartX) {
            convertedTouchPoint.x = maxChartX;
        }
        self.tooltipView.frame = CGRectMake(convertedTouchPoint.x - ceil(self.tooltipView.frame.size.width * 0.5), 10, self.tooltipView.frame.size.width, self.tooltipView.frame.size.height);
    };

    dispatch_block_t isVisibility = ^{
        self.tooltipView.alpha = _tooltipVisible ? 1.0 : 0.0;
    };

    if (animated) {
        if (tooltipVisible) {
            updatePosition();
        }

        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations: ^{
             isVisibility();
         } completion: ^(BOOL finished) {
             if (!tooltipVisible) {
                 updatePosition();
             }
         }];
    }
    else {
        updatePosition();
        isVisibility();
    }

}

- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated {
    [self setTooltipVisible:tooltipVisible animated:animated atTouchPoint:CGPointZero];
}

- (void)setTooltipVisible:(BOOL)tooltipVisible {
    [self setTooltipVisible:tooltipVisible animated:NO];
}

- (void)showLabelSetText {
    // 檢查線跟按鈕是否有重疊（CGRectIntersectsRect），如果是就顯示
    //        for (int i = 0; i < self.pillarsLayerArrays.count; i++) {
    //            CALayer *pillarLayer = self.pillarsLayerArrays[i];
    //            if (CGRectIntersectsRect(pillarLayer.frame, self.birdLayer.frame)) {
    //                return YES;
    //            }
    //        }
    //        return NO;
}

@end





