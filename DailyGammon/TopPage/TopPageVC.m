//
//  TopPageVC.m
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

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
#import "RatingVC.h"
#import "Player.h"
#import "iPhoneMenue.h"
#import "iPhonePlayMatch.h"
#import "Tools.h"
#import "NoInternet.h"
#import <SafariServices/SafariServices.h>

@interface TopPageVC ()

@property (readwrite, retain, nonatomic) NSMutableData *datenData;
@property (readwrite, retain, nonatomic) NSURLConnection *downloadConnection;
@property (assign, atomic) BOOL loginOk;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (readwrite, retain, nonatomic) NSMutableArray *topPageArray;
@property (readwrite, retain, nonatomic) NSMutableArray *topPageHeaderArray;
@property (weak, nonatomic) IBOutlet UIButton *sortGraceButton;
@property (weak, nonatomic) IBOutlet UIButton *sortPoolButton;
@property (weak, nonatomic) IBOutlet UIButton *sortGracePoolButton;
@property (weak, nonatomic) IBOutlet UIButton *sortRecentButton;
@property (weak, nonatomic) IBOutlet UILabel *header;

@property (readwrite, retain, nonatomic) NSString *matchString;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *moreButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;

@property (weak, nonatomic) IBOutlet UIButton *refreshButtonIPAD;

@property (assign, atomic) float nummerBreite;
@property (assign, atomic) float graceBreite;
@property (assign, atomic) float poolBreite;
@property (assign, atomic) float roundBreite;
@property (assign, atomic) float lengthBreite;
@property (assign, atomic) float opponentBreite;
@property (assign, atomic) float eventBreite;

@property (readwrite, retain, nonatomic) UIButton *topPageButton;

@property (nonatomic, retain, readwrite) UIActivityIndicatorView *indicator;

@end

@implementation TopPageVC

@synthesize design, preferences, rating, tools;

- (void)viewDidLoad
{
    [super viewDidLoad];

//    NSURL *scriptUrl = [NSURL URLWithString:@"http://www.google.com/m"];
//    NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
//    if (data)
//        NSLog(@"Device is connected to the Internet");
//    else
//        NSLog(@"Device is not connected to the Internet");
//
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
    self.indicator.color = [schemaDict objectForKey:@"TintColor"];
    self.indicator.center = self.view.center;
    [self.view addSubview:self.indicator];

    self.view.backgroundColor = VIEWBACKGROUNDCOLOR;
//    self.tableView.backgroundColor = HEADERBACKGROUNDCOLOR;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reDrawHeader) name:@"changeSchemaNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readTopPage) name:@"applicationDidBecomeActive" object:nil];

    design      = [[Design alloc] init];
    preferences = [[Preferences alloc] init];
    rating      = [[Rating alloc] init];
    tools       = [[Tools alloc] init];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if([design isX])
    {
        UIEdgeInsets safeArea = [[UIApplication sharedApplication] keyWindow].safeAreaInsets;
        
        CGRect frame = self.tableView.frame;
        frame.origin.x = safeArea.left ;
        frame.size.width = self.tableView.frame.size.width - safeArea.left ;
        self.tableView.frame = frame;
    }
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        self.nummerBreite = 40;
        self.graceBreite  = 80;
        self.poolBreite   = 120;
        self.roundBreite  = 80;
        self.lengthBreite = 80;
    }
    else
    {
        self.nummerBreite = 30;
        self.graceBreite  = 70;
        self.poolBreite   = 86;
        self.roundBreite  = 70;
        self.lengthBreite = 70;
    }
    self.opponentBreite = (self.tableView.frame.size.width - self.nummerBreite - self.graceBreite - self.poolBreite - self.roundBreite - self.lengthBreite)/2 ;
    self.eventBreite = self.opponentBreite;

}
- (UIActivityIndicatorView *)indicator
{
    if (!_indicator)
    {
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _indicator;
}
-(void) reDrawHeader
{
//    [self.view addSubview:[self makeHeader]];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self.view addSubview:[self makeHeader]];
    else
    {
        int maxBreite = [UIScreen mainScreen].bounds.size.width;
        int rand = 20;
        float luecke = (maxBreite - rand - rand - self.sortGraceButton.frame.size.width - self.sortPoolButton.frame.size.width - self.sortGracePoolButton.frame.size.width - self.sortRecentButton.frame.size.width) / 3;
        CGRect buttonFrame;
        buttonFrame = self.sortPoolButton.frame;
        buttonFrame.origin.x = self.sortGraceButton.frame.origin.x + self.sortGraceButton.frame.size.width + luecke;
        self.sortPoolButton.frame = buttonFrame;
        
        buttonFrame = self.sortGracePoolButton.frame;
        buttonFrame.origin.x = self.sortPoolButton.frame.origin.x + self.sortPoolButton.frame.size.width + luecke;
        self.sortGracePoolButton.frame = buttonFrame;
        
        buttonFrame = self.sortRecentButton.frame;
        buttonFrame.origin.x = self.sortGracePoolButton.frame.origin.x + self.sortGracePoolButton.frame.size.width + luecke;
        self.sortRecentButton.frame = buttonFrame;

    }
    
    self.sortGraceButton = [design makeNiceButton:self.sortGraceButton];
    self.sortPoolButton = [design makeNiceButton:self.sortPoolButton];
    self.sortGracePoolButton = [design makeNiceButton:self.sortGracePoolButton];
    self.sortRecentButton = [design makeNiceButton:self.sortRecentButton];

    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];

    self.moreButton.tintColor = [schemaDict objectForKey:@"TintColor"];
    
    self.refreshButtonIPAD = [design makeNiceButton:self.refreshButtonIPAD];
    self.refreshButtonIPAD.tintColor = [schemaDict objectForKey:@"TintColor"];

    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[schemaDict objectForKey:@"TintColor"]}];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//    if(![tools hasConnectivity])
