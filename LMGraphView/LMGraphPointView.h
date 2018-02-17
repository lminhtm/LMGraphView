//
//  LMGraphPointView.h
//  LMGraphView
//
//  Created by LMinh on 25/09/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMGraphPoint.h"

@interface LMGraphPointView : UIView

@property (nonatomic, strong) LMGraphPoint *graphPoint;
@property (nonatomic, assign) BOOL isSelected;

- (id)initWithFrame:(CGRect)frame
         graphPoint:(LMGraphPoint *)graphPoint
              color:(UIColor *)color
     highlightColor:(UIColor *)highlightColor;

@end
