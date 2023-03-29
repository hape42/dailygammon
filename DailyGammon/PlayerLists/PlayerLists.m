//
//  PlayerLists.m
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "PlayerLists.h"
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
#import "DGLabel.h"
#import "TopPageVC.h"
#import "Tournament.h"
#import "Review.h"
#import "Constants.h"
#import "DGRequest.h"

@interface PlayerLists ()<NSURLSessionDataDelegate>

@property (readwrite, retain, nonatomic) NSMutableData *datenData;
@property (assign, atomic) BOOL loginOk;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (readwrite, retain, nonatomic) NSMutableArray *listArray;
@property (readwrite, retain, nonatomic) NSMutableArray *listHeaderArray;

@property (weak, nonatomic) IBOutlet DGButton *activeMatchesButton;
@property (weak, nonatomic) IBOutlet DGButton *activeTournamentsButton;
@property (weak, nonatomic) IBOutlet DGButton *finishedMatchesButton;
@property (weak, nonatomic) IBOutlet DGButton *tournamentWinsButton;
@property (weak, nonatomic) IBOutlet UILabel *header;

@property (readwrite, retain, nonatomic) NSString *matchString;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *moreButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;

@property (readwrite, retain, nonatomic) DGButton *topPageButton;


@end

@implementation PlayerLists

@synthesize design, preferences, rating, tools, ratingTools;
@synthesize listTyp;
@synthesize waitView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
    
    self.tableView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reDrawHeader) name:changeSchemaNotification object:nil];

    design      = [[Design alloc] init];
    preferences = [[Preferences alloc] init];
    rating      = [[Rating alloc] init];
    tools       = [[Tools alloc] init];
    ratingTools = [[RatingTools alloc] init];

    listTyp = 1;
    
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
    
    return;

}

-(void) reDrawHeader
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        UIView *header = [self makeHeader];
        if(header)
            [self.view addSubview:header];
    }
    
    int maxWidth = [UIScreen mainScreen].bounds.size.width;
    int edge = 20;
    int gap  = 20;
    float buttonWidth = (maxWidth - edge - gap - gap - gap - edge) / 4;
    int x = edge;
    
    CGRect buttonFrame;
    buttonFrame = self.activeMatchesButton.frame;
    buttonFrame.origin.x = x;
    buttonFrame.size.width = buttonWidth;
    self.activeMatchesButton.frame = buttonFrame;
    
    x += buttonWidth + gap;
    
    buttonFrame = self.activeTournamentsButton.frame;
    buttonFrame.origin.x = x;
    buttonFrame.size.width = buttonWidth;
    self.activeTournamentsButton.frame = buttonFrame;

    x += buttonWidth + gap;
    
    buttonFrame = self.finishedMatchesButton.frame;
    buttonFrame.origin.x = x;
    buttonFrame.size.width = buttonWidth;
    self.finishedMatchesButton.frame = buttonFrame;
    
    x += buttonWidth + gap;
    
    buttonFrame = self.tournamentWinsButton.frame;
    buttonFrame.origin.x = x;
    buttonFrame.size.width = buttonWidth;
    self.tournamentWinsButton.frame = buttonFrame;
    
    self.navigationBar.leftBarButtonItems = nil;

    self.moreButton.tintColor = [UIColor colorNamed:@"ColorSwitch"];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    else
        [self.navigationController setNavigationBarHidden:NO animated:animated];

    self.navigationItem.hidesBackButton = YES;

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

    [self updateMatchCount:self.view];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reDrawHeader];
    [self updateTableView];
    
    [ self readActiveMatches];
    
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
        return;
    }
}

#pragma mark - Hpple

-(void)readActiveMatches
{
    [self startActivityIndicator:@"Getting active matches from www.dailygammon.com"];

    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];

    self.listArray = [[NSMutableArray alloc]init];

    DGRequest *request = [[DGRequest alloc] initWithString:[NSString stringWithFormat:@"http://dailygammon.com/bg/user/%@?days_to_view=30&active=1&finished=1", userID] completionHandler:^(BOOL success, NSError *error, NSString *result)
                          {
        if (success)
        {
            NSData *htmlData = [result dataUsingEncoding:NSUnicodeStringEncoding];
            
            TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];

            int tableNo = 3;
            NSString *queryString = [NSString stringWithFormat:@"//table[%d]/tr[1]/th",tableNo];
            NSArray *elementHeader  = [xpathParser searchWithXPathQuery:queryString];
            self.listHeaderArray = [[NSMutableArray alloc]init];

            for(TFHppleElement *element in elementHeader)
            {
                [self.listHeaderArray addObject:[element text]];
            }
            self.listArray = [[NSMutableArray alloc]init];
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

                [self.listArray addObject:topPageZeile];
            }
            [self updateTableView];
        }
        else
        {
            XLog(@"Error: %@", error.localizedDescription);
        }
    }];
    request = nil;

}

