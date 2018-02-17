//
//  LMGraphLayout.h
//  LMGraphViewDemo
//
//  Created by LMinh on 2/1/18.
//  Copyright © 2018 LMinh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LMGraphLayout : NSObject

@property (nonatomic, assign) BOOL startPlotFromZero;
@property (nonatomic, assign) BOOL drawMovement;

@property (nonatomic, assign) BOOL xAxisScrollableOnly;
@property (nonatomic, assign) BOOL xAxisGridHidden;
@property (nonatomic, assign) BOOL xAxisGridDashLine;
@property (nonatomic, assign) CGFloat xAxisIntervalInPx;
@property (nonatomic, assign) CGFloat xAxisMargin;

@property (nonatomic, assign) BOOL xAxisZeroHidden;
@property (nonatomic, assign) BOOL xAxisZeroDashLine;
@property (nonatomic, assign) CGFloat xAxisLinesWidth;
@property (nonatomic, strong) UIColor *xAxisLinesStrokeColor;
@property (nonatomic, assign) CGFloat xAxisLabelHeight;
@property (nonatomic, strong) UIFont *xAxisLabelFont;
@property (nonatomic, strong) UIColor *xAxisLabelColor;

@property (nonatomic, assign) NSUInteger yAxisSegmentCount;
@property (nonatomic, assign) BOOL yAxisZeroHidden;
@property (nonatomic, assign) BOOL yAxisZeroDashLine;
@property (nonatomic, assign) BOOL yAxisGridHidden;
@property (nonatomic, assign) BOOL yAxisGridDashLine;
@property (nonatomic, strong) UIColor *yAxisLinesStrokeColor;
@property (nonatomic, assign) CGFloat yAxisLinesWidth;
@property (nonatomic, assign) CGFloat yAxisLabelWidth;
@property (nonatomic, assign) CGFloat yAxisLabelHeight;
@property (nonatomic, strong) UIFont *yAxisLabelFont;
@property (nonatomic, strong) UIColor *yAxisLabelColor;

@property (nonatomic, strong) UIFont *yAxisUnitLabelFont;
@property (nonatomic, strong) UIColor *yAxisUnitLabelColor;

@property (nonatomic, assign) CGFloat titleLabelHeight;
@property (nonatomic, strong) UIFont *titleLabelFont;
@property (nonatomic, strong) UIColor *titleLabelColor;

@property (nonatomic, assign) CGFloat movementLineWidth;
@property (nonatomic, strong) UIColor *movementLineColor;
@property (nonatomic, strong) UIColor *movementDotColor;

@end
