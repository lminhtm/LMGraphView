//
//  LMGraphPoint.h
//  LMGraphView
//
//  Created by LMinh on 24/09/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMGraphPoint : NSObject

@property (nonatomic, assign) CGPoint point;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *value;

+ (instancetype)graphPointWithPoint:(CGPoint)point
                              title:(NSString *)title
                              value:(NSString *)value;

@end


/*** Definitions of inline functions. ***/

CG_INLINE LMGraphPoint*
LMGraphPointMake(CGPoint point, NSString *title, NSString *value)
{
    return [LMGraphPoint graphPointWithPoint:point title:title value:value];
}
