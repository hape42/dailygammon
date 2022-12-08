//
//  RatingVC.m
//  DailyGammon
//
//  Created by Peter on 27.02.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import "RatingVC.h"
#import "TopPageVC.h"
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
#import <SafariServices/SafariServices.h>
#import "RatingTools.h"
#import "SetUpVC.h"
#import "LoginVC.h"
#import "About.h"

@interface RatingVC ()

@property (strong, nonatomic) NSMutableArray *ratingArray;
@property (strong, nonatomic) NSMutableArray *ratingArrayAll;

@property (strong, nonatomic) NSMutableArray *monatArray;

@property (strong, nonatomic) NSMutableArray *averageArray;
@property (readwrite, atomic) int average, dataRange;
@property (readwrite, atomic) BOOL iPad;

@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIImageView *iCloudConnected;
@property (weak, nonatomic) IBOutlet UIButton *iCloud;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;

@property (readwrite, retain, nonatomic) UIButton *topPageButton;

@end

@implementation RatingVC

@synthesize design, preferences, rating, tools, ratingTools;
@synthesize filterView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initGraph) name:@"changeSchemaNotification" object:nil];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self.view addSubview:[self makeHeader]];

    self.iPad = FALSE;
    
    int ratingAverage = 0;
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"ratingAverage"] != nil)
    {
        ratingAverage = [[[NSUserDefaults standardUserDefaults] valueForKey:@"ratingAverage"]intValue];
    }
    else
    {
        self.average = 90;
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"ratingAverage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    switch (ratingAverage)
    {
        case 0:
                self.average = 0;
            break;
        case 1:
                self.average = 7;
            break;
        case 2:
                self.average = 30;
            break;
        case 3:
                self.average = 90;
            break;
        case 4:
                self.average = 365;
            break;
        default:
            self.average = 90;
            break;
    }
    
    int dataArea = 0;
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"ratingData"] != nil)
    {
        dataArea = [[[NSUserDefaults standardUserDefaults] valueForKey:@"ratingData"]intValue];
    }
    else
    {
        self.dataRange = 0;
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"ratingData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    switch (dataArea)
    {
        case 0:
                self.dataRange = 0;
            break;
        case 1:
                self.dataRange = 30;
            break;
        case 2:
                self.dataRange = 60;
            break;
        case 3:
                self.dataRange = 90;
            break;
        case 4:
                self.dataRange = 365;
            break;
        default:
            self.dataRange = 0;
            break;
    }

    self.moreButton.tintColor = [UIColor colorNamed:@"ColorSwitch"];
    self.filterButton.tintColor = [UIColor colorNamed:@"ColorSwitch"];

    self.moreButton.tintColor = [UIColor yellowColor];

    UIImage *image = [[UIImage imageNamed:@"menue.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.moreButton setImage:image forState:UIControlStateNormal];
    
    self.moreButton.tintColor = [UIColor colorNamed:@"ColorSwitch"];

    image = [[UIImage imageNamed:@"slider"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.filterButton setImage:image forState:UIControlStateNormal];
    self.filterButton.tintColor = [UIColor colorNamed:@"ColorSwitch"];

}

- (void)viewWillAppear:(BOOL)animated
{

    ratingTools = [[RatingTools alloc] init];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];

//    self.ratingArray = [app.dbConnect readAlleRatingForUser:userID];
 
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"iCloud"]boolValue])
        self.ratingArrayAll = [ratingTools readAll];
    else
        self.ratingArrayAll = [app.dbConnect readAlleRatingForUserAufgefuellt:userID];

    self.ratingArray = [self filterDataArray];
    
    design =      [[Design alloc] init];
    preferences = [[Preferences alloc] init];
    rating =      [[Rating alloc] init];
    tools =       [[Tools alloc] init];


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
 
        UIButton *iCloudButton = [UIButton buttonWithType:UIButtonTypeSystem];
        iCloudButton = [design makeNiceButton:iCloudButton];
        [iCloudButton setTitle:@"iCloud" forState: UIControlStateNormal];
        iCloudButton.frame = CGRectMake(250, 100, 80, 35);
        [iCloudButton addTarget:self action:@selector(iCloudAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:iCloudButton];

        UIImageView *iCloudConnected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iCloudOFF.png"]];
        iCloudConnected.frame = CGRectMake(330, 100, 35, 35);
        if ( [[NSFileManager defaultManager] ubiquityIdentityToken] != nil)
            [iCloudConnected setImage:[UIImage imageNamed:@"iCloudON.png"]];
        else
            [iCloudConnected setImage:[UIImage imageNamed:@"iCloudOFF.png"]];
        
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"iCloud"]boolValue])
            [iCloudConnected setImage:[UIImage imageNamed:@"iCloudON.png"]];
        else
            [iCloudConnected setImage:[UIImage imageNamed:@"iCloudOFF.png"]];

        [self.view addSubview:iCloudConnected];

        int maxWidth = self.view.bounds.size.width;
