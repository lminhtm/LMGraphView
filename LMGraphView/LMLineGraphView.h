//
//  LMLineGraphView.h
//  LMGraphView
//
//  Created by LMinh on 17/09/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMGraphPointView.h"
#import "LMGraphPlot.h"
#import "LMGraphPoint.h"
#import "PopoverView.h"
#import "LMGraphLayout.h"

@protocol LMLineGraphViewDelegate;

@interface LMLineGraphView : UIView

@property (nonatomic, strong) NSArray *xAxisValues;
@property (nonatomic, assign) CGFloat xAxisInterval;
@property (nonatomic, assign) CGFloat yAxisMaxValue;
@property (nonatomic, assign) CGFloat yAxisMinValue;
@property (nonatomic, strong) NSArray *graphPlots;

@property (nonatomic, strong) NSString *yAxisSuffix;
@property (nonatomic, strong) NSString *yAxisUnit;
@property (nonatomic, strong) NSString *noDataText;
@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) LMGraphLayout *layout;

@property (nonatomic, weak) id<LMLineGraphViewDelegate> delegate;

- (void)animateWithDuration:(NSTimeInterval)duration;

- (UIImage *)graphImage;

@end

@protocol LMLineGraphViewDelegate <NSObject>

@optional
- (NSString *)lineGraphView:(LMLineGraphView *)lineGraphView yAxisLabelTitleFromValue:(CGFloat)value index:(int)index;
- (void)lineGraphView:(LMLineGraphView *)lineGraphView beganTouchWithGraphPoint:(LMGraphPoint *)graphPoint;
- (void)lineGraphView:(LMLineGraphView *)lineGraphView moveTouchWithGraphPoint:(LMGraphPoint *)graphPoint;
- (void)lineGraphView:(LMLineGraphView *)lineGraphView endTouchWithGraphPoint:(LMGraphPoint *)graphPoint;

@end