//    {
//
//        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//
//        NoInternet *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"NoInternet"];
//
//        [self.navigationController pushViewController:vc animated:NO];
//        return;
//    }

    [self.indicator startAnimating];

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    else
        [self.navigationController setNavigationBarHidden:NO animated:animated];

    NSString *userName     = [[NSUserDefaults standardUserDefaults] stringForKey:@"user"];
    NSString *userPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];

    self.loginOk = FALSE;

    //    https://stackoverflow.com/questions/15749486/sending-an-http-post-request-on-ios
    NSString *post               = [NSString stringWithFormat:@"login=%@&password=%@",userName,userPassword];
    NSData *postData             = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength         = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://dailygammon.com/bg/login"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    
#warning https://stackoverflow.com/questions/32647138/nsurlconnection-initwithrequest-is-deprecated
    if(conn)
    {
        //XLog(@"Connection Successful");
    } else
    {
        //XLog(@"Connection could not be made");
    }

    if (self.downloadConnection)
    {
        self.datenData = [[NSMutableData alloc] init];
    }
    [self reDrawHeader];

}

/**/
#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.datenData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(self.loginOk)
        [self.datenData appendData:data];
    else
        self.loginOk = TRUE;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    XLog(@"Connection didFailWithError");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
//        XLog(@"name: '%@'\n",   [cookie name]);
//        XLog(@"value: '%@'\n",  [cookie value]);
//        XLog(@"domain: '%@'\n", [cookie domain]);
//        XLog(@"path: '%@'\n",   [cookie path]);
        if([[cookie name] isEqualToString:@"USERID"])
            [[NSUserDefaults standardUserDefaults] setValue:[cookie value] forKey:@"USERID"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        if([[cookie value] isEqualToString:@"N/A"])
        {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

            LoginVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"LoginVC"];
            [self.navigationController pushViewController:vc animated:NO];
        }
        else
        {
            [ self readTopPage];
        }
    }
    XLog(@"cookie %ld",[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies].count);
    if([[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies].count < 1)
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        LoginVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"LoginVC"];
        [self.navigationController pushViewController:vc animated:NO];
    }
    
    return;
}
/**/
#pragma mark - Hpple

