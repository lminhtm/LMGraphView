//
//  ViewController.m
//  LMGraphViewDemo
//
//  Created by LMinh on 7/25/15.
//  Copyright (c) 2015 LMinh. All rights reserved.
//

#import "LMViewController.h"
#import "LMLineGraphView.h"

@interface LMViewController () <LMLineGraphViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet LMLineGraphView *lineGraphView1;
@property (weak, nonatomic) IBOutlet LMLineGraphView *lineGraphView2;
@property (weak, nonatomic) IBOutlet LMLineGraphView *lineGraphView3;
@property (weak, nonatomic) IBOutlet LMLineGraphView *lineGraphView4;

@end

@implementation LMViewController

#pragma mark - VIEW LIFECYCLES

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Generate sample data
    NSArray *xAxisValues = [self xAxisValues];
    NSArray *shortXAxisValues = [self shortXAxisValues];
    LMGraphPlot *plot1 = [self sampleGraphPlot1];
    LMGraphPlot *plot2 = [self sampleGraphPlot2];
    LMGraphPlot *plot3 = [self sampleGraphPlot3];
    LMGraphPlot *plot4 = [self sampleGraphPlot4];
    
    // Line Graph View 1
    self.lineGraphView1.layout.xAxisScrollableOnly = YES;
    self.lineGraphView1.xAxisValues = xAxisValues;
    self.lineGraphView1.yAxisMaxValue = 90;
    self.lineGraphView1.yAxisUnit = @"(customer)";
    self.lineGraphView1.title = @"MONTHLY CUSTOMER";
    self.lineGraphView1.graphPlots = @[plot1, plot2];
    
    // Line Graph View 2
    self.lineGraphView2.layout.xAxisScrollableOnly = NO;
    self.lineGraphView2.layout.drawMovement = NO;
    self.lineGraphView2.xAxisValues = shortXAxisValues;
    self.lineGraphView2.yAxisMaxValue = 90;
    self.lineGraphView2.yAxisUnit = @"(customer)";
    self.lineGraphView2.title = @"MONTHLY CUSTOMER";
    self.lineGraphView2.graphPlots = @[plot3];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.lineGraphView2 animateWithDuration:2];
    });
    
    // Line Graph View 3
    self.lineGraphView3.layout.xAxisScrollableOnly = YES;
    self.lineGraphView3.xAxisValues = xAxisValues;
    self.lineGraphView3.yAxisMaxValue = 90;
    self.lineGraphView3.yAxisUnit = @"(customer)";
    self.lineGraphView3.title = @"MONTHLY CUSTOMER";
    self.lineGraphView3.graphPlots = @[plot3];
    
    // Line Graph View 4
    self.lineGraphView4.backgroundColor = [UIColor blackColor];
    self.lineGraphView4.layout.xAxisScrollableOnly = NO;
    self.lineGraphView4.delegate = self;
    self.lineGraphView4.xAxisValues = shortXAxisValues;
    self.lineGraphView4.yAxisMaxValue = 90;
    self.lineGraphView4.yAxisMinValue = 10;
    self.lineGraphView4.yAxisUnit = @"(customer)";
    self.lineGraphView4.title = @"MONTHLY CUSTOMER";
    self.lineGraphView4.layout.titleLabelColor = [UIColor whiteColor];
    self.lineGraphView4.layout.xAxisLabelColor = [UIColor whiteColor];
    self.lineGraphView4.layout.yAxisLabelColor = [UIColor whiteColor];
    self.lineGraphView4.layout.yAxisUnitLabelColor = [UIColor whiteColor];
    self.lineGraphView4.graphPlots = @[plot4];
}


#pragma mark - LINE GRAPH VIEW DELEGATE

- (void)lineGraphView:(LMLineGraphView *)lineGraphView beganTouchWithGraphPoint:(LMGraphPoint *)graphPoint
{
    self.scrollView.scrollEnabled = NO;
}

- (void)lineGraphView:(LMLineGraphView *)lineGraphView moveTouchWithGraphPoint:(LMGraphPoint *)graphPoint
{
    
}

- (void)lineGraphView:(LMLineGraphView *)lineGraphView endTouchWithGraphPoint:(LMGraphPoint *)graphPoint
{
    self.scrollView.scrollEnabled = YES;
}


#pragma mark - SUPPORT

- (NSArray *)xAxisValues
{
    return @[@{ @1 : @"JAN" },
             @{ @2 : @"FEB" },
             @{ @3 : @"MAR" },
             @{ @4 : @"APR" },
             @{ @5 : @"MAY" },
             @{ @6 : @"JUN" },
             @{ @7 : @"JUL" },
             @{ @8 : @"AUG" },
             @{ @9 : @"SEP" },
             @{ @10 : @"OCT" },
             @{ @11 : @"NOV" },
             @{ @12 : @"DEC" }];
}

- (NSArray *)shortXAxisValues
{
    return @[@{ @1 : @"1" },
             @{ @2 : @"2" },
             @{ @3 : @"3" },
             @{ @4 : @"4" },
             @{ @5 : @"5" },
             @{ @6 : @"6" },
             @{ @7 : @"7" },
             @{ @8 : @"8" },
             @{ @9 : @"9" },
             @{ @10 : @"10" },
             @{ @11 : @"11" },
             @{ @12 : @"12" }];
}

- (LMGraphPlot *)sampleGraphPlot1
{
    LMGraphPlot *plot1 = [[LMGraphPlot alloc] init];
    plot1.strokeColor = [UIColor colorWithRed:11.0/255 green:150.0/255 blue:246.0/255 alpha:0.9];
    plot1.fillColor = [UIColor colorWithRed:11.0/255 green:150.0/255 blue:246.0/255 alpha:0.5];
    plot1.graphPointColor = [UIColor whiteColor];
    plot1.graphPointHighlightColor = plot1.fillColor;
    plot1.graphPoints = @[LMGraphPointMake(CGPointMake(1, 47), @"1", @"47"),
                          LMGraphPointMake(CGPointMake(2, 69), @"2", @"69"),
                          LMGraphPointMake(CGPointMake(3, 77), @"3", @"77"),
                          LMGraphPointMake(CGPointMake(4, 60), @"4", @"60"),
                          LMGraphPointMake(CGPointMake(5, 59), @"5", @"59"),
                          LMGraphPointMake(CGPointMake(6, 40), @"6", @"40"),
                          LMGraphPointMake(CGPointMake(7, 60), @"7", @"60"),
                          LMGraphPointMake(CGPointMake(8, 45), @"8", @"45"),
                          LMGraphPointMake(CGPointMake(9, 50), @"9", @"50"),
                          LMGraphPointMake(CGPointMake(10, 70), @"10", @"70"),
                          LMGraphPointMake(CGPointMake(11, 56), @"11", @"56"),
                          LMGraphPointMake(CGPointMake(12, 30), @"12", @"30")];
    return plot1;
}

- (LMGraphPlot *)sampleGraphPlot2
{
    LMGraphPlot *plot2 = [[LMGraphPlot alloc] init];
    plot2.strokeColor = [UIColor colorWithRed:255/255.0 green:130/255.0 blue:166/255.0 alpha:0.9];
    plot2.fillColor = [UIColor colorWithRed:255/255.0 green:130/255.0 blue:166/255.0 alpha:0.5];
    plot2.graphPointColor = [UIColor whiteColor];
    plot2.graphPointHighlightColor = plot2.strokeColor;
    plot2.graphPoints = @[LMGraphPointMake(CGPointMake(1, 25), @"1", @"25"),
                          LMGraphPointMake(CGPointMake(2, 20), @"2", @"20"),
                          LMGraphPointMake(CGPointMake(3, 30), @"3", @"30"),
                          LMGraphPointMake(CGPointMake(4, 30), @"4", @"30"),
                          LMGraphPointMake(CGPointMake(5, 35), @"5", @"35"),
                          LMGraphPointMake(CGPointMake(6, 30), @"6", @"30"),
                          LMGraphPointMake(CGPointMake(7, 25), @"7", @"25"),
                          LMGraphPointMake(CGPointMake(8, 30), @"8", @"30"),
                          LMGraphPointMake(CGPointMake(9, 40), @"9", @"40"),
                          LMGraphPointMake(CGPointMake(10, 15), @"10", @"15"),
                          LMGraphPointMake(CGPointMake(11, 30), @"11", @"30"),
                          LMGraphPointMake(CGPointMake(12, 50), @"12", @"50")];
    return plot2;
}

- (LMGraphPlot *)sampleGraphPlot3
{
    LMGraphPlot *plot3 = [[LMGraphPlot alloc] init];
    plot3.strokeColor = [UIColor brownColor];
    plot3.fillColor = [UIColor clearColor];
    plot3.graphPointColor = [UIColor brownColor];
    
    NSMutableArray *graphPoints = [NSMutableArray new];
    for (int i = 1; i <= 12; i++) {
        CGFloat value = rand() % 60 + 20;
        NSString *titleString = [NSString stringWithFormat:@"%d", i];
        NSString *valueString = [NSString stringWithFormat:@"%d", (int)value];
        LMGraphPoint *graphPoint = LMGraphPointMake(CGPointMake(i, value), titleString, valueString);
        [graphPoints addObject:graphPoint];
    }
    plot3.graphPoints = graphPoints;
    
    return plot3;
}

- (LMGraphPlot *)sampleGraphPlot4
{
    LMGraphPlot *plot4 = [[LMGraphPlot alloc] init];
    plot4.graphPointSize = 0;
    plot4.fillCircleAroundGraphPoint = NO;
    plot4.strokeCircleAroundGraphPoint = NO;
    plot4.curveLine = YES;
    plot4.strokeColor = [UIColor whiteColor];
    plot4.fillColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    plot4.graphPointColor = [UIColor whiteColor];
    plot4.graphPointHighlightColor = [UIColor redColor];
    
    NSMutableArray *graphPoints = [NSMutableArray new];
    for (CGFloat i = 1; i <= 12; i += 0.25) {
        CGFloat value = rand() % 50 + 30;
        NSString *titleString = [NSString stringWithFormat:@"%.2f", i];
        NSString *valueString = [NSString stringWithFormat:@"%d", (int)value];
        LMGraphPoint *graphPoint = LMGraphPointMake(CGPointMake(i, value), titleString, valueString);
        [graphPoints addObject:graphPoint];
    }
    plot4.graphPoints = graphPoints;
    
    return plot4;
}

@end
