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

@end

@implementation TopPageVC

@synthesize design, preferences, rating;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = VIEWBACKGROUNDCOLOR;
//    self.tableView.backgroundColor = HEADERBACKGROUNDCOLOR;

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
    self.sortGraceButton = [design makeNiceButton:self.sortGraceButton];
    self.sortPoolButton = [design makeNiceButton:self.sortPoolButton];
    self.sortGracePoolButton = [design makeNiceButton:self.sortGracePoolButton];
    self.sortRecentButton = [design makeNiceButton:self.sortRecentButton];

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
//    NSString *cookie = [fields valueForKey:@"Set-Cookie"];
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
            LoginVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
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
        LoginVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
        [self.navigationController pushViewController:vc animated:NO];
    }
    
    return;
}

#pragma mark - Hpple

-(void)readTopPage
{

    NSURL *urlTopPage = [NSURL URLWithString:@"http://dailygammon.com/bg/top"];
    NSData *topPageHtmlData = [NSData dataWithContentsOfURL:urlTopPage];

    NSString *htmlString = [NSString stringWithUTF8String:[topPageHtmlData bytes]];
    htmlString = [[NSString alloc]
                  initWithData:topPageHtmlData encoding: NSISOLatin1StringEncoding];
    self.topPageArray = [[NSMutableArray alloc]init];

    if ([htmlString rangeOfString:@"There are no matches where you can move."].location != NSNotFound)
    {
        return;
    }

    // Create parser
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:topPageHtmlData];
    
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
    
//    UIView.animate(
//                   withDuration: duration,
//                   delay: delayFactor * Double(indexPath.row),
//                   options: [.curveEaseInOut],
//                   animations: {
//                       cell.transform = CGAffineTransform(translationX: 0, y: 0)
//                   })

