//
//  LMGraphPlot.h
//  LMGraphView
//
//  Created by LMinh on 24/09/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMGraphPoint.h"

@interface LMGraphPlot : NSObject

@property (nonatomic, strong) NSArray *graphPoints;

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic, assign) CGFloat graphPointSize;
@property (nonatomic, strong) UIColor *graphPointColor;
@property (nonatomic, strong) UIColor *graphPointHighlightColor;

@property (nonatomic, assign) BOOL strokeCircleAroundGraphPoint;
@property (nonatomic, assign) BOOL fillCircleAroundGraphPoint;
@property (nonatomic, assign) BOOL curveLine;

@end
