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
#import "PlayerVC.h"
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

@property (readwrite, retain, nonatomic) NSArray       *landscapeConstraints;
@property (readwrite, retain, nonatomic) NSArray       *portraitConstraints;

@end

@implementation RatingVC

@synthesize design, preferences, rating, tools, ratingTools, ratingCD;

@synthesize infoView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    design =      [[Design alloc] init];
    preferences = [[Preferences alloc] init];
    rating =      [[Rating alloc] init];
    tools =       [[Tools alloc] init];
    ratingCD =    [[RatingCD alloc] init];

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

    self.filterButton.tintColor = [UIColor colorNamed:@"ColorSwitch"];

    UIImageSymbolConfiguration *configurationColor = [UIImageSymbolConfiguration configurationWithHierarchicalColor:[design getTintColorSchema]];
    UIImageSymbolConfiguration *configurationSize = [UIImageSymbolConfiguration configurationWithPointSize:30];
    UIImageSymbolConfiguration *total = [configurationColor configurationByApplyingConfiguration:configurationSize];

    UIImage *image = [UIImage systemImageNamed:@"slider.horizontal.3" withConfiguration:total];
    
    [self.filterButton setImage:image forState:UIControlStateNormal];
    self.filterButton.tintColor = [design getTintColorSchema];

    [self filterMenu];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.moreButton.menu = [app mainMenu:self.navigationController button:self.moreButton];
    self.moreButton.showsMenuAsPrimaryAction = YES;

}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.navigationItem.hidesBackButton = YES;


    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];

    self.ratingArrayAll = [ratingCD readAlleRatingForUser:userID];

    self.ratingArray = [self filterDataArray];
    

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
    
    self.header.textColor = [design getTintColorSchema];
    self.moreButton = [design designMoreButton:self.moreButton];
    
    [self layoutObjects];
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
    
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    float edge = 5.0;
    float gap = 5;
    int width = 320;
    int height  = 200;
    
    infoView = [[UIView alloc] init];
    
    infoView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
    infoView.layer.borderWidth = 1;
    infoView.tag = 42;
    infoView.layer.cornerRadius = 14.0f;
    infoView.layer.masksToBounds = YES;
    [self.view addSubview:infoView];
    
    [infoView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [infoView.centerYAnchor constraintEqualToAnchor:safe.centerYAnchor constant:0].active = YES;
    [infoView.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor constant:0].active = YES;
    [infoView.heightAnchor constraintEqualToConstant:height].active = YES;
    [infoView.widthAnchor constraintEqualToConstant:width].active = YES;

    DGLabel *title = [[DGLabel alloc] init];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"Rating"];
    [attr addAttribute:NSFontAttributeName
                 value:[UIFont boldSystemFontOfSize:25.0]
                 range:NSMakeRange(0, [attr length])];
    [title setAttributedText:attr];

    title.textAlignment = NSTextAlignmentCenter;
    [infoView addSubview:title];
    
    [title setTranslatesAutoresizingMaskIntoConstraints:NO];
    [title.topAnchor constraintEqualToAnchor:infoView.topAnchor constant:edge].active = YES;
    [title.centerXAnchor constraintEqualToAnchor:infoView.centerXAnchor constant:0].active = YES;
    [title.heightAnchor constraintEqualToConstant:25].active = YES;

    DGLabel *message = [[DGLabel alloc] init];
    message.text = @"Every time you play via the app your highest rating for the day will be saved.";
    message.numberOfLines = 0;
    message.textAlignment = NSTextAlignmentCenter;
    [infoView addSubview:message];

    [message setTranslatesAutoresizingMaskIntoConstraints:NO];

    [message.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:gap].active = YES;
    [message.rightAnchor constraintEqualToAnchor:infoView.rightAnchor constant:-edge].active = YES;
    [message.leftAnchor constraintEqualToAnchor:infoView.leftAnchor constant:edge].active = YES;
    [message.heightAnchor constraintEqualToConstant:50].active = YES;

    Ratings *dictBest =  [ratingCD bestRating];
    Ratings *dictWorst =  [ratingCD worstRating];

    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];

    NSDate *dateDBBest = [format dateFromString:dictBest.dateRating];

    DGLabel *highText = [[DGLabel alloc] init];
    highText.text = [NSString stringWithFormat:@"Highest"];
    highText.textAlignment = NSTextAlignmentLeft;
    [infoView addSubview:highText];

    [highText setTranslatesAutoresizingMaskIntoConstraints:NO];

    [highText.topAnchor constraintEqualToAnchor:message.bottomAnchor constant:gap].active = YES;
    [highText.leftAnchor constraintEqualToAnchor:infoView.leftAnchor constant:edge].active = YES;
    [highText.heightAnchor constraintEqualToConstant:25].active = YES;
    [highText.widthAnchor constraintEqualToConstant:70].active = YES;

    DGLabel *highRating = [[DGLabel alloc] init];
    highRating.text = [NSString stringWithFormat:@"%3.1f",dictBest.rating];
    highRating.textColor = [UIColor colorNamed:@"ColorRatingHigh"];
    highRating.textAlignment = NSTextAlignmentLeft;
    [infoView addSubview:highRating];

    [highRating setTranslatesAutoresizingMaskIntoConstraints:NO];

    [highRating.topAnchor constraintEqualToAnchor:message.bottomAnchor constant:gap].active = YES;
    [highRating.leftAnchor constraintEqualToAnchor:highText.rightAnchor constant:gap].active = YES;
    [highRating.heightAnchor constraintEqualToConstant:25].active = YES;

    DGLabel *highDate = [[DGLabel alloc] init];
    highDate.text = [NSDateFormatter localizedStringFromDate:dateDBBest dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
    highDate.textAlignment = NSTextAlignmentCenter;
    [infoView addSubview:highDate];

    [highDate setTranslatesAutoresizingMaskIntoConstraints:NO];

    [highDate.topAnchor constraintEqualToAnchor:message.bottomAnchor constant:gap].active = YES;
    [highDate.rightAnchor constraintEqualToAnchor:infoView.rightAnchor constant:-edge].active = YES;
    [highDate.leftAnchor constraintEqualToAnchor:highRating.rightAnchor constant:gap].active = YES;
    [highDate.heightAnchor constraintEqualToConstant:25].active = YES;

    DGLabel *lowText = [[DGLabel alloc] init];
    lowText.text = [NSString stringWithFormat:@"Lowest"];
    lowText.textAlignment = NSTextAlignmentLeft;
    [infoView addSubview:lowText];

    [lowText setTranslatesAutoresizingMaskIntoConstraints:NO];

    [lowText.topAnchor constraintEqualToAnchor:highText.bottomAnchor constant:gap].active = YES;
    [lowText.leftAnchor constraintEqualToAnchor:infoView.leftAnchor constant:edge].active = YES;
    [lowText.heightAnchor constraintEqualToConstant:25].active = YES;
    [lowText.widthAnchor constraintEqualToConstant:70].active = YES;

    DGLabel *lowRating = [[DGLabel alloc] init];
    lowRating.text = [NSString stringWithFormat:@"%3.1f",dictWorst.rating];
    lowRating.textColor = [UIColor colorNamed:@"ColorRatingLow"];
    lowRating.textAlignment = NSTextAlignmentLeft;
    [infoView addSubview:lowRating];

    [lowRating setTranslatesAutoresizingMaskIntoConstraints:NO];

    [lowRating.topAnchor constraintEqualToAnchor:highText.bottomAnchor constant:gap].active = YES;
    [lowRating.leftAnchor constraintEqualToAnchor:lowText.rightAnchor constant:gap].active = YES;
    [lowRating.heightAnchor constraintEqualToConstant:25].active = YES;

    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateDBWorst = [format dateFromString:dictWorst.dateRating];

    DGLabel *lowDate = [[DGLabel alloc] init];
    lowDate.text = [NSString stringWithFormat:@"%@",[format stringFromDate:dateDBWorst]];
    lowDate.text = [NSDateFormatter localizedStringFromDate:dateDBWorst dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];

    lowDate.textAlignment = NSTextAlignmentRight;
    [infoView addSubview:lowDate];

    [lowDate setTranslatesAutoresizingMaskIntoConstraints:NO];

    [lowDate.topAnchor constraintEqualToAnchor:highText.bottomAnchor constant:gap].active = YES;
    [lowDate.rightAnchor constraintEqualToAnchor:infoView.rightAnchor constant:-edge].active = YES;
    [lowDate.leftAnchor constraintEqualToAnchor:lowRating.rightAnchor constant:gap].active = YES;
    [lowDate.heightAnchor constraintEqualToConstant:25].active = YES;

    DGButton *buttonClose = [[DGButton alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    [buttonClose setTitle:@"Close" forState: UIControlStateNormal];
    [buttonClose addTarget:self action:@selector(closeInfo) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:buttonClose];
    
    [buttonClose setTranslatesAutoresizingMaskIntoConstraints:NO];

    [buttonClose.bottomAnchor constraintEqualToAnchor:infoView.bottomAnchor constant:-edge].active = YES;
    [buttonClose.centerXAnchor constraintEqualToAnchor:infoView.centerXAnchor constant:0].active = YES;
    [buttonClose.heightAnchor constraintEqualToConstant:25].active = YES;
    [buttonClose.widthAnchor constraintEqualToConstant:70].active = YES;

    
}

-(void)closeInfo
{
    [infoView removeFromSuperview];

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
        SetUpVC *controller = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"SetUpVC"];
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

#pragma mark - filter Menu
-(void)filterMenu
{
    
    NSMutableArray  *menuAverageArray = [[NSMutableArray alloc] initWithCapacity:3];

    [menuAverageArray addObject:[UIAction actionWithTitle:@"No"
                                             image:nil
                                        identifier:@"0"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self averageAction:0];
   }]];
   
    [menuAverageArray addObject:[UIAction actionWithTitle:@"7"
                                             image:nil
                                        identifier:@"1"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self averageAction:1];
    }]];
    [menuAverageArray addObject:[UIAction actionWithTitle:@"30"
                                             image:nil
                                        identifier:@"2"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self averageAction:2];
    }]];
    [menuAverageArray addObject:[UIAction actionWithTitle:@"90"
                                             image:nil
                                        identifier:@"3"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self averageAction:3];
    }]];
    [menuAverageArray addObject:[UIAction actionWithTitle:@"365"
                                             image:nil
                                        identifier:@"4"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self averageAction:4];
    }]];

    UIMenu *averageMenu = [UIMenu menuWithTitle:@"Average"  children:menuAverageArray];
    
    NSMutableArray  *menuDaysArray = [[NSMutableArray alloc] initWithCapacity:3];

    [menuDaysArray addObject:[UIAction actionWithTitle:@"All"
                                             image:nil
                                        identifier:@"0"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self daysAction:0];
   }]];
   
    [menuDaysArray addObject:[UIAction actionWithTitle:@"30"
                                             image:nil
                                        identifier:@"1"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self daysAction:1];
    }]];
    [menuDaysArray addObject:[UIAction actionWithTitle:@"60"
                                             image:nil
                                        identifier:@"2"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self daysAction:2];
    }]];
    [menuDaysArray addObject:[UIAction actionWithTitle:@"90"
                                             image:nil
                                        identifier:@"3"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self daysAction:3];
    }]];
    [menuDaysArray addObject:[UIAction actionWithTitle:@"365"
                                             image:nil
                                        identifier:@"4"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self daysAction:4];
    }]];

    UIMenu *daysMenu = [UIMenu menuWithTitle:@"Show last x days"  children:menuDaysArray];

    NSMutableArray  *menuArray = [[NSMutableArray alloc] initWithCapacity:3];

    [menuArray addObject:averageMenu];
    [menuArray addObject:daysMenu];

    self.filterButton.menu = [UIMenu menuWithChildren:menuArray];
    self.filterButton.showsMenuAsPrimaryAction = YES;
}

