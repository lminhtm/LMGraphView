//
//  LMGraphPlot.m
//  LMGraphView
//
//  Created by LMinh on 24/09/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import "LMGraphPlot.h"

@implementation LMGraphPlot

- (id)init
{
    self = [super init];
    if (self) {
        _fillColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        _strokeColor = [UIColor clearColor];
        _lineWidth = 2;
        
        _graphPointSize = 10;
        _graphPointColor = [UIColor whiteColor];
        _graphPointHighlightColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        
        _strokeCircleAroundGraphPoint = NO;
        _fillCircleAroundGraphPoint = YES;
    }
    return self;
}

@end
