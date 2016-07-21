 //
//  LEOVitalGraphViewController.m
//  Leo
//
//  Created by Zachary Drossman on 4/7/16.
//  Copyright © 2016 Leo Health. All rights reserved.
//

#import "LEOVitalGraphViewController.h"
#import "UIColor+LeoColors.h"
#import "UIFont+LeoFonts.h"
#import "LEOVitalGraphDataSource.h"
#import <NSDate+DateTools.h>
#import "PatientVitalMeasurement.h"
#import "NSDate+Extensions.h"
#import "NSString+Extensions.h"
#import <GNZSlidingSegment/GNZSegmentedControl.h>
#import "Patient.h"
#import "HealthRecord.h"
#import "LEOVitalScoreboardView.h"

@interface LEOVitalGraphViewController ()

@property (weak, nonatomic) TKChart *chart;
@property (weak, nonatomic) UISegmentedControl *metricControl;
@property (weak, nonatomic) LEOVitalScoreboardView *scoreboardView;

@property (copy, nonatomic) NSArray *coordinateData;
@property (copy, nonatomic) NSArray *placeholderData;
@property (copy, nonatomic) NSArray *selectedDataSet;
@property (strong, nonatomic) NSNumber *selectedDataPointIndex;
@property (strong, nonatomic) LEOVitalGraphDataSource *dataSource;
@property (copy, nonatomic) GraphSeriesConfigureBlock seriesBlock;

@property (copy, nonatomic) NSArray *horizontalLayoutConstraintsForScoreboardView;
@property (copy, nonatomic) NSArray *verticalLayoutConstraints;

@property (nonatomic) BOOL alreadyUpdatedConstraints;

@end

@implementation LEOVitalGraphViewController

static NSInteger const kVitalGraphMinDaysBeforeOrAfter = 1;
static CGFloat const kNumberOfSectionsSeparatedByLinesOnGraph = 3.0;

static NSInteger const kScoreboardHeight = 65;
static NSInteger const kChartHeight = 160;

#pragma mark - View Controller Lifecycle

- (instancetype)initWithPatient:(Patient *)patient {

    self = [super initWithNibName:nil bundle:nil];

    if (self) {

        _patient = patient;

    }

    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    self.dataSource = [[LEOVitalGraphDataSource alloc] initWithDataSet:[self selectedDataSet] seriesIdentifier:@"series" configureSeriesBlock:self.seriesBlock dataXValue:@"takenAt" dataYValue:@"value"];

    self.chart.delegate = self;
    self.chart.dataSource = self.dataSource;

    [self formatChart];
    [self reloadWithUIUpdates];

    [self setupScoreboardViewWithVital:self.selectedDataSet.firstObject];
}

- (void)setupScoreboardViewWithVital:(PatientVitalMeasurement *)vital {

    [self.scoreboardView removeFromSuperview];

    self.scoreboardView = nil;

    LEOVitalScoreboardView *strongVitalStatView = [[LEOVitalScoreboardView alloc] initWithVital:vital forPatient:self.patient];

    self.scoreboardView = strongVitalStatView;

    [self.view addSubview:self.scoreboardView];
}

- (void)formatChart {

    self.chart.insets = UIEdgeInsetsZero;

    TKChartGridStyle *gridStyle = _chart.gridStyle;

    gridStyle.horizontalFill = [TKSolidFill solidFillWithColor:[UIColor leo_gray251]];
    gridStyle.horizontalAlternateFill = [TKSolidFill solidFillWithColor:[UIColor leo_gray251]];
    gridStyle.horizontalLineStroke = [TKStroke strokeWithColor:[UIColor leo_gray211]];
    gridStyle.horizontalLineAlternateStroke = [TKStroke strokeWithColor:[UIColor leo_gray211]];
}


#pragma mark - Accessors

- (TKChart *)chart {

    if (!_chart) {

        TKChart *strongChart = [TKChart new];

        _chart = strongChart;
        _chart.allowAnimations = YES;
        _chart.allowTrackball = YES;
        _chart.trackball.minimumPressDuration = 0.01;

        [self setupTrackball:_chart.trackball];

        [self.view addSubview:_chart];
    }
    
    return _chart;
}

