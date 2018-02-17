//
//  LMGraphLayout.m
//  LMGraphViewDemo
//
//  Created by LMinh on 2/1/18.
//  Copyright © 2018 LMinh. All rights reserved.
//

#import "LMGraphLayout.h"

@implementation LMGraphLayout

- (id)init
{
    self = [super init];
    if (self)
    {
        _drawMovement = YES;
        
        _xAxisScrollableOnly = YES;
        _xAxisGridDashLine = YES;
        _xAxisIntervalInPx = 60;
        _xAxisMargin = 0;
        
        _xAxisZeroHidden = NO;
        _xAxisZeroDashLine = NO;
        _xAxisLinesWidth = 0.5;
        _xAxisLinesStrokeColor = [UIColor lightGrayColor];
        _xAxisLabelHeight = 40;
        _xAxisLabelFont = [UIFont systemFontOfSize:12];
        _xAxisLabelColor = [UIColor darkGrayColor];
        
        _yAxisSegmentCount = 3;
        _yAxisZeroHidden = NO;
        _yAxisZeroDashLine = NO;
        _yAxisLinesWidth = 0.5;
        _xAxisGridHidden = NO;
        _yAxisGridHidden = NO;
        _yAxisGridDashLine = YES;
        _yAxisLabelWidth  = 40;
        _yAxisLinesStrokeColor = [UIColor lightGrayColor];
        _yAxisLabelHeight = 20;
        _yAxisLabelFont = [UIFont systemFontOfSize:12];
        _yAxisLabelColor = [UIColor darkGrayColor];
    
        _yAxisUnitLabelFont = [UIFont systemFontOfSize:10];
        _yAxisUnitLabelColor = [UIColor darkGrayColor];
        
        _titleLabelHeight = 25;
        _titleLabelFont = [UIFont systemFontOfSize:14];
        _titleLabelColor = [UIColor darkGrayColor];
        
        _movementLineWidth = 2;
        _movementLineColor = [UIColor lightGrayColor];
        _movementDotColor = [UIColor redColor];
    }
    return self;
}

@end
