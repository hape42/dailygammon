//
//  TopPageVC.m
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

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
#import "RatingVC.h"
#import "Player.h"
#import "iPhoneMenue.h"
#import "iPhonePlayMatch.h"
#import "Tools.h"
#import "RatingTools.h"
#import "NoInternet.h"
#import <SafariServices/SafariServices.h>
#import "About.h"
#import "DGButton.h"
#import "PlayerLists.h"
#import "Tournament.h"
#import "DGRequest.h"
#import "Constants.h"

@interface TopPageVC ()<NSURLSessionDataDelegate>

@property (readwrite, retain, nonatomic) NSMutableData *datenData;
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

@property (assign, atomic) float numberWidth;
@property (assign, atomic) float graceWidth;
@property (assign, atomic) float poolWidth;
@property (assign, atomic) float roundWidth;
@property (assign, atomic) float lengthWidth;
@property (assign, atomic) float opponentWidth;
@property (assign, atomic) float eventWidth;

@property (readwrite, retain, nonatomic) DGButton *topPageButton;

@property (nonatomic, retain, readwrite) UIActivityIndicatorView *indicator;

@end

@implementation TopPageVC

@synthesize design, preferences, rating, tools, ratingTools;
@synthesize timeRefresh, refreshButtonPressed;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.indicator.color = [design schemaColor];
    self.indicator.center = self.view.center;
    [self.view addSubview:self.indicator];
    
    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
    
    self.tableView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reDrawHeader) name:changeSchemaNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readTopPage) name:@"applicationDidBecomeActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMatchCount) name:matchCountChangedNotification object:nil];

    design      = [[Design alloc] init];
    preferences = [[Preferences alloc] init];
    rating      = [[Rating alloc] init];
    tools       = [[Tools alloc] init];
    ratingTools = [[RatingTools alloc] init];

    timeRefresh = 60;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if([design isX])
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        UIWindow *keyWindow = (UIWindow *) windows[0];
        UIEdgeInsets safeArea = keyWindow.safeAreaInsets;

        CGRect frame = self.tableView.frame;
        frame.origin.x = safeArea.left ;
        frame.size.width = self.tableView.frame.size.width - safeArea.left ;
        self.tableView.frame = frame;
    }
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        self.numberWidth = 40;
        self.graceWidth  = 80;
        self.poolWidth   = 120;
        self.roundWidth  = 80;
        self.lengthWidth = 80;
    }
    else
    {
        self.numberWidth = 30;
        self.graceWidth  = 70;
        self.poolWidth   = 86;
        self.roundWidth  = 70;
        self.lengthWidth = 70;
    }
    self.opponentWidth = (self.tableView.frame.size.width - self.numberWidth - self.graceWidth - self.poolWidth - self.roundWidth - self.lengthWidth)/2 ;
    self.eventWidth = self.opponentWidth;

}
- (UIActivityIndicatorView *)indicator
{
    if (!_indicator)
    {
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
        self.indicator.color = [schemaDict objectForKey:@"TintColor"];

    }
    return _indicator;
}
-(void) reDrawHeader
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        UIView *header = [self makeHeader];
        if(header)
            [self.view addSubview:header];
    }
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
    
    self.moreButton.tintColor = [UIColor colorNamed:@"ColorSwitch"];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.indicator startAnimating];

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    else
        [self.navigationController setNavigationBarHidden:NO animated:animated];

    NSString *userName     = [[NSUserDefaults standardUserDefaults] stringForKey:@"user"];
    NSString *userPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];

    self.loginOk = NO;

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
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task resume];
    [self reDrawHeader];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [ self readTopPage];

    [self reDrawHeader];
    [self updateTableView];
    
    refreshButtonPressed = NO;
    
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    self.datenData = [[NSMutableData alloc] init];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    if(self.loginOk)
    {
        [self.datenData appendData:data];
    }
    else
    {
        self.loginOk = YES;
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    if (error)
    {
        XLog(@"Connection didFailWithError %@", error.localizedDescription);
        return;
    }

    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
        if([[cookie name] isEqualToString:@"USERID"])
            [[NSUserDefaults standardUserDefaults] setValue:[cookie value] forKey:@"USERID"];

        [[NSUserDefaults standardUserDefaults] synchronize];
        if([[cookie value] isEqualToString:@"N/A"])
        {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

            LoginVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"LoginVC"];
            [self.navigationController pushViewController:vc animated:NO];
        }
    }
    if([[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies].count < 1)
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

#pragma mark - Hpple

-(void)readTopPage
{
    [self.indicator startAnimating];
    
    DGRequest *request = [[DGRequest alloc] initWithString:@"http://dailygammon.com/bg/top" completionHandler:^(BOOL success, NSError *error, NSString *result)
                          {
        if (success)
        {
            [ self analyzeHTML:result];
            
        }
        else
        {
            XLog(@"Error: %@", error.localizedDescription);
        }
    }];
}
-(void)analyzeHTML:(NSString *)htmlString
{
    NSData *topPageHtmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];

    if(topPageHtmlData == nil)
    {
        [self.indicator stopAnimating];
        self.header.text = [NSString stringWithFormat:@"There are no matches where you can move."];
        self.navigationBar.title = [NSString stringWithFormat:@"There are no matches where you can move."];

        return;

    }
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
    NSArray *rows  = [xpathParser searchWithXPathQuery:queryString];
    for(int row = 2; row <= rows.count; row ++)
    {
        NSMutableArray *topPageZeile = [[NSMutableArray alloc]init];

        NSString * searchString = [NSString stringWithFormat:@"//table[%d]/tr[%d]/td",tableNo,row];
        NSArray *elementZeile  = [xpathParser searchWithXPathQuery:searchString];
        for(TFHppleElement *element in elementZeile)
        {
            NSMutableDictionary *topPageZeileSpalte = [[NSMutableDictionary alloc]init];

            for (TFHppleElement *child in element.children)
            {
                if ([child.tagName isEqualToString:@"a"])
                {
                   // NSDictionary *href = [child attributes];
                    [topPageZeileSpalte setValue:[child content] forKey:@"Text"];
                    [topPageZeileSpalte setValue:[[child attributes] objectForKey:@"href"]forKey:@"href"];
                }
                else
                {
                    [topPageZeileSpalte setValue:[element content] forKey:@"Text"];
                }
            }
            [topPageZeile addObject:topPageZeileSpalte];
        }

        [self.topPageArray addObject:topPageZeile];
    }
    if(self.topPageArray.count > 0)
        [self updateTableView];
    [self.indicator stopAnimating];

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
    cell.backgroundColor = [UIColor colorNamed:@"ColorTableViewCell"];

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
        if ([subview isKindOfClass:[DGButton class]])
        {
            [subview removeFromSuperview];
        }

    }
    
    [cell setTintColor:[UIColor greenColor]];
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
    
    NSArray *row = self.topPageArray[indexPath.row];
    
    int x = 0;
    int labelHeight = cell.frame.size.height;
    
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,self.numberWidth,labelHeight)];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *nummer = row[0];
    numberLabel.text = [nummer objectForKey:@"Text"];
    x += self.numberWidth;
    
    NSDictionary *event = row[1];
    UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,self.eventWidth,labelHeight)];
    eventLabel.textAlignment = NSTextAlignmentLeft;
    eventLabel.text = [event objectForKey:@"Text"];
    eventLabel.adjustsFontSizeToFitWidth = YES;

    DGButton *eventButton = [[DGButton alloc] initWithFrame:CGRectMake(x+3, 3 ,self.eventWidth-6,labelHeight-6)];
    [eventButton setTitle:[event objectForKey:@"Text"] forState: UIControlStateNormal];
    eventButton.tag = indexPath.row;
    [eventButton.layer setValue:[event objectForKey:@"href"] forKey:@"href"];
    [eventButton.layer setValue:[event objectForKey:@"Text"] forKey:@"Text"];

    [eventButton addTarget:self action:@selector(eventAction:) forControlEvents:UIControlEventTouchUpInside];

    x += self.eventWidth;
    
    UILabel *graceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,self.graceWidth,labelHeight)];
    graceLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *grace = row[2];
    graceLabel.text = [grace objectForKey:@"Text"];
    graceLabel.adjustsFontSizeToFitWidth = YES;

    x += self.graceWidth;
    
    UILabel *poolLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,self.poolWidth,labelHeight)];
    poolLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *pool = row[3];
    poolLabel.text = [pool objectForKey:@"Text"];
    poolLabel.adjustsFontSizeToFitWidth = YES;

    x += self.poolWidth;
    
    UILabel *roundLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,self.roundWidth,labelHeight)];
    roundLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *round = row[4];
    roundLabel.text = [round objectForKey:@"Text"];
    roundLabel.adjustsFontSizeToFitWidth = YES;

    x += self.roundWidth;
    
    UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,self.lengthWidth,labelHeight)];
    lengthLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *length = row[5];
    lengthLabel.text = [length objectForKey:@"Text"];
    lengthLabel.adjustsFontSizeToFitWidth = YES;

    x += self.lengthWidth;
    
    UILabel *opponentLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,self.opponentWidth,labelHeight)];
    opponentLabel.textAlignment = NSTextAlignmentLeft;
    opponentLabel.text = self.topPageHeaderArray[6];
    NSDictionary *opponent = row[6];
    opponentLabel.text = [opponent objectForKey:@"Text"];
    opponentLabel.adjustsFontSizeToFitWidth = YES;

    [cell.contentView addSubview:numberLabel];
    if([event objectForKey:@"href"])
        [cell.contentView addSubview:eventButton];
    else
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

    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,self.numberWidth,30)];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    numberLabel.text = @"#";
    numberLabel.textColor = [UIColor whiteColor];
    x += self.numberWidth;
    
    UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,self.eventWidth,30)];
    eventLabel.textAlignment = NSTextAlignmentCenter;
    eventLabel.text = @"Event";
    eventLabel.textColor = [UIColor whiteColor];
    UIButton *buttonEvent = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonEvent.frame = eventLabel.frame;
    [buttonEvent addTarget:self action:@selector(sortEvent) forControlEvents:UIControlEventTouchUpInside];

    x += self.eventWidth;

    UILabel *graceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, self.graceWidth, 30)];
    graceLabel.textAlignment = NSTextAlignmentCenter;
    graceLabel.text =@"Grace";
    graceLabel.textColor = [UIColor whiteColor];
    UIButton *buttonGrace = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonGrace.frame = graceLabel.frame;
    [buttonGrace addTarget:self action:@selector(sortGrace:) forControlEvents:UIControlEventTouchUpInside];

    x += self.graceWidth;
    
    UILabel *poolLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, self.poolWidth,30)];
    poolLabel.textAlignment = NSTextAlignmentCenter;
    poolLabel.text = @"Time Pool";
    poolLabel.textColor = [UIColor whiteColor];
    UIButton *buttonPool = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonPool.frame = poolLabel.frame;
    [buttonPool addTarget:self action:@selector(sortPool:) forControlEvents:UIControlEventTouchUpInside];

    x += self.poolWidth;
    
    UILabel *roundLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, self.roundWidth,30)];
    roundLabel.textAlignment = NSTextAlignmentCenter;
    roundLabel.text = @"Round";
    roundLabel.textColor = [UIColor whiteColor];
    UIButton *buttonRound = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonRound.frame = roundLabel.frame;
    [buttonRound addTarget:self action:@selector(sortRound) forControlEvents:UIControlEventTouchUpInside];

    x += self.roundWidth;
    
    UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 , self.lengthWidth,30)];
    lengthLabel.textAlignment = NSTextAlignmentCenter;
    lengthLabel.text = @"Length";
    lengthLabel.textColor = [UIColor whiteColor];
    UIButton *buttonLength = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonLength.frame = lengthLabel.frame;
    [buttonLength addTarget:self action:@selector(sortLength) forControlEvents:UIControlEventTouchUpInside];

    x += self.lengthWidth;
    
    UILabel *opponentLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 , self.opponentWidth,30)];
    opponentLabel.textAlignment = NSTextAlignmentCenter;
    opponentLabel.text = @"Opponent";
    opponentLabel.textColor = [UIColor whiteColor];
    UIButton *buttonOpponent = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonOpponent.frame = opponentLabel.frame;
    [buttonOpponent addTarget:self action:@selector(sortOpponent) forControlEvents:UIControlEventTouchUpInside];

    [preferences readNextMatchOrdering];
    int order = [[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue];
    
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
    
    switch (order)
    {
        case 0:
            graceLabel.textColor = [design schemaColor];
            break;
        case 1:
            poolLabel.textColor = [design schemaColor];
            break;
        case 2:
            graceLabel.textColor = [design schemaColor];
            poolLabel.textColor = [design schemaColor];
            break;
        case 3:
            opponentLabel.textColor = [design schemaColor];
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

    [headerView addSubview:numberLabel];
    
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
-(void)updateMatchCount
{
    [self updateMatchCount:self.view];
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

    [self updateMatchCount];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSString *dateDB = [format stringFromDate:[NSDate date]];
    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];
    float ratingUser = [self->rating readRatingForUser:userID];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                        float ratingDB = [app.dbConnect readRatingForDatum:dateDB andUser:userID];
                        if(ratingUser > ratingDB)
                            [app.dbConnect saveRating:dateDB withRating:ratingUser forUser:userID];
                   });
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"iCloud"]boolValue])
        [ratingTools saveRating:dateDB withRating:ratingUser] ;

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
    NSArray *row = self.topPageArray[indexPath.row];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        PlayMatch *vc = [app.activeStoryBoard  instantiateViewControllerWithIdentifier:@"PlayMatch"];
        NSDictionary *match = row[8];
        vc.matchLink = [match objectForKey:@"href"];
        vc.topPageArray = self.topPageArray;
        [self.navigationController pushViewController:vc animated:NO];
    }
    else
    {
        iPhonePlayMatch *vc = [app.activeStoryBoard  instantiateViewControllerWithIdentifier:@"iPhonePlayMatch"];
        NSDictionary *match = row[8];
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
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task resume];

    [[NSUserDefaults standardUserDefaults] setInteger:typ forKey:@"orderTyp"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self readTopPage];
    [self reDrawHeader];

    [self.tableView reloadData];
    

}