-(void)readActiveTournaments
{
    [self startActivityIndicator:@"Getting active tournaments from www.dailygammon.com"];

    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];

    self.listArray = [[NSMutableArray alloc]init];
    DGRequest *request = [[DGRequest alloc] initWithString:[NSString stringWithFormat:@"http://dailygammon.com/bg/userevent/%@", userID] completionHandler:^(BOOL success, NSError *error, NSString *result)
                          {
        if (success)
        {
            
            NSData *htmlData = [result dataUsingEncoding:NSUnicodeStringEncoding];
            
            TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
            
            int tableNo = 2;
            NSString *queryString = [NSString stringWithFormat:@"//table[%d]/tr[1]/th",tableNo];
            NSArray *elementHeader  = [xpathParser searchWithXPathQuery:queryString];
            self.listHeaderArray = [[NSMutableArray alloc]init];
            
            for(TFHppleElement *element in elementHeader)
            {
                if([element text] != nil)
                    [self.listHeaderArray addObject:[element text]];
            }
            self.listArray = [[NSMutableArray alloc]init];
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
                
                [self.listArray addObject:topPageZeile];
            }
            [self updateTableView];
        }
        else
        {
            XLog(@"Error: %@", error.localizedDescription);
        }
    }];
    request = nil;
}

-(void)readFinishedMatches
{
    [self startActivityIndicator:@"Getting finished matches from www.dailygammon.com"];

    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];

    self.listArray = [[NSMutableArray alloc]init];
    
    DGRequest *request = [[DGRequest alloc] initWithString:[NSString stringWithFormat:@"http://dailygammon.com/bg/user/%@?days_to_view=30&active=1&finished=1", userID] completionHandler:^(BOOL success, NSError *error, NSString *result)
                          {
        if (success)
        {

            NSData *htmlData = [result dataUsingEncoding:NSUnicodeStringEncoding];
            
            TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];

            int tableNo = 4;
            NSString *queryString = [NSString stringWithFormat:@"//table[%d]/tr[1]/th",tableNo];
            NSArray *elementHeader  = [xpathParser searchWithXPathQuery:queryString];
            self.listHeaderArray = [[NSMutableArray alloc]init];

            for(TFHppleElement *element in elementHeader)
            {
                [self.listHeaderArray addObject:[element text]];
            }
            self.listArray = [[NSMutableArray alloc]init];
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

                [self.listArray addObject:topPageZeile];
            }
            [self updateTableView];
        }
        else
        {
            XLog(@"Error: %@", error.localizedDescription);
        }
    }];
    request = nil;

}