-(void)readTopPage
{

    [self.indicator startAnimating];

    NSURL *urlTopPage = [NSURL URLWithString:@"http://dailygammon.com/bg/top"];
    NSData *topPageHtmlData = [NSData dataWithContentsOfURL:urlTopPage];

    NSString *htmlString = [NSString stringWithUTF8String:[topPageHtmlData bytes]];
    htmlString = [[NSString alloc]
                  initWithData:topPageHtmlData encoding: NSISOLatin1StringEncoding];
    self.topPageArray = [[NSMutableArray alloc]init];

    if ([htmlString rangeOfString:@"There are no matches where you can move."].location != NSNotFound)
    {
        [self.indicator stopAnimating];
        self.header.text = [NSString stringWithFormat:@"There are no matches where you can move."];
        self.navigationBar.title = [NSString stringWithFormat:@"There are no matches where you can move."];

        return;
    }

    // Create parser
    
    //    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:topPageHtmlData];
    
    NSData *htmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];

    //Get all the cells of the 2nd row of the 3rd table
    //        NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[3]/tr[2]/td"];
    int tableNo = 1;
    if([preferences isMiniBoard])
        tableNo = 1;
    else
        tableNo = 2;
    NSString *queryString = [NSString stringWithFormat:@"//table[%d]/tr[1]/th",tableNo];
    NSArray *elementHeader  = [xpathParser searchWithXPathQuery:queryString];
    self.topPageHeaderArray = [[NSMutableArray alloc]init];

    for(TFHppleElement *element in elementHeader)
    {
        //            XLog(@"%@",[element text]);
        [self.topPageHeaderArray addObject:[element text]];
    }
    self.topPageArray = [[NSMutableArray alloc]init];
    queryString = [NSString stringWithFormat:@"//table[%d]/tr",tableNo];
    NSArray *zeilen  = [xpathParser searchWithXPathQuery:queryString];
    for(int zeile = 2; zeile <= zeilen.count; zeile ++)
    {
        NSMutableArray *topPageZeile = [[NSMutableArray alloc]init];

        NSString * searchString = [NSString stringWithFormat:@"//table[%d]/tr[%d]/td",tableNo,zeile];
        NSArray *elementZeile  = [xpathParser searchWithXPathQuery:searchString];
        for(TFHppleElement *element in elementZeile)
        {
            NSMutableDictionary *topPageZeileSpalte = [[NSMutableDictionary alloc]init];

            for (TFHppleElement *child in element.children)
            {
//                XLog(@"Child %@", child);

                if ([child.tagName isEqualToString:@"a"])
                {
                   // NSDictionary *href = [child attributes];
                    [topPageZeileSpalte setValue:[child content] forKey:@"Text"];
                    [topPageZeileSpalte setValue:[[child attributes] objectForKey:@"href"]forKey:@"href"];

//                    XLog(@"gefunden %@", [child attributes]);
                }
                else
                {
                    [topPageZeileSpalte setValue:[element content] forKey:@"Text"];
                }
            }
            [topPageZeile addObject:topPageZeileSpalte];
        }
//        XLog(@"%@", topPageZeile);

        [self.topPageArray addObject:topPageZeile];
    }
    [self updateTableView];
    
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return self.topPageArray.count;
}
//This function is where all the magic happens
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //https://stackoverflow.com/questions/40203124/uitableviewcell-animation-only-once
    UIView *cellContentView = [cell contentView];
    CGFloat rotationAngleDegrees = -30;
    CGFloat rotationAngleRadians = rotationAngleDegrees * (M_PI/180);
    CGPoint offsetPositioning = CGPointMake(0, cell.contentView.frame.size.height*10);
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DRotate(transform, rotationAngleRadians, -50.0, 0.0, 1.0);
    transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y, -50.0);
    cellContentView.layer.transform = transform;
    cellContentView.layer.opacity = 0.8;
    
    [UIView animateWithDuration:0.95 delay:00 usingSpringWithDamping:0.85 initialSpringVelocity:0.8 options:0 animations:^{
        cellContentView.layer.transform = CATransform3DIdentity;
        cellContentView.layer.opacity = 1;
    } completion:^(BOOL finished) {}];

    return;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    for (UIView *subview in [cell.contentView subviews])
    {
        if ([subview isKindOfClass:[UILabel class]])
        {
            [subview removeFromSuperview];
        }
    }
    [cell setTintColor:[UIColor greenColor]];

    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell setTintColor:[UIColor greenColor]];
    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1)
        boardSchema = 4;
    NSString *imageName = @"pfeil_rot.png";
    switch(boardSchema)
    {
        case 1:
        case 2:
            imageName = @"pfeil_gruen.png";
            break;
        case 3:
            imageName = @"pfeil_blau.png";
            break;
        case 4:
            imageName = @"pfeil_rot.png";
            break;
            
    }

    UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    CGRect frame = checkmark.frame;
    frame.size.height = 10;
    frame.size.width = 10;

    checkmark.frame = frame;
    cell.accessoryView = checkmark;
    
    
    NSArray *zeile = self.topPageArray[indexPath.row];
    
    int x = 0;
    int labelHoehe = cell.frame.size.height;
