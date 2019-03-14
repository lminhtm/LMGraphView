//
//  LMLineGraphView.m
//  LMGraphView
//
//  Created by LMinh on 17/09/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import "LMLineGraphView.h"

#define DEBUG_MODE 0
#define graphPointInPx(a) [self graphPointInPxFromGraphPoint:a]

// RECT
#define frx(a)                      (a.frame.origin.x)
#define fry(a)                      (a.frame.origin.y)
#define maxfry(a)                   (a.frame.origin.y) + (a.frame.size.height)
#define maxfrx(a)                   (a.frame.origin.x) + (a.frame.size.width)
#define midx(a)                     (CGRectGetMidX(a.frame))
#define midy(a)                     (CGRectGetMidY(a.frame))
#define W(a)                        (a.frame.size.width)
#define H(a)                        (a.frame.size.height)
#define FULL(a)                     (CGRectMake(0, 0, a.frame.size.width, a.frame.size.height))
#define below(a)                    (a.frame.origin.y) + (a.frame.size.height)

@interface LMLineGraphView ()

@property (nonatomic, strong) LMGraphPoint *currentGraphPoint;
@property (nonatomic, assign) BOOL isMovement;

@property (nonatomic, assign) BOOL validGraphData;

@property (nonatomic, assign) CGFloat xAxisMaxValue;

@property (nonatomic, strong) NSArray *yAxisValues;
@property (nonatomic, assign) CGFloat yAxisInterval;
@property (nonatomic, assign) CGFloat yAxisIntervalInPx;

@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIView *graphContentView;
@property (nonatomic, strong) UIView *xAxisLabelsContainerView;
@property (nonatomic, strong) UIView *yAxisLabelsContainerView;
@property (nonatomic, strong) UILabel *yAxisUnitLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *noDataTextLabel;

@property (nonatomic, strong) CAShapeLayer *xAxisZeroLayer;
@property (nonatomic, strong) CAShapeLayer *xAxisGridLayer;
@property (nonatomic, strong) CAShapeLayer *yAxisZeroLayer;
@property (nonatomic, strong) CAShapeLayer *yAxisGridLayer;
@property (nonatomic, strong) CAShapeLayer *touchLayer;
@property (nonatomic, strong) NSMutableArray *backgroundPlotLayers;
@property (nonatomic, strong) NSMutableArray *graphPlotLayers;

@end

@implementation LMLineGraphView

#pragma mark - INIT

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _xAxisInterval = 1;
    _yAxisMinValue = 0;
    _xAxisStartGraphPoint = 0;
    
    _layout = [LMGraphLayout new];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapGesture];
}


#pragma mark - LAYOUT

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Setup content views
    [self setupContentViews];
    
    // Redraw
    [self setNeedsDisplay];
}

- (void)setupContentViews
{
    // Calculate frame
    CGFloat contentSizeWidth;
    if (self.layout.xAxisScrollableOnly)
    {
        contentSizeWidth = self.xAxisMaxValue * self.layout.xAxisIntervalInPx - self.layout.xAxisMargin + MAX(self.layout.xAxisMargin, self.layout.xAxisIntervalInPx/2);
    }
    else
    {
        contentSizeWidth = W(self) - self.layout.xAxisMargin;
    }
    
    // Title Label
    if (!self.titleLabel) {
        self.titleLabel = [[UILabel alloc] init];
#if DEBUG_MODE
        self.titleLabel.backgroundColor = [UIColor redColor];
#else
        self.titleLabel.backgroundColor = [UIColor clearColor];
#endif
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
    }
    self.titleLabel.frame = CGRectMake(0,
                                       5,
                                       W(self),
                                       self.title ? self.layout.titleLabelHeight : 0);
    self.titleLabel.font = self.layout.titleLabelFont;
    self.titleLabel.textColor = self.layout.titleLabelColor;
    self.titleLabel.text = self.title;
    self.titleLabel.hidden = (self.title == nil);
    
    // Y Axis Unit Label
    if (!self.yAxisUnitLabel) {
        self.yAxisUnitLabel = [[UILabel alloc] init];
#if DEBUG_MODE
        self.yAxisUnitLabel.backgroundColor = [UIColor magentaColor];
#else
        self.yAxisUnitLabel.backgroundColor = [UIColor clearColor];
#endif
        self.yAxisUnitLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.yAxisUnitLabel];
    }
    self.yAxisUnitLabel.frame = CGRectMake(self.layout.yAxisLabelWidth,
                                           maxfry(self.titleLabel),
                                           100,
                                           self.yAxisUnit ? self.layout.yAxisLabelHeight : 0);
    self.yAxisUnitLabel.font = self.layout.yAxisUnitLabelFont;
    self.yAxisUnitLabel.textColor = self.layout.yAxisUnitLabelColor;
    self.yAxisUnitLabel.text = self.yAxisUnit;
    self.yAxisUnitLabel.hidden = (self.yAxisUnit == nil);
    
    // Content Scroll View
    if (!self.contentScrollView) {
        self.contentScrollView = [[UIScrollView alloc] init];
#if DEBUG_MODE
        self.contentScrollView.backgroundColor = [UIColor darkTextColor];
#else
        self.contentScrollView.backgroundColor = [UIColor clearColor];
#endif
        self.contentScrollView.showsHorizontalScrollIndicator = NO;
        self.contentScrollView.showsVerticalScrollIndicator = NO;
        self.contentScrollView.userInteractionEnabled = self.layout.xAxisScrollableOnly;
        self.contentScrollView.clipsToBounds = self.layout.xAxisScrollableOnly;
        [self addSubview:self.contentScrollView];
    }
    CGFloat contentX = self.layout.xAxisScrollableOnly ? self.layout.yAxisLabelWidth : 0;
    CGFloat contentY = maxfry(self.yAxisUnitLabel);
    self.contentScrollView.frame = CGRectMake(contentX,
                                              contentY,
                                              W(self) - contentX - self.layout.xAxisMargin,
                                              H(self) - contentY);
    self.contentScrollView.contentSize = CGSizeMake(contentSizeWidth, H(self.contentScrollView));
    
    // Graph Content View
    if (!self.graphContentView) {
        self.graphContentView = [[UIView alloc] init];
#if DEBUG_MODE
        self.graphContentView.backgroundColor = [UIColor brownColor];
#else
        self.graphContentView.backgroundColor = [UIColor clearColor];
#endif
        [self.contentScrollView addSubview:self.graphContentView];
    }
    contentX = self.layout.xAxisScrollableOnly ? 0 : self.layout.yAxisLabelWidth;
    self.graphContentView.frame = CGRectMake(contentX,
                                             0,
                                             self.contentScrollView.contentSize.width - contentX,
                                             H(self.contentScrollView) - self.layout.xAxisLabelHeight);
    
    // noDataText Label
    if (!self.noDataTextLabel) {
        self.noDataTextLabel = [[UILabel alloc] init];
#if DEBUG_MODE
        self.noDataTextLabel.backgroundColor = [UIColor magentaColor];
#else
        self.noDataTextLabel.backgroundColor = [UIColor clearColor];
#endif
        self.noDataTextLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.noDataTextLabel];
    }
    self.noDataTextLabel.frame = CGRectMake(0,
                                            fry(self.contentScrollView),
                                            W(self),
                                            H(self) - fry(self.contentScrollView));
    self.noDataTextLabel.font = self.layout.yAxisUnitLabelFont;
    self.noDataTextLabel.textColor = self.layout.yAxisUnitLabelColor;
    self.noDataTextLabel.text = self.noDataText;
    self.noDataTextLabel.hidden = YES;
}