-(void)readTournamentWins
{
    [self startActivityIndicator:@"Getting tournament wins matches from www.dailygammon.com"];

    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];

    self.listArray = [[NSMutableArray alloc]init];
    
    DGRequest *request = [[DGRequest alloc] initWithString:[NSString stringWithFormat:@"http://dailygammon.com/bg/userwins/%@", userID] completionHandler:^(BOOL success, NSError *error, NSString *result)
                          {
        if (success)
        {

            NSData *htmlData = [result dataUsingEncoding:NSUnicodeStringEncoding];
            
            TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];

            int tableNo = 2;
            NSString *queryString = [NSString stringWithFormat:@"//table[%d]/tr[1]/th",tableNo];
            NSArray *elementHeader  = [xpathParser searchWithXPathQuery:queryString];
            self.listHeaderArray = [[NSMutableArray alloc]init];

            for(TFHppleElement *element in elementHeader)
            {
                [self.listHeaderArray addObject:[element text]];
            }
            self.listArray = [[NSMutableArray alloc]init];
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

                [self.listArray addObject:topPageZeile];
            }
            [self updateTableView];
        }
        else
        {
            XLog(@"Error: %@", error.localizedDescription);
        }
    }];
    request = nil;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
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
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSArray *row = self.listArray[indexPath.row];
    
    int x = 0;
    int labelHeight = cell.frame.size.height;
    int cellWidth   = tableView.frame.size.width - 50;

    switch(listTyp)
    {
        case 1:
        {
            float numberWidth   = cellWidth *.05;
            float eventWidth    = cellWidth *.3;
            float graceWidth    = cellWidth *.05;
            float poolWidth     = cellWidth *.1;
            float roundWidth    = cellWidth *.05;
            float lengthWidth   = cellWidth *.05;
            float opponentWidth = cellWidth *.3;
            float reviewWidth   = cellWidth *.1;

            DGLabel *numberLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0 ,numberWidth,labelHeight)];
            numberLabel.textAlignment = NSTextAlignmentCenter;
            NSDictionary *number = row[0];
            numberLabel.text = [number objectForKey:@"Text"];
            
            x += numberWidth;
            
            UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,eventWidth,labelHeight)];
            eventLabel.textAlignment = NSTextAlignmentLeft;
            NSDictionary *event = row[1];
            eventLabel.text = [event objectForKey:@"Text"];
            eventLabel.adjustsFontSizeToFitWidth = YES;
            DGButton *eventButton = [[DGButton alloc] initWithFrame:CGRectMake(x+3, 3 ,eventWidth-6,labelHeight-6)];
            [eventButton setTitle:[event objectForKey:@"Text"] forState: UIControlStateNormal];
            eventButton.tag = indexPath.row;
            [eventButton.layer setValue:[event objectForKey:@"href"] forKey:@"href"];
            [eventButton.layer setValue:[event objectForKey:@"Text"] forKey:@"Text"];

            [eventButton addTarget:self action:@selector(eventAction:) forControlEvents:UIControlEventTouchUpInside];

            x += eventWidth;
            
            UILabel *graceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,graceWidth,labelHeight)];
            graceLabel.textAlignment = NSTextAlignmentCenter;
            NSDictionary *grace = row[2];
            graceLabel.text = [grace objectForKey:@"Text"];
            graceLabel.adjustsFontSizeToFitWidth = YES;
            
            x += graceWidth;
            
            UILabel *poolLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,poolWidth,labelHeight)];
            poolLabel.textAlignment = NSTextAlignmentCenter;
            NSDictionary *pool = row[3];
            poolLabel.text = [pool objectForKey:@"Text"];
            poolLabel.adjustsFontSizeToFitWidth = YES;
            
            x += poolWidth;
            
            UILabel *roundLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,roundWidth,labelHeight)];
            roundLabel.textAlignment = NSTextAlignmentCenter;
            NSDictionary *round = row[4];
            roundLabel.text = [round objectForKey:@"Text"];
            roundLabel.adjustsFontSizeToFitWidth = YES;
            
            x += roundWidth;
            
            UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,lengthWidth,labelHeight)];
            lengthLabel.textAlignment = NSTextAlignmentCenter;
            NSDictionary *length = row[5];
            lengthLabel.text = [length objectForKey:@"Text"];
            lengthLabel.adjustsFontSizeToFitWidth = YES;
            
            x += lengthWidth;
            
            NSDictionary *opponent = row[6];
            DGButton *opponentButton = [[DGButton alloc] initWithFrame:CGRectMake(x+3, 3 ,opponentWidth-6,labelHeight-6)];
            [opponentButton setTitle:[opponent objectForKey:@"Text"] forState: UIControlStateNormal];
            opponentButton.tag = indexPath.row;
            [opponentButton addTarget:self action:@selector(opponentAction:) forControlEvents:UIControlEventTouchUpInside];
            [opponentButton.layer setValue:[opponent objectForKey:@"Text"] forKey:@"name"];
            
            x += opponentWidth;
            
            DGButton *reviewButton = [[DGButton alloc] initWithFrame:CGRectMake(x+3, 3 ,reviewWidth-6,labelHeight-6)];
            [reviewButton setTitle:@"Review" forState: UIControlStateNormal];
            reviewButton.tag = indexPath.row;
            [reviewButton addTarget:self action:@selector(reviewAction:) forControlEvents:UIControlEventTouchUpInside];

            [cell.contentView addSubview:numberLabel];
            if(event.count == 1)
                [cell.contentView addSubview:eventLabel];
            else
                [cell.contentView addSubview:eventButton];
            [cell.contentView addSubview:graceLabel];
            [cell.contentView addSubview:poolLabel];
            [cell.contentView addSubview:roundLabel];
            [cell.contentView addSubview:lengthLabel];
            [cell.contentView addSubview:opponentButton];
            [cell.contentView addSubview:reviewButton];
       }
            break;
        case 2:
        {
            float numberWidth   = cellWidth *.1;
            float eventWidth    = cellWidth *.5;
            float winsWidth     = cellWidth *.2;
            float activeWidth   = cellWidth *.2;

            DGLabel *numberLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0 ,numberWidth,labelHeight)];
            numberLabel.textAlignment = NSTextAlignmentCenter;
            NSDictionary *number = row[1];
            numberLabel.text = [number objectForKey:@"Text"];
            
            x += numberWidth;
            
            UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,eventWidth,labelHeight)];
            eventLabel.textAlignment = NSTextAlignmentLeft;
            NSDictionary *event = row[3];
            eventLabel.text = [event objectForKey:@"Text"];
            eventLabel.adjustsFontSizeToFitWidth = YES;
            DGButton *eventButton = [[DGButton alloc] initWithFrame:CGRectMake(x+3, 3 ,eventWidth-6,labelHeight-6)];
            [eventButton setTitle:[event objectForKey:@"Text"] forState: UIControlStateNormal];
            eventButton.tag = indexPath.row;
            [eventButton.layer setValue:[event objectForKey:@"href"] forKey:@"href"];
            [eventButton.layer setValue:[event objectForKey:@"Text"] forKey:@"Text"];
            [eventButton addTarget:self action:@selector(eventAction:) forControlEvents:UIControlEventTouchUpInside];

            x += eventWidth;
            
            UILabel *winsLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,winsWidth,labelHeight)];
            winsLabel.textAlignment = NSTextAlignmentCenter;
            NSDictionary *wins = row[4];
            winsLabel.text = [wins objectForKey:@"Text"];
            winsLabel.adjustsFontSizeToFitWidth = YES;
            
            x += winsWidth;
            
            DGButton *activeGameButton = [[DGButton alloc] initWithFrame:CGRectMake(x+3, 3 ,activeWidth-6,labelHeight-6)];

            if(row.count == 6)
            {
                [activeGameButton setTitle:@"Active Game" forState: UIControlStateNormal];
                activeGameButton.tag = indexPath.row;
                [activeGameButton addTarget:self action:@selector(activeGameAction:) forControlEvents:UIControlEventTouchUpInside];
            }
            [cell.contentView addSubview:numberLabel];
            [cell.contentView addSubview:eventButton];
            [cell.contentView addSubview:winsLabel];
            if(row.count == 6)
                [cell.contentView addSubview:activeGameButton];

        }
            break;
        case 3:
        {
            float numberWidth   = cellWidth *.05;
            float eventWidth    = cellWidth *.3;
            float roundWidth    = cellWidth *.05;
            float lengthWidth   = cellWidth *.05;
            float opponentWidth = cellWidth *.3;
            float reviewWidth   = cellWidth *.1;

            DGLabel *numberLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0 ,numberWidth,labelHeight)];
            numberLabel.textAlignment = NSTextAlignmentCenter;
            NSDictionary *number = row[0];
            numberLabel.text = [number objectForKey:@"Text"];
            
            x += numberWidth;
            
            UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,eventWidth,labelHeight)];
            eventLabel.textAlignment = NSTextAlignmentLeft;
            NSDictionary *event = row[1];
            eventLabel.text = [event objectForKey:@"Text"];
            eventLabel.adjustsFontSizeToFitWidth = YES;
            DGButton *eventButton = [[DGButton alloc] initWithFrame:CGRectMake(x+3, 3 ,eventWidth-6,labelHeight-6)];
            [eventButton setTitle:[event objectForKey:@"Text"] forState: UIControlStateNormal];
            eventButton.tag = indexPath.row;
            [eventButton.layer setValue:[event objectForKey:@"href"] forKey:@"href"];
            [eventButton.layer setValue:[event objectForKey:@"Text"] forKey:@"Text"];
            [eventButton addTarget:self action:@selector(eventAction:) forControlEvents:UIControlEventTouchUpInside];

            x += eventWidth;
                        
            UILabel *roundLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,roundWidth,labelHeight)];
            roundLabel.textAlignment = NSTextAlignmentCenter;
            NSDictionary *round = row[2];
            roundLabel.text = [round objectForKey:@"Text"];
            roundLabel.adjustsFontSizeToFitWidth = YES;
            
            x += roundWidth;
            
            UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,lengthWidth,labelHeight)];
            lengthLabel.textAlignment = NSTextAlignmentCenter;
            NSDictionary *length = row[3];
            lengthLabel.text = [length objectForKey:@"Text"];
            lengthLabel.adjustsFontSizeToFitWidth = YES;
            
            x += lengthWidth;
            
            NSDictionary *opponent = row[4];
            DGButton *opponentButton = [[DGButton alloc] initWithFrame:CGRectMake(x+3, 3 ,opponentWidth-6,labelHeight-6)];
            [opponentButton setTitle:[opponent objectForKey:@"Text"] forState: UIControlStateNormal];
            opponentButton.tag = indexPath.row;
            [opponentButton addTarget:self action:@selector(opponentAction:) forControlEvents:UIControlEventTouchUpInside];
            [opponentButton.layer setValue:[opponent objectForKey:@"Text"] forKey:@"name"];
            
            x += opponentWidth;
            
            DGButton *reviewButton = [[DGButton alloc] initWithFrame:CGRectMake(x+3, 3 ,reviewWidth-6,labelHeight-6)];
            [reviewButton setTitle:@"Review" forState: UIControlStateNormal];
            reviewButton.tag = indexPath.row;
            [reviewButton addTarget:self action:@selector(reviewAction:) forControlEvents:UIControlEventTouchUpInside];

            x += reviewWidth;
            
            DGButton *exportButton = [[DGButton alloc] initWithFrame:CGRectMake(x+3, 3 ,reviewWidth-6,labelHeight-6)];
            [exportButton setTitle:@"Export" forState: UIControlStateNormal];
            exportButton.tag = indexPath.row;
            [exportButton addTarget:self action:@selector(exportAction:) forControlEvents:UIControlEventTouchUpInside];

            [cell.contentView addSubview:numberLabel];
            if(event.count == 1)
                [cell.contentView addSubview:eventLabel];
            else
                [cell.contentView addSubview:eventButton];
            [cell.contentView addSubview:roundLabel];
            [cell.contentView addSubview:lengthLabel];
            [cell.contentView addSubview:opponentButton];
            [cell.contentView addSubview:reviewButton];
            [cell.contentView addSubview:exportButton];
        }
            break;
        case 4:
        {
            float eventWidth    = cellWidth *.5;
            float dateWidth     = cellWidth *.3;

           
            UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,eventWidth,labelHeight)];
            eventLabel.textAlignment = NSTextAlignmentLeft;
            NSDictionary *event = row[0];
            eventLabel.text = [event objectForKey:@"Text"];
            eventLabel.adjustsFontSizeToFitWidth = YES;
            DGButton *eventButton = [[DGButton alloc] initWithFrame:CGRectMake(x+3, 3 ,eventWidth-6,labelHeight-6)];
            [eventButton setTitle:[event objectForKey:@"Text"] forState: UIControlStateNormal];
            eventButton.tag = indexPath.row;
            [eventButton.layer setValue:[event objectForKey:@"href"] forKey:@"href"];
            [eventButton.layer setValue:[event objectForKey:@"Text"] forKey:@"Text"];
            [eventButton addTarget:self action:@selector(eventAction:) forControlEvents:UIControlEventTouchUpInside];

            x += eventWidth;
            
            UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,dateWidth,labelHeight)];
            dateLabel.textAlignment = NSTextAlignmentCenter;
            NSDictionary *wins = row[1];
            dateLabel.text = [wins objectForKey:@"Text"];
            dateLabel.adjustsFontSizeToFitWidth = YES;
            
            [cell.contentView addSubview:eventButton];
            [cell.contentView addSubview:dateLabel];

       }
            break;
        default:
            break;
   }

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(tableView.frame.origin.x,0,tableView.frame.size.width,30)];
    headerView.backgroundColor = [UIColor lightGrayColor];

    int x = 0;
    int cellWidth   = tableView.frame.size.width - 50;

    switch(listTyp)
    {
        case 1:
        {
            float numberWidth   = cellWidth *.05;
            float eventWidth    = cellWidth *.3;
            float graceWidth    = cellWidth *.05;
            float poolWidth     = cellWidth *.1;
            float roundWidth    = cellWidth *.05;
            float lengthWidth   = cellWidth *.05;
            float opponentWidth = cellWidth *.3;
            
            DGLabel *numberLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0 ,numberWidth,30)];
            numberLabel.textAlignment = NSTextAlignmentCenter;
            numberLabel.text = self.listHeaderArray[0];
            numberLabel.textColor = [UIColor whiteColor];
            x += numberWidth;
            
            DGLabel *eventLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0 ,eventWidth,30)];
            eventLabel.textAlignment = NSTextAlignmentCenter;
            eventLabel.text = self.listHeaderArray[1];
            eventLabel.textColor = [UIColor whiteColor];
            
            x += eventWidth;
            
            DGLabel *graceLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0, graceWidth-2, 30)];
            graceLabel.textAlignment = NSTextAlignmentCenter;
            graceLabel.text = self.listHeaderArray[2];
            graceLabel.textColor = [UIColor whiteColor];
             
            x += graceWidth;
            
            DGLabel *poolLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0, poolWidth-2,30)];
            poolLabel.textAlignment = NSTextAlignmentCenter;
            poolLabel.text = self.listHeaderArray[3];
            poolLabel.textColor = [UIColor whiteColor];
            
            x += poolWidth;
            
            DGLabel *roundLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0, roundWidth-2,30)];
            roundLabel.textAlignment = NSTextAlignmentCenter;
            roundLabel.text = self.listHeaderArray[4];
            roundLabel.textColor = [UIColor whiteColor];
            
            x += roundWidth;
            
            DGLabel *lengthLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0 , lengthWidth-2,30)];
            lengthLabel.textAlignment = NSTextAlignmentCenter;
            lengthLabel.text = self.listHeaderArray[5];
            lengthLabel.textColor = [UIColor whiteColor];
             
            x += lengthWidth;
            
            DGLabel *opponentLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0 , opponentWidth,30)];
            opponentLabel.textAlignment = NSTextAlignmentCenter;
            opponentLabel.text = self.listHeaderArray[6];
            opponentLabel.textColor = [UIColor whiteColor];
            
            [headerView addSubview:numberLabel];
            [headerView addSubview:eventLabel];
            [headerView addSubview:graceLabel];
            [headerView addSubview:poolLabel];
            [headerView addSubview:roundLabel];
            [headerView addSubview:lengthLabel];
            [headerView addSubview:opponentLabel];

            [headerView layoutIfNeeded];
            float minFontSize = poolLabel.font.pointSize;
            if(lengthLabel.font.pointSize < minFontSize)
                minFontSize = lengthLabel.font.pointSize;
            if(graceLabel.font.pointSize < minFontSize)
                minFontSize = graceLabel.font.pointSize;
            if(roundLabel.font.pointSize < minFontSize)
                minFontSize = roundLabel.font.pointSize;

            [roundLabel setFont:[roundLabel.font fontWithSize: minFontSize]];
            [lengthLabel setFont:[lengthLabel.font fontWithSize: minFontSize]];
            [graceLabel setFont:[graceLabel.font fontWithSize: minFontSize]];
            [poolLabel setFont:[poolLabel.font fontWithSize: minFontSize]];


        }
            break;
        case 2:
        {
            float numberWidth   = cellWidth *.1;
            float eventWidth    = cellWidth *.5;
            float winsWidth     = cellWidth *.2;
            
            DGLabel *numberLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0 ,numberWidth,30)];
            numberLabel.textAlignment = NSTextAlignmentCenter;
            numberLabel.text = self.listHeaderArray[0];
            numberLabel.textColor = [UIColor whiteColor];
            x += numberWidth;
            
            DGLabel *eventLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0 ,eventWidth,30)];
            eventLabel.textAlignment = NSTextAlignmentCenter;
            eventLabel.text = self.listHeaderArray[1];
            eventLabel.textColor = [UIColor whiteColor];
            
            x += eventWidth;
            
            DGLabel *winsLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0, winsWidth, 30)];
            winsLabel.textAlignment = NSTextAlignmentCenter;
            NSArray* words = [self.listHeaderArray[2] componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString* nospacestring = [words componentsJoinedByString:@""];
            winsLabel.text = [nospacestring stringByReplacingOccurrencesOfString:@" " withString:@""];
            winsLabel.textColor = [UIColor whiteColor];
             
            x += winsWidth;
                        
            [headerView addSubview:numberLabel];
            [headerView addSubview:eventLabel];
            [headerView addSubview:winsLabel];
        }
            break;
        case 3:
        {
            float numberWidth   = cellWidth *.05;
            float eventWidth    = cellWidth *.3;
            float roundWidth    = cellWidth *.05;
            float lengthWidth   = cellWidth *.05;
            float opponentWidth = cellWidth *.3;
            
            DGLabel *numberLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0 ,numberWidth,30)];
            numberLabel.textAlignment = NSTextAlignmentCenter;
            numberLabel.text = self.listHeaderArray[0];
            numberLabel.textColor = [UIColor whiteColor];
            x += numberWidth;
            
            DGLabel *eventLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0 ,eventWidth,30)];
            eventLabel.textAlignment = NSTextAlignmentCenter;
            eventLabel.text = self.listHeaderArray[1];
            eventLabel.textColor = [UIColor whiteColor];
            
            x += eventWidth;
            
            DGLabel *roundLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0, roundWidth-5,30)];
            roundLabel.textAlignment = NSTextAlignmentCenter;
            roundLabel.text = self.listHeaderArray[2];
            roundLabel.textColor = [UIColor whiteColor];
            
            x += roundWidth;
            
            DGLabel *lengthLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0 , lengthWidth-5,30)];
            lengthLabel.textAlignment = NSTextAlignmentCenter;
            lengthLabel.text = self.listHeaderArray[3];
            lengthLabel.textColor = [UIColor whiteColor];
             
            int minFontSize = roundLabel.font.pointSize;
            if(lengthLabel.font.pointSize < minFontSize)
                minFontSize = lengthLabel.font.pointSize;
            
            [roundLabel setFont:[roundLabel.font fontWithSize: minFontSize]];
            [lengthLabel setFont:[roundLabel.font fontWithSize: minFontSize]];

            x += lengthWidth;
            
            DGLabel *opponentLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0 , opponentWidth,30)];
            opponentLabel.textAlignment = NSTextAlignmentCenter;
            opponentLabel.text = self.listHeaderArray[4];
            opponentLabel.textColor = [UIColor whiteColor];
            
            [headerView addSubview:numberLabel];
            [headerView addSubview:eventLabel];
            [headerView addSubview:roundLabel];
            [headerView addSubview:lengthLabel];
            [headerView addSubview:opponentLabel];
        }
            break;
        case 4:
        {
            float eventWidth    = cellWidth *.5;
            float dateWidth     = cellWidth *.3;
                        
            DGLabel *eventLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0 ,eventWidth,30)];
            eventLabel.textAlignment = NSTextAlignmentCenter;
            eventLabel.text = self.listHeaderArray[0];
            eventLabel.textColor = [UIColor whiteColor];
            
            x += eventWidth;
            
            DGLabel *dateLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0, dateWidth, 30)];
            dateLabel.textAlignment = NSTextAlignmentCenter;
            NSArray* words = [self.listHeaderArray[1] componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString* nospacestring = [words componentsJoinedByString:@""];
            dateLabel.text = [nospacestring stringByReplacingOccurrencesOfString:@" " withString:@""];
            dateLabel.textColor = [UIColor whiteColor];
             
            [headerView addSubview:eventLabel];
            [headerView addSubview:dateLabel];
        }
            break;
        default:
            break;
   }

    return headerView;
    
}

