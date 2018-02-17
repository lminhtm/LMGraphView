//
//  LMGraphPoint.m
//  LMGraphView
//
//  Created by LMinh on 24/09/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import "LMGraphPoint.h"

@implementation LMGraphPoint

+ (instancetype)graphPointWithPoint:(CGPoint)point
                              title:(NSString *)title
                              value:(NSString *)value
{
    LMGraphPoint *graphPoint = [[LMGraphPoint alloc] init];
    graphPoint.point = point;
    graphPoint.title = title;
    graphPoint.value = value;
    return graphPoint;
}

@end