-(void)sortOpponent
{
    if(self.topPageArray.count < 1)
        return;

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
    
    if(self.topPageArray.count < 1)
        return;
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
    if(self.topPageArray.count < 1)
        return;

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
    if(self.topPageArray.count < 1)
        return;

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
    
    infoView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
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
    
    DGButton *buttonNext = [[DGButton alloc] initWithFrame:CGRectMake(r, infoView.layer.frame.size.height - 50, 100, 35)];
    [buttonNext setTitle:@"Fix it for me" forState: UIControlStateNormal];
    [buttonNext addTarget:self action:@selector(fixIt) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:buttonNext];
    
    DGButton *buttonToTop = [[DGButton alloc] initWithFrame:CGRectMake(r + 100 + r, infoView.layer.frame.size.height - 50, 100, 35)];
    [buttonToTop setTitle:@"I fix it" forState: UIControlStateNormal];
    [buttonToTop addTarget:self action:@selector(gotoWebsite) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:buttonToTop];
    
    DGButton *cancel = [[DGButton alloc] initWithFrame:CGRectMake(r + 100 + r + 100 + r, infoView.layer.frame.size.height - 50, 100, 35)];
    [cancel setTitle:@"Cancel" forState: UIControlStateNormal];
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
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task resume];

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
    if(!refreshButtonPressed)
    {
        [NSTimer scheduledTimerWithTimeInterval:60.0f
                                         target:self selector:@selector(automaticRefresh) userInfo:nil repeats:YES];
        timeRefresh = 60;
        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                         target:self selector:@selector(updateRefreshButton) userInfo:nil repeats:YES];
        refreshButtonPressed = YES;
    }
}
- (IBAction)eventAction:(UIButton*)button
{

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Tournament *vc = [app.activeStoryBoard  instantiateViewControllerWithIdentifier:@"Tournament"];
    vc.url   = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",(NSString *)[button.layer valueForKey:@"href"]]];
    vc.name = (NSString *)[button.layer valueForKey:@"Text"];
    [self.navigationController pushViewController:vc animated:NO];

}

- (void)automaticRefresh
{
    [self readTopPage];
    [self reDrawHeader];
    timeRefresh = 60;
}

-(void)updateRefreshButton
{
    if(timeRefresh-- < 0)
        timeRefresh = 60;
    self.refreshButton.title = [NSString stringWithFormat:@"%d", timeRefresh];
    [self.refreshButtonIPAD setTitle:[NSString stringWithFormat:@"%d", timeRefresh] forState: UIControlStateNormal];
}

#pragma mark - Header
#include "HeaderInclude.h"

@end