- (void)updateTableView
{
    NSString *headerText = @"";
    switch(listTyp)
    {
        case 1:
            headerText = [NSString stringWithFormat: @"%ld active matches", self.listArray.count];
            break;
        case 2:
            headerText = [NSString stringWithFormat: @"%ld active tournaments", self.listArray.count];
           break;
        case 3:
            headerText = [NSString stringWithFormat: @"%ld finished matches", self.listArray.count];
           break;
        case 4:
            headerText = [NSString stringWithFormat: @"%ld tournaments win", self.listArray.count];
           break;
        default:
            headerText = @"unknown";
            break;
   }
    self.header.text = headerText;
    self.navigationBar.title = headerText;
    [self.tableView reloadData];

    [self stopActivityIndicator];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self inProgress];
}
#pragma mark -

- (IBAction)activeMatches:(id)sender
{
    listTyp = 1;
    [self readActiveMatches];
}
- (IBAction)activeTournaments:(id)sender
{
    listTyp = 2;
    [self readActiveTournaments];
}
- (IBAction)finishedMatches:(id)sender
{
    listTyp = 3;
    [self readFinishedMatches];

}
- (IBAction)tournamentWins:(id)sender
{
    listTyp = 4;
    [self readTournamentWins];
}

-(void)inProgress
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Information"
                                 message:@"I am very sorry. This feature is still under development."
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