//    //1. Define the initial state (Before the animation)
//    cell.transform = CGAffineTransformMakeTranslation(0.f, 100);
//    cell.layer.shadowColor = [[UIColor greenColor]CGColor];
//    cell.layer.shadowOffset = CGSizeMake(10, 10);
//    cell.alpha = 0;
//
//    //2. Define the final state (After the animation) and commit the animation
//    [UIView beginAnimations:@"rotation" context:NULL];
//    [UIView setAnimationDuration:0.5];
//    cell.transform = CGAffineTransformMakeTranslation(0.f, 0);
//    cell.alpha = 1;
//    cell.layer.shadowOffset = CGSizeMake(0, 0);
//    [UIView commitAnimations];
    
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
    frame.size.height = 20;
    frame.size.width = 20;

    checkmark.frame = frame;
    cell.accessoryView = checkmark;
    
    
    NSArray *zeile = self.topPageArray[indexPath.row];
    
    int x = 0;
    int labelHoehe = cell.frame.size.height;
    int nummerBreite = 40;
    int graceBreite = 80;
    int poolBreite = 120;
    int roundBreite = 80;
    int lengthBreite = 80;
    int opponentBreite = (tableView.frame.size.width - nummerBreite - graceBreite - poolBreite - roundBreite - lengthBreite)/2 ;
    int eventBreite = opponentBreite;
    
    UILabel *nummerLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,nummerBreite,labelHoehe)];
    nummerLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *nummer = zeile[0];
    nummerLabel.text = [nummer objectForKey:@"Text"];
    
    x += nummerBreite;
    
    UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,eventBreite,labelHoehe)];
    eventLabel.textAlignment = NSTextAlignmentLeft;
    NSDictionary *event = zeile[1];
    eventLabel.text = [event objectForKey:@"Text"];
    
    x += eventBreite;
    
    UILabel *graceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,graceBreite,labelHoehe)];
    graceLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *grace = zeile[2];
    graceLabel.text = [grace objectForKey:@"Text"];
    
    x += graceBreite;
    
    UILabel *poolLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,poolBreite,labelHoehe)];
    poolLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *pool = zeile[3];
    poolLabel.text = [pool objectForKey:@"Text"];

    x += poolBreite;
    
    UILabel *roundLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,roundBreite,labelHoehe)];
    roundLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *round = zeile[4];
    roundLabel.text = [round objectForKey:@"Text"];

    x += roundBreite;
    
    UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,lengthBreite,labelHoehe)];
    lengthLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *length = zeile[5];
    lengthLabel.text = [length objectForKey:@"Text"];

    x += lengthBreite;
    
    UILabel *opponentLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,opponentBreite,labelHoehe)];
    opponentLabel.textAlignment = NSTextAlignmentLeft;
    opponentLabel.text = self.topPageHeaderArray[6];
    NSDictionary *opponent = zeile[6];
    opponentLabel.text = [opponent objectForKey:@"Text"];
    
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

    int nummerBreite = 40;
    int graceBreite = 80;
    int poolBreite = 120;
    int roundBreite = 80;
    int lengthBreite = 80;
    int opponentBreite = (tableView.frame.size.width - nummerBreite - graceBreite - poolBreite - roundBreite - lengthBreite)/2 ;
    int eventBreite = opponentBreite;

    UILabel *nummerLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,nummerBreite,30)];
    nummerLabel.textAlignment = NSTextAlignmentCenter;
    nummerLabel.text = self.topPageHeaderArray[0];
    nummerLabel.textColor = [UIColor whiteColor];
    
    x += nummerBreite;
    
    UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,eventBreite,30)];
    eventLabel.textAlignment = NSTextAlignmentLeft;
    eventLabel.text = self.topPageHeaderArray[1];
    eventLabel.textColor = [UIColor whiteColor];

    x += eventBreite;

    UILabel *graceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,graceBreite,30)];
    graceLabel.textAlignment = NSTextAlignmentCenter;
    graceLabel.text = self.topPageHeaderArray[2];
    graceLabel.textColor = [UIColor whiteColor];

    x += graceBreite;
    
    UILabel *poolLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,poolBreite,30)];
    poolLabel.textAlignment = NSTextAlignmentCenter;
    poolLabel.text = self.topPageHeaderArray[3];
    poolLabel.textColor = [UIColor whiteColor];

    x += poolBreite;
    
    UILabel *roundLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,roundBreite,30)];
    roundLabel.textAlignment = NSTextAlignmentCenter;
    roundLabel.text = self.topPageHeaderArray[4];
    roundLabel.textColor = [UIColor whiteColor];

    x += roundBreite;
    
    UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,lengthBreite,30)];
    lengthLabel.textAlignment = NSTextAlignmentCenter;
    lengthLabel.text = self.topPageHeaderArray[5];
    lengthLabel.textColor = [UIColor whiteColor];

    x += lengthBreite;
    
    UILabel *opponentLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,opponentBreite,30)];
    opponentLabel.textAlignment = NSTextAlignmentLeft;
    opponentLabel.text = self.topPageHeaderArray[6];
    opponentLabel.textColor = [UIColor whiteColor];

    int order = [preferences readNextMatchOrdering];

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
    }

    [headerView addSubview:nummerLabel];
    [headerView addSubview:eventLabel];
    [headerView addSubview:graceLabel];
    [headerView addSubview:poolLabel];
    [headerView addSubview:roundLabel];
    [headerView addSubview:lengthLabel];
    [headerView addSubview:opponentLabel];

    return headerView;
    
}

- (void)updateTableView
{
    self.header.text = [NSString stringWithFormat:@"%d Matches where you can move:" ,(int)self.topPageArray.count];
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

    [self.tableView reloadData];

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
//    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];
//    NSDictionary *opponent = zeile[6];
//    NSString *opponentID = [[opponent objectForKey:@"href"] lastPathComponent];
//
//    NSMutableDictionary *ratingDict = [rating readRatingForPlayer:userID andOpponent:opponentID];
    
    

    PlayMatch *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PlayMatch"];
    NSDictionary *match = zeile[8];
    vc.matchLink = [match objectForKey:@"href"];
//    vc.ratingDict = ratingDict;
    
    [self.navigationController pushViewController:vc animated:NO];

    
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

#pragma mark - Header
#include "HeaderInclude.h"

@end