//    int nummerBreite = 40;
//    int graceBreite = 80;
//    int poolBreite = 120;
//    int roundBreite = 80;
//    int lengthBreite = 80;
//    int opponentBreite = (tableView.frame.size.width - nummerBreite - graceBreite - poolBreite - roundBreite - lengthBreite)/2 ;
//    int eventBreite = opponentBreite;
    
    UILabel *nummerLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,self.nummerBreite,labelHoehe)];
    nummerLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *nummer = zeile[0];
    nummerLabel.text = [nummer objectForKey:@"Text"];
    
    x += self.nummerBreite;
    
    UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,self.eventBreite,labelHoehe)];
    eventLabel.textAlignment = NSTextAlignmentLeft;
    NSDictionary *event = zeile[1];
    eventLabel.text = [event objectForKey:@"Text"];
    eventLabel.adjustsFontSizeToFitWidth = YES;

    x += self.eventBreite;
    
    UILabel *graceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,self.graceBreite,labelHoehe)];
    graceLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *grace = zeile[2];
    graceLabel.text = [grace objectForKey:@"Text"];
    graceLabel.adjustsFontSizeToFitWidth = YES;

    x += self.graceBreite;
    
    UILabel *poolLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,self.poolBreite,labelHoehe)];
    poolLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *pool = zeile[3];
    poolLabel.text = [pool objectForKey:@"Text"];
    poolLabel.adjustsFontSizeToFitWidth = YES;

    x += self.poolBreite;
    
    UILabel *roundLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,self.roundBreite,labelHoehe)];
    roundLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *round = zeile[4];
    roundLabel.text = [round objectForKey:@"Text"];
    roundLabel.adjustsFontSizeToFitWidth = YES;

    x += self.roundBreite;
    
    UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,self.lengthBreite,labelHoehe)];
    lengthLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *length = zeile[5];
    lengthLabel.text = [length objectForKey:@"Text"];
    lengthLabel.adjustsFontSizeToFitWidth = YES;

    x += self.lengthBreite;
    
    UILabel *opponentLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,self.opponentBreite,labelHoehe)];
    opponentLabel.textAlignment = NSTextAlignmentLeft;
    opponentLabel.text = self.topPageHeaderArray[6];
    NSDictionary *opponent = zeile[6];
    opponentLabel.text = [opponent objectForKey:@"Text"];
    opponentLabel.adjustsFontSizeToFitWidth = YES;

    [cell.contentView addSubview:nummerLabel];
    [cell.contentView addSubview:eventLabel];
    [cell.contentView addSubview:graceLabel];
    [cell.contentView addSubview:poolLabel];
    [cell.contentView addSubview:roundLabel];
    [cell.contentView addSubview:lengthLabel];
    [cell.contentView addSubview:opponentLabel];

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(tableView.frame.origin.x,0,tableView.frame.size.width,30)];
    headerView.backgroundColor = [UIColor lightGrayColor];

    int x = 0;

    UILabel *nummerLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,self.nummerBreite,30)];
    nummerLabel.textAlignment = NSTextAlignmentCenter;
    nummerLabel.text = self.topPageHeaderArray[0];
    nummerLabel.textColor = [UIColor whiteColor];
    x += self.nummerBreite;
    
    UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,self.eventBreite,30)];
    eventLabel.textAlignment = NSTextAlignmentCenter;
    eventLabel.text = self.topPageHeaderArray[1];
    eventLabel.textColor = [UIColor whiteColor];
    UIButton *buttonEvent = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonEvent.frame = eventLabel.frame;
    [buttonEvent addTarget:self action:@selector(sortEvent) forControlEvents:UIControlEventTouchUpInside];

    x += self.eventBreite;

    UILabel *graceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, self.graceBreite, 30)];
    graceLabel.textAlignment = NSTextAlignmentCenter;
    graceLabel.text = self.topPageHeaderArray[2];
    graceLabel.textColor = [UIColor whiteColor];
    UIButton *buttonGrace = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonGrace.frame = graceLabel.frame;
    [buttonGrace addTarget:self action:@selector(sortGrace:) forControlEvents:UIControlEventTouchUpInside];

    x += self.graceBreite;
    
    UILabel *poolLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, self.poolBreite,30)];
    poolLabel.textAlignment = NSTextAlignmentCenter;
    poolLabel.text = self.topPageHeaderArray[3];
    poolLabel.textColor = [UIColor whiteColor];
    UIButton *buttonPool = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonPool.frame = poolLabel.frame;
    [buttonPool addTarget:self action:@selector(sortPool:) forControlEvents:UIControlEventTouchUpInside];

    x += self.poolBreite;
    
    UILabel *roundLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, self.roundBreite,30)];
    roundLabel.textAlignment = NSTextAlignmentCenter;
    roundLabel.text = self.topPageHeaderArray[4];
    roundLabel.textColor = [UIColor whiteColor];
    UIButton *buttonRound = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonRound.frame = roundLabel.frame;
    [buttonRound addTarget:self action:@selector(sortRound) forControlEvents:UIControlEventTouchUpInside];

    x += self.roundBreite;
    
    UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 , self.lengthBreite,30)];
    lengthLabel.textAlignment = NSTextAlignmentCenter;
    lengthLabel.text = self.topPageHeaderArray[5];
    lengthLabel.textColor = [UIColor whiteColor];
    UIButton *buttonLength = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonLength.frame = lengthLabel.frame;
    [buttonLength addTarget:self action:@selector(sortLength) forControlEvents:UIControlEventTouchUpInside];

    x += self.lengthBreite;
    
    UILabel *opponentLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 , self.opponentBreite,30)];
    opponentLabel.textAlignment = NSTextAlignmentCenter;
    opponentLabel.text = self.topPageHeaderArray[6];
    opponentLabel.textColor = [UIColor whiteColor];
    UIButton *buttonOpponent = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonOpponent.frame = opponentLabel.frame;
    [buttonOpponent addTarget:self action:@selector(sortOpponent) forControlEvents:UIControlEventTouchUpInside];

    int order = [preferences readNextMatchOrdering];
                 
    
    switch([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue])
    {
        case 4:
            order = 4;
            break;
        case 41:
            order = 41;
            break;
       case 5:
            order = 5;
            break;
        case 51:
            order = 51;
            break;
       case 6:
            order = 6;
           break;
        case 61:
            order = 61;
            break;
        case 7:
            order = 7;
            break;
        case 71:
            order = 71;
            break;
   }
    
    
    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];

    switch (order)
    {
        case 0:
            graceLabel.textColor = [schemaDict objectForKey:@"TintColor"];
            break;
        case 1:
            poolLabel.textColor = [schemaDict objectForKey:@"TintColor"];
            break;
        case 2:
            graceLabel.textColor = [schemaDict objectForKey:@"TintColor"];
            poolLabel.textColor = [schemaDict objectForKey:@"TintColor"];
            break;
        case 3:
            opponentLabel.textColor = [schemaDict objectForKey:@"TintColor"];
            break;
        case 4:
            roundLabel = [design makeSortLabel:roundLabel sortOrderDown:YES];
            break;
        case 41:
            roundLabel = [design makeSortLabel:roundLabel sortOrderDown:NO];
            break;
        case 5:
            lengthLabel = [design makeSortLabel:lengthLabel sortOrderDown:YES];
            break;
        case 51:
            lengthLabel = [design makeSortLabel:lengthLabel sortOrderDown:NO];
            break;
       case 6:
            eventLabel = [design makeSortLabel:eventLabel sortOrderDown:YES];
           break;
        case 61:
            eventLabel = [design makeSortLabel:eventLabel sortOrderDown:NO];
            break;
        case 7:
            opponentLabel = [design makeSortLabel:opponentLabel sortOrderDown:YES];
            break;
        case 71:
            opponentLabel = [design makeSortLabel:opponentLabel sortOrderDown:NO];
        break;  }

    [headerView addSubview:nummerLabel];
    
    [headerView addSubview:eventLabel];
    [headerView addSubview:buttonEvent];

    [headerView addSubview:graceLabel];
    [headerView addSubview:buttonGrace];
    
    [headerView addSubview:poolLabel];
    [headerView addSubview:buttonPool];

    [headerView addSubview:roundLabel];
    [headerView addSubview:buttonRound];
    
    [headerView addSubview:lengthLabel];
    [headerView addSubview:buttonLength];
    
    [headerView addSubview:opponentLabel];
    [headerView addSubview:buttonOpponent];

    return headerView;
    
}