#pragma mark - DRAWING

- (void)drawRect:(CGRect)rect
{
    // Calculate graph data
    [self calculateGraphData];
    
    // Check valid data
    if (self.validGraphData)
    {
        self.noDataTextLabel.hidden = YES;
        self.yAxisUnitLabel.hidden = (self.yAxisUnit == nil);
        
        // Draw XY Axis
        [self drawXYAxis];
        
        // Draw plots
        [self drawPlots];
        
        if(self.shouldScrollToRecentData) {
            ///Scroll to most recent data
            CGSize contentScrollViewSize = self.contentScrollView.contentSize;
            if(contentScrollViewSize.width > W(self.contentScrollView)) {
                [self.contentScrollView scrollRectToVisible:CGRectMake(contentScrollViewSize.width - W(self.contentScrollView), self.contentScrollView.contentOffset.y, contentScrollViewSize.width, contentScrollViewSize.height) animated:YES];
            }
        }
    }
    else
    {
        self.noDataTextLabel.hidden = NO;
        self.yAxisUnitLabel.hidden = YES;
    }
}

- (void)drawXYAxis
{
    // X Axis Labels
    [self drawXAxisLabels];
    
    // X Axis Line
    if (!self.layout.xAxisZeroHidden) {
        [self drawXAsisZero];
    }
    
    // X Axis Grid
    if (!self.layout.xAxisGridHidden) {
        [self drawXAxisGrid];
    }
    
    // Y Axis Labels
    [self drawYAxisLabels];
    
    // Y Axis Line
    if (!self.layout.yAxisZeroHidden) {
        [self drawYAsisZero];
    }
    
    // Y Axis Grid
    if (!self.layout.yAxisGridHidden) {
        [self drawYAxisGrid];
    }
}

