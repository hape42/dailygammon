//
//  GameLounge.m
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "GameLounge.h"
#import "Header.h"
#import "Design.h"
#import "TFHpple.h"
#import "PlayMatch.h"
#import "Preferences.h"
#import "Rating.h"
#import "LoginVC.h"
#import "TopPageVC.h"
#import "AppDelegate.h"
#import "DbConnect.h"
#import "RatingVC.h"

@interface GameLounge ()

@property (readwrite, retain, nonatomic) NSMutableData *datenData;
@property (readwrite, retain, nonatomic) NSURLConnection *downloadConnection;
@property (assign, atomic) BOOL loginOk;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (readwrite, retain, nonatomic) NSMutableArray *gameLoungeArray;
@property (readwrite, retain, nonatomic) NSMutableArray *gameLoungeHeaderArray;
@property (weak, nonatomic) IBOutlet UILabel *header;

@property (readwrite, retain, nonatomic) NSString *matchString;

@end

@implementation GameLounge

@synthesize design, preferences, rating;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = VIEWBACKGROUNDCOLOR;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reDrawHeader) name:@"changeSchemaNotification" object:nil];

    design = [[Design alloc] init];
    preferences = [[Preferences alloc] init];
    rating = [[Rating alloc] init];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}

-(void) reDrawHeader
{
    [self.view addSubview:[self makeHeader]];

    [self updateTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];

    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"user"];
    NSString *userPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];

    self.loginOk = FALSE;
    
    //    https://stackoverflow.com/questions/15749486/sending-an-http-post-request-on-ios
    NSString *post = [NSString stringWithFormat:@"login=%@&password=%@",userName,userPassword];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
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
        XLog(@"Connection Successful");
    } else
    {
        XLog(@"Connection could not be made");
    }

    if (self.downloadConnection)
    {
        self.datenData = [[NSMutableData alloc] init];
    }
    
    [self reDrawHeader];

}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
//    NSDictionary *fields = [HTTPResponse allHeaderFields];
 //   NSString *cookie = [fields valueForKey:@"Set-Cookie"];
//    XLog(@"Connection begonnen %@", cookie);
    
    self.datenData = [[NSMutableData alloc] init];

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(self.loginOk)
        [self.datenData appendData:data];
    else
        self.loginOk = TRUE;
//    XLog(@"Connection didReceiveData");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
//    XLog(@"Connection didFailWithError");
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
            [ self readGameLounge];
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

#pragma mark - Hpple