- (void)setupTrackball:(TKChartTrackball *)trackball {

    CGSize size = CGSizeMake(8, 8);
    TKPredefinedShape *shape =
    [[TKPredefinedShape alloc] initWithType:TKShapeTypeCircle
                                    andSize:size];

    TKChartCrossLineAnnotationStyle *style = trackball.line.style;

    style.verticalLineStroke =
    [TKStroke strokeWithColor:[UIColor leo_orangeRed]
                        width:1.0];
    style.pointShapeFill =
    [TKSolidFill solidFillWithColor:[UIColor leo_orangeRed]];

    style.pointShapeStroke =
    [TKStroke strokeWithColor:[UIColor leo_orangeRed]];

    style.pointShape = shape;

    trackball.tooltip.hidden = YES;
}

- (UISegmentedControl *)metricControl {

    if (!_metricControl) {

        UISegmentedControl *strongSegmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Weight", @"Height"]];

        _metricControl = strongSegmentControl;

        _metricControl.selectedSegmentIndex = 0;

        [_metricControl addTarget:self action:@selector(reloadWithUIUpdates) forControlEvents:UIControlEventValueChanged];

        _metricControl.tintColor = [UIColor leo_orangeRed];

        NSDictionary *normalAttributes = @{ NSFontAttributeName :
                                                     [UIFont leo_regular15], NSForegroundColorAttributeName :
                                                     [UIColor leo_orangeRed]
                                            };


        [_metricControl setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];

        NSDictionary *highlightedAttributes = @{ NSFontAttributeName :
                                                     [UIFont leo_regular15], NSForegroundColorAttributeName :
                                                     [UIColor leo_white]};

        [_metricControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateSelected];

        [self.view addSubview:_metricControl];
    }

    return _metricControl;
}

- (void)setPatient:(Patient *)patient {

    _patient = patient;

    [self reloadWithUIUpdates];
}

#pragma mark - Dataset Helpers

-(NSArray *)coordinateData {

    NSInteger countDataSets = self.patient.healthRecord.timeSeries.count;
    NSInteger selectedSegmentIndex = self.metricControl.selectedSegmentIndex;

    if (countDataSets > selectedSegmentIndex) {

        return self.patient.healthRecord.timeSeries[selectedSegmentIndex];
    }

    return nil;
}

- (NSArray *)selectedDataSet {
    return self.coordinateData ? : nil;
}


#pragma mark - Axis helpers

- (id)graphXStartPoint {

    NSInteger daysInset =
    [self rangeInsetXWithStartDate:[[self selectedDataSet].firstObject takenAt]
                           endDate:[[self selectedDataSet].lastObject takenAt]];

    NSDate *initialDateOfDataToPlot =
    [(PatientVitalMeasurement *)[self selectedDataSet].firstObject takenAt];

    return [initialDateOfDataToPlot dateBySubtractingDays:daysInset];
}

- (id)graphXEndPoint {

    NSInteger daysInset =
    [self rangeInsetXWithStartDate:[[self selectedDataSet].firstObject takenAt]
                           endDate:[[self selectedDataSet].lastObject takenAt]];

    NSDate *finalDateOfDataToPlot =
    [(PatientVitalMeasurement *)[self selectedDataSet].lastObject takenAt];

    return [finalDateOfDataToPlot dateByAddingDays:daysInset];
}

/**
 *  Creates an inset for the x axis in order to ensure points do not start from edge of graph
 *
 *  @param startDate date of first datapoint
 *  @param endDate   date of last datapoint
 *
 *  @return NSInteger inset width
 */
- (NSInteger)rangeInsetXWithStartDate:(NSDate *)startDate
                              endDate:(NSDate *)endDate  {

    NSInteger daysSinceBeginningOfRange = [startDate daysEarlierThan:endDate];
    return MAX(daysSinceBeginningOfRange/20, kVitalGraphMinDaysBeforeOrAfter);
}

- (CGFloat)graphYStartPoint {

    CGFloat minValue = [self findMinValueOfYAxis];
    CGFloat valueSpan = [self calculateYAxisValueSpan];

    return (minValue - valueSpan / 5.0);
}