- (void)drawXAxisLabels
{
    // xAxisLabels Container View
    if (!self.xAxisLabelsContainerView) {
        self.xAxisLabelsContainerView = [[UIView alloc] init];
#if DEBUG_MODE
        self.xAxisLabelsContainerView.backgroundColor = [UIColor blueColor];
#else
        self.xAxisLabelsContainerView.backgroundColor = [UIColor clearColor];
#endif
        [self.contentScrollView addSubview:self.xAxisLabelsContainerView];
    }
    CGFloat contentX = self.layout.xAxisScrollableOnly ? 0 : self.layout.yAxisLabelWidth;
    self.xAxisLabelsContainerView.frame = CGRectMake(contentX,
                                                     H(self.contentScrollView) - self.layout.xAxisLabelHeight,
                                                     self.contentScrollView.contentSize.width - contentX,
                                                     self.layout.xAxisLabelHeight);
    [[self.xAxisLabelsContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // xAxisLabels
    if (!self.isMovement)
    {
        for (NSDictionary *xAxisValueDict in self.xAxisValues)
        {
            __block NSNumber *xAxisValue = nil;
            __block NSString *xAxisTitle = nil;
            [xAxisValueDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                xAxisValue = (NSNumber *)key;
                xAxisTitle = (NSString *)obj;
            }];
            
            // Create xAxisLabel
            CGPoint graphPointInPx = graphPointInPx(CGPointMake([xAxisValue floatValue], 0));
            graphPointInPx = [self.xAxisLabelsContainerView convertPoint:graphPointInPx fromView:self.graphContentView];
            CGFloat labelWidth = [xAxisTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, self.layout.xAxisLabelHeight)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:self.layout.xAxisLabelFont}
                                                          context:nil].size.width;
            labelWidth = MAX(MIN(labelWidth, 150), self.layout.xAxisIntervalInPx);
            UILabel *xAxisLabel = [[UILabel alloc] initWithFrame:CGRectMake(graphPointInPx.x - labelWidth/2,
                                                                            0,
                                                                            labelWidth,
                                                                            self.layout.xAxisLabelHeight)];
            xAxisLabel.backgroundColor = [UIColor clearColor];
            xAxisLabel.font = self.layout.xAxisLabelFont;
            xAxisLabel.textColor = self.layout.xAxisLabelColor;
            xAxisLabel.textAlignment = NSTextAlignmentCenter;
            xAxisLabel.text = xAxisTitle;
            xAxisLabel.numberOfLines = 2;
            [self.xAxisLabelsContainerView addSubview:xAxisLabel];
        }
    }
    else
    {
        NSNumber *xAxisValue = @(self.currentGraphPoint.point.x);
        NSString *xAxisTitle = self.currentGraphPoint.title;
        
        // Create xAxisLabel
        CGPoint graphPointInPx = graphPointInPx(CGPointMake([xAxisValue floatValue], 0));
        graphPointInPx = [self.xAxisLabelsContainerView convertPoint:graphPointInPx fromView:self.graphContentView];
        CGFloat labelWidth = [xAxisTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, self.layout.xAxisLabelHeight)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName:self.layout.xAxisLabelFont}
                                                      context:nil].size.width;
        labelWidth = MAX(MIN(labelWidth, 150), self.layout.xAxisIntervalInPx);
        
        CGFloat originX = graphPointInPx.x - labelWidth/2;
        originX = MIN(MAX(originX, 0), W(self.xAxisLabelsContainerView) - labelWidth);
        UILabel *xAxisLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX,
                                                                        0,
                                                                        labelWidth,
                                                                        self.layout.xAxisLabelHeight)];
        xAxisLabel.backgroundColor = [UIColor clearColor];
        xAxisLabel.font = self.layout.xAxisLabelFont;
        xAxisLabel.textColor = self.layout.xAxisLabelColor;
        xAxisLabel.textAlignment = NSTextAlignmentCenter;
        xAxisLabel.text = xAxisTitle;
        xAxisLabel.numberOfLines = 2;
        [self.xAxisLabelsContainerView addSubview:xAxisLabel];
    }
}

- (void)drawYAxisLabels
{
    // yAxisLabels Container View
    if (!self.yAxisLabelsContainerView) {
        self.yAxisLabelsContainerView = [[UIView alloc] init];
#if DEBUG_MODE
        self.yAxisLabelsContainerView.backgroundColor = [UIColor greenColor];
#else
        self.yAxisLabelsContainerView.backgroundColor = [UIColor clearColor];
#endif
        if (self.layout.xAxisScrollableOnly) {
            [self addSubview:self.yAxisLabelsContainerView];
        }
        else {
            [self.contentScrollView insertSubview:self.yAxisLabelsContainerView belowSubview:self.graphContentView];
        }
    }
    CGFloat positionY = self.layout.xAxisScrollableOnly ? maxfry(self.yAxisUnitLabel) : 0;
    self.yAxisLabelsContainerView.frame = CGRectMake(0,
                                                     positionY,
                                                     self.layout.yAxisLabelWidth,
                                                     H(self.yAxisLabelsContainerView.superview) - positionY);
    [[self.yAxisLabelsContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // yAxisLabels
    for (NSDictionary *yAxisValueDict in self.yAxisValues)
    {
        __block NSNumber *yAxisValue = nil;
        __block NSString *yAxisTitle = nil;
        [yAxisValueDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            yAxisValue = (NSNumber *)key;
            yAxisTitle = (NSString *)obj;
        }];
        
        // Create yAxisLabel
        CGPoint graphPointInPx = graphPointInPx(CGPointMake(0, [yAxisValue floatValue]));
        graphPointInPx = [self.yAxisLabelsContainerView convertPoint:graphPointInPx fromView:self.graphContentView];
        UILabel *yAxisLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                        graphPointInPx.y - self.layout.yAxisLabelHeight/2,
                                                                        self.layout.yAxisLabelWidth - 5,
                                                                        self.layout.yAxisLabelHeight)];
        yAxisLabel.backgroundColor = [UIColor clearColor];
        yAxisLabel.font = self.layout.yAxisLabelFont;
        yAxisLabel.textColor = self.layout.yAxisLabelColor;
        yAxisLabel.textAlignment = NSTextAlignmentRight;
        yAxisLabel.text = yAxisTitle;
        yAxisLabel.adjustsFontSizeToFitWidth = YES;
        yAxisLabel.minimumScaleFactor = 0.5;
        [self.yAxisLabelsContainerView addSubview:yAxisLabel];
    }
}

