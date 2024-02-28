//
//  RatingVC.m
//  DailyGammon
//
//  Created by Peter on 27.02.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import "RatingVC.h"
#import "Design.h"
#import "TFHpple.h"
#import "PlayMatch.h"
#import "Preferences.h"
#import "Rating.h"
#import "LoginVC.h"
#import "DbConnect.h"
#import "AppDelegate.h"
#import "Player.h"
#import "Tools.h"
#import <SafariServices/SafariServices.h>
#import "RatingTools.h"
#import "SetUpVC.h"
#import "LoginVC.h"
#import "About.h"
#import "DGButton.h"
#import "PlayerLists.h"
#import "Constants.h"
#import "DGLabel.h"
#import "RatingCD.h"
#import "Ratings+CoreDataProperties.h"
#import <Charts/Charts.h>
#import "DateValueFormatter.h"

@interface RatingVC ()<ChartViewDelegate>

@property (nonatomic, strong) IBOutlet LineChartView *chartView;

@property (strong, nonatomic) NSMutableArray *ratingArray;
@property (strong, nonatomic) NSMutableArray *ratingArrayAll;

@property (strong, nonatomic) NSMutableArray *monatArray;

@property (strong, nonatomic) NSMutableArray *averageArray;
@property (readwrite, atomic) int average, dataRange;
@property (readwrite, atomic) BOOL iPad;
@property (readwrite, atomic) float gap;

@property (weak, nonatomic) IBOutlet DGLabel *header;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIImageView *iCloudConnected;
@property (weak, nonatomic) IBOutlet DGButton *iCloud;
@property (weak, nonatomic) IBOutlet DGButton *shareButton;
@property (weak, nonatomic) IBOutlet DGButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;

@property (readwrite, retain, nonatomic) DGButton *topPageButton;

@end

@implementation RatingVC

@synthesize design, preferences, rating, tools, ratingTools, ratingCD;
@synthesize filterView;

@synthesize ratingHigh, ratingLow, dateHigh, dateLow;

@synthesize menueView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initGraph) name:changeSchemaNotification object:nil];
    
    self.iPad = FALSE;
    self.gap = 50;
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

    ratingHigh = 0;
    ratingLow = 99999;
    dateHigh = @"";
    dateLow = @"";

}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.navigationItem.hidesBackButton = YES;

    design =      [[Design alloc] init];
    preferences = [[Preferences alloc] init];
    rating =      [[Rating alloc] init];
    tools =       [[Tools alloc] init];
    ratingCD =    [[RatingCD alloc] init];

    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];

    self.ratingArrayAll = [ratingCD readAlleRatingForUser:userID];

    self.ratingArray = [self filterDataArray];
    
    for( NSMutableDictionary *ratingDict in self.ratingArrayAll)
    {
        if([[ratingDict objectForKey:@"rating"]floatValue] > ratingHigh)
        {
            ratingHigh = [[ratingDict objectForKey:@"rating"]floatValue];
            dateHigh = [ratingDict objectForKey:@"datum"];
        }
        if([[ratingDict objectForKey:@"rating"]floatValue] < ratingLow)
        {
            ratingLow = [[ratingDict objectForKey:@"rating"]floatValue];
            dateLow = [ratingDict objectForKey:@"datum"];
        }

    }

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        DGButton *infoButton = [[DGButton alloc] initWithFrame:CGRectMake(50, 100, 80, 35)];
        [infoButton setTitle:@"Info" forState: UIControlStateNormal];
        [infoButton addTarget:self action:@selector(info:) forControlEvents:UIControlEventTouchUpInside];

        [self.view addSubview:infoButton];
        
        DGButton *shareButton = [[DGButton alloc] initWithFrame:CGRectMake(150, 100, 80, 35)];
        [shareButton setTitle:@"Share" forState: UIControlStateNormal];
        [shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:shareButton];
 
        DGButton *iCloudButton = [[DGButton alloc] initWithFrame:CGRectMake(250, 100, 80, 35)];
        [iCloudButton setTitle:@"iCloud" forState: UIControlStateNormal];
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
        int edge = 50;

        UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        filterButton.frame = CGRectMake(maxWidth-35-edge, 100, 35, 35);
        UIImage *image = [[UIImage imageNamed:@"slider"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [filterButton setImage:image forState:UIControlStateNormal];
        filterButton.tintColor = [UIColor colorNamed:@"ColorSwitch"];

        [filterButton addTarget:self action:@selector(showFilter:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:filterButton];
        self.gap = filterButton.frame.origin.y + self.filterButton.frame.size.height + 30;

        self.iPad = TRUE;

        CGRect frame = self.header.frame;
        frame.origin.y = filterButton.frame.origin.y;
        frame.origin.x = iCloudConnected.frame.origin.x + iCloudConnected.frame.size.width + 10;
        frame.size.width = filterButton.frame.origin.x - frame.origin.x ;
        self.header.frame = frame;
    }
    else
    {
        self.moreButton.tintColor   = [UIColor colorNamed:@"ColorSwitch"];
        self.filterButton.tintColor = [UIColor colorNamed:@"ColorSwitch"];
        self.gap = self.filterButton.frame.origin.y + self.filterButton.frame.size.height + 10;

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
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

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

- (IBAction)info:(id)sender
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Rating"
                                 message:[NSString stringWithFormat:@"Every time you play via the app your highest rating for the day will be saved.\n\nHighest rating %3.1f %@\nLowest rating %3.1f %@",ratingHigh, dateHigh, ratingLow, dateLow]
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

    CGSize size = [self.chartView bounds].size;
    UIGraphicsBeginImageContext(size);
    [[self.chartView layer] renderInContext:UIGraphicsGetCurrentContext()];
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
    if(!menueView)
    {
        menueView = [[MenueView alloc]init];
        menueView.navigationController = self.navigationController;
    }
    [menueView showMenueInView:self.view];
}

#pragma mark - Filter

- (IBAction)showFilter:(id)sender
{
    [self closeFilter];
    
    float filterWidth =  400.0;
    float filterHeight = 250;

    float labelWidth = 200;
    float labelHeight = 35;
    int rand = 10;
    
    float y = rand;
    float x = rand;

  //  if(filterView == nil)
    {
        filterView = [[UIView alloc]initWithFrame:CGRectMake( [[UIScreen mainScreen] bounds].size.width,
                                                           self.chartView.frame.origin.y + 50,
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
        y += 50;

        label = [[UILabel alloc] initWithFrame:CGRectMake(rand, y, filterWidth - rand - rand, labelHeight)];
        [label setTextAlignment:NSTextAlignmentCenter];
        label.adjustsFontSizeToFitWidth = YES;
        [label setFont:[UIFont boldSystemFontOfSize: 25.0]];
        label.numberOfLines = 0;
        label.minimumScaleFactor = 0.1;

        Ratings *dictBest =  [ratingCD bestRating];
        Ratings *dictWorst =  [ratingCD worstRating];

        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        
        NSDate *dateDB = [format dateFromString:dictBest.dateRating];
        [format setLocale:[NSLocale currentLocale]];
        [format setDateFormat:@"dd. MMMM yyyy"];

        label.text = [NSString stringWithFormat: @"Best Rating %5.1f - %@",dictBest.rating,[format stringFromDate:dateDB]];
        [filterView addSubview:label];
        
        y += 50;
        label = [[UILabel alloc] initWithFrame:CGRectMake(rand, y, filterWidth - rand - rand, labelHeight)];
        [label setTextAlignment:NSTextAlignmentCenter];
        label.adjustsFontSizeToFitWidth = YES;
        [label setFont:[UIFont boldSystemFontOfSize: 25.0]];
        label.numberOfLines = 0;
        label.minimumScaleFactor = 0.1;

        [format setDateFormat:@"yyyy-MM-dd"];
        dateDB = [format dateFromString:dictWorst.dateRating];
        [format setLocale:[NSLocale currentLocale]];
        [format setDateFormat:@"dd. MMMM yyyy"];
        label.text = [NSString stringWithFormat: @"Worst Rating %5.1f - %@",dictWorst.rating,[format stringFromDate:dateDB]];
        [filterView addSubview:label];

        y += 50;
        DGButton *closeButton = [[DGButton alloc]initWithFrame:CGRectMake((filterWidth - 100) / 2, y, 100, 35)];
        [closeButton addTarget:self action:@selector(closeFilter) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTitle:@"Close" forState:UIControlStateNormal];
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

-(void)showData
{
    
}
#pragma mark - Charts

-(void)initGraph
{
    NSDictionary *dictForDate = [self.ratingArray objectAtIndex:0];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [format stringFromDate:[NSDate date]];

    self.header.text = [NSString stringWithFormat:@"Rating from %@ to %@ ",[dictForDate objectForKey:@"datum"],today] ;
    self.header = [design makeNiceLabel:self.header];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    
    if (self.chartView == nil)
    {
        float gap = 0;
        if([design isX]) //Notch
            gap = 50;
        self.chartView = [[LineChartView alloc]initWithFrame:CGRectMake(0 + gap, safe.layoutFrame.origin.y + self.gap, safe.layoutFrame.size.width - gap, safe.layoutFrame.size.height - self.gap - 20 )];
        [self.view addSubview:self.chartView];
        
  }
    self.chartView.tag = 42;
    
    self.chartView.delegate = self;
    
    self.chartView.chartDescription.enabled = NO;
    self.chartView.dragEnabled = YES;
    [self.chartView setScaleEnabled:YES];
    self.chartView.drawGridBackgroundEnabled = YES;
    self.chartView.pinchZoomEnabled = YES;
    
    
    ChartLegend *l = self.chartView.legend;
    l.form = ChartLegendFormLine;
    l.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    l.textColor = UIColor.blackColor;
    l.horizontalAlignment = ChartLegendHorizontalAlignmentCenter;
    l.verticalAlignment = ChartLegendVerticalAlignmentTop;
    l.orientation = ChartLegendOrientationHorizontal;
    l.drawInside = NO;
    
    ChartXAxis *xAxis = self.chartView.xAxis;
    xAxis.labelFont = [UIFont systemFontOfSize:11.f];
    xAxis.labelTextColor = UIColor.blackColor;
    xAxis.drawGridLinesEnabled = YES;
    xAxis.drawAxisLineEnabled = NO;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.valueFormatter = [[DateValueFormatter alloc] init];
    xAxis.granularity = 60*60*24*30; // 30 days
 //   xAxis.granularity = 7;
    [xAxis setLabelCount:self.ratingArray.count];

    ChartYAxis *leftAxis = self.chartView.leftAxis;
    leftAxis.labelTextColor = [UIColor colorNamed:@"ColorGraphSD"];
    leftAxis.axisMaximum = [self maxY];
    leftAxis.axisMinimum = [self minY];
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.drawZeroLineEnabled = NO;
    leftAxis.granularityEnabled = YES;
    leftAxis.granularity = 1;
    
    ChartYAxis *rightAxis = self.chartView.rightAxis;
    rightAxis.labelTextColor = [UIColor colorNamed:@"ColorGraphSD" ];
    rightAxis.axisMaximum = [self maxY];
    rightAxis.axisMinimum = [self minY];
    rightAxis.drawGridLinesEnabled = NO;
    rightAxis.granularityEnabled = YES;
    rightAxis.granularity = 1;

    
    [self.chartView animateWithXAxisDuration:.5];
//DESIGN: if you tap anywhere with your finger, a small window could appear with date and rating
    
    [self graphData];
}
- (float)maxY
{
    float max = 0;
    for(NSMutableDictionary *dict in self.ratingArray)
    {
       if( [[dict objectForKey: @"rating"]floatValue] > max)
           max = [[dict objectForKey: @"rating"]floatValue];
    }
    return max + 10;
}

- (float)minY
{
    float min = 9999;
    for(NSMutableDictionary *dict in self.ratingArray)
    {
        if( [[dict objectForKey: @"rating"]floatValue] > 0)
            if( [[dict objectForKey: @"rating"]floatValue] < min)
                min = [[dict objectForKey: @"rating"]floatValue];
        
    }
    return min - 10;
}

- (void)updateChartData
{
    if (self.shouldHideData)
    {
        self.chartView.data = nil;
        return;
    }
    
}

- (void)graphData
{
#pragma mark - Rating
    NSMutableArray *ratingData = [[NSMutableArray alloc] init];
    int i = 0;
    for(NSMutableDictionary *dict in self.ratingArray)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormatter dateFromString:[dict objectForKey: @"datum"]];
        double timeIntervall = date.timeIntervalSince1970;
        [ratingData addObject:[[ChartDataEntry alloc] initWithX:timeIntervall y:[[dict objectForKey: @"rating"]floatValue]]];
    }
    LineChartDataSet *ratingSet = nil;
    ratingSet = [[LineChartDataSet alloc] initWithEntries:ratingData label:@"Rating"];
    ratingSet.axisDependency = AxisDependencyLeft;
    [ratingSet setColor:[design schemaColor]];
    ratingSet.lineWidth = 2.0;
    ratingSet.circleRadius = 0.0;
    ratingSet.fillAlpha = 0.0;
    ratingSet.fillColor = [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f];
    ratingSet.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
    ratingSet.drawCircleHoleEnabled = NO;
    ratingSet.mode = LineChartModeLinear;


#pragma mark - Average
    NSMutableArray *averageData = [[NSMutableArray alloc] init];
    i = 0;
    for(NSMutableDictionary *dict in self.averageArray)
    {
        ChartDataEntry *ratingDict = ratingData[i++];
        if([[dict objectForKey: @"rating"]floatValue] > 0)
            [averageData addObject:[[ChartDataEntry alloc] initWithX:ratingDict.x y:[[dict objectForKey: @"rating"]floatValue]]];
     }
    NSString *text = [NSString stringWithFormat:@"Average %d days",self.average];
    LineChartDataSet *avergeSet = nil;
    avergeSet = [[LineChartDataSet alloc] initWithEntries:averageData label:text];
    avergeSet.axisDependency = AxisDependencyLeft;
    [avergeSet setColor:[UIColor yellowColor ]];
    avergeSet.lineWidth = 2.0;
    avergeSet.circleRadius = 0.0;
    avergeSet.fillAlpha = 0.0;
    avergeSet.fillColor = [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f];
    avergeSet.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
    avergeSet.drawCircleHoleEnabled = NO;
    avergeSet.mode = LineChartModeLinear;



    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:ratingSet];
    [dataSets addObject:avergeSet];

    LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
    [data setValueTextColor:UIColor.whiteColor];
    [data setValueFont:[UIFont systemFontOfSize:9.f]];
    
    self.chartView.data = data;

}


@end