//        int segmentWidth = 180;
//        int labelWidth = 80;
        int edge = 50;
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(maxWidth - segmentWidth - edge -labelWidth, 100, labelWidth, 35)];
//        [label setTextAlignment:NSTextAlignmentCenter];
//        label.text = @"Average";
//
//        [self.view addSubview:label];
//        NSArray *itemArray = [NSArray arrayWithObjects: @"7", @"30", @"90", @"365",nil];
//        UISegmentedControl *averageControl = [[UISegmentedControl alloc] initWithItems:itemArray];
//        averageControl.frame = CGRectMake(maxWidth-segmentWidth-edge, 100, segmentWidth, 35);
//
//        [averageControl addTarget:self action:@selector(averageAction:) forControlEvents: UIControlEventValueChanged];
//        averageControl.selectedSegmentIndex = 1;
//        [self.view addSubview:averageControl];

        UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        filterButton.frame = CGRectMake(maxWidth-35-edge, 100, 35, 35);
        UIImage *image = [[UIImage imageNamed:@"slider"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [filterButton setImage:image forState:UIControlStateNormal];
        filterButton.tintColor = [UIColor colorNamed:@"ColorSwitch"];

        [filterButton addTarget:self action:@selector(showFilter:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:filterButton];

        self.iPad = TRUE;
    }
    else
    {
        self.moreButton.tintColor   = [UIColor colorNamed:@"ColorSwitch"];
        self.filterButton.tintColor = [UIColor colorNamed:@"ColorSwitch"];

        self.iCloud      = [design makeNiceButton:self.iCloud];
        self.shareButton = [design makeNiceButton:self.shareButton];
        self.infoButton  = [design makeNiceButton:self.infoButton];

    }
    if ( [[NSFileManager defaultManager] ubiquityIdentityToken] != nil)
        [self.iCloudConnected setImage:[UIImage imageNamed:@"iCloudON.png"]];
    else
        [self.iCloudConnected setImage:[UIImage imageNamed:@"iCloudOFF.png"]];
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"iCloud"]boolValue])
        [self.iCloudConnected setImage:[UIImage imageNamed:@"iCloudON.png"]];
    else
        [self.iCloudConnected setImage:[UIImage imageNamed:@"iCloudOFF.png"]];

    [self makeAverageArray];
    [self initGraph];

}


-(void)makeAverageArray
{
    self.averageArray = [[NSMutableArray alloc]initWithCapacity:20];
    for(int index = 0; index < self.ratingArray.count; index++)
    {
        if(index > self.average)
        {
            float rating = 0.0;
            for(int i = 0; i < self.average; i++)
            {
                NSMutableDictionary *dict = self.ratingArray[index-i];

                rating += [[dict objectForKey:@"rating"]floatValue];
            }
            rating /= self.average;
            NSDictionary *averageDict = @{
                                          @"rating"  : [NSNumber numberWithDouble: rating]
                                         };
            [self.averageArray addObject:averageDict];
        }
        else
        {
            NSDictionary *averageDict = @{
                                          @"rating"  : [NSNumber numberWithDouble: 0.0]
                                         };
            [self.averageArray addObject:averageDict];
        }
    }
}

