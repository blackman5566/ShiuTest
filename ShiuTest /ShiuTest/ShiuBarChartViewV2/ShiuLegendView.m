//
//  ShiuLegendView.m
//  ShiuTest
//
//  Created by AllenShiu on 2016/7/25.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ShiuLegendView.h"

#define LegendTextSize 10
#define RectWidth 7
#define Rect_TextMargin 5
#define LegendMargin 7
#define Margin 5

@implementation ShiuLegendView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setDatas:(NSArray <ShiuLegendViewData *> *)datas {
    _datas = datas;

    __block CGFloat textMaxWidth = 0;
    __block CGFloat textWidth = 0;
    [datas enumerateObjectsUsingBlock: ^(ShiuLegendViewData *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
         NSString *legendText = obj.label;
         CGSize size = [legendText sizeWithAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:LegendTextSize] }];
         textWidth = textWidth + size.width;
         if (size.width > textMaxWidth) {
             textMaxWidth = size.width;
         }
     }];

    switch (self.alignment) {
        case LegendAlignmentVertical:
        {
            CGRect bounds = CGRectMake(0, 0, Margin + RectWidth + Rect_TextMargin + textMaxWidth + Margin, Margin + (LegendTextSize + LegendMargin) * datas.count - LegendMargin + Margin);
            self.bounds = bounds;
            break;
        }
        case LegendAlignmentHorizontal:
        {
            CGRect bounds = CGRectMake(0, 0, Margin + (RectWidth + Rect_TextMargin + LegendMargin) * datas.count + textWidth - LegendMargin + Margin, Margin + LegendTextSize + Margin);
            self.bounds = bounds;
            break;
        }
    }

}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (self.alignment) {
        case LegendAlignmentVertical:
        {
            [self.datas enumerateObjectsUsingBlock: ^(ShiuLegendViewData *_Nonnull obj, NSUInteger index, BOOL *_Nonnull stop) {
                 CGContextSetFillColorWithColor(context, obj.color.CGColor);
                 CGRect rect = CGRectMake(Margin, Margin + index * (LegendTextSize + LegendMargin) + (LegendTextSize - RectWidth) / 2, RectWidth, RectWidth);
                 CGContextFillRect(context, rect);
                 [obj.label drawInRect:CGRectMake(Margin + RectWidth + Rect_TextMargin, Margin + index * (LegendTextSize + LegendMargin) - 2, self.bounds.size.width, LegendTextSize * 2) withAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:LegendTextSize], NSForegroundColorAttributeName:[UIColor grayColor] }];
             }];
            break;
        }
        case LegendAlignmentHorizontal:
        {
            __block CGFloat xPoint = Margin;
            [self.datas enumerateObjectsUsingBlock: ^(ShiuLegendViewData *_Nonnull shiuLegendViewData, NSUInteger index, BOOL *_Nonnull stop) {
                 CGContextSetFillColorWithColor(context, shiuLegendViewData.color.CGColor);
                 CGRect rect = CGRectMake(xPoint, Margin + (LegendTextSize - RectWidth) / 2, RectWidth, RectWidth);//坐标
                 CGContextFillRect(context, rect);
                 CGSize size = [shiuLegendViewData.label sizeWithAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:LegendTextSize] }];
                 xPoint += RectWidth + Rect_TextMargin;
                 [shiuLegendViewData.label drawInRect:CGRectMake(xPoint, Margin - 2, size.width, self.bounds.size.height) withAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:LegendTextSize], NSForegroundColorAttributeName:[UIColor grayColor] }];
                 xPoint += size.width + LegendMargin;
             }];
            break;
        }
    }
}

@end

@implementation ShiuLegendViewData

@end