-(void)readGameLounge
{

    NSURL *urlTopPage = [NSURL URLWithString:@"http://dailygammon.com/bg/lounge"];
    NSData *topPageHtmlData = [NSData dataWithContentsOfURL:urlTopPage];

    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:topPageHtmlData];
    
    // sind "waiting games "da, dann stehen die Turniere in der 3 tabelle, sonst in der 2.
    //  Header, Waiting, Turniere, Footer = 4 Tabellen
    //  Header, Turniere, Footer = 3 Tabellen
    NSArray *tableArray  = [xpathParser searchWithXPathQuery:@"//table"];
    int tabelleNummer = tableArray.count == 4 ? 3 : 2;

    NSString *searchString = [NSString stringWithFormat:@"//table[%d]/tr[1]/th",tabelleNummer];
    NSArray *elementHeader  = [xpathParser searchWithXPathQuery:searchString];
    self.gameLoungeHeaderArray = [[NSMutableArray alloc]init];

    for(TFHppleElement *element in elementHeader)
    {
        //            XLog(@"%@",[element text]);
        [self.gameLoungeHeaderArray addObject:[element text]];
    }
    self.gameLoungeArray = [[NSMutableArray alloc]init];
    searchString = [NSString stringWithFormat:@"//table[%d]/tr",tabelleNummer];
    NSArray *zeilen  = [xpathParser searchWithXPathQuery:searchString];
    for(int zeile = 2; zeile <= zeilen.count; zeile ++)
    {
        NSMutableArray *topPageZeile = [[NSMutableArray alloc]init];

        NSString * searchString = [NSString stringWithFormat:@"//table[%d]/tr[%d]/td",tabelleNummer, zeile];
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

        [self.gameLoungeArray addObject:topPageZeile];
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return self.gameLoungeArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
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
        if ([subview isKindOfClass:[UIButton class]])
        {
            [subview removeFromSuperview];
        }
    }

    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSArray *zeile = self.gameLoungeArray[indexPath.row];
    
    int x = 0;
    int labelHoehe = cell.frame.size.height;
    int nameBreite = 250;
    int variantBreite = 120;
    int lengthBreite = 60;
    int roundsBreite = 60;
    int timeBreite = 150;
    int graceBreite = 60;
    int signUpBreite = (tableView.frame.size.width - nameBreite - variantBreite - lengthBreite - roundsBreite - timeBreite - graceBreite);
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,nameBreite,labelHoehe)];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    NSDictionary *name = zeile[0];
    nameLabel.text = [name objectForKey:@"Text"];
    
    x += nameBreite;
    
    UILabel *variantLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,variantBreite,labelHoehe)];
    variantLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *variant = zeile[1];
    variantLabel.text = [variant objectForKey:@"Text"];
    
    x += variantBreite;
    
    UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,lengthBreite,labelHoehe)];
    lengthLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *length = zeile[2];
    lengthLabel.text = [length objectForKey:@"Text"];
    
    x += lengthBreite;
    
    UILabel *roundsLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,roundsBreite,labelHoehe)];
    roundsLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *rounds = zeile[3];
    roundsLabel.text = [rounds objectForKey:@"Text"];

    x += roundsBreite;
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,timeBreite,labelHoehe)];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *time = zeile[4];
    NSDictionary *timePlus = zeile[5];

    timeLabel.text = [NSString stringWithFormat:@"%@ %@",[time objectForKey:@"Text"], [timePlus objectForKey:@"Text"]];

    x += timeBreite;
    
    UILabel *graceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,graceBreite,labelHoehe)];
    graceLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *grace = zeile[6];
    graceLabel.text = [grace objectForKey:@"Text"];

    x += graceBreite;
    
    UILabel *signUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,signUpBreite,labelHoehe)];
    signUpLabel.textAlignment = NSTextAlignmentLeft;
    NSDictionary *signUp = zeile[7];
    //signUpLabel.text = [signUp objectForKey:@"Text"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    if([[signUp objectForKey:@"Text"] isEqualToString:@"Sign Up\n"] || [[signUp objectForKey:@"Text"] isEqualToString:@"Cancel Signup\n"])
    {
        button = [design makeNiceButton:button];
        [button setTitle:[signUp objectForKey:@"Text"] forState: UIControlStateNormal];
//        [button sizeToFit];
        if([[signUp objectForKey:@"Text"] isEqualToString:@"Sign Up\n"])
            button.frame = CGRectMake((signUpBreite - button.frame.size.width - 25)/2 , 5, 100 , 35);
        else
            button.frame = CGRectMake((signUpBreite - button.frame.size.width - 25)/2 , 5, 150 , 35);

        button.frame = CGRectMake(x + ((signUpBreite - button.frame.size.width -50)/2), 5, button.frame.size.width + 50 , 35);

        button.tag = indexPath.row;
        [button addTarget:self action:@selector(signUp:) forControlEvents:UIControlEventTouchUpInside];
        [signUpLabel addSubview:button];
    }
    else
    {
        XLog(@"kein Button");
    }

    [cell.contentView addSubview:nameLabel];
    [cell.contentView addSubview:variantLabel];
    [cell.contentView addSubview:lengthLabel];
    [cell.contentView addSubview:roundsLabel];
    [cell.contentView addSubview:timeLabel];
    [cell.contentView addSubview:graceLabel];
   // [cell.contentView addSubview:signUpLabel];
    [cell.contentView addSubview:button];

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(tableView.frame.origin.x,0,tableView.frame.size.width,30)];
    headerView.backgroundColor = [UIColor lightGrayColor];

    int x = 0;

    int nameBreite = 250;
    int variantBreite = 120;
    int lengthBreite = 60;
    int roundsBreite = 60;
    int timeBreite = 150;
    int graceBreite = 60;

    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,nameBreite,30)];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.text = self.gameLoungeHeaderArray[0];
    nameLabel.textColor = [UIColor whiteColor];

    x += nameBreite;
    
    UILabel *variantLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,variantBreite,30)];
    variantLabel.textAlignment = NSTextAlignmentCenter;
    variantLabel.text = self.gameLoungeHeaderArray[1];
    variantLabel.textColor = [UIColor whiteColor];

    x += variantBreite;

    UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,lengthBreite,30)];
    lengthLabel.textAlignment = NSTextAlignmentCenter;
    lengthLabel.text = self.gameLoungeHeaderArray[2];
    lengthLabel.textColor = [UIColor whiteColor];

    x += lengthBreite;
    
    UILabel *roundsLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,roundsBreite,30)];
    roundsLabel.textAlignment = NSTextAlignmentCenter;
    roundsLabel.text = self.gameLoungeHeaderArray[3];
    roundsLabel.textColor = [UIColor whiteColor];

    x += roundsBreite;
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,timeBreite,30)];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.text = self.gameLoungeHeaderArray[4];
    timeLabel.textColor = [UIColor whiteColor];

    x += timeBreite;
    
    UILabel *graceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,graceBreite,30)];
    graceLabel.textAlignment = NSTextAlignmentCenter;
    graceLabel.text = self.gameLoungeHeaderArray[5];
    graceLabel.textColor = [UIColor whiteColor];


    [headerView addSubview:nameLabel];
    [headerView addSubview:variantLabel];
    [headerView addSubview:lengthLabel];
    [headerView addSubview:roundsLabel];
    [headerView addSubview:timeLabel];
    [headerView addSubview:graceLabel];

    return headerView;
    
}