- (void)updateTableView
{
    
    self.header.text = [NSString stringWithFormat:@"%d Matches where you can move:"
                        ,(int)self.topPageArray.count];
    self.navigationBar.title = [NSString stringWithFormat:@"%d Matches where you can move" ,(int)self.topPageArray.count];
    if(self.topPageArray.count == 0)
    {
        self.header.text = [NSString stringWithFormat:@"There are no matches where you can move."];
        self.navigationBar.title = [NSString stringWithFormat:@"There are no matches where you can move."];

    }
    [self.topPageButton setTitle:[NSString stringWithFormat:@"%d Top Page", (int)self.topPageArray.count] forState: UIControlStateNormal];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{

                        NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];
                        float ratingUser = [self->rating readRatingForUser:userID];

                        NSDateFormatter *format = [[NSDateFormatter alloc] init];
                        [format setDateFormat:@"yyy-MM-dd"];
                        NSString *dateDB = [format stringFromDate:[NSDate date]];
                       
                        float ratingDB = [app.dbConnect readRatingForDatum:dateDB andUser:userID];
                        if(ratingUser > ratingDB)
                            [app.dbConnect saveRating:dateDB withRating:ratingUser forUser:userID];
                   });

    switch([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue])
    {
        case 4:
        case 41:
            [self sortRound];
            break;
        case 5:
        case 51:
            [self sortLength];
            break;
        case 6:
        case 61:
            [self sortEvent];
            break;
        case 7:
        case 71:
            [self sortOpponent];
            break;
     default:
            [self.tableView reloadData];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                        inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionTop animated:NO];

            break;
    }
    [self.indicator stopAnimating];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([preferences isMiniBoard])
    {
        [self miniBoardSchemaWarning];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:Nil];
    NSArray *zeile = self.topPageArray[indexPath.row];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        PlayMatch *vc = [app.activeStoryBoard  instantiateViewControllerWithIdentifier:@"PlayMatch"];
        NSDictionary *match = zeile[8];
        vc.matchLink = [match objectForKey:@"href"];
        vc.topPageArray = self.topPageArray;
        [self.navigationController pushViewController:vc animated:NO];
    }
    else
    {
        iPhonePlayMatch *vc = [app.activeStoryBoard  instantiateViewControllerWithIdentifier:@"iPhonePlayMatch"];
        NSDictionary *match = zeile[8];
        vc.matchLink = [match objectForKey:@"href"];
        vc.topPageArray = self.topPageArray;

        [self.navigationController pushViewController:vc animated:NO];

    }
}
#pragma mark - Sort

- (IBAction)sortGrace:(id)sender
{
    [self matchOrdering:0];
}
- (IBAction)sortPool:(id)sender
{
    [self matchOrdering:1];
}
- (IBAction)sortGracePool:(id)sender
{
    [self matchOrdering:2];
}
- (IBAction)sortRecent:(id)sender
{
    [self matchOrdering:3];
}

-(void)matchOrdering:(int)typ
{
    NSString *postString = [NSString stringWithFormat:@"order=%d",typ];
    NSString *preferencesString = @"";
    NSMutableArray *preferencesArray = [preferences readPreferences];
    for(NSMutableDictionary *preferencesDict in preferencesArray)
    {
        if([preferencesDict objectForKey:@"checked"] != nil)
        {
            preferencesString = [NSString stringWithFormat:@"%@&%@=on",preferencesString,[preferencesDict objectForKey:@"name"]];
        }
        else
        {
            preferencesString = [NSString stringWithFormat:@"%@&%@=off",preferencesString,[preferencesDict objectForKey:@"name"]];
        }
    }
    postString = [NSString stringWithFormat:@"%@%@",postString,preferencesString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://dailygammon.com/bg/profile/pref"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    [NSURLConnection connectionWithRequest:request delegate:self];
 
    [[NSUserDefaults standardUserDefaults] setInteger:typ forKey:@"orderTyp"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
}

-(void)sortOpponent
{
    [self.topPageArray sortUsingComparator:^(id first, id second){
        id firstObject = [first objectAtIndex:6];
        id secondObject = [second objectAtIndex:6];
        NSString *erstes = [[firstObject objectForKey:@"Text"]lastPathComponent];
        NSString *zweites = [[secondObject objectForKey:@"Text"]lastPathComponent];
        
        NSComparisonResult result = [erstes compare:zweites options:NSCaseInsensitiveSearch];
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] != 7)
        {
            if( result == NSOrderedAscending)
                return NSOrderedDescending;
            if( result == NSOrderedDescending)
                return NSOrderedAscending;
        }
        else
            return result;
        
        return NSOrderedSame;
    }];
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] != 7)
        [[NSUserDefaults standardUserDefaults] setInteger:7 forKey:@"orderTyp"];
    else
        [[NSUserDefaults standardUserDefaults] setInteger:71 forKey:@"orderTyp"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
}

