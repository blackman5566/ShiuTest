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
#import "ShiuCircleView.h"
#import "ShiuChartView.h"

@interface ShiuChartScrollView ()

@property (strong, nonatomic) ShiuVerticalSelectionView *verticalSelectionView;

@property (nonatomic, strong) ShiuChartTooltipView *tooltipView;
@property (nonatomic, strong) ShiuChartView *chartView;
@property (nonatomic, strong) UIView *yView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *xValue;
@property (nonatomic, strong) NSMutableArray *yValue;

@property (nonatomic, assign) CGFloat displacementAmount;
@property (nonatomic, assign) BOOL tooltipVisible;
@property (nonatomic, assign) BOOL verticalSelectionViewVisible;

@end

@implementation ShiuChartScrollView

#pragma mark - UIResponder (處理觸碰事件)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // 手指開始觸碰螢幕
    [self touchesBeganOrMovedWithTouches:touches];
    [self changeScrollViewDisplacementAmount:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // 手指移動
    [self touchesBeganOrMovedWithTouches:touches];
    [self changeScrollViewDisplacementAmount:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // 手指離開螢幕
    [self touchesEndedOrCancelledWithTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // 當有突發事件發生時 (比如觸碰過程被來電打斷)
    [self touchesEndedOrCancelledWithTouches:touches];
}

#pragma mark *  misc

- (void)touchesBeganOrMovedWithTouches:(NSSet *)touches {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];

    CGFloat xOffset1 = CGRectGetWidth(self.frame) - CGRectGetWidth(self.verticalSelectionView.frame);
    CGFloat xOffset2 = fmax(0, touchPoint.x - (CGRectGetWidth(self.verticalSelectionView.frame) * 0.5));
    CGFloat xOffset = fmin(xOffset1, xOffset2);
    CGFloat width = CGRectGetWidth(self.verticalSelectionView.frame);
    CGFloat height = CGRectGetHeight(self.verticalSelectionView.frame);
    self.verticalSelectionView.frame = CGRectMake(xOffset, 0, width, height);

    [self showLabelSetText];
}

- (void)changeScrollViewDisplacementAmount:(NSSet *)touches {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];

    BOOL isMoveToRight = (touchPoint.x > (CGRectGetWidth([UIScreen mainScreen].bounds) - (DashLineWidth + 10)));
    BOOL isMoveToLeft = (touchPoint.x < (DashLineWidth + 10));
    if (isMoveToRight || isMoveToLeft) {
        if (!self.timer) {
            SEL updateRight = @selector(updateRightDisplacementAmount);
            SEL updateLeft = @selector(updateLeftDisplacementAmount);
            SEL updateDisplacementAmount = isMoveToRight ? updateRight : updateLeft;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:updateDisplacementAmount userInfo:nil repeats:YES];
        }
    }
    else {
        [self cancelAllTask];
    }
}

- (void)touchesEndedOrCancelledWithTouches:(NSSet *)touches {
    [self setTooltipVisible:NO animated:YES];
    [self showLabelSetText];
}

#pragma mark - private instance method

#pragma mark * init

- (void)setupInitValue:(CGRect)frame {
    self.xValue = [[NSMutableArray alloc] init];
    self.yValue = [[NSMutableArray alloc] init];

    //[self.yValue addObject:[NSString stringWithFormat:@"%u", 1 + arc4random() % 100]];
    for (int i = 1; i < 40; i++) {
        [self.xValue addObject:[NSString stringWithFormat:@"%d", i]];
        [self.yValue addObject:[NSString stringWithFormat:@"%u", 1 + arc4random() % 100]];
    }
//    [self.yValue addObject:[NSString stringWithFormat:@"%d", 20]];
//    [self.yValue addObject:[NSString stringWithFormat:@"%d", 10]];
//    [self.yValue addObject:[NSString stringWithFormat:@"%d", 30]];
//    [self.yValue addObject:[NSString stringWithFormat:@"%d", 0]];
//    [self.yValue addObject:[NSString stringWithFormat:@"%d", 0]];
//    [self.yValue addObject:[NSString stringWithFormat:@"%d", 0]];
//    [self.yValue addObject:[NSString stringWithFormat:@"%d", 0]];
//    [self.yValue addObject:[NSString stringWithFormat:@"%d", 40]];
//    [self.yValue addObject:[NSString stringWithFormat:@"%d", 50]];
//    [self.yValue addObject:[NSString stringWithFormat:@"%d", 60]];
//    [self.yValue addObject:[NSString stringWithFormat:@"%d", 70]];
//    [self.yValue addObject:[NSString stringWithFormat:@"%d", 80]];
//    [self.yValue addObject:[NSString stringWithFormat:@"%d", 23]];
//    [self.yValue addObject:[NSString stringWithFormat:@"%d", 54]];
//    [self.yValue addObject:[NSString stringWithFormat:@"%d", 10]];
//    [self.yValue addObject:[NSString stringWithFormat:@"%d", 23]];
//    [self.yValue addObject:[NSString stringWithFormat:@"%d", 43]];
//    [self.yValue addObject:[NSString stringWithFormat:@"%d", 56]];

    CGFloat width = MAX(CGRectGetWidth([UIScreen mainScreen].bounds), (self.xValue.count * DashLineWidth));
    CGFloat height = CGRectGetHeight(frame) - 50;

    self.yView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DashLineWidth, height)];
    self.yView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.yView];
    self.chartView = [[ShiuChartView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.chartView.xValues = self.xValue;
    self.chartView.yValues = self.yValue;
    self.chartView.chartColor = [UIColor blueColor];
    __weak typeof(self) weakSelf = self;
    self.chartView.drawAtPointBlock = ^(CGFloat cX, CGFloat cY, CGSize size, NSString *yValue){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(cX, cY - (size.height / 2), size.width, size.height)];
        label.font = [UIFont systemFontOfSize:14];
        label.text = yValue;
        [weakSelf.yView addSubview:label];
    };


    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(DashLineWidth, 0, CGRectGetWidth([UIScreen mainScreen].bounds) - DashLineWidth, height)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(width, height);
    [self.scrollView addSubview:self.chartView];
    [self addSubview:self.scrollView];
    [self sendSubviewToBack:self.scrollView];

    self.displacementAmount = 0;
}