- (IBAction)eventAction:(UIButton*)button
{

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Tournament *vc = [app.activeStoryBoard  instantiateViewControllerWithIdentifier:@"Tournament"];
    vc.url   = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",(NSString *)[button.layer valueForKey:@"href"]]];
    vc.name = (NSString *)[button.layer valueForKey:@"Text"];
    [self.navigationController pushViewController:vc animated:NO];

}

- (IBAction)reviewAction:(UIButton*)button
{
    NSArray *row = self.listArray[button.tag];
    int index = 7;
    if(listTyp == 3)
        index = 5;
    NSDictionary *review = row[index];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    Review *vc = [app.activeStoryBoard  instantiateViewControllerWithIdentifier:@"Review"];
    vc.reviewURL = [NSURL URLWithString: [NSString stringWithFormat:@"http://dailygammon.com%@", [review objectForKey:@"href"]]];
    switch(listTyp)
    {
        case 1:
        {
            NSDictionary *length = row[5];
            vc.matchLength = [[length objectForKey:@"Text"]intValue];
            break;
        }
        case 3:
        {
            NSDictionary *length = row[3];
            vc.matchLength = [[length objectForKey:@"Text"]intValue];
            break;
        }
    }
    [self.navigationController pushViewController:vc animated:NO];

    return;
}
- (IBAction)activeGameAction:(UIButton*)button
{
    NSArray *row = self.listArray[button.tag];
    
    NSDictionary *match = row[5];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        PlayMatch *vc = [app.activeStoryBoard  instantiateViewControllerWithIdentifier:@"PlayMatch"];
        vc.matchLink = [match objectForKey:@"href"];
        vc.isReview = TRUE;
        vc.topPageArray = [[NSMutableArray alloc]init];
        [self.navigationController pushViewController:vc animated:NO];
    }
    else
    {
        iPhonePlayMatch *vc = [app.activeStoryBoard  instantiateViewControllerWithIdentifier:@"iPhonePlayMatch"];
        vc.matchLink = [match objectForKey:@"href"];
        vc.isReview = TRUE;
        vc.topPageArray = [[NSMutableArray alloc]init];
        [self.navigationController pushViewController:vc animated:NO];
    }
    return;
    NSDictionary *activeGame = row[5];

    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Information"
                                 message:@"I am very sorry. This feature is still under development."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    
                                }];
    UIAlertAction* browserButton = [UIAlertAction
                                actionWithTitle:@"Show me in the browser please"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://dailygammon.com%@", [activeGame objectForKey:@"href"]]] options:@{} completionHandler:nil];
                                }];

    [alert addAction:yesButton];
    [alert addAction:browserButton];

    [self presentViewController:alert animated:YES completion:nil];

}
- (IBAction)exportAction:(UIButton*)button
{
    NSArray *row = self.listArray[button.tag];
    NSDictionary *activeGame = row[6];
    
    NSDictionary *oppNameDict = row[4];
    NSString *oppName = [oppNameDict objectForKey:@"Text"];
    

    NSString *match = [[activeGame objectForKey:@"href"] lastPathComponent];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com/bg/export/%@", match]];
    NSData *htmlData = [NSData dataWithContentsOfURL:url];

    NSString *htmlString = [NSString stringWithUTF8String:[htmlData bytes]];
    htmlString = [[NSString alloc]
                  initWithData:htmlData encoding: NSISOLatin1StringEncoding];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSMutableString *filtered = [NSMutableString stringWithCapacity:[oppName length]];

    // remove all characters from oppName except for alnums
    for (int i = 0; i < [oppName length]; i++) {
        unichar c = [oppName characterAtIndex:i];
        if (isalnum(c)) {
            [filtered appendFormat:@"%C", c];
        }
    }
    NSURL *urlExport = [[NSURL fileURLWithPath:documentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"dg_%@_%@.txt", match, filtered]];
    NSError *error;

    BOOL success = [htmlString writeToURL:urlExport atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!success) {
        NSLog(@"oh no! - %@",error.localizedDescription);
    }

    NSString *matchExport = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"dg_%@_%@.txt", match, filtered]];

    UIActivityViewController *shareVC = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:matchExport]] applicationActivities:nil];
    shareVC.popoverPresentationController.sourceView    = self.view;
    shareVC.popoverPresentationController.sourceRect = button.frame;
    [self presentViewController:shareVC animated:YES completion:nil];

    return;

}

- (IBAction)moreAction:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    iPhoneMenue *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneMenue"];
    [self.navigationController pushViewController:vc animated:NO];
    
}

- (IBAction)opponentAction:(UIButton*)button
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Player *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"PlayerVC"];
    vc.name   = (NSString *)[button.layer valueForKey:@"name"];

    [self.navigationController pushViewController:vc animated:NO];


}
#pragma mark - Header
#include "HeaderInclude.h"

@end