-(void)sortEvent
{
    [self.topPageArray sortUsingComparator:^(id first, id second){
        id firstObject = [first objectAtIndex:1];
        id secondObject = [second objectAtIndex:1];
        NSString *erstes = [[firstObject objectForKey:@"Text"]lastPathComponent];
        NSString *zweites = [[secondObject objectForKey:@"Text"]lastPathComponent];

        NSComparisonResult result = [erstes compare:zweites options:NSCaseInsensitiveSearch];
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] != 6)
        {
            if( result == NSOrderedAscending)
                return NSOrderedDescending;
            if( result == NSOrderedDescending)
                return NSOrderedAscending;
        }
        else
            return result;

        return NSOrderedSame;
    }];

    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] != 6)
        [[NSUserDefaults standardUserDefaults] setInteger:6 forKey:@"orderTyp"];
    else
        [[NSUserDefaults standardUserDefaults] setInteger:61 forKey:@"orderTyp"];

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
}

-(void)sortLength
{
    [self.topPageArray sortUsingComparator:^(id first, id second){
        id firstObject = [first objectAtIndex:5];
        id secondObject = [second objectAtIndex:5];
        int erstes = [[firstObject objectForKey:@"Text"]intValue];
        int zweites = [[secondObject objectForKey:@"Text"]intValue];
        
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] == 5)
        {
            if(erstes < zweites)
                return NSOrderedAscending;
            if(erstes > zweites)
                return NSOrderedDescending;
            if(erstes == zweites)
                return NSOrderedSame;
        }
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] != 5)
        {
            if(erstes > zweites)
                return NSOrderedAscending;
            if(erstes < zweites)
                return NSOrderedDescending;
            if(erstes == zweites)
                return NSOrderedSame;
        }
       return NSOrderedSame;
    }];
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] != 5)
        [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"orderTyp"];
    else
        [[NSUserDefaults standardUserDefaults] setInteger:51 forKey:@"orderTyp"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop animated:NO];

}

