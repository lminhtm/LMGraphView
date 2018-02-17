//
//  LMGraphPointView.m
//  LMGraphView
//
//  Created by LMinh on 25/09/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import "LMGraphPointView.h"

@interface LMGraphPointView ()

@property (nonatomic, strong) UIView *innerView;

@end

@implementation LMGraphPointView

- (id)initWithFrame:(CGRect)frame
         graphPoint:(LMGraphPoint *)graphPoint
              color:(UIColor *)color
     highlightColor:(UIColor *)highlightColor
{
    self = [super initWithFrame:frame];
    if (self) {
        self.graphPoint = graphPoint;
        
        self.clipsToBounds = YES;
        self.layer.cornerRadius = self.frame.size.width/2;
        self.backgroundColor = color;
        
        self.innerView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, self.frame.size.width - 2*2, self.frame.size.height - 2*2)];
        self.innerView.clipsToBounds = YES;
        self.innerView.layer.cornerRadius = self.innerView.frame.size.width/2;
        self.innerView.backgroundColor = highlightColor;
        self.innerView.hidden = YES;
        [self addSubview:self.innerView];
    }
    return self;
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    
    if (isSelected) {
        self.innerView.hidden = NO;
    }
    else {
        self.innerView.hidden = YES;
    }
}

@end
