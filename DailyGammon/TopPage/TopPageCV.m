//
//  TopPageCV.m
//  DailyGammon
//
//  Created by Peter Schneider on 31.01.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import "TopPageCV.h"
#import "DGButton.h"
#import "DGLabel.h"
#import "Constants.h"
#import "Design.h"
#import "DGRequest.h"
#import "Preferences.h"
#import "Tools.h"
#import "RatingTools.h"
#import "NoInternet.h"
#import "Rating.h"
#import "LoginVC.h"
#import "AppDelegate.h"
#import "TFHpple.h"
#import "Tournament.h"
#import "PlayMatch.h"
#import "Constants.h"
#import "WebViewVC.h"

@interface TopPageCV ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet DGButton *refreshButton;
@property (weak, nonatomic) IBOutlet DGButton *sortButton;
@property (weak, nonatomic) IBOutlet UILabel *sortLabel;

@property (readwrite, retain, nonatomic) NSMutableData *datenData;
@property (assign, atomic) BOOL loginOk;
@property (readwrite, retain, nonatomic) NSMutableArray *topPageArray;
@property (readwrite, retain, nonatomic) NSMutableArray *topPageHeaderArray;

@end

@implementation TopPageCV

@synthesize waitView;
@synthesize design, preferences, rating, tools, ratingTools;
@synthesize timeRefresh, refreshButtonPressed, timer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reDrawHeader) name:changeSchemaNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readTopPage) name:@"applicationDidBecomeActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sortUpdate) name:@"sortNotification" object:nil];

    design      = [[Design alloc] init];
    preferences = [[Preferences alloc] init];
    rating      = [[Rating alloc] init];
    tools       = [[Tools alloc] init];
    ratingTools = [[RatingTools alloc] init];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;
    self.collectionView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;

    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
    self.header.textColor = [schemaDict objectForKey:@"TintColor"];
    self.moreButton = [design designMoreButton:self.moreButton];
    self.sortLabel.textColor = [schemaDict objectForKey:@"TintColor"];

    timeRefresh = 60;

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.moreButton.menu = [app mainMenu:self.navigationController button:self.moreButton];
    self.moreButton.showsMenuAsPrimaryAction = YES;

    [self sortUpdate];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:YES animated:animated];

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
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startActivityIndicator: @"Getting TopPage data from www.dailygammon.com"];

    [self layoutObjects];
    [self drawSortButton];

    [self readTopPage];

    refreshButtonPressed = NO;
}

-(void)drawSortButton
{
    NSString *buttonTitle = @"unknown";
    switch([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue])
    {
        case SORT_GRACE_THEN_POOL:
            buttonTitle = @"Grace then Pool ↓";
            break;
        case SORT_POOL:
            buttonTitle = @"Pool ↓";
           break;
        case SORT_GRACE_PLUS_POOL:
            buttonTitle = @"Grace + Pool ↓";
            break;
        case SORT_RECENT_OPPONENT_MOVE:
            buttonTitle = @"Recent Opponent Move ↓";
           break;
        case SORT_ROUND_DOWN:
            buttonTitle = @"Round ↓";
            break;
        case SORT_ROUND_UP:
            buttonTitle = @"Round ↑";
            break;
        case SORT_EVENT_DOWN:
            buttonTitle = @"Event ↓";
            break;
        case SORT_EVENT_UP:
            buttonTitle = @"Round ↑";
            break;
        case SORT_LENGTH_DOWN:
            buttonTitle = @"Length ↓";
            break;
        case SORT_LENGTH_UP:
            buttonTitle = @"Length ↑";
            break;
        case SORT_OPPONENT_NAME_DOWN:
            buttonTitle = @"Opponent Name ↓";
            break;
        case SORT_OPPONENT_NAME_UP:
            buttonTitle = @"Opponent Name ↑";
            break;
    }
    [self.sortButton setTitle:buttonTitle forState: UIControlStateNormal];

}
-(void) reDrawHeader
{
    [self drawSortButton];
    [self updateCollectionView];

}
#pragma mark - WaitView

- (void)startActivityIndicator:(NSString *)text
{
    if(!waitView)
    {
        waitView = [[WaitView alloc]initWithText:text];
    }
    else
    {
        waitView.messageText = text;
    }
    [waitView showInView:self.view];

}

- (void)stopActivityIndicator
{
    [waitView dismiss];
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

            LoginVC *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
            [self.navigationController pushViewController:vc animated:NO];
        }
    }
    if([[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies].count < 1)
    {
        LoginVC *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
        [self.navigationController pushViewController:vc animated:NO];
    }
    else
    {
        [preferences ensurePlayerNameLink];
        

        [preferences initPreferences];

        [ self readTopPage];
    }
}

#pragma mark - Hpple

-(void)readTopPage
{
    [self startActivityIndicator: @"Getting TopPage data from www.dailygammon.com"];
//    XLog(@"readTopPage");
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
    request = nil;
}
-(void)analyzeHTML:(NSString *)htmlString
{
    NSData *topPageHtmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];

    if(topPageHtmlData == nil)
    {
        [self stopActivityIndicator];
        self.header.text = [NSString stringWithFormat:@"There are no matches where you can move."];

        return;

    }
    self.topPageArray = [[NSMutableArray alloc]init];

    if ([htmlString rangeOfString:@"There are no matches where you can move."].location != NSNotFound)
    {
        [self stopActivityIndicator];
        self.header.text = [NSString stringWithFormat:@"There are no matches where you can move."];

        return;
    }

    // Create parser
        
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
    {
        switch([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue])
        {
            case SORT_ROUND_DOWN:
            case SORT_ROUND_UP:
                [self sortRound];
                break;
            case SORT_EVENT_DOWN:
            case SORT_EVENT_UP:
                [self sortEvent];
                break;
            case SORT_LENGTH_DOWN:
            case SORT_LENGTH_UP:
                [self sortLength];
                break;
            case SORT_OPPONENT_NAME_DOWN:
            case SORT_OPPONENT_NAME_UP:
                [self sortOpponent];
                break;
        }

        [self updateCollectionView];
    }
    [self stopActivityIndicator];

}

- (void)updateCollectionView
{
    [self sortUpdate];
    [rating updateRating];
 
    [self.collectionView reloadData];
    self.header.text = [NSString stringWithFormat:@"%d Matches where you can move:"
                        ,(int)self.topPageArray.count];
    [self drawSortButton];
    [self stopActivityIndicator];
}
#pragma mark - sort
-(void)sortUpdate
{
    int orderTyp = [[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue];
    UIImage *orderImage = nil;
    
    NSMutableArray  *menuArray = [[NSMutableArray alloc] initWithCapacity:3];

    if(orderTyp == SORT_GRACE_THEN_POOL)
        orderImage = [design designSystemImage:@"arrow.down.square"];
    [menuArray addObject:[UIAction actionWithTitle:@"Grace then Pool"
                                             image:orderImage
                                        identifier:@"0"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self matchOrdering:SORT_GRACE_THEN_POOL];
        [self reDrawHeader];

   }]];
    
    orderImage = nil;
    if(orderTyp == SORT_POOL)
        orderImage = [design designSystemImage:@"arrow.down.square"];
    [menuArray addObject:[UIAction actionWithTitle:@"Pool"
                                             image:orderImage
                                        identifier:@"1"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self matchOrdering:SORT_POOL];
        [self reDrawHeader];
    }]];

    orderImage = nil;
    if(orderTyp == SORT_GRACE_PLUS_POOL)
        orderImage = [design designSystemImage:@"arrow.down.square"];
    [menuArray addObject:[UIAction actionWithTitle:@"Grace + Pool"
                                             image:orderImage
                                        identifier:@"2"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self matchOrdering:SORT_GRACE_PLUS_POOL];
        [self reDrawHeader];
    }]];

    orderImage = nil;
    if(orderTyp == SORT_RECENT_OPPONENT_MOVE)
        orderImage = [design designSystemImage:@"arrow.down.square"];
    [menuArray addObject:[UIAction actionWithTitle:@"Recent Opponent Move"
                                             image:orderImage
                                        identifier:@"3"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self matchOrdering:SORT_RECENT_OPPONENT_MOVE];
        [self reDrawHeader];
    }]];

    orderImage = nil;
    if(orderTyp == SORT_EVENT_DOWN)
    {
        orderImage = [design designSystemImage:@"arrow.down.square"];
    }
    if(orderTyp == SORT_EVENT_UP)
    {
        orderImage = [design designSystemImage:@"arrow.up.square"];
    }
    [menuArray addObject:[UIAction actionWithTitle:@"Event"
                                             image:orderImage
                                        identifier:@"4"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self sortEvent];
        [self reDrawHeader];
    }]];

    orderImage = nil;
    if(orderTyp == SORT_ROUND_DOWN)
    {
        orderImage = [design designSystemImage:@"arrow.down.square"];
    }
    if(orderTyp == SORT_ROUND_UP)
    {
        orderImage = [design designSystemImage:@"arrow.up.square"];
    }
    [menuArray addObject:[UIAction actionWithTitle:@"Round"
                                             image:orderImage
                                        identifier:@"5"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self sortRound];
        [self reDrawHeader];
    }]];

    orderImage = nil;
    if(orderTyp == SORT_LENGTH_DOWN)
    {
        orderImage = [design designSystemImage:@"arrow.down.square"];
    }
    if(orderTyp == SORT_LENGTH_UP)
    {
        orderImage = [design designSystemImage:@"arrow.up.square"];
    }
    [menuArray addObject:[UIAction actionWithTitle:@"Length"
                                             image:orderImage
                                        identifier:@"6"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self sortLength];
        [self reDrawHeader];
    }]];

    orderImage = nil;
    if(orderTyp == SORT_OPPONENT_NAME_DOWN)
    {
        orderImage = [design designSystemImage:@"arrow.down.square"];
    }
    if(orderTyp == SORT_OPPONENT_NAME_UP)
    {
        orderImage = [design designSystemImage:@"arrow.up.square"];
    }
    [menuArray addObject:[UIAction actionWithTitle:@"Opponent Name"
                                             image:orderImage
                                        identifier:@"7"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self sortOpponent];
        [self reDrawHeader];
    }]];

    self.sortButton.menu = [UIMenu menuWithChildren:menuArray];
    self.sortButton.showsMenuAsPrimaryAction = YES;
    
    [self drawSortButton];

    [self.collectionView reloadData];
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

    [self updateCollectionView];
    
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
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] != SORT_EVENT_DOWN)
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

    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] != SORT_EVENT_DOWN)
        [[NSUserDefaults standardUserDefaults] setInteger:SORT_EVENT_DOWN forKey:@"orderTyp"];
    else
        [[NSUserDefaults standardUserDefaults] setInteger:SORT_EVENT_UP forKey:@"orderTyp"];

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateCollectionView];

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
        
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] == SORT_LENGTH_DOWN)
        {
            if(erstes < zweites)
                return NSOrderedAscending;
            if(erstes > zweites)
                return NSOrderedDescending;
            if(erstes == zweites)
                return NSOrderedSame;
        }
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] != SORT_LENGTH_DOWN)
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
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] != SORT_LENGTH_DOWN)
        [[NSUserDefaults standardUserDefaults] setInteger:SORT_LENGTH_DOWN forKey:@"orderTyp"];
    else
        [[NSUserDefaults standardUserDefaults] setInteger:SORT_LENGTH_UP forKey:@"orderTyp"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self updateCollectionView];

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
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] != SORT_ROUND_DOWN)
        {
            if(erstes > zweites)
                return NSOrderedAscending;
            if(erstes < zweites)
                return NSOrderedDescending;
            if(erstes == zweites)
                return NSOrderedSame;
        }
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] == SORT_ROUND_DOWN)
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
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] != SORT_ROUND_DOWN)
        [[NSUserDefaults standardUserDefaults] setInteger:SORT_ROUND_DOWN forKey:@"orderTyp"];
    else
        [[NSUserDefaults standardUserDefaults] setInteger:SORT_ROUND_UP forKey:@"orderTyp"];

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateCollectionView];
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
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] != SORT_OPPONENT_NAME_DOWN)
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
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] != SORT_OPPONENT_NAME_DOWN)
        [[NSUserDefaults standardUserDefaults] setInteger:SORT_OPPONENT_NAME_DOWN forKey:@"orderTyp"];
    else
        [[NSUserDefaults standardUserDefaults] setInteger:SORT_OPPONENT_NAME_UP forKey:@"orderTyp"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateCollectionView];

}

#pragma mark - autoLayout
-(void)layoutObjects
{
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    float edge = 5.0;
    
#pragma mark moreButton autoLayout
    [self.moreButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.moreButton.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge].active = YES;
    [self.moreButton.heightAnchor constraintEqualToConstant:40].active = YES;
    [self.moreButton.widthAnchor constraintEqualToConstant:40].active = YES;
    [self.moreButton.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;

#pragma mark refreshButton autoLayout
    [self.refreshButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.refreshButton.topAnchor constraintEqualToAnchor:self.moreButton.topAnchor constant:0].active = YES;
    [self.refreshButton.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.refreshButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.refreshButton.widthAnchor constraintEqualToConstant:90].active = YES;

#pragma mark header autoLayout
    [self.header setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.header.topAnchor constraintEqualToAnchor:safe.topAnchor constant:0].active = YES;
    [self.header.leadingAnchor constraintEqualToAnchor:self.refreshButton.trailingAnchor constant:edge].active = YES;
    [self.header.heightAnchor constraintEqualToConstant:40].active = YES;
    [self.header.rightAnchor constraintEqualToAnchor:self.moreButton.leftAnchor constant:-edge].active = YES;
//    [self.header.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor constant:0].active = YES;
    
#pragma mark sortLabel autoLayout
    [self.sortLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.sortLabel.topAnchor constraintEqualToAnchor:self.refreshButton.bottomAnchor constant:20].active = YES;
    [self.sortLabel.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.sortLabel.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.sortLabel.widthAnchor constraintEqualToConstant:130].active = YES;

#pragma mark sortButton autoLayout
    [self.sortButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.sortButton.topAnchor constraintEqualToAnchor:self.sortLabel.topAnchor constant:0].active = YES;
    [self.sortButton.leftAnchor constraintEqualToAnchor:self.sortLabel.rightAnchor constant:10].active = YES;
    [self.sortButton.heightAnchor constraintEqualToConstant:35].active = YES;
//    [self.sortButton.widthAnchor constraintEqualToConstant:190].active = YES;

#pragma mark collectionView autoLayout
    [self.collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.collectionView.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.collectionView.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.collectionView.topAnchor constraintEqualToAnchor:self.sortLabel.bottomAnchor constant:20].active = YES;
    [self.collectionView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-edge].active = YES;

}
#pragma mark - CollectionView dataSource


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.topPageArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float edge = 5;
    float gap = 5;

    int labelHeight = 20;
    int buttonHeight = 35;

    int height = edge + buttonHeight + gap + labelHeight + gap + labelHeight + gap + (labelHeight*2) ;
    return CGSizeMake(175, height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    for (UIView *subview in [cell.contentView subviews])
    {
        if ([subview isKindOfClass:[DGLabel class]])
        {
            [subview removeFromSuperview];
        }
        if ([subview isKindOfClass:[UIButton class]])
        {
            [subview removeFromSuperview];
        }
        if ([subview isKindOfClass:[DGButton class]])
        {
            [subview removeFromSuperview];
        }
   }
    cell.layer.cornerRadius = 14.0f;
    cell.layer.masksToBounds = YES;
    cell.backgroundColor = [UIColor colorNamed:@"ColorCV"];
    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
    UIColor *tintColor = [schemaDict objectForKey:@"TintColor"];

    if(self.topPageArray.count < 1)
        return cell;

    NSArray *row = self.topPageArray[indexPath.row];

    float edge = 5;
    float gap = 5;
    float x = edge;
    float y = edge;
    float maxWidth = cell.frame.size.width - edge - edge;
    float firstRowWidth = maxWidth * 0.5;
    float secondRowWidth = maxWidth * 0.5;
    int labelHeight = 20;
    int buttonHeight = 35;
#pragma mark 1. Line Tournament name
    NSDictionary *event = row[1];
    
    DGButton *eventButton = [[DGButton alloc] initWithFrame:CGRectMake(x, y ,maxWidth,buttonHeight)];
    [eventButton setTitle:[event objectForKey:@"Text"] forState: UIControlStateNormal];
    eventButton.tag = indexPath.row;
    [eventButton.layer setValue:[event objectForKey:@"href"] forKey:@"href"];
    [eventButton.layer setValue:[event objectForKey:@"Text"] forKey:@"Text"];
    [eventButton addTarget:self action:@selector(eventAction:) forControlEvents:UIControlEventTouchUpInside];
    
    DGLabel *eventLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,maxWidth,buttonHeight)];
    eventLabel.textAlignment = NSTextAlignmentCenter;
    [eventLabel setFont:[UIFont boldSystemFontOfSize: eventLabel.font.pointSize]];
    eventLabel.numberOfLines = 0;
    eventLabel.text = [event objectForKey:@"Text"];
    eventLabel.adjustsFontSizeToFitWidth = YES;

    if([event objectForKey:@"href"])
        [cell.contentView addSubview:eventButton];
    else
        [cell.contentView addSubview:eventLabel];

#pragma mark 2. Line length & rounds
    y += eventButton.frame.size.height + gap;

    DGLabel *lengthLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,firstRowWidth,labelHeight)];
    lengthLabel.textAlignment = NSTextAlignmentLeft;
    NSDictionary *length = row[5];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"Length: %@",[length objectForKey:@"Text"]]];
    NSRange range = NSMakeRange(7, attributedString.length - 7);
    NSDictionary *boldAttributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize: lengthLabel.font.pointSize]};
    NSDictionary *colorAttributes = @{NSForegroundColorAttributeName: tintColor};
    NSMutableDictionary *combinedAttributes = [NSMutableDictionary dictionaryWithDictionary:boldAttributes];
    [combinedAttributes addEntriesFromDictionary:colorAttributes];
    [attributedString setAttributes:combinedAttributes range:range];
    lengthLabel.attributedText = attributedString;

    [cell.contentView addSubview:lengthLabel];

    x += lengthLabel.frame.size.width;
    
    DGLabel *roundLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,secondRowWidth,labelHeight)];
    roundLabel.textAlignment = NSTextAlignmentLeft;
    NSDictionary *round = row[4];
    
    attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"Round: %@",[round objectForKey:@"Text"]]];
    range = NSMakeRange(7, attributedString.length - 7);
    boldAttributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize: lengthLabel.font.pointSize]};
    combinedAttributes = [NSMutableDictionary dictionaryWithDictionary:boldAttributes];
    [combinedAttributes addEntriesFromDictionary:colorAttributes];
    [attributedString setAttributes:combinedAttributes range:range];    roundLabel.attributedText = attributedString;

    [cell.contentView addSubview:roundLabel];

#pragma mark 3. Line time & grace
    y += roundLabel.frame.size.height + gap;
    x = edge;
    
    DGLabel *timeLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,firstRowWidth,labelHeight)];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    NSDictionary *time = row[3];
    
    attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"Time: %@",[time objectForKey:@"Text"]]];
    range = NSMakeRange(6, attributedString.length - 6);
    boldAttributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize: lengthLabel.font.pointSize]};
    combinedAttributes = [NSMutableDictionary dictionaryWithDictionary:boldAttributes];
    [combinedAttributes addEntriesFromDictionary:colorAttributes];
    [attributedString setAttributes:combinedAttributes range:range];    timeLabel.attributedText = attributedString;

    [cell.contentView addSubview:timeLabel];

    x += timeLabel.frame.size.width;
    
    DGLabel *graceLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,secondRowWidth,labelHeight)];
    graceLabel.textAlignment = NSTextAlignmentLeft;
    NSDictionary *grace = row[2];
    
    attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"Grace: %@",[grace objectForKey:@"Text"]]];
    range = NSMakeRange(7, attributedString.length - 7);
    boldAttributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize: lengthLabel.font.pointSize]};
    combinedAttributes = [NSMutableDictionary dictionaryWithDictionary:boldAttributes];
    [combinedAttributes addEntriesFromDictionary:colorAttributes];
    [attributedString setAttributes:combinedAttributes range:range];    graceLabel.attributedText = attributedString;

    [cell.contentView addSubview:graceLabel];

#pragma mark 4&5. Line opponent

    y += graceLabel.frame.size.height + gap;
    x = edge;
    
    DGLabel *opponentLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x,y,maxWidth, labelHeight*2)];
    opponentLabel.textAlignment = NSTextAlignmentCenter;
    [opponentLabel setFont:[UIFont boldSystemFontOfSize: 20.0]];
    NSDictionary *opponent = row[6];
    opponentLabel.text = [opponent objectForKey:@"Text"];
    NSString *opponentNameString = [opponent objectForKey:@"Text"];
    UIFont *font = opponentLabel.font;
    CGSize textSize = [opponentNameString sizeWithAttributes:@{NSFontAttributeName: font}];
    if(textSize.width > (opponentLabel.frame.size.width ))
    {
        float factor =  opponentLabel.frame.size.width / textSize.width ;
        opponentNameString = [NSString stringWithFormat:@"%@ ...",[opponentNameString substringToIndex:(opponentNameString.length * factor) ]];
    }
    opponentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    opponentLabel.text = opponentNameString;

    [cell.contentView addSubview:opponentLabel];

    return cell;
}

#pragma mark - CollectionView delegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if([preferences isMiniBoard])
    {
        [self miniBoardSchemaWarning];
        return;
    }
    if(!self.topPageArray)
    {
        [self readTopPage];
        [self updateCollectionView];
        XLog(@"if(!self.topPageArray)");
        return;
    }
    NSArray *row = self.topPageArray[indexPath.row];
    
    PlayMatch *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"PlayMatch"];
    NSDictionary *match = row[8];
    app.matchLink = [match objectForKey:@"href"];
    vc.topPageArray = self.topPageArray;
    [self.navigationController pushViewController:vc animated:NO];
    
    [self dismissViewControllerAnimated:YES completion:Nil];

    return;

}

- (IBAction)eventAction:(UIButton*)button
{
    Tournament *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"Tournament"];
    vc.url   = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",(NSString *)[button.layer valueForKey:@"href"]]];
    vc.name = (NSString *)[button.layer valueForKey:@"Text"];
    [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)refreshAction:(id)sender
{
    [self readTopPage];
    [self reDrawHeader];
    [self updateCollectionView];

    if(!refreshButtonPressed)
    {

        timeRefresh = 60;
        [NSTimer scheduledTimerWithTimeInterval:60.0f
                                         target:self selector:@selector(automaticRefresh) userInfo:nil repeats:YES];

        timer =[NSTimer scheduledTimerWithTimeInterval:1.0f
                                         target:self selector:@selector(updateRefreshButton) userInfo:nil repeats:YES];
        refreshButtonPressed = YES;
    }
    else
    {
        refreshButtonPressed = NO;
        if (timer && [timer isValid])
        {
            [timer invalidate];
            timer = nil;
        }
        [self.refreshButton setTitle:@"Refresh" forState: UIControlStateNormal];
    }
}
- (void)automaticRefresh
{
    [self readTopPage];
    [self reDrawHeader];
    [self updateCollectionView];
    timeRefresh = 60;
}

-(void)updateRefreshButton
{
    if(timeRefresh-- < 1)
        timeRefresh = 60;
    [self.refreshButton setTitle:[NSString stringWithFormat:@"%d", timeRefresh] forState: UIControlStateNormal];
}

#pragma mark - miniBoard
- (void)miniBoardSchemaWarning
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Warning"
                                 message:@"This App doesn’t currently support Board Scheme \"Mini\" as set in your account preferences. Only \"Classic\" or \"Blue/White\" will work. \n\nPlease select:"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* fixItButton = [UIAlertAction
                                actionWithTitle:@"Fix it for me"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [self fixIt];
                                 }];

    [alert addAction:fixItButton];

    UIAlertAction* gotoWebsiteButton = [UIAlertAction
                                actionWithTitle:@"I fix it"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
        WebViewVC *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"WebViewVC"];
        vc.url = [NSURL URLWithString:@"http://dailygammon.com/bg/profile"];
        [self.navigationController pushViewController:vc animated:NO];

                                 }];

    [alert addAction:gotoWebsiteButton];

    UIAlertAction* cancelButton = [UIAlertAction
                                actionWithTitle:@"Cancel"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {

                                 }];

    [alert addAction:cancelButton];

    [self presentViewController:alert animated:YES completion:nil];

    return;

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

@end