- (NSMutableArray *)filterDataArray
{
    NSMutableArray *filteredArray = [[NSMutableArray alloc]initWithCapacity:1000];
    
    int dataArea = 0;
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"ratingData"] != nil)
    {
        dataArea = [[[NSUserDefaults standardUserDefaults] valueForKey:@"ratingData"]intValue];
    }
    unsigned long filter = 30;
    switch (dataArea)
    {
        case 0: //Alle
            return self.ratingArrayAll;
            break;
        case 1:
            filter = 30;
            break;
        case 2:
            filter = 60;
            break;
        case 3:
            filter = 90;
            break;
        case 4:
            filter = 365;
            break;
        default:
            filter = 30;
            break;
    }
    if(self.ratingArrayAll.count < filter)
        filter = self.ratingArrayAll.count;
    
    float ratingBefore = 0.0;
    float min = 9999.0;
    float max = -1.0;

    for(unsigned long i = filter; i > 0; i--)
    {
        NSMutableDictionary *ratingDict = [self.ratingArrayAll[self.ratingArrayAll.count - i]mutableCopy];
        
        float rating = [[ratingDict objectForKey:@"rating"]floatValue];

        if (rating < 1.0)
            rating = ratingBefore;
        else
            ratingBefore = rating;
        
//        XLog(@"%3.1f %3.1f", rating, ratingVorher);
        if(rating > max)
            max = rating;
        if(rating < min)
            min = rating;
        [ratingDict setObject:[NSNumber numberWithDouble: max]  forKey:@"max"];
        [ratingDict setObject:[NSNumber numberWithDouble: min]  forKey:@"min"];
        
        [filteredArray addObject:ratingDict];
    }
    return filteredArray;
}
#pragma mark - CorePlot
    
- (void) initGraph
{
    if(hostingView != nil)
    {
        for (UIView *view in [self.view subviews])
        {
            if(view.tag == 1)
                [view removeFromSuperview];
        }

        for (UIView *view in [hostingView subviews])
        {
            [view removeFromSuperview];
        }
    }
    CPTColor *tintColor = [CPTColor colorWithCGColor:[[design schemaColor] CGColor]];

    CPTColor *averageColor = [CPTColor colorWithCGColor:[[UIColor yellowColor] CGColor]];

    int maxWidth = self.view.bounds.size.width;
    int maxHeight = self.view.bounds.size.height;
    

    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [format stringFromDate:[NSDate date]];
    NSDictionary *dictForDate = [self.ratingArray objectAtIndex:0];

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        barLineChart = [[CPTXYGraph alloc] initWithFrame:CGRectMake(0, 0, maxWidth, maxHeight-200)];
        barLineChart.title = [NSString stringWithFormat:@"Rating from %@ to %@ ",[dictForDate objectForKey:@"datum"],today] ;
    }
    else
    {
        if([design isX]) //Notch
            barLineChart = [[CPTXYGraph alloc] initWithFrame:CGRectMake(30, 0, maxWidth - 30, maxHeight)];
        else
            barLineChart = [[CPTXYGraph alloc] initWithFrame:CGRectMake(40, 0, maxWidth, maxHeight-0)];
        self.header.text = [NSString stringWithFormat:@"Rating from %@ to %@ ",[dictForDate objectForKey:@"datum"],today] ;
        self.header = [design makeNiceLabel:self.header];
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
    textStyle.color = [CPTColor colorWithCGColor:[[UIColor colorNamed:@"ColorSwitch"]CGColor]];
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
    y.majorIntervalLength = CPTDecimalFromString(@"20");
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    //    y.title = @"Kontostand";
    y.titleOffset = 40.0f;
    y.titleLocation = CPTDecimalFromFloat(150.0f);
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    
    y.majorGridLineStyle = gridLineStyle;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 140, maxWidth, maxHeight-140)];
    else
    {
        if([design isX]) //Notch
            hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(30, 40, maxWidth - 30, maxHeight-40)];
        else
            hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 40, maxWidth, maxHeight-0)];
    }
    hostingView.hostedGraph = barLineChart;
    hostingView.tag = 1;
    [self.view addSubview:hostingView];
    
    CPTGraph *graph = hostingView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0f) length:CPTDecimalFromInt((int)[self.ratingArray count])];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(min) length:CPTDecimalFromDouble(max - min)];
    
    CPTScatterPlot *ratingPlot = [[CPTScatterPlot alloc] init];
    ratingPlot.dataSource = self;
    if(self.dataRange == 0)
        ratingPlot.identifier = [NSString stringWithFormat: @"Rating"] ;
    else
        ratingPlot.identifier = [NSString stringWithFormat: @"Rating last %d days",self.dataRange] ;

    CPTMutableLineStyle *ratingLineStyle = [ratingPlot.dataLineStyle mutableCopy];
    ratingLineStyle.lineWidth = 3.0;
    ratingLineStyle.lineColor = tintColor;
    ratingPlot.dataLineStyle = ratingLineStyle;
    
    CPTScatterPlot *averagePlot = [[CPTScatterPlot alloc] init];
    averagePlot.dataSource = self;
    averagePlot.identifier = [NSString stringWithFormat: @"Average %d days",self.average] ;
   
    CPTMutableLineStyle *averageLineStyle = [averagePlot.dataLineStyle mutableCopy];
    averageLineStyle.lineWidth = 3.0;
    averageLineStyle.lineColor = averageColor;
    averagePlot.dataLineStyle = averageLineStyle;

    if([[NSUserDefaults standardUserDefaults] objectForKey:@"ratingAverage"] != nil)
    {
        if( [[[NSUserDefaults standardUserDefaults] valueForKey:@"ratingAverage"]intValue] >0 )
            [graph addPlot:averagePlot toPlotSpace:plotSpace];
    }

    [graph addPlot:ratingPlot toPlotSpace:plotSpace];

    graph.legend = [CPTLegend legendWithGraph:graph];
    graph.legend.cornerRadius = 5.0;
    graph.legend.swatchSize = CGSizeMake(25.0, 25.0);
    graph.legendAnchor = CPTRectAnchorBottom;
    graph.legendDisplacement = CGPointMake(0.0, 30.0);
    graph.legend.numberOfColumns = 3;
    
    CPTMutableTextStyle *legendeTextStyle = [CPTTextStyle textStyle];
    legendeTextStyle.color = [CPTColor colorWithCGColor:[[UIColor colorNamed:@"ColorSwitch"]CGColor]];

    [graph.legend setTextStyle:(CPTTextStyle *)legendeTextStyle];


}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.ratingArray count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString *ratingPlotIdentifier = [NSString stringWithFormat: @"Rating"] ;
    if(self.dataRange == 0)
        ratingPlotIdentifier = [NSString stringWithFormat: @"Rating"] ;
    else
        ratingPlotIdentifier = [NSString stringWithFormat: @"Rating last %d days",self.dataRange] ;

    switch (fieldEnum)
    {
        case CPTScatterPlotFieldX:
        {
            return [NSNumber numberWithUnsignedInteger:index];
        }
            break;
            
        case CPTScatterPlotFieldY:
        {
            if ([plot.identifier isEqual:ratingPlotIdentifier] == YES)
            {
                NSDictionary *dict = [self.ratingArray objectAtIndex:index];
                //            NSLog(@"%6.2f", [NSNumber numberWithFloat: [[dict objectForKey:@"kontostand"]floatValue]]);
                
                return [NSNumber numberWithFloat: [[dict objectForKey:@"rating"]floatValue]];
            }
            else if ([plot.identifier isEqual:[NSString stringWithFormat: @"Average %d days",self.average] ] == YES)
            {
                if(index <= self.average)
                    return nil;


                NSDictionary *dict = [self.averageArray objectAtIndex:index];
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
    NSString *oldMonth = @"99";
    int step = 1;
    if([self.ratingArray count] > 600)
        step = 3;
    int monthCounter = 1;
    for (int i = 0; i < [self.ratingArray count]; i++)
    {
        NSDictionary *dict = [self.ratingArray objectAtIndex:i];
        CPTAxisLabel *axisLabel = [[CPTAxisLabel alloc] initWithText:@"" textStyle:textStyle];
        NSString *newMonth = [[dict objectForKey:@"datum"] substringWithRange:NSMakeRange(5, 2)];
        if(![oldMonth isEqualToString:newMonth])
        {
            NSString *dateText = [NSString stringWithFormat:@"%@ %@",
                                  [[dict objectForKey:@"datum"] substringWithRange:NSMakeRange(2, 2)],
                                  [[dict objectForKey:@"datum"] substringWithRange:NSMakeRange(5, 2)]];
            if(monthCounter == step)
            {
                axisLabel = [[CPTAxisLabel alloc] initWithText:dateText textStyle:textStyle];
                monthCounter = 1;
            }
            else
            {
                monthCounter++;
            }
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
    
    alert = [design makeBackgroundColor:alert];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}
- (IBAction)iCloudAction:(id)sender
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"iCloud"
                                 message:@"If you enable iCloud for your device (you have to do this in the settings of your device), your rating data will be stored in iCloud. This is only a few bytes per day.\n The green (or red) dot gives you a hint if iCloud is switched on or not.\n\nYou have several advantages:\n- If you play on multiple devices, you have the same rating data on each device.\n- If you have a new device, the rating data is automatically available.\n\nYou can also switch off the iCloud at any time. However, then you only have the respective local data available for each device."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    
                                }];
    
    UIAlertAction* iCloudButton = [UIAlertAction
                                actionWithTitle:@"Setting"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        SetUpVC *controller = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"SetUpVC"];
        controller.fromRating = TRUE;
        // present the controller
        // on iPad, this will be a Popover
        // on iPhone, this will be an action sheet
        controller.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:controller animated:YES completion:nil];
        
        UIPopoverPresentationController *popController = [controller popoverPresentationController];
        popController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        popController.delegate = self;
        
        UIButton *button = (UIButton *)sender;
        popController.sourceView = button;
        popController.sourceRect = button.bounds;

                                }];

    [alert addAction:yesButton];
    [alert addAction:iCloudButton];
    alert = [design makeBackgroundColor:alert];

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
    
    UIActivityViewController *shareVC = [[UIActivityViewController alloc] initWithActivityItems:@[str, ratingImage] applicationActivities:nil];
    shareVC.popoverPresentationController.sourceView    = self.view;
    UIButton *button = (UIButton *)sender;

    shareVC.popoverPresentationController.sourceRect = button.frame;

    [self presentViewController:shareVC animated:YES completion:nil];

}

- (IBAction)moreAction:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    iPhoneMenue *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneMenue"];
    [self.navigationController pushViewController:vc animated:NO];
    
}

#pragma mark - Filter

- (IBAction)showFilter:(id)sender
{
    [self closeFilter];
    
    float filterWidth =  400.0;
    float filterHeight = 200;

    float labelWidth = 200;
    float labelHeight = 35;
    int rand = 10;
    
    float y = rand;
    float x = rand;

  //  if(filterView == nil)
    {
        filterView = [[UIView alloc]initWithFrame:CGRectMake( [[UIScreen mainScreen] bounds].size.width,
                                                           hostingView.frame.origin.y + 50,
                                                           filterWidth,
                                                           filterHeight)];
        filterView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];

        filterView.layer.borderWidth = 1;
        [self.view addSubview:filterView];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(rand, y, labelWidth, labelHeight)];
        [label setTextAlignment:NSTextAlignmentCenter];
        label.text = @"Average:";
        [filterView addSubview:label];
        
        int ratingAverage = 0;
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"ratingAverage"] != nil)
        {
            ratingAverage = [[[NSUserDefaults standardUserDefaults] valueForKey:@"ratingAverage"]intValue];
        }
        else
        {
            ratingAverage = 2;
            [[NSUserDefaults standardUserDefaults] setInteger:ratingAverage forKey:@"ratingAverage"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        NSArray *itemArray = [NSArray arrayWithObjects:  @"No", @"7", @"30", @"90", @"365",nil];
        UISegmentedControl *averageControl = [[UISegmentedControl alloc] initWithItems:itemArray];
        averageControl.frame = CGRectMake(rand + labelWidth + rand, 10, 170, labelHeight);
        [averageControl addTarget:self action:@selector(averageAction:) forControlEvents: UIControlEventValueChanged];
        averageControl.selectedSegmentIndex = ratingAverage;
        [filterView addSubview:averageControl];

        x = rand;
        y += 50;

        label = [[UILabel alloc] initWithFrame:CGRectMake(rand, y, labelWidth, labelHeight)];
        [label setTextAlignment:NSTextAlignmentCenter];
        label.text = @"Data: show last x days";
        [filterView addSubview:label];
        
        int ratingData = 0;
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"ratingData"] != nil)
        {
            ratingData = [[[NSUserDefaults standardUserDefaults] valueForKey:@"ratingData"]intValue];
        }
        else
        {
            ratingData = 2;
            [[NSUserDefaults standardUserDefaults] setInteger:ratingData forKey:@"ratingData"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

        itemArray = [NSArray arrayWithObjects: @"All", @"30", @"60", @"90", @"365",nil];
        UISegmentedControl *dataControl = [[UISegmentedControl alloc] initWithItems:itemArray];
        dataControl.frame = CGRectMake(rand + labelWidth + rand, y, 170, labelHeight);
        [dataControl addTarget:self action:@selector(dataAction:) forControlEvents: UIControlEventValueChanged];
        dataControl.selectedSegmentIndex = ratingData;
        [filterView addSubview:dataControl];

        x = rand;
        y += 70;
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake((filterWidth - 100) / 2, y, 100, 35);
        [closeButton addTarget:self action:@selector(closeFilter) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTitle:@"Close" forState:UIControlStateNormal];
        closeButton = [design makeNiceButton:closeButton];
        [filterView addSubview:closeButton];
    }
    filterView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];

    x = [[UIScreen mainScreen] bounds].size.width - filterWidth - 50;

    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self->filterView.frame = CGRectMake(x,self->filterView.frame.origin.y,filterWidth,filterHeight);

    } completion:^(BOOL finished) {
    }];

    return;
}


-(void)closeFilter
{

    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self->filterView.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width,
                                            self->filterView.frame.origin.y,
                                            self->filterView.frame.size.width,
                                            self->filterView.frame.size.height);

    } completion:^(BOOL finished) {
    }];

}

- (IBAction)averageAction:(UISegmentedControl *)segment
{
    [self closeFilter];
    
    if(segment.selectedSegmentIndex == 0)
        self.average = 0;
    if(segment.selectedSegmentIndex == 1)
        self.average = 7;
    if(segment.selectedSegmentIndex == 2)
        self.average = 30;
    if(segment.selectedSegmentIndex == 3)
        self.average = 90;
    if(segment.selectedSegmentIndex == 4)
        self.average = 365;
    
    [[NSUserDefaults standardUserDefaults] setInteger:segment.selectedSegmentIndex forKey:@"ratingAverage"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self makeAverageArray];
    [self initGraph];

}
- (IBAction)dataAction:(UISegmentedControl *)segment
{
    [self closeFilter];
    
    if(segment.selectedSegmentIndex == 0)
        self.dataRange = 0;
    if(segment.selectedSegmentIndex == 1)
        self.dataRange = 30;
    if(segment.selectedSegmentIndex == 2)
        self.dataRange = 60;
    if(segment.selectedSegmentIndex == 3)
        self.dataRange = 90;
    if(segment.selectedSegmentIndex == 4)
        self.dataRange = 365;
    
    [[NSUserDefaults standardUserDefaults] setInteger:segment.selectedSegmentIndex forKey:@"ratingData"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    self.ratingArray = [self filterDataArray];

    [self makeAverageArray];
    [self initGraph];

}

#pragma mark - Header
#include "HeaderInclude.h"

@end