- (CGFloat)graphYEndPoint {

    CGFloat maxValue = [self findMaxValueOfYAxis];
    CGFloat valueSpan = [self calculateYAxisValueSpan];

    return (maxValue + valueSpan / 2.0);
}

- (CGFloat)calculateYAxisValueSpan {

    CGFloat maxValue = [self findMaxValueOfYAxis];
    CGFloat minValue = [self findMinValueOfYAxis];

    return maxValue - minValue;
}

- (CGFloat)findMaxValueOfYAxis {
    return [[[self selectedDataSet] valueForKeyPath:@"@max.value"] floatValue];
}

- (CGFloat)findMinValueOfYAxis {
    return [[[self selectedDataSet] valueForKeyPath:@"@min.value"] floatValue];
}


#pragma mark - UI

- (void)reloadWithUIUpdates {

    if (self.selectedDataPointIndex && self.selectedDataSet.count > 0) {

        PatientVitalMeasurement *vital = self.selectedDataSet[[[self selectedDataPointIndex] integerValue]];
        [self setupScoreboardViewWithVital:vital];
    }

    [self.chart removeAllAnnotations];

    [self.dataSource updateDataSet:[self selectedDataSet] seriesIdentifier:@"series"];

    [self.chart reloadData];

    self.chart.delegate = self;

    [self updateAxes];

    self.alreadyUpdatedConstraints = NO;
}

- (void)updateAxes {

    TKChartNumericAxis *xAxis = (TKChartNumericAxis *)self.chart.xAxis;
    TKChartNumericAxis *yAxis = (TKChartNumericAxis *)self.chart.yAxis;

    xAxis.style.labelStyle.textHidden = YES;
    yAxis.style.labelStyle.textHidden = YES;
    xAxis.style.majorTickStyle.ticksHidden = YES;
    xAxis.style.minorTickStyle.ticksHidden = YES;
    yAxis.style.majorTickStyle.ticksHidden = YES;
    yAxis.style.minorTickStyle.ticksHidden = YES;

    yAxis.majorTickInterval = [self yAxisMajorTickInterval];

    [self setupRanges];
}

- (NSNumber *)yAxisMajorTickInterval {
    return @(([self graphYEndPoint] - [self graphYStartPoint]) / kNumberOfSectionsSeparatedByLinesOnGraph);
}

- (void)setupRanges {

    TKChartDateTimeAxis *xAxis = (TKChartDateTimeAxis *)self.chart.xAxis;
    TKChartNumericAxis *yAxis = (TKChartNumericAxis *)self.chart.yAxis;

    TKRange *xAxisRange = [[TKRange alloc] initWithMinimum:[self graphXStartPoint] andMaximum:[self graphXEndPoint]];
    xAxis.range = xAxisRange;

    TKRange *yAxisRange = [[TKRange alloc] initWithMinimum:@([self graphYStartPoint]) andMaximum:@([self graphYEndPoint])];
    yAxis.range = yAxisRange;
}


#pragma mark - Layout

- (void)updateViewConstraints {

    self.chart.translatesAutoresizingMaskIntoConstraints = NO;
    self.metricControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.scoreboardView.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *bindings = NSDictionaryOfVariableBindings(_chart, _metricControl, _scoreboardView);

    [self.view removeConstraints:self.horizontalLayoutConstraintsForScoreboardView];
    [self.view removeConstraints:self.verticalLayoutConstraints];

    self.horizontalLayoutConstraintsForScoreboardView =
    [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scoreboardView]|"
                                            options:0
                                            metrics:nil
                                              views:bindings];


    NSDictionary *metrics = @{ @"scoreboardHeight" : @(kScoreboardHeight), @"chartHeight" : @(kChartHeight) };

    self.verticalLayoutConstraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_metricControl][_scoreboardView(scoreboardHeight)][_chart(chartHeight)]|"
                                            options:0
                                            metrics:metrics
                                              views:bindings];

    [self.view addConstraints:self.horizontalLayoutConstraintsForScoreboardView];
    [self.view addConstraints:self.verticalLayoutConstraints];

    if (!self.alreadyUpdatedConstraints) {

        NSArray *horizontalLayoutConstraintsForChart =
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_chart]|"
                                                options:0
                                                metrics:nil
                                                  views:bindings];

        NSArray *horizontalLayoutConstraintsForMetricControl =
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_metricControl]|"
                                                options:0
                                                metrics:nil
                                                  views:bindings];

        [self.view addConstraints:horizontalLayoutConstraintsForChart];
        [self.view addConstraints:horizontalLayoutConstraintsForMetricControl];

        self.alreadyUpdatedConstraints = YES;
    }

    [super updateViewConstraints];
}