- (void)drawXAsisZero
{
    // Create xAxisZeroPath
    CGMutablePathRef xAxisZeroPath = CGPathCreateMutable();
    
    CGPoint zeroPoint = graphPointInPx(CGPointMake(0, self.yAxisMinValue));
    CGPathMoveToPoint(xAxisZeroPath, NULL, 0, zeroPoint.y);
    CGPathAddLineToPoint(xAxisZeroPath, NULL, W(self.graphContentView), zeroPoint.y);
    
    // Create xAxisZeroLayer
    if (!self.xAxisZeroLayer) {
        self.xAxisZeroLayer = [CAShapeLayer layer];
        self.xAxisZeroLayer.fillColor = [UIColor clearColor].CGColor;
        self.xAxisZeroLayer.backgroundColor = [UIColor clearColor].CGColor;
        [self.graphContentView.layer addSublayer:self.xAxisZeroLayer];
    }
    self.xAxisZeroLayer.frame = self.xAxisZeroLayer.superlayer.bounds;
    self.xAxisZeroLayer.lineWidth = self.layout.xAxisLinesWidth;
    self.xAxisZeroLayer.strokeColor = self.layout.xAxisLinesStrokeColor.CGColor;
    self.xAxisZeroLayer.lineDashPattern = self.layout.xAxisZeroDashLine ? @[@(2), @(1)] : nil;
    self.xAxisZeroLayer.path = xAxisZeroPath;
    CGPathRelease(xAxisZeroPath);
}

- (void)drawYAsisZero
{
    // Create yAxisZeroPath
    CGMutablePathRef yAxisZeroPath = CGPathCreateMutable();
    
    UIView *superView = self.layout.xAxisScrollableOnly ? self : self.graphContentView;
    CGPoint zeroPoint = [superView convertPoint:CGPointZero fromView:self.graphContentView];
    CGPathMoveToPoint(yAxisZeroPath, NULL, zeroPoint.x + self.layout.xAxisLinesWidth/2, zeroPoint.y);
    CGPathAddLineToPoint(yAxisZeroPath, NULL, zeroPoint.x + self.layout.xAxisLinesWidth/2, zeroPoint.y + H(self.graphContentView));
    
    // Create yAxisZeroLayer
    if (!self.yAxisZeroLayer) {
        self.yAxisZeroLayer = [CAShapeLayer layer];
        self.yAxisZeroLayer.fillColor = [UIColor clearColor].CGColor;
        self.yAxisZeroLayer.backgroundColor = [UIColor clearColor].CGColor;
        [superView.layer addSublayer:self.yAxisZeroLayer];
    }
    self.yAxisZeroLayer.frame = self.yAxisZeroLayer.superlayer.bounds;
    self.yAxisZeroLayer.lineWidth = self.layout.yAxisLinesWidth;
    self.yAxisZeroLayer.strokeColor = self.layout.yAxisLinesStrokeColor.CGColor;
    self.yAxisZeroLayer.lineDashPattern = self.layout.yAxisZeroDashLine ? @[@(2), @(1)] : nil;
    self.yAxisZeroLayer.path = yAxisZeroPath;
    CGPathRelease(yAxisZeroPath);
}

- (void)drawXAxisGrid
{
    // Create xAxisGridPath
    CGMutablePathRef xAxisGridPath = CGPathCreateMutable();
    
    for (NSDictionary *xAxisValueDict in self.yAxisValues)
    {
        __block NSNumber *xAxisValue = nil;
        [xAxisValueDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            xAxisValue = (NSNumber *)key;
        }];
        
        CGPoint convertedPoint = graphPointInPx(CGPointMake(0, [xAxisValue floatValue]));
        CGPathMoveToPoint(xAxisGridPath, NULL, 0, convertedPoint.y);
        CGPathAddLineToPoint(xAxisGridPath, NULL, W(self.graphContentView), convertedPoint.y);
    }
    
    // Create xAxisGridLayer
    if (!self.xAxisGridLayer) {
        self.xAxisGridLayer = [CAShapeLayer layer];
        self.xAxisGridLayer.fillColor = [UIColor clearColor].CGColor;
        self.xAxisGridLayer.backgroundColor = [UIColor clearColor].CGColor;
        [self.graphContentView.layer addSublayer:self.xAxisGridLayer];
    }
    self.xAxisGridLayer.frame = self.graphContentView.bounds;
    self.xAxisGridLayer.lineWidth = self.layout.xAxisLinesWidth;
    self.xAxisGridLayer.strokeColor = self.layout.xAxisLinesStrokeColor.CGColor;
    self.xAxisGridLayer.lineDashPattern = self.layout.xAxisGridDashLine ? @[@(2), @(1)] : nil;
    self.xAxisGridLayer.path = xAxisGridPath;
    CGPathRelease(xAxisGridPath);
}

- (void)drawYAxisGrid
{
    // Create xAxisGridPath
    CGMutablePathRef yAxisGridPath = CGPathCreateMutable();
    
    CGPoint leftPoint = CGPointZero;
    CGPathMoveToPoint(yAxisGridPath, NULL, leftPoint.x + self.layout.xAxisLinesWidth/2, 0);
    CGPathAddLineToPoint(yAxisGridPath, NULL, leftPoint.x + self.layout.xAxisLinesWidth/2, H(self.graphContentView));
    
    for (NSDictionary *yAxisValueDict in self.xAxisValues)
    {
        __block NSNumber *yAxisValue = nil;
        [yAxisValueDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            yAxisValue = (NSNumber *)key;
        }];
        
        CGPoint convertedPoint = graphPointInPx(CGPointMake([yAxisValue floatValue], 0));
        CGPathMoveToPoint(yAxisGridPath, NULL, convertedPoint.x, 0);
        CGPathAddLineToPoint(yAxisGridPath, NULL, convertedPoint.x, H(self.graphContentView));
    }
    
    if (self.layout.xAxisScrollableOnly) {
        CGPoint rightPoint = CGPointMake(W(self.graphContentView) - self.layout.xAxisLinesWidth, 0);
        CGPathMoveToPoint(yAxisGridPath, NULL, rightPoint.x + self.layout.xAxisLinesWidth/2, 0);
        CGPathAddLineToPoint(yAxisGridPath, NULL, rightPoint.x + self.layout.xAxisLinesWidth/2, H(self.graphContentView));
    }
    
    // Create yAxisGridLayer
    if (!self.yAxisGridLayer) {
        self.yAxisGridLayer = [CAShapeLayer layer];
        self.yAxisGridLayer.fillColor = [UIColor clearColor].CGColor;
        self.yAxisGridLayer.backgroundColor = [UIColor clearColor].CGColor;
        [self.graphContentView.layer addSublayer:self.yAxisGridLayer];
    }
    self.yAxisGridLayer.frame = self.graphContentView.bounds;
    self.yAxisGridLayer.lineWidth = self.layout.yAxisLinesWidth;
    self.yAxisGridLayer.strokeColor = self.layout.yAxisLinesStrokeColor.CGColor;
    self.yAxisGridLayer.lineDashPattern = self.layout.yAxisGridDashLine ? @[@(2), @(1)] : nil;
    self.yAxisGridLayer.path = yAxisGridPath;
    CGPathRelease(yAxisGridPath);
}