-(void)sortRound
{
    [self.topPageArray sortUsingComparator:^(id first, id second){
        id firstObject = [first objectAtIndex:4];
        id secondObject = [second objectAtIndex:4];
        
        float erstes = .0001;
        float zweites = .0001;
        NSString *vorne = @"";
        NSString *hinten = @"";

        NSArray *Array = [[firstObject objectForKey:@"Text"] componentsSeparatedByString:@"/"];
        if(Array.count == 2)
        {
            vorne = [Array objectAtIndex:0];
            hinten = [Array objectAtIndex:1];
            erstes = [vorne floatValue] / [hinten floatValue];
        }
        Array = [[secondObject objectForKey:@"Text"] componentsSeparatedByString:@"/"];
        if(Array.count == 2)
        {
            vorne = [Array objectAtIndex:0];
            hinten = [Array objectAtIndex:1];
            zweites = [vorne floatValue] / [hinten floatValue];
        }
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] != 4)
        {
            if(erstes > zweites)
                return NSOrderedAscending;
            if(erstes < zweites)
                return NSOrderedDescending;
            if(erstes == zweites)
                return NSOrderedSame;
        }
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] == 4)
        {
            if(erstes < zweites)
                return NSOrderedAscending;
            if(erstes > zweites)
                return NSOrderedDescending;
            if(erstes == zweites)
                return NSOrderedSame;
        }
        return NSOrderedSame;
    }];
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] != 4)
        [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"orderTyp"];
    else
        [[NSUserDefaults standardUserDefaults] setInteger:41 forKey:@"orderTyp"];

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark - finishedMatch
- (void)miniBoardSchemaWarning
{
    int rand = 10;
    int maxBreite = [UIScreen mainScreen].bounds.size.width;
    int maxHoehe  = [UIScreen mainScreen].bounds.size.height;
    
    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake((maxBreite - (maxBreite / 3)) / 2 ,
                                                                (maxHoehe - (maxHoehe / 3)) / 2 ,
                                                                maxBreite / 3,
                                                                maxHoehe / 3)];
    
    infoView.backgroundColor = VIEWBACKGROUNDCOLOR;
    infoView.layer.borderWidth = 1;
    infoView.tag = 42;
    [self.view addSubview:infoView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(rand, rand, infoView.layer.frame.size.width - (2 * rand), 40)];
    title.text = @"Warning:";
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"Warning:"];
    [attr addAttribute:NSFontAttributeName
                 value:[UIFont systemFontOfSize:20.0]
                 range:NSMakeRange(0, [attr length])];
    [title setAttributedText:attr];

    title.textAlignment = NSTextAlignmentCenter;
    [infoView addSubview:title];
    
    
    UITextView *message  = [[UITextView alloc] initWithFrame:CGRectMake(rand, 50 , infoView.layer.frame.size.width - (2 * rand), infoView.layer.frame.size.height - 50 - rand)];
    message.textAlignment = NSTextAlignmentCenter;
    message.text = @"This App doesn’t currently support Board Scheme “Mini” as set in your account preferences. Only “Classic” or “Blue/White” will work. \n\nPlease select:";
    attr = [[NSMutableAttributedString alloc] initWithString:@"This App doesn’t currently support Board Scheme “Mini” as set in your account preferences. Only “Classic” or “Blue/White” will work. \n\nPlease select:"];
    [attr addAttribute:NSFontAttributeName
                 value:[UIFont systemFontOfSize:20.0]
                 range:NSMakeRange(0, [attr length])];
    [message setAttributedText:attr];
    message.textAlignment = NSTextAlignmentCenter;

    [infoView addSubview:message];
    
    float r = (infoView.layer.frame.size.width - ( 3 * 100)) / 4;
    
    UIButton *buttonNext = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonNext = [design makeNiceButton:buttonNext];
    [buttonNext setTitle:@"Fix it for me" forState: UIControlStateNormal];
    buttonNext.frame = CGRectMake(r, infoView.layer.frame.size.height - 50, 100, 35);
    [buttonNext addTarget:self action:@selector(fixIt) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:buttonNext];
    
    UIButton *buttonToTop = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonToTop = [design makeNiceButton:buttonToTop];
    [buttonToTop setTitle:@"I fix it" forState: UIControlStateNormal];
    buttonToTop.frame = CGRectMake(r + 100 + r, infoView.layer.frame.size.height - 50, 100, 35);
    [buttonToTop addTarget:self action:@selector(gotoWebsite) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:buttonToTop];
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
    cancel = [design makeNiceButton:cancel];
    [cancel setTitle:@"Cancel" forState: UIControlStateNormal];
    cancel.frame = CGRectMake(r + 100 + r + 100 + r, infoView.layer.frame.size.height - 50, 100, 35);
    [cancel addTarget:self action:@selector(cancelInfo) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:cancel];

    return;
}

-(void)cancelInfo
{
    UIView *removeView;
    while((removeView = [self.view viewWithTag:42]) != nil)
    {
        [removeView removeFromSuperview];
    }
}

-(void)fixIt
{
    UIView *removeView;
    while((removeView = [self.view viewWithTag:42]) != nil)
    {
        [removeView removeFromSuperview];
    }
    NSString *postString = @"board=0";
    NSString *preferencesString = @"";
    NSMutableArray *preferencesArray = [preferences readPreferences];
    for(NSMutableDictionary *preferencesDict in preferencesArray)
    {
        if([preferencesDict objectForKey:@"checked"] != nil)
        {
            preferencesString = [NSString stringWithFormat:@"%@&%@=on",preferencesString,[preferencesDict objectForKey:@"name"]];
        }
        else
        {
            preferencesString = [NSString stringWithFormat:@"%@&%@=off",preferencesString,[preferencesDict objectForKey:@"name"]];
        }
    }
    postString = [NSString stringWithFormat:@"%@%@",postString,preferencesString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://dailygammon.com/bg/profile/pref"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    [NSURLConnection connectionWithRequest:request delegate:self];

}
-(void)gotoWebsite
{
    UIView *removeView;
    while((removeView = [self.view viewWithTag:42]) != nil)
    {
        [removeView removeFromSuperview];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://dailygammon.com/bg/profile"] options:@{} completionHandler:nil];

}

- (IBAction)moreAction:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    iPhoneMenue *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneMenue"];
    [self.navigationController pushViewController:vc animated:NO];
    
}
- (IBAction)refreshAction:(id)sender
{
    [self readTopPage];
    [self reDrawHeader];
}
#pragma mark - Header
#include "HeaderInclude.h"

@end