#pragma mark * misc

- (void)addVerticalSelectionView {
    // 初始化紅色線
    self.verticalSelectionView = [[ShiuVerticalSelectionView alloc] initWithFrame:CGRectMake(50, 0, 1, CGRectGetHeight(self.frame))];
    [self addSubview:self.verticalSelectionView];

    // 初始化資訊 view
    self.tooltipView = [[ShiuChartTooltipView alloc] initWithFrame:CGRectMake(50, 0, 60, 20)];
    [self addSubview:self.tooltipView];
}

- (void)updateRightDisplacementAmount {
    // 開始向右滑動
    // 當 distanceFromRight 等於 width 就代表說已經到底了，
    // 使用 roundf 是因為不同尺寸下會有些許誤差值，所以用無條件捨棄方式比對。
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds) - DashLineWidth;
    CGFloat contentYoffset = self.scrollView.contentOffset.x;
    CGFloat distanceFromRight = self.scrollView.contentSize.width - contentYoffset;
    BOOL isMoveRightMaxLimit = (roundf(distanceFromRight) == width);
    if (isMoveRightMaxLimit) {
        [self cancelAllTask];
    }
    else {
        self.displacementAmount += DashLineWidth;
        CGPoint position = CGPointMake(self.displacementAmount, 0);
        [self.scrollView setContentOffset:position animated:NO];
        [self showLabelSetText];
    }
}

- (void)updateLeftDisplacementAmount {
    // 開始向左滑動
    // contentYoffset 當為 0 時就代表已經到最前面了，當不是為0時就繼續滑動
    CGFloat contentYoffset = self.scrollView.contentOffset.x;
    BOOL isMoveLeftMaxLimit = (contentYoffset == 0);
    if (isMoveLeftMaxLimit) {
        [self cancelAllTask];
        [self performSelector:@selector(delayRequest) withObject:nil afterDelay:2.0f];
    }
    else {
        self.displacementAmount -= DashLineWidth;
        CGPoint position = CGPointMake(self.displacementAmount, 0);
        [self.scrollView setContentOffset:position animated:NO];
        [self showLabelSetText];
    }
}

- (void)delayRequest {
    [self.scrollView removeFromSuperview];
    [self setupInitValue:self.frame];
}

- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated atTouchPoint:(CGPoint)touchPoint {
    _tooltipVisible = tooltipVisible;

    // 將資訊 view 新增進來
    [self addSubview:self.tooltipView];
    // 將兩個 view 都放到畫面最上面
    [self bringSubviewToFront:self.tooltipView];

    // 更新資訊view的位置
    __weak typeof(self) weakSelf = self;
    void (^updatePosition)() = ^{
        CGPoint convertedTouchPoint = touchPoint;
        CGFloat minChartX = (CGRectGetMinX(weakSelf.frame) + ceil(CGRectGetWidth(weakSelf.tooltipView.frame) * 0.5));
        if (convertedTouchPoint.x < minChartX) {
            convertedTouchPoint.x = minChartX;
        }

        CGFloat maxChartX = (CGRectGetMinY(weakSelf.frame) + CGRectGetWidth(weakSelf.frame) - ceil(CGRectGetWidth(weakSelf.tooltipView.frame) * 0.5));
        if (convertedTouchPoint.x > maxChartX) {
            convertedTouchPoint.x = maxChartX;
        }

        CGFloat x = convertedTouchPoint.x - ceil(CGRectGetWidth(weakSelf.tooltipView.frame) * 0.5);
        CGFloat y = 10;
        CGFloat width = CGRectGetWidth(weakSelf.tooltipView.frame);
        CGFloat height = CGRectGetHeight(weakSelf.tooltipView.frame);
        weakSelf.tooltipView.frame = CGRectMake(x, y, width, height);
    };

    if (animated) {
        if (tooltipVisible) {
            updatePosition();
        }
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations: ^{
             weakSelf.tooltipView.alpha = tooltipVisible ? 1.0 : 0.0;
         } completion: ^(BOOL finished) {
             if (!tooltipVisible) {
                 updatePosition();
             }
         }];
    }
    else {
        updatePosition();
        self.tooltipView.alpha = tooltipVisible ? 1.0 : 0.0;
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
    for (int i = 0; i < self.chartView.circleViewArray.count; i++) {
        ShiuCircleView *circleView = self.chartView.circleViewArray[i];
        CGRect newRect = [self convertRect:circleView.frame fromView:self.scrollView];
        if (CGRectIntersectsRect(newRect, self.verticalSelectionView.frame)) {
            [self.tooltipView setText:circleView.value];
        }
    }
}

- (void)cancelAllTask {
    [self.timer invalidate];
    self.timer = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayRequest) object:nil];
}

#pragma mark - life cycle

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupInitValue:frame];
    }
    return self;
}

#pragma mark * override

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self addVerticalSelectionView];
}

@end