- (void)drawPlots
{
    // Remove previous plot content views and layers
    [[self.graphContentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSMutableArray *layersToRemove = [NSMutableArray new];
    for (CALayer *layer in self.graphContentView.layer.sublayers)
    {
        BOOL canRemove = [layer.name isEqualToString:@"backgroundPlotLayer"] || [layer.name isEqualToString:@"linePlotLayer"];
        if (canRemove) {
            [layersToRemove addObject:layer];
        }
    }
    for (CALayer *layer in layersToRemove) {
        [layer removeFromSuperlayer];
    }
    
    // Start to draw
    for (LMGraphPlot *graphPlot in self.graphPlots)
    {
        // Create Background Plot & Line Plot Path
        CGMutablePathRef backgroundPlotPath = CGPathCreateMutable();
        CGMutablePathRef linePlotPath = CGPathCreateMutable();
        for (int i = 0; i < graphPlot.graphPoints.count; i++)
        {
            LMGraphPoint *graphPoint = [graphPlot.graphPoints objectAtIndex:i];
            CGPoint convertedPoint = graphPointInPx(graphPoint.point);
            LMGraphPoint *preGraphPoint = graphPoint;
            CGPoint convertedPrePoint = convertedPoint;
            if (i > 0) {
                preGraphPoint = [graphPlot.graphPoints objectAtIndex:i-1];
                convertedPrePoint = graphPointInPx(preGraphPoint.point);
            }
            
            // Move to zero start point
            if (i == 0) {
                CGPathMoveToPoint(backgroundPlotPath, NULL, 0, self.layout.startPlotFromZero ? H(self.graphContentView) : convertedPoint.y);
                CGPathMoveToPoint(linePlotPath, NULL, 0, self.layout.startPlotFromZero ? H(self.graphContentView) : convertedPoint.y);
            }
            
            if (graphPlot.curveLine)
            {
                // Draw curve line
                CGPoint midPoint = midPointForPoints(convertedPrePoint, convertedPoint);
                CGPoint cp1 = controlPointForPoints(midPoint, convertedPrePoint);
                CGPoint cp2 = controlPointForPoints(midPoint, convertedPoint);
                CGPathAddQuadCurveToPoint(backgroundPlotPath, NULL, cp1.x, cp1.y, midPoint.x, midPoint.y);
                CGPathAddQuadCurveToPoint(backgroundPlotPath, NULL, cp2.x, cp2.y, convertedPoint.x, convertedPoint.y);
                CGPathAddQuadCurveToPoint(linePlotPath, NULL, cp1.x, cp1.y, midPoint.x, midPoint.y);
                CGPathAddQuadCurveToPoint(linePlotPath, NULL, cp2.x, cp2.y, convertedPoint.x, convertedPoint.y);
            }
            else
            {
                // Draw line to graph point
                CGPathAddLineToPoint(backgroundPlotPath, NULL, convertedPoint.x, convertedPoint.y);
                CGPathAddLineToPoint(linePlotPath, NULL, convertedPoint.x, convertedPoint.y);
            }
            
            // Draw last line
            if (i == graphPlot.graphPoints.count - 1) {
                CGPathAddLineToPoint(backgroundPlotPath, NULL, W(self.graphContentView), convertedPoint.y);
                CGPathAddLineToPoint(linePlotPath, NULL, W(self.graphContentView), convertedPoint.y);
                
                // Close subpath of backgroundPlotPath
                CGPathAddLineToPoint(backgroundPlotPath, NULL, W(self.graphContentView), H(self.graphContentView));
                CGPathAddLineToPoint(backgroundPlotPath, NULL, 0, H(self.graphContentView));
                CGPathCloseSubpath(backgroundPlotPath);
            }
        }
        
        // Create Background Plot Layer
        CAShapeLayer *backgroundPlotLayer = [CAShapeLayer layer];
        backgroundPlotLayer.name = @"backgroundPlotLayer";
        backgroundPlotLayer.frame = self.graphContentView.bounds;
        backgroundPlotLayer.fillColor = graphPlot.fillColor.CGColor;
        backgroundPlotLayer.backgroundColor = [UIColor clearColor].CGColor;
        backgroundPlotLayer.strokeColor = [UIColor clearColor].CGColor;
        [self.graphContentView.layer addSublayer:backgroundPlotLayer];
        
        // Create Line Plot Layer
        CAShapeLayer *linePlotLayer = [CAShapeLayer layer];
        linePlotLayer.name = @"linePlotLayer";
        linePlotLayer.frame = self.graphContentView.bounds;
        linePlotLayer.fillColor = [UIColor clearColor].CGColor;
        linePlotLayer.backgroundColor = [UIColor clearColor].CGColor;
        linePlotLayer.strokeColor = graphPlot.strokeColor.CGColor;
        linePlotLayer.lineWidth = graphPlot.lineWidth;
        [self.graphContentView.layer addSublayer:linePlotLayer];
        
        // Draw graph points
        if (graphPlot.graphPointSize > 0)
        {
            for (int i = 0; i < graphPlot.graphPoints.count; i++)
            {
                LMGraphPoint *graphPoint = [graphPlot.graphPoints objectAtIndex:i];
                CGPoint convertedPoint = graphPointInPx(graphPoint.point);
                CGRect frame = CGRectMake(convertedPoint.x - graphPlot.graphPointSize/2.0,
                                          convertedPoint.y - graphPlot.graphPointSize/2.0,
                                          graphPlot.graphPointSize,
                                          graphPlot.graphPointSize);
                
                // Draw circle around graph point
                if (graphPlot.fillCircleAroundGraphPoint) {
                    CGPathAddEllipseInRect(backgroundPlotPath, NULL, CGRectInset(frame, -graphPlot.lineWidth, -graphPlot.lineWidth));
                    CGPathMoveToPoint(backgroundPlotPath, NULL, convertedPoint.x, convertedPoint.y);
                }
                if (graphPlot.strokeCircleAroundGraphPoint) {
                    CGPathAddEllipseInRect(linePlotPath, NULL, CGRectInset(frame, -graphPlot.lineWidth/2, -graphPlot.lineWidth/2));
                    CGPathMoveToPoint(linePlotPath, NULL, convertedPoint.x, convertedPoint.y);
                }
                
                // Create Graph Point View
                LMGraphPointView *graphPointView = [[LMGraphPointView alloc] initWithFrame:frame
                                                                                graphPoint:graphPoint
                                                                                     color:graphPlot.graphPointColor
                                                                            highlightColor:graphPlot.graphPointHighlightColor];
                [self.graphContentView addSubview:graphPointView];
            }
        }
        
        // Update Background Plot & Line Plot Path
        backgroundPlotLayer.path = backgroundPlotPath;
        linePlotLayer.path = linePlotPath;
        CGPathRelease(backgroundPlotPath);
        CGPathRelease(linePlotPath);
    }
}

- (void)handleDrawMovement
{
    if (self.isMovement && self.currentGraphPoint)
    {
        CGPoint point = graphPointInPx(self.currentGraphPoint.point);
        
        // Create touchPath
        CGMutablePathRef touchPath = CGPathCreateMutable();
        CGPathMoveToPoint(touchPath, NULL, point.x, 0);
        CGPathAddLineToPoint(touchPath, NULL, point.x, point.y - 5);
        CGPathMoveToPoint(touchPath, NULL, point.x, point.y);
        CGPathAddEllipseInRect(touchPath, NULL, CGRectMake(point.x - 5, point.y - 5, 10, 10));
        CGPathMoveToPoint(touchPath, NULL, point.x, point.y + 5);
        CGPathAddLineToPoint(touchPath, NULL, point.x, H(self.graphContentView));
        
        // Create touchLayer
        if (!self.touchLayer) {
            self.touchLayer = [CAShapeLayer layer];
            self.touchLayer.backgroundColor = [UIColor clearColor].CGColor;
            [self.graphContentView.layer addSublayer:self.touchLayer];
        }
        CGFloat maxZPosition = 0;
        for (CALayer *layer in self.graphContentView.layer.sublayers) {
            maxZPosition = (layer.zPosition > maxZPosition) ? layer.zPosition : maxZPosition;
        }
        self.touchLayer.zPosition = maxZPosition + 1;
        self.touchLayer.frame = self.graphContentView.bounds;
        self.touchLayer.lineWidth = self.layout.movementLineWidth;
        self.touchLayer.fillColor = self.layout.movementDotColor.CGColor;
        self.touchLayer.strokeColor = self.layout.movementLineColor.CGColor;
        self.touchLayer.path = touchPath;
        CGPathRelease(touchPath);
    }
    else
    {
        self.touchLayer.path = nil;
    }
}


#pragma mark - TOUCH EVENTS

- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if (!self.layout.xAxisScrollableOnly && self.layout.drawMovement) {
        return;
    }
    
    CGPoint tapPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGPoint convertedTapPoint = [self.graphContentView convertPoint:tapPoint fromView:self];
    
    for (UIView *view in self.graphContentView.subviews) {
        if ([view isKindOfClass:[LMGraphPointView class]]) {
            [((LMGraphPointView *)view) setIsSelected:NO];
        }
    }
    
    LMGraphPointView *selectedGraphPointView = [self graphPointViewWithTouchPoint:convertedTapPoint];
    if (selectedGraphPointView)
    {
        [selectedGraphPointView setIsSelected:YES];
        
        if (selectedGraphPointView.graphPoint)
        {
            UIButton *popoverButton = [UIButton buttonWithType:UIButtonTypeSystem];
            popoverButton.frame = CGRectMake(0, 0, 80, 30);
            [popoverButton.titleLabel setNumberOfLines:2];
            [popoverButton setBackgroundColor:[UIColor clearColor]];
            [popoverButton setTitle:selectedGraphPointView.graphPoint.value forState:UIControlStateNormal];
            [popoverButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [popoverButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [popoverButton sizeToFit];
            
            CGPoint point = [self convertPoint:selectedGraphPointView.center fromView:self.graphContentView];
            [PopoverView showPopoverAtPoint:CGPointMake(point.x, point.y)
                                     inView:self
                            withContentView:popoverButton
                                  isFitView:NO
                                   delegate:nil];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.layout.xAxisScrollableOnly || !self.layout.drawMovement) {
        return;
    }
    
    self.isMovement = YES;
    CGPoint point = [[touches anyObject] locationInView:self.graphContentView];
    point.x = MAX(0, MIN(point.x, W(self.graphContentView)));
    self.currentGraphPoint = [self graphPointFromTouchPoint:point];
    
    // Draw movement
    [self handleDrawMovement];
    
    // Update xAxisLabels
    [self drawXAxisLabels];
    
    // Delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(lineGraphView:beganTouchWithGraphPoint:)]) {
        [self.delegate lineGraphView:self beganTouchWithGraphPoint:self.currentGraphPoint];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.layout.xAxisScrollableOnly || !self.layout.drawMovement) {
        return;
    }
    
    CGPoint point = [[touches anyObject] locationInView:self.graphContentView];
    point.x = MAX(0, MIN(point.x, W(self.graphContentView)));
    self.currentGraphPoint = [self graphPointFromTouchPoint:point];
    
    // Draw movement
    [self handleDrawMovement];
    
    // Update xAxisLabels
    [self drawXAxisLabels];
    
    // Delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(lineGraphView:moveTouchWithGraphPoint:)]) {
        [self.delegate lineGraphView:self moveTouchWithGraphPoint:self.currentGraphPoint];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.layout.xAxisScrollableOnly || !self.layout.drawMovement) {
        return;
    }
    
    self.isMovement = NO;
    CGPoint point = [[touches anyObject] locationInView:self.graphContentView];
    point = CGPointMake(MAX(0, MIN(point.x, W(self.graphContentView))), -1);
    self.currentGraphPoint = [self graphPointFromTouchPoint:point];
    
    // Draw movement
    [self handleDrawMovement];
    
    // Update xAxisLabels
    [self drawXAxisLabels];
    
    // Delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(lineGraphView:endTouchWithGraphPoint:)]) {
        [self.delegate lineGraphView:self endTouchWithGraphPoint:self.currentGraphPoint];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}


#pragma mark - SUPPORT

- (void)calculateGraphData
{
    // Calculate yAxisMaxValue if needed
    if (self.yAxisMaxValue == 0) {
        CGFloat yAxisMaxValue = -MAXFLOAT;
        for (LMGraphPlot *graphPlot in self.graphPlots) {
            for (LMGraphPoint *graphPoint in graphPlot.graphPoints) {
                if (yAxisMaxValue < graphPoint.point.y) {
                    yAxisMaxValue = graphPoint.point.y;
                }
            }
        }
        self.yAxisMaxValue = yAxisMaxValue;
    }
    
    // Calculate xAxisMaxValue
    CGFloat xAxisMaxValue = -MAXFLOAT;
    for (NSDictionary *xAxisValueDict in self.xAxisValues)
    {
        __block NSNumber *xAxisValue = nil;
        [xAxisValueDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            xAxisValue = (NSNumber *)key;
        }];
        
        if (xAxisMaxValue < [xAxisValue doubleValue]) {
            xAxisMaxValue = [xAxisValue doubleValue];
        }
    }
    self.xAxisMaxValue = xAxisMaxValue;
    
    // Check validDataToDraw
    if (self.layout.yAxisSegmentCount <= 0
        || self.yAxisMaxValue <= 0
        || (H(self.graphContentView) - self.layout.yAxisLinesWidth <= 0)
        || self.xAxisValues.count == 0) {
        self.validGraphData = NO;
        return;
    }
    else {
        self.validGraphData = YES;
    }
    
    // Calculate xAxisIntervalInPx
    if (!self.layout.xAxisScrollableOnly && self.xAxisValues.count) {
        self.layout.xAxisIntervalInPx = MAX(W(self.graphContentView)/(self.xAxisValues.count - 1), 5);
    }
    
    // Calculate yAxisInterval
    self.yAxisInterval = (self.yAxisMaxValue - self.yAxisMinValue) / self.layout.yAxisSegmentCount;
    
    // Calculate yAxisIntervalInPx
    self.yAxisIntervalInPx = (H(self.graphContentView) - self.layout.yAxisLinesWidth)/self.layout.yAxisSegmentCount;
    
    // Calculate yAxisValues
    NSMutableArray *yAxisValues = [NSMutableArray array];
    for (int i = 0; i < self.layout.yAxisSegmentCount + 1; i++)
    {
        double yAxisValue = (self.yAxisInterval * i) + self.yAxisMinValue;
        
        NSString *yAxisValueTitle;
        if (self.delegate && [self.delegate respondsToSelector:@selector(lineGraphView:yAxisLabelTitleFromValue:index:)]) {
            yAxisValueTitle = [self.delegate lineGraphView:self yAxisLabelTitleFromValue:yAxisValue index:i];
        }
        else {
            if (yAxisValue < 1 && yAxisValue != 0) {
                yAxisValueTitle = [NSString stringWithFormat:@"%f", yAxisValue];
            }
            else {
                static NSNumberFormatter *numberFormatter = nil;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    numberFormatter = [[NSNumberFormatter alloc] init];
                    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                    numberFormatter.maximumFractionDigits = 0;
                    numberFormatter.locale = [NSLocale currentLocale];
                });
                yAxisValueTitle = [numberFormatter stringFromNumber:@(yAxisValue)];
            }
        }
        
        if (self.yAxisSuffix) {
            yAxisValueTitle = [yAxisValueTitle stringByAppendingString:self.yAxisSuffix];
        }
        
        NSDictionary *finalYAxisValue = @{@(yAxisValue) : yAxisValueTitle ? yAxisValueTitle : @""};
        [yAxisValues addObject:finalYAxisValue];
    }
    self.yAxisValues = yAxisValues;
}