- (void)updateTableView
{
    [ self readGameLounge];
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *zeile = self.gameLoungeArray[indexPath.row];
    NSDictionary *turnier = zeile[0];
    
    NSURL *urlTurnier = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",[turnier objectForKey:@"href"]]];
    
    NSError *error = nil;
    NSStringEncoding encoding = 0;
    NSString *htmlString = [[NSString alloc] initWithContentsOfURL:urlTurnier
                                                       usedEncoding:&encoding
                                                              error:&error];
    NSData *turnierHtmlData = [NSData dataWithContentsOfURL:urlTurnier];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:turnierHtmlData];

    
    NSArray *tableArray  = [xpathParser searchWithXPathQuery:@"//table[1]"];
    NSString *raw = @"";
    for(TFHppleElement *element in tableArray)
    {
        for (TFHppleElement *child in element.children)
        {
            raw = [child raw];
//            XLog(@"%@", raw);
        }
    }
    NSString *tabelleString = @"";
    NSRange preStart = [htmlString rangeOfString:@"<TABLE"];
    if(preStart.length > 0)
    {
        NSRange preEnd = [htmlString rangeOfString:@"</TABLE"];
        NSRange tabelleRange = NSMakeRange(preStart.location + preStart.length, preEnd.location - preStart.location - preStart.length);
        tabelleString = [htmlString substringWithRange:tabelleRange];
    }
    [htmlString stringByReplacingOccurrencesOfString:raw withString:@""];


    return;
}

-(void)signUp:(UIButton*)sender
{
    NSArray *zeile = self.gameLoungeArray[sender.tag];
    NSDictionary *signUp = zeile[7];

    NSURL *urlSignUp = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",[signUp objectForKey:@"href"]]];
    
    NSError *error = nil;
    NSStringEncoding encoding = 0;
    self.matchString = [[NSString alloc] initWithContentsOfURL:urlSignUp
                                                       usedEncoding:&encoding
                                                              error:&error];
    if(error)
        XLog(@"%@ %@", urlSignUp, error.localizedDescription);
    [self updateTableView];
}

#pragma mark - Header
#include "HeaderInclude.h"

@end
