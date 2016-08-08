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

@property (nonatomic, strong) ShiuVerticalSelectionView *verticalSelectionView;

@property (nonatomic, strong) ShiuChartTooltipView *tooltipView;
@property (nonatomic, strong) ShiuChartView *chartView;
@property (nonatomic, strong) UIView *yView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *xValue;
@property (nonatomic, strong) NSMutableArray *yValue;
@property (nonatomic, strong) UIView *moveView;

@property (nonatomic, assign) CGFloat displacementAmount;
@property (nonatomic, assign) BOOL isTouchPointInMoveView;

@end

@implementation ShiuChartScrollView

#pragma mark - UIResponder (處理觸碰事件)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // 手指開始觸碰螢幕
    // 判斷是否在 moveView 的範圍內
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(self.moveView.frame, touchPoint)) {
        self.isTouchPointInMoveView = YES;
        [self touchesBeganOrMovedWithTouches:touches];
        [self changeScrollViewDisplacementAmount:touches];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // 手指移動
    if (self.isTouchPointInMoveView) {
        [self touchesBeganOrMovedWithTouches:touches];
        [self changeScrollViewDisplacementAmount:touches];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // 手指離開螢幕
    if (self.isTouchPointInMoveView) {
        self.isTouchPointInMoveView = NO;
        [self touchesEndedOrCancelledWithTouches:touches];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // 當有突發事件發生時 (比如觸碰過程被來電打斷)
    if (self.isTouchPointInMoveView) {
        self.isTouchPointInMoveView = NO;
        [self touchesEndedOrCancelledWithTouches:touches];
    }
}

#pragma mark *  misc

- (void)touchesBeganOrMovedWithTouches:(NSSet *)touches {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    [self tooltipVisible:YES animated:YES atTouchPoint:touchPoint];
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
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    [self tooltipVisible:NO animated:YES atTouchPoint:touchPoint];
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
        [self.yValue addObject:[NSString stringWithFormat:@"%u", 1 + arc4random() % 500]];
    }

    CGFloat width = MAX(CGRectGetWidth([UIScreen mainScreen].bounds), (self.xValue.count * DashLineWidth));
    CGFloat height = CGRectGetHeight(frame) - 80;
    
    self.yView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DashLineWidth, height)];
    self.yView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.yView];
    [self sendSubviewToBack:self.yView];

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
    self.scrollView.scrollEnabled = NO;
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
    self.tooltipView = [[ShiuChartTooltipView alloc] initWithFrame:CGRectMake(50, 10, 60, 20)];
    [self addSubview:self.tooltipView];

    // 初始化 moveView
    self.moveView = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(self.chartView.frame), 100, 80)];
    self.moveView.userInteractionEnabled = NO;
    self.moveView.backgroundColor = [UIColor yellowColor];
    [self addSubview:self.moveView];

}

- (void)updateRightDisplacementAmount {
    // 開始向右滑動
    // 當 distanceFromRight 等於 width 就代表說已經到底了，
    // 使用 roundf 是因為不同尺寸下會有些許誤差值，所以用無條件捨棄方式比對。
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds) - DashLineWidth;
    CGFloat contentYoffset = self.scrollView.contentOffset.x;
    CGFloat distanceFromRight = self.scrollView.contentSize.width - contentYoffset;
    BOOL isMoveRightMaxLimit = (roundf(distanceFromRight) == roundf(width));
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
- (CGRect)updateVerticalSelectionViewWith:(CGPoint)touchPoint {
    CGFloat xOffset1 = CGRectGetWidth(self.frame) - CGRectGetWidth(self.verticalSelectionView.frame);
    CGFloat xOffset2 = fmax(0, touchPoint.x - (CGRectGetWidth(self.verticalSelectionView.frame) * 0.5));
    CGFloat xOffset = fmin(xOffset1, xOffset2);
    CGFloat width = CGRectGetWidth(self.verticalSelectionView.frame);
    CGFloat height = CGRectGetHeight(self.verticalSelectionView.frame);
    return CGRectMake(xOffset, 0, width, height);
}

- (CGRect)updatePosition:(UIView *)view with:(CGPoint)touchPoint {
    CGPoint convertedTouchPoint = touchPoint;
    CGFloat minChartX = (CGRectGetMinX(self.frame) + ceil(CGRectGetWidth(view.frame) * 0.5));
    if (convertedTouchPoint.x < minChartX) {
        convertedTouchPoint.x = minChartX;
    }

    CGFloat maxChartX = (CGRectGetMinX(self.frame) + CGRectGetWidth(self.frame) - ceil(CGRectGetWidth(view.frame) * 0.5));
    if (convertedTouchPoint.x > maxChartX) {
        convertedTouchPoint.x = maxChartX;
    }

    CGFloat x = convertedTouchPoint.x - ceil(CGRectGetWidth(view.frame) * 0.5);
    CGFloat y = CGRectGetMinY(view.frame);
    CGFloat width = CGRectGetWidth(view.frame);
    CGFloat height = CGRectGetHeight(view.frame);
    return CGRectMake(x, y, width, height);
}

- (void)tooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated atTouchPoint:(CGPoint)touchPoint {
    // 更新相關view的位置
    // verticalSelectionView 紅線
    // tooltipView 上方數值 view
    // moveView 下面移動的view
    self.verticalSelectionView.frame = [self updateVerticalSelectionViewWith:touchPoint];
    self.tooltipView.frame = [self updatePosition:self.tooltipView with:touchPoint];
    self.moveView.frame = [self updatePosition:self.moveView with:touchPoint];

    // 隱藏效果
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations: ^{
         weakSelf.tooltipView.alpha = tooltipVisible ? 1.0 : 0.0;
     } completion:nil];
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
        self.isTouchPointInMoveView = NO;
    }
    return self;
}

#pragma mark * override

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self addVerticalSelectionView];
}

@end