#pragma mark - <TKChartDelegate>

-(TKChartPaletteItem *)chart:(TKChart *)chart
        paletteItemForSeries:(TKChartSeries *)series
                     atIndex:(NSInteger)index {

    TKChartLineSeries *lineSeries = (TKChartLineSeries *)series;

    lineSeries.selectionMode = TKChartSeriesSelectionModeDataPoint;
    lineSeries.style.pointShape = [[TKPredefinedShape alloc] initWithType:TKShapeTypeCircle andSize:CGSizeMake(8, 8)];
    lineSeries.style.palette = [TKChartPalette new];
    lineSeries.style.shapeMode = TKChartSeriesStyleShapeModeAlwaysShow;

    TKChartPaletteItem *seriesPaletteItem = [TKChartPaletteItem new];
    seriesPaletteItem.stroke = [TKStroke strokeWithColor:[UIColor leo_orangeRed] width:1.0];

    NSArray *colors = @[[[UIColor leo_gray176] colorWithAlphaComponent:0.6], [UIColor clearColor]];
    seriesPaletteItem.fill = [TKLinearGradientFill linearGradientFillWithColors:colors
                                                                      locations:@[@(0.0f),@(0.7f)]
                                                                     startPoint:CGPointMake(0.5f,0.f)
                                                                       endPoint:CGPointMake(0.5f, 1.f)];

    return seriesPaletteItem;
}

- (TKChartPaletteItem *)chart:(TKChart *)chart
          paletteItemForPoint:(NSUInteger)index
                     inSeries:(TKChartSeries *)series {

    TKChartPaletteItem *pointPaletteItem = [TKChartPaletteItem new];
    pointPaletteItem.stroke = [TKStroke strokeWithColor:[UIColor leo_orangeRed] width:3.0];

    UIColor *fillColor =
    [self.selectedDataPointIndex  isEqual:@(index)] ? [UIColor leo_orangeRed] : [UIColor leo_white];

    pointPaletteItem.fill = [TKSolidFill solidFillWithColor:fillColor];

    return pointPaletteItem;
}

- (NSNumber *)selectedDataPointIndex {

    if (!_selectedDataPointIndex) {

        if (self.selectedDataSet.count > 0) {
            _selectedDataPointIndex = @(self.selectedDataSet.count - 1);
        }
    }

    /**
     *  ZSD
     *  Protects against array out of bounds if refreshing the chart with a
     *  new dataset that has fewer data points than the last
     */
    if ([_selectedDataPointIndex integerValue] >= self.selectedDataSet.count && self.selectedDataSet.count > 0) {
        _selectedDataPointIndex = @(self.selectedDataSet.count - 1);
    }

    return _selectedDataPointIndex;
}

#pragma mark - Overlay annotations

- (void)chart:(TKChart *)chart trackballDidTrackSelection:(NSArray *)selection {
    [self.chart select:selection.firstObject];
}

- (void)chart:(TKChart *__nonnull)chart
didSelectPoint:(id<TKChartData> __nonnull)point
     inSeries:(TKChartSeries *__nonnull)series
      atIndex:(NSInteger)index {

    self.selectedDataPointIndex = @(index);

    [chart removeAllAnnotations];

    TKChartGridLineAnnotation *lineAnnotation =
    [[TKChartGridLineAnnotation alloc] initWithValue:point.dataXValue
                                             forAxis:chart.xAxis];

    lineAnnotation.style.stroke = [TKStroke strokeWithColor:[UIColor leo_orangeRed]
                                                      width:1.0];
    [chart addAnnotation:lineAnnotation];

    [self setupScoreboardViewWithVital:self.selectedDataSet[index]];

    //HACK: Required for iOS8
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
}


@end