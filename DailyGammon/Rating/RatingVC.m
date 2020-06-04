//
//  RatingVC.m
//  DailyGammon
//
//  Created by Peter on 27.02.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import "RatingVC.h"
#import "TopPageVC.h"
#import "Header.h"
#import "Design.h"
#import "TFHpple.h"
#import "PlayMatch.h"
#import "Preferences.h"
#import "Rating.h"
#import "LoginVC.h"
#import "GameLounge.h"
#import "DbConnect.h"
#import "AppDelegate.h"
#import "Player.h"
#import "iPhoneMenue.h"
#import "Tools.h"

@interface RatingVC ()

@property (strong, nonatomic) NSMutableArray *ratingArray;
@property (strong, nonatomic) NSMutableArray *monatArray;

@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@property (readwrite, retain, nonatomic) UIButton *topPageButton;

@end

@implementation RatingVC

@synthesize design, preferences, rating, tools;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = VIEWBACKGROUNDCOLOR;
    //    self.tableView.backgroundColor = HEADERBACKGROUNDCOLOR;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initGraph) name:@"changeSchemaNotification" object:nil];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self.view addSubview:[self makeHeader]];

    
}

- (void)viewWillAppear:(BOOL)animated
{

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];

//    self.ratingArray = [app.dbConnect readAlleRatingForUser:userID];
 
    self.ratingArray = [app.dbConnect readAlleRatingForUserAufgefuellt:userID];

    design = [[Design alloc] init];
    preferences = [[Preferences alloc] init];
    rating = [[Rating alloc] init];
    tools = [[Tools alloc] init];

    [self initGraph];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeSystem];
        infoButton = [design makeNiceButton:infoButton];
        [infoButton setTitle:@"Info" forState: UIControlStateNormal];
        infoButton.frame = CGRectMake(50, 100, 80, 35);
        [infoButton addTarget:self action:@selector(info:) forControlEvents:UIControlEventTouchUpInside];

        [self.view addSubview:infoButton];
        
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
        shareButton = [design makeNiceButton:shareButton];
        [shareButton setTitle:@"Share" forState: UIControlStateNormal];
        shareButton.frame = CGRectMake(150, 100, 80, 35);
        [shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:shareButton];
    }
}

#pragma mark CorePlot
- (void) initGraph
{
    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1) boardSchema = 4;
    NSMutableDictionary *schemaDict = [design schema:boardSchema];
    CPTColor *tintColor = [CPTColor colorWithCGColor:[[schemaDict objectForKey:@"TintColor"] CGColor]];
    
    int maxWidth = self.view.bounds.size.width;
    int maxHeight = self.view.bounds.size.height;
    

    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyy-MM-dd"];
    NSString *heute = [format stringFromDate:[NSDate date]];
    NSDictionary *dictForDate = [self.ratingArray objectAtIndex:0];

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        barLineChart = [[CPTXYGraph alloc] initWithFrame:CGRectMake(0, 0, maxWidth, maxHeight-200)];
        barLineChart.title = [NSString stringWithFormat:@"Rating from %@ to %@ ",[dictForDate objectForKey:@"datum"],heute] ;
    }
    else
    {
        if([design isX]) //Notch
            barLineChart = [[CPTXYGraph alloc] initWithFrame:CGRectMake(30, 0, maxWidth - 30, maxHeight)];
        else
            barLineChart = [[CPTXYGraph alloc] initWithFrame:CGRectMake(0, 0, maxWidth, maxHeight)];
        self.header.text = [NSString stringWithFormat:@"Rating from %@ to %@ ",[dictForDate objectForKey:@"datum"],heute] ;
    }

        
    barLineChart.plotAreaFrame.borderLineStyle = nil;
    barLineChart.plotAreaFrame.cornerRadius = 0.0f;
    
    barLineChart.paddingLeft = 0.0f;
    barLineChart.paddingRight = 0.0f;
    barLineChart.paddingTop = 0.0f;
    barLineChart.paddingBottom = 0.0f;
    
    barLineChart.plotAreaFrame.paddingLeft = 50.0;

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        barLineChart.plotAreaFrame.paddingTop = 50.0;
    else
        barLineChart.plotAreaFrame.paddingTop = 0.0;

    barLineChart.plotAreaFrame.paddingRight = 50.0;
    barLineChart.plotAreaFrame.paddingBottom = 100.0;
    
    CPTMutableTextStyle *textStyle = [CPTTextStyle textStyle];
    textStyle.color = tintColor;
    textStyle.fontSize = 16.0f;
    textStyle.textAlignment = CPTTextAlignmentCenter;
    barLineChart.titleTextStyle = textStyle;
    barLineChart.titleDisplacement = CGPointMake(0.0f, -10.0f);
    barLineChart.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)barLineChart.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    x.axisLineStyle = nil;
    x.majorTickLineStyle = nil;
    x.minorTickLineStyle = nil;
    x.majorIntervalLength = CPTDecimalFromString(@"7.0");

    NSDictionary *dict = [self.ratingArray lastObject];

    float min = [[dict objectForKey:@"min"]floatValue] - 20.0;
    float max = [[dict objectForKey:@"max"]floatValue] + 20.0;

    x.orthogonalCoordinateDecimal = CPTDecimalFromFloat(min);

    //x.title = @"Names";
    x.titleLocation = CPTDecimalFromFloat(7.5f);
    x.titleOffset = 25.0f;
    NSMutableSet *xMajorLocations = [NSMutableSet set];
    
    dict = [self.ratingArray objectAtIndex:0];
    NSString *oldMonth = [[dict objectForKey:@"datum"] substringWithRange:NSMakeRange(5, 2)];

    float tag = 0;
    for (int i = 0; i < [self.ratingArray count]; i++)
    {
        NSDictionary *dict = [self.ratingArray objectAtIndex:i];
        NSString *newMonth = [[dict objectForKey:@"datum"] substringWithRange:NSMakeRange(5, 2)];
        if(![oldMonth isEqualToString:newMonth])
        {
            [xMajorLocations addObject:[NSNumber numberWithFloat:tag]];
            
            oldMonth = newMonth;
        }
        tag++;
    }
    x.majorTickLocations = xMajorLocations;
    
    x.alternatingBandFills = [NSArray arrayWithObjects: [[CPTColor lightGrayColor] colorWithAlphaComponent:CPTFloat(0.1)],
                              [[CPTColor lightGrayColor] colorWithAlphaComponent:CPTFloat(0.2)],
                              nil];
    
    
    // Define some custom labels for the data elements
    x.labelRotation = M_PI/2;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    NSArray *subjectsArray = [self getSubjectTitlesAsArray];
    [x setAxisLabels:[NSSet setWithArray:subjectsArray]];
    
    CPTXYAxis *y = axisSet.yAxis;
    y.axisLineStyle = nil;
    y.majorTickLineStyle = nil;
    y.minorTickLineStyle = nil;
    y.majorIntervalLength = CPTDecimalFromString(@"10");
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    //    y.title = @"Kontostand";
    y.titleOffset = 40.0f;
    y.titleLocation = CPTDecimalFromFloat(150.0f);
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    
    y.majorGridLineStyle = gridLineStyle;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 100, maxWidth, maxHeight-100)];
    else
    {
        if([design isX]) //Notch
            hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(30, 40, maxWidth - 30, maxHeight-50)];
        else
            hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 40, maxWidth, maxHeight-20)];
    }
    hostingView.hostedGraph = barLineChart;
    hostingView.tag = 1;
    [self.view addSubview:hostingView];
    
    CPTGraph *graph = hostingView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0f) length:CPTDecimalFromInt((int)[self.ratingArray count])];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(min) length:CPTDecimalFromDouble(max - min)];
    
    CPTScatterPlot *kontoPlot = [[CPTScatterPlot alloc] init];
    kontoPlot.dataSource = self;
    kontoPlot.identifier = @"Rating";
    [graph addPlot:kontoPlot toPlotSpace:plotSpace];
    CPTMutableLineStyle *kontoLineStyle = [kontoPlot.dataLineStyle mutableCopy];
    kontoLineStyle.lineWidth = 3.0;
    kontoLineStyle.lineColor = tintColor;
    kontoPlot.dataLineStyle = kontoLineStyle;
    
    graph.legend = [CPTLegend legendWithGraph:graph];
    graph.legend.cornerRadius = 5.0;
    graph.legend.swatchSize = CGSizeMake(25.0, 25.0);
    graph.legendAnchor = CPTRectAnchorBottom;
    graph.legendDisplacement = CGPointMake(0.0, -10.0);
    graph.legend.numberOfColumns = 3;
    
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.ratingArray count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    switch (fieldEnum)
    {
        case CPTScatterPlotFieldX:
        {
            return [NSNumber numberWithUnsignedInteger:index];
        }
            break;
            
        case CPTScatterPlotFieldY:
        {
            if ([plot.identifier isEqual:@"Rating"] == YES)
            {
                NSDictionary *dict = [self.ratingArray objectAtIndex:index];
                //            NSLog(@"%6.2f", [NSNumber numberWithFloat: [[dict objectForKey:@"kontostand"]floatValue]]);
                
                return [NSNumber numberWithFloat: [[dict objectForKey:@"rating"]floatValue]];
            }
            else if ([plot.identifier isEqual:@"Monat"] == YES)
            {
                NSDictionary *dict = [self.monatArray objectAtIndex:index];
                return [NSNumber numberWithFloat: [[dict objectForKey:@"tag"]floatValue]];
            }
        }
            break;
    }
    return [NSDecimalNumber zero];
}

