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

@property (nonatomic, retain, readwrite) UIActivityIndicatorView *indicator;

@end

@implementation PlayerLists

@synthesize design, preferences, rating, tools, ratingTools;
@synthesize listTyp;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.indicator.color = [design schemaColor];
    self.indicator.center = self.view.center;
    [self.view addSubview:self.indicator];
    
    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
    
    self.tableView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reDrawHeader) name:@"changeSchemaNotification" object:nil];

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
 //       [ self readTopPage];
    }
}

#pragma mark - Hpple

-(void)readActiveMatches
{
    [self.indicator startAnimating];

    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];

    NSURL *urlTopPage = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com/bg/user/%@?days_to_view=30&active=1&finished=1", userID]];
    NSData *topPageHtmlData = [NSData dataWithContentsOfURL:urlTopPage];

    NSString *htmlString = [NSString stringWithUTF8String:[topPageHtmlData bytes]];
    htmlString = [[NSString alloc]
                  initWithData:topPageHtmlData encoding: NSISOLatin1StringEncoding];
    self.listArray = [[NSMutableArray alloc]init];


    // Create parser
    
    //    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:topPageHtmlData];
    
    NSData *htmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];

    //Get all the cells of the 2nd row of the 3rd table
    //        NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[3]/tr[2]/td"];
    int tableNo = 3;
    NSString *queryString = [NSString stringWithFormat:@"//table[%d]/tr[1]/th",tableNo];
    NSArray *elementHeader  = [xpathParser searchWithXPathQuery:queryString];
    self.listHeaderArray = [[NSMutableArray alloc]init];

    for(TFHppleElement *element in elementHeader)
    {
        //            XLog(@"%@",[element text]);
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

        [self.listArray addObject:topPageZeile];
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
            float reviewWidth   = cellWidth *.15;

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
            
            NSDictionary *review = row[7];
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
            break;
        case 3:
            break;
        case 4:
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
            float reviewWidth   = cellWidth *.15;
            
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
            
            DGLabel *graceLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0, graceWidth, 30)];
            graceLabel.textAlignment = NSTextAlignmentCenter;
            graceLabel.text = self.listHeaderArray[2];
            graceLabel.textColor = [UIColor whiteColor];
             
            x += graceWidth;
            
            DGLabel *poolLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0, poolWidth,30)];
            poolLabel.textAlignment = NSTextAlignmentCenter;
            poolLabel.text = self.listHeaderArray[3];
            poolLabel.textColor = [UIColor whiteColor];
            
            x += poolWidth;
            
            DGLabel *roundLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0, roundWidth,30)];
            roundLabel.textAlignment = NSTextAlignmentCenter;
            roundLabel.text = self.listHeaderArray[4];
            roundLabel.textColor = [UIColor whiteColor];
            
            x += roundWidth;
            
            DGLabel *lengthLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0 , lengthWidth,30)];
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
        }
            break;
        case 2:
            break;
        case 3:
            break;
        case 4:
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
            headerText = @"active matches";
            break;
        case 2:
            headerText = @"active tournaments";
            break;
        case 3:
            headerText = @"finished matches";
            break;
        case 4:
            headerText = @"tournaments win";
            break;
        default:
            headerText = @"unknown";
            break;
   }
    self.header.text = headerText;
    self.navigationBar.title = headerText;
    [self.tableView reloadData];

    [self.indicator stopAnimating];
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
    [self inProgress];
}
- (IBAction)finishedMatches:(id)sender
{
    listTyp = 3;
    [self inProgress];

}
- (IBAction)tournamentWins:(id)sender
{
    listTyp = 4;
    [self inProgress];
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
    NSArray *row = self.listArray[button.tag];
    NSDictionary *event = row[1];

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
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://dailygammon.com%@", [event objectForKey:@"href"]]] options:@{} completionHandler:nil];
                                }];

    [alert addAction:yesButton];
    [alert addAction:browserButton];

    
    [self presentViewController:alert animated:YES completion:nil];

}

- (IBAction)reviewAction:(UIButton*)button
{
    NSArray *row = self.listArray[button.tag];
    NSDictionary *review = row[7];

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
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://dailygammon.com%@", [review objectForKey:@"href"]]] options:@{} completionHandler:nil];
                                }];

    [alert addAction:yesButton];
    [alert addAction:browserButton];

    [self presentViewController:alert animated:YES completion:nil];

}

- (IBAction)moreAction:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    iPhoneMenue *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneMenue"];
    [self.navigationController pushViewController:vc animated:NO];
    
}

- (IBAction)opponentAction:(UIButton*)button
{
    NSArray *row = self.listArray[button.tag];
    
    NSMutableDictionary *dict = row[3];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Player *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"PlayerVC"];
    vc.name   = (NSString *)[button.layer valueForKey:@"name"];

    [self.navigationController pushViewController:vc animated:NO];


}
#pragma mark - Header
#include "HeaderInclude.h"

@end