#pragma mark - Filter


- (IBAction)averageAction:(int)selected
{
    switch(selected)
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
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:selected forKey:@"ratingAverage"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self makeAverageArray];
    [self initGraph];

}

- (IBAction)daysAction:(int)selected
{
    switch(selected)
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
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:selected forKey:@"ratingData"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    self.ratingArray = [self filterDataArray];

    [self makeAverageArray];
    [self initGraph];

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
    NSString *ratinglabel = [NSString stringWithFormat:@"Rating %d days",self.dataRange];
    if(self.dataRange == 0)
        ratinglabel = @"Rating all days";
    ratingSet = [[LineChartDataSet alloc] initWithEntries:ratingData label:ratinglabel];
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

#pragma mark - autoLayout
-(void)layoutObjects
{
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    float edge = 5.0;
    float gap = 5;

#pragma mark moreButton autoLayout
    [self.moreButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.moreButton.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge].active = YES;
    [self.moreButton.heightAnchor constraintEqualToConstant:40].active = YES;
    [self.moreButton.widthAnchor constraintEqualToConstant:40].active = YES;
    [self.moreButton.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;

#pragma mark filterButton autoLayout
    [self.filterButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.filterButton.topAnchor constraintEqualToAnchor:self.moreButton.topAnchor constant:0].active = YES;
    [self.filterButton.heightAnchor constraintEqualToConstant:40].active = YES;
    [self.filterButton.widthAnchor constraintEqualToConstant:40].active = YES;
    [self.filterButton.rightAnchor constraintEqualToAnchor:self.moreButton.leftAnchor constant:-edge].active = YES;

#pragma mark infoButton autoLayout
    [self.infoButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.infoButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.infoButton.widthAnchor constraintEqualToConstant:70].active = YES;
    [self.infoButton.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;

#pragma mark shareButton autoLayout
    [self.shareButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.shareButton.topAnchor constraintEqualToAnchor:self.infoButton.topAnchor constant:0].active = YES;
    [self.shareButton.leftAnchor constraintEqualToAnchor:self.infoButton.rightAnchor constant:gap].active = YES;
    [self.shareButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.shareButton.widthAnchor constraintEqualToConstant:70].active = YES;

#pragma mark iCloudButton autoLayout
    [self.iCloud setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.iCloud.topAnchor constraintEqualToAnchor:self.infoButton.topAnchor constant:0].active = YES;
    [self.iCloud.leftAnchor constraintEqualToAnchor:self.shareButton.rightAnchor constant:gap].active = YES;
    [self.iCloud.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.iCloud.widthAnchor constraintEqualToConstant:70].active = YES;

#pragma mark iCloudConnected autoLayout
    [self.iCloudConnected setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.iCloudConnected.topAnchor constraintEqualToAnchor:self.infoButton.topAnchor constant:0].active = YES;
    [self.iCloudConnected.leftAnchor constraintEqualToAnchor:self.iCloud.rightAnchor constant:gap].active = YES;
    [self.iCloudConnected.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.iCloudConnected.widthAnchor constraintEqualToConstant:35].active = YES;

#pragma mark header autoLayout
    [self.header setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.header.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge].active = YES;
    [self.header.heightAnchor constraintEqualToConstant:40].active = YES;
    [self.header.rightAnchor constraintEqualToAnchor:self.filterButton.leftAnchor constant:-edge].active = YES;


    self.landscapeConstraints = @[
        [self.infoButton.topAnchor constraintEqualToAnchor:self.moreButton.topAnchor constant:0],
        [self.header.leftAnchor constraintEqualToAnchor:self.iCloudConnected.rightAnchor constant:gap]
    ];
    self.portraitConstraints = @[
        [self.infoButton.topAnchor constraintEqualToAnchor:self.header.bottomAnchor constant:gap],
        [self.header.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge]
    ];

    if(safe.layoutFrame.size.width > 500 )
    {
        [NSLayoutConstraint deactivateConstraints:self.portraitConstraints];
        [NSLayoutConstraint activateConstraints:self.landscapeConstraints];
    }
    else
    {
        [NSLayoutConstraint deactivateConstraints:self.landscapeConstraints];
        [NSLayoutConstraint activateConstraints:self.portraitConstraints];
    }

#pragma mark chartView autoLayout
    self.chartView = [[LineChartView alloc]initWithFrame:CGRectMake(0 + gap, safe.layoutFrame.origin.y + self.gap, safe.layoutFrame.size.width - gap, safe.layoutFrame.size.height - self.gap - 20 )];
    [self.view addSubview:self.chartView];

    [self.chartView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.chartView.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.chartView.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.chartView.topAnchor constraintEqualToAnchor:self.infoButton.bottomAnchor constant:20].active = YES;
    [self.chartView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-edge].active = YES;

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
        
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;

    if(safe.layoutFrame.size.width > 500 )
    {
        [NSLayoutConstraint deactivateConstraints:self.portraitConstraints];
        [NSLayoutConstraint activateConstraints:self.landscapeConstraints];
    }
    else
    {
        [NSLayoutConstraint deactivateConstraints:self.landscapeConstraints];
        [NSLayoutConstraint activateConstraints:self.portraitConstraints];
    }

}

@end