- (CGPoint)graphPointInPxFromGraphPoint:(CGPoint)graphPoint
{
    CGFloat convertedX = 0;
    CGFloat convertedY = 0;
    
    CGFloat realGraphPointX = graphPoint.x - self.xAxisStartGraphPoint;
    convertedX = (realGraphPointX/self.xAxisInterval) * self.layout.xAxisIntervalInPx + self.layout.xAxisLinesWidth/2;
    
    convertedY = ((graphPoint.y - self.yAxisMinValue)/self.yAxisInterval) * self.yAxisIntervalInPx + self.layout.yAxisLinesWidth/2;
    convertedY = H(self.graphContentView) - convertedY;
    
    return CGPointMake(convertedX, convertedY);
}

- (LMGraphPoint *)graphPointFromTouchPoint:(CGPoint)touchPoint
{
    LMGraphPlot *graphPlot = [self.graphPlots firstObject];
    
    CGFloat interval = MAX(W(self.graphContentView)/(graphPlot.graphPoints.count - 1), 1);
    NSInteger index = round(touchPoint.x/interval);
    index = MIN(MAX(index, 0), graphPlot.graphPoints.count - 1);
    
    LMGraphPoint *graphPoint = [graphPlot.graphPoints objectAtIndex:index];
    return graphPoint;
}

- (LMGraphPointView *)graphPointViewWithTouchPoint:(CGPoint)touchPoint
{
    for (UIView *view in self.graphContentView.subviews)
    {
        if ([view isKindOfClass:[LMGraphPointView class]])
        {
            LMGraphPointView *graphPointView = (LMGraphPointView *)view;
            if (CGRectContainsPoint(CGRectInset(graphPointView.frame, -5, -5), touchPoint)) {
                return graphPointView;
            }
        }
    }
    return nil;
}

static CGPoint midPointForPoints(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
}

static CGPoint controlPointForPoints(CGPoint p1, CGPoint p2)
{
    CGPoint controlPoint = midPointForPoints(p1, p2);
    CGFloat diffY = fabs(p2.y - controlPoint.y);
    
    if (p1.y < p2.y)
        controlPoint.y += diffY;
    else if (p1.y > p2.y)
        controlPoint.y -= diffY;
    
    return controlPoint;
}


#pragma mark - PUBLIC

- (void)animateWithDuration:(NSTimeInterval)duration
{
    [self.graphContentView.layer removeAllAnimations];
    
    for (CAShapeLayer *layer in self.graphContentView.layer.sublayers) {
        if ([layer.name isEqualToString:@"linePlotLayer"]) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation.duration = duration;
            animation.fromValue = @(0.0);
            animation.toValue = @(1.0);
            [layer addAnimation:animation forKey:@"strokeEnd"];
        }
    }
}

- (UIImage *)graphImage
{
    CGFloat scale = 1;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [[UIScreen mainScreen] scale];
    }
    
    if (scale > 1) {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, scale);
    }
    else {
        UIGraphicsBeginImageContext(self.frame.size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext: context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

