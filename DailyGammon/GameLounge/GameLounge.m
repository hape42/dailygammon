//
//  GameLounge.m
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "GameLounge.h"
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
#import "Player.h"
#import "Tools.h"
#import <SafariServices/SafariServices.h>
#import "iPhoneMenue.h"

@interface GameLounge ()

@property (readwrite, retain, nonatomic) NSMutableData *datenData;
@property (assign, atomic) BOOL loginOk;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (readwrite, retain, nonatomic) NSMutableArray *gameLoungeArray;
@property (readwrite, retain, nonatomic) NSMutableArray *gameLoungeHeaderArray;
@property (weak, nonatomic) IBOutlet UILabel *header;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *moreButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;

@property (readwrite, retain, nonatomic) NSString *matchString;

@property (readwrite, retain, nonatomic) UIButton *topPageButton;

@property (nonatomic, retain, readwrite) UIActivityIndicatorView *indicator;

@end

@implementation GameLounge

@synthesize design, preferences, rating, tools;

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.indicator.color = [design schemaColor];
    self.indicator.center = self.view.center;
    [self.view addSubview:self.indicator];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;

    self.tableView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reDrawHeader) name:@"changeSchemaNotification" object:nil];

    design = [[Design alloc] init];
    preferences = [[Preferences alloc] init];
    rating = [[Rating alloc] init];
    tools = [[Tools alloc] init];

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
        [self.view addSubview:[self makeHeader]];

    self.moreButton.tintColor = [UIColor colorNamed:@"ColorSwitch"];

    [self updateTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    else
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationItem.hidesBackButton = YES;


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
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task resume];

    [self.indicator startAnimating];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self.view addSubview:[self makeHeader]];

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
    }
    XLog(@"cookie %ld",[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies].count);
    if([[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies].count < 1)
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        LoginVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"LoginVC"];
        [self.navigationController pushViewController:vc animated:NO];
    }
    else
    {
        [self reDrawHeader];
    }
}


#pragma mark - Hpple

-(void)readGameLounge
{
    XLog(@"readGameLounge");
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
    NSArray *rown  = [xpathParser searchWithXPathQuery:searchString];
    for(int row = 2; row <= rown.count; row ++)
    {
        NSMutableArray *topPageZeile = [[NSMutableArray alloc]init];

        NSString * searchString = [NSString stringWithFormat:@"//table[%d]/tr[%d]/td",tabelleNummer, row];
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
        NSMutableDictionary *event = topPageZeile[0];
        [event setObject:[tools readPlayers:[event objectForKey:@"href"]] forKey:@"player"];

        [self.gameLoungeArray addObject:topPageZeile];
        if(topPageZeile.count == 9)
        {
            NSMutableDictionary *note = topPageZeile[8];
            [note setObject:[tools readNote:[event objectForKey:@"href"]] forKey:@"note"];
        }
    }
    [self.indicator stopAnimating];

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
        if ([subview isKindOfClass:[UIButton class]])
        {
            [subview removeFromSuperview];
        }
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    
    NSArray *row = self.gameLoungeArray[indexPath.row];
    
    int x = 0;
    int labelHeight = cell.frame.size.height;
    int signUpWidth = 100;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        int nameWidth = 250;
        int variantWidth = 120;
        int lengthWidth = 60;
        int roundsWidth = 60;
        int playerWidth = 60;
        int timeWidth = 120;
        int graceWidth = 60;
        
        signUpWidth = (tableView.frame.size.width - nameWidth - variantWidth - lengthWidth - roundsWidth - playerWidth - timeWidth - graceWidth)- 00;
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,nameWidth,labelHeight)];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        NSDictionary *name = row[0];
        nameLabel.text = [name objectForKey:@"Text"];
        
        x += nameWidth;
        
        UILabel *variantLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,variantWidth,labelHeight)];
        variantLabel.textAlignment = NSTextAlignmentCenter;
        NSDictionary *variant = row[1];
        variantLabel.text = [variant objectForKey:@"Text"];
        
        x += variantWidth;
        
        UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,lengthWidth,labelHeight)];
        lengthLabel.textAlignment = NSTextAlignmentCenter;
        NSDictionary *length = row[2];
        lengthLabel.text = [length objectForKey:@"Text"];
        
        x += lengthWidth;
        
        UILabel *roundsLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,roundsWidth,labelHeight)];
        roundsLabel.textAlignment = NSTextAlignmentCenter;
        NSDictionary *rounds = row[3];
        roundsLabel.text = [rounds objectForKey:@"Text"];
        
        x += roundsWidth;
        
        UILabel *playerLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,playerWidth,labelHeight)];
        playerLabel.textAlignment = NSTextAlignmentCenter;
        playerLabel.text = [name objectForKey:@"player"];
        playerLabel.adjustsFontSizeToFitWidth = YES;
        
        x += playerWidth;
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,timeWidth,labelHeight)];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        NSDictionary *time = row[4];
        NSDictionary *timePlus = row[5];
        
        timeLabel.text = [NSString stringWithFormat:@"%@ %@",[time objectForKey:@"Text"], [timePlus objectForKey:@"Text"]];
        
        x += timeWidth;
        
        UILabel *graceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,graceWidth,labelHeight)];
        graceLabel.textAlignment = NSTextAlignmentCenter;
        NSDictionary *grace = row[6];
        graceLabel.text = [grace objectForKey:@"Text"];
    
        x += graceWidth;
        
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:variantLabel];
        [cell.contentView addSubview:lengthLabel];
        [cell.contentView addSubview:roundsLabel];
        [cell.contentView addSubview:playerLabel];
        [cell.contentView addSubview:timeLabel];
        [cell.contentView addSubview:graceLabel];

    }
    else
    {
        //iPhone
        int maxWidth = tableView.frame.size.width;
        int buttonWidth = 120;
        maxWidth -= (buttonWidth + 5);
        
        float nameWidth = maxWidth * 0.35;
        float lengthWidth = maxWidth * 0.125;
        float timeWidth = maxWidth * 0.3;
        float playerWidth = maxWidth * 0.125;
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,nameWidth,labelHeight/2)];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        NSDictionary *name = row[0];
        nameLabel.text = [name objectForKey:@"Text"];
        [nameLabel setFont:[UIFont boldSystemFontOfSize: nameLabel.font.pointSize]];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        
        UILabel *variantLabel = [[UILabel alloc] initWithFrame:CGRectMake(x + 10, labelHeight/2 ,nameWidth - 10,labelHeight/2)];
        variantLabel.textAlignment = NSTextAlignmentLeft;
        NSDictionary *variant = row[1];
        variantLabel.text = [variant objectForKey:@"Text"];

        x += nameWidth;
        
        UILabel *playerLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+3, 0 ,playerWidth,labelHeight/2)];
        playerLabel.textAlignment = NSTextAlignmentCenter;
        playerLabel.text = [name objectForKey:@"player"];
        playerLabel.adjustsFontSizeToFitWidth = YES;

        x += playerWidth;

        UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,lengthWidth,labelHeight/2)];
        lengthLabel.textAlignment = NSTextAlignmentCenter;
        NSDictionary *length = row[2];
        lengthLabel.text = [length objectForKey:@"Text"];

        UILabel *roundsLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, labelHeight/2 ,lengthWidth,labelHeight/2)];
        roundsLabel.textAlignment = NSTextAlignmentCenter;
        NSDictionary *rounds = row[3];
        roundsLabel.text = [rounds objectForKey:@"Text"];

        x += lengthWidth;

        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,timeWidth,labelHeight/2)];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        NSDictionary *time = row[4];
        NSDictionary *timePlus = row[5];

        timeLabel.text = [NSString stringWithFormat:@"%@ %@",[time objectForKey:@"Text"], [timePlus objectForKey:@"Text"]];

        UILabel *graceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, labelHeight/2 ,timeWidth,labelHeight/2)];
        graceLabel.textAlignment = NSTextAlignmentCenter;
        NSDictionary *grace = row[6];
        graceLabel.text = [grace objectForKey:@"Text"];
        
        x += timeWidth;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:variantLabel];
        [cell.contentView addSubview:playerLabel];
        [cell.contentView addSubview:lengthLabel];
        [cell.contentView addSubview:roundsLabel];
        [cell.contentView addSubview:timeLabel];
        [cell.contentView addSubview:graceLabel];

    }
    UILabel *signUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,signUpWidth,labelHeight)];
    signUpLabel.textAlignment = NSTextAlignmentLeft;
    
    NSDictionary *signUp = row[7];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    if([[signUp objectForKey:@"Text"] isEqualToString:@"Sign Up\n"] || [[signUp objectForKey:@"Text"] isEqualToString:@"Cancel Signup\n"])
    {
        button = [design makeNiceButton:button];
        [button setTitle:[signUp objectForKey:@"Text"] forState: UIControlStateNormal];
        if([[signUp objectForKey:@"Text"] isEqualToString:@"Sign Up\n"])
            button.frame = CGRectMake((signUpWidth - button.frame.size.width - 25)/2 , 5, 100 , 35);
        else
        {
            button.frame = CGRectMake((signUpWidth - button.frame.size.width - 25)/2 , 5, 150 , 35);
            button = [design makeReverseButton:button];
        }
        button.frame = CGRectMake(x + ((signUpWidth - button.frame.size.width -50)/2), 5, button.frame.size.width + 50 , 35);

        button.tag = indexPath.row;
        [button addTarget:self action:@selector(signUp:) forControlEvents:UIControlEventTouchUpInside];
        [signUpLabel addSubview:button];
    }
    else
    {
        XLog(@"no Button");
    }

    [cell.contentView addSubview:button];

    if(row.count == 9)
    {
        UIButton *infoButton = [self makeInfoButton];
        infoButton.tag = indexPath.row;
        cell.accessoryView = infoButton;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(tableView.frame.origin.x,0,tableView.frame.size.width,30)];
    headerView.backgroundColor = [UIColor lightGrayColor];

    int x = 0;

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        
        int nameWidth = 250;
        int variantWidth = 120;
        int lengthWidth = 60;
        int roundsWidth = 60;
        int playerWidth = 60;
        int timeWidth = 120;
        int graceWidth = 60;
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,nameWidth,30)];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.text = self.gameLoungeHeaderArray[0];
        nameLabel.textColor = [UIColor whiteColor];
        
        x += nameWidth;
        
        UILabel *variantLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,variantWidth,30)];
        variantLabel.textAlignment = NSTextAlignmentCenter;
        variantLabel.text = self.gameLoungeHeaderArray[1];
        variantLabel.textColor = [UIColor whiteColor];
        
        x += variantWidth;
        
        UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,lengthWidth,30)];
        lengthLabel.textAlignment = NSTextAlignmentCenter;
        lengthLabel.text = self.gameLoungeHeaderArray[2];
        lengthLabel.textColor = [UIColor whiteColor];
        
        x += lengthWidth;
        
        UILabel *roundsLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,roundsWidth,30)];
        roundsLabel.textAlignment = NSTextAlignmentCenter;
        roundsLabel.text = self.gameLoungeHeaderArray[3];
        roundsLabel.textColor = [UIColor whiteColor];
        
        x += roundsWidth;
        
        UILabel *playerLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,roundsWidth,30)];
        playerLabel.textAlignment = NSTextAlignmentCenter;
        playerLabel.text = @"Player";
        playerLabel.textColor = [UIColor whiteColor];
        
        x += playerWidth;
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,timeWidth,30)];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.text = self.gameLoungeHeaderArray[4];
        timeLabel.textColor = [UIColor whiteColor];
        
        x += timeWidth;
        
        UILabel *graceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,graceWidth,30)];
        graceLabel.textAlignment = NSTextAlignmentCenter;
        graceLabel.text = self.gameLoungeHeaderArray[5];
        graceLabel.textColor = [UIColor whiteColor];
        
        
        [headerView addSubview:nameLabel];
        [headerView addSubview:variantLabel];
        [headerView addSubview:lengthLabel];
        [headerView addSubview:roundsLabel];
        [headerView addSubview:playerLabel];
        [headerView addSubview:timeLabel];
        [headerView addSubview:graceLabel];
    }
    else
    {
        int maxWidth = tableView.frame.size.width;
        int buttonWidth = 120;
        maxWidth -= buttonWidth;
        int x = 0;
        
        float nameWidth = maxWidth * 0.35;
        float lengthWidth = maxWidth * 0.125;
        float timeWidth = maxWidth * 0.3;
        float playerWidth = maxWidth * 0.125;

        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,nameWidth,40)];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.text = self.gameLoungeHeaderArray[0];
        nameLabel.textColor = [UIColor whiteColor];
        
        x += nameWidth;
        
        UILabel *playerLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,playerWidth,20)];
        playerLabel.textAlignment = NSTextAlignmentCenter;
        playerLabel.text = @"Player";
        playerLabel.textColor = [UIColor whiteColor];

        x += playerWidth;

        UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,lengthWidth,20)];
        lengthLabel.textAlignment = NSTextAlignmentCenter;
        lengthLabel.text = self.gameLoungeHeaderArray[2];
        lengthLabel.textColor = [UIColor whiteColor];
        
        UILabel *roundsLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 20 ,lengthWidth,20)];
        roundsLabel.textAlignment = NSTextAlignmentCenter;
        roundsLabel.text = self.gameLoungeHeaderArray[3];
        roundsLabel.textColor = [UIColor whiteColor];

        x += lengthWidth;

        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,timeWidth,20)];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.text = self.gameLoungeHeaderArray[4];
        timeLabel.textColor = [UIColor whiteColor];

        UILabel *graceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 20 ,timeWidth,20)];
        graceLabel.textAlignment = NSTextAlignmentCenter;
        graceLabel.text = self.gameLoungeHeaderArray[5];
        graceLabel.textColor = [UIColor whiteColor];
        
        [headerView addSubview:nameLabel];
        [headerView addSubview:playerLabel];
        [headerView addSubview:lengthLabel];
        [headerView addSubview:roundsLabel];
        [headerView addSubview:timeLabel];
        [headerView addSubview:graceLabel];

    }
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        return 30;
    else
        return 40;

}
- (void)updateTableView
{
    [self readGameLounge];
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *row = self.gameLoungeArray[indexPath.row];
    NSDictionary *turnier = row[0];
    
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
    NSArray *row = self.gameLoungeArray[sender.tag];
    NSDictionary *signUp = row[7];

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

- (UIButton *)makeInfoButton
{
    UIButton *button = [[UIButton alloc]init];
    UIImage *image = [[UIImage imageNamed:@"Note"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 10.0, 30, 30);
    [button addTarget:self action:@selector(showNote:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];

    [button setTintColor:[design schemaColor]];
    [button setTitleColor:[UIColor colorNamed:@"ColorSwitch"] forState:UIControlStateNormal];
    button.imageView.tintColor = [UIColor colorNamed:@"ColorSwitch"];
    return button;
}
- (void)showNote:(UIButton*)sender
{
    NSString *note = @"Note";
    NSArray *row = self.gameLoungeArray[sender.tag];
    if(row.count == 9)
    {
        NSDictionary *dict = row[8];
        note = [dict objectForKey:@"note"];
    }
     UIAlertController * alert = [UIAlertController
                                   alertControllerWithTitle:@"Note"
                                   message:note
                                   preferredStyle:UIAlertControllerStyleAlert];

     UIAlertAction* okButton = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     return;
                                 }];

     [alert addAction:okButton];
    
    alert = [design makeBackgroundColor:alert];

     [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Header

- (IBAction)moreAction:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    iPhoneMenue *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneMenue"];
    [self.navigationController pushViewController:vc animated:NO];
    
}

#include "HeaderInclude.h"

@end