- (NSArray *)getSubjectTitlesAsArray
{
    NSMutableArray *labelArray = [NSMutableArray array];
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    [textStyle setFontSize:15];
    NSString *oldMonth = @"12";
    for (int i = 0; i < [self.ratingArray count]; i++)
    {
        NSDictionary *dict = [self.ratingArray objectAtIndex:i];
        CPTAxisLabel *axisLabel = [[CPTAxisLabel alloc] initWithText:@"" textStyle:textStyle];
        NSString *newMonth = [[dict objectForKey:@"datum"] substringWithRange:NSMakeRange(5, 2)];
        if(![oldMonth isEqualToString:newMonth])
        {
            axisLabel = [[CPTAxisLabel alloc] initWithText:[dict objectForKey:@"datum"] textStyle:textStyle];
            oldMonth = newMonth;
        }
        [axisLabel setTickLocation:CPTDecimalFromInt(i)];
        [axisLabel setRotation:M_PI/2];
        [axisLabel setOffset:0.1];
        [labelArray addObject:axisLabel];
    }
    
    return [NSArray arrayWithArray:labelArray];
}

- (IBAction)info:(id)sender
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Rating"
                                 message:@"Every time you play via the app your highest rating for the day will be saved."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    
                                }];
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)share:(id)sender
{

    CGSize size = [hostingView bounds].size;
    UIGraphicsBeginImageContext(size);
    [[hostingView layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *ratingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSString *str = [NSString stringWithFormat:@"My Name on DailyGammon %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"user"]];
    NSArray *postItems=@[ratingImage];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:postItems applicationActivities:nil];
    
    //if iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self presentViewController:controller animated:YES completion:nil];
    }
    //if iPad
    else
    {
        // Change Rect to position Popover
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:controller];
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (IBAction)moreAction:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    iPhoneMenue *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneMenue"];
    [self.navigationController pushViewController:vc animated:NO];
    
}
#pragma mark - Header
#include "HeaderInclude.h"

@end