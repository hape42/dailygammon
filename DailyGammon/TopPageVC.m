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

@end

@implementation TopPageVC

@synthesize design;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = VIEWBACKGROUNDCOLOR;
//    self.tableView.backgroundColor = VIEWBACKGROUNDCOLOR;

    design = [[Design alloc] init];

    [self.view addSubview:[self makeHeader]];
    self.sortGraceButton = [design makeNiceButton:self.sortGraceButton];
    self.sortPoolButton = [design makeNiceButton:self.sortPoolButton];
    self.sortGracePoolButton = [design makeNiceButton:self.sortGracePoolButton];
    self.sortRecentButton = [design makeNiceButton:self.sortRecentButton];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    NSString *userName = @"hape42";
    NSString *userPassword = @"00450045";
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
        NSLog(@"Connection Successful");
    } else
    {
        NSLog(@"Connection could not be made");
    }

    if (self.downloadConnection)
    {
        self.datenData = [[NSMutableData alloc] init];
    }
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    NSDictionary *fields = [HTTPResponse allHeaderFields];
    NSString *cookie = [fields valueForKey:@"Set-Cookie"];
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
//    XLog(@"Connection Finished");
    
//    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
//    {
//        NSLog(@"name: '%@'\n",   [cookie name]);
//        NSLog(@"value: '%@'\n",  [cookie value]);
//        NSLog(@"domain: '%@'\n", [cookie domain]);
//        NSLog(@"path: '%@'\n",   [cookie path]);
//    }
//    NSLog(@"%@", [NSString stringWithFormat:@"%@", [NSString stringWithUTF8String:[self.datenData bytes]]]);
    

    [ self readTopPage];
    
    return;
}

#pragma mark - Hpple

-(void)readTopPage
{
    NSURL *urlTopPage = [NSURL URLWithString:@"http://dailygammon.com/bg/top"];
    NSData *topPageHtmlData = [NSData dataWithContentsOfURL:urlTopPage];

    // Create parser
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:topPageHtmlData];
    
    //Get all the cells of the 2nd row of the 3rd table
    //        NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[3]/tr[2]/td"];
    NSArray *elementHeader  = [xpathParser searchWithXPathQuery:@"//table[2]/tr[1]/th"];
    self.topPageHeaderArray = [[NSMutableArray alloc]init];

    for(TFHppleElement *element in elementHeader)
    {
        //            XLog(@"%@",[element text]);
        [self.topPageHeaderArray addObject:[element text]];
    }
    self.topPageArray = [[NSMutableArray alloc]init];
    NSArray *zeilen  = [xpathParser searchWithXPathQuery:@"//table[2]/tr"];
    for(int zeile = 2; zeile < zeilen.count; zeile ++)
    {
        NSMutableArray *topPageZeile = [[NSMutableArray alloc]init];

        NSString * searchString = [NSString stringWithFormat:@"//table[2]/tr[%d]/td",zeile];
        NSArray *elementZeile  = [xpathParser searchWithXPathQuery:searchString];
        for(TFHppleElement *element in elementZeile)
        {
            NSMutableDictionary *topPageZeileSpalte = [[NSMutableDictionary alloc]init];

            for (TFHppleElement *child in element.children)
            {
//                XLog(@"Child %@", child);

                if ([child.tagName isEqualToString:@"a"])
                {
                    NSDictionary *href = [child attributes];
                    [topPageZeileSpalte setValue:[child content] forKey:@"Text"];
                    [topPageZeileSpalte setValue:[[child attributes] objectForKey:@"href"]forKey:@"href"];

//                    XLog(@"gefunden %@", [child attributes]);
                }
                else
                {
                    [topPageZeileSpalte setValue:[element text] forKey:@"Text"];

                }
            }
            [topPageZeile addObject:topPageZeileSpalte];

        }

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

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 30;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellEditingStyleNone reuseIdentifier:CellIdentifier];
    }
    for (UIView *subview in [cell.contentView subviews])
    {
        if ([subview isKindOfClass:[UILabel class]])
        {
            [subview removeFromSuperview];
        }
    }
    [cell setTintColor:[UIColor greenColor]];

    cell.backgroundColor = GRAYLIGHT;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell setTintColor:[UIColor greenColor]];
    UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DisclosureIndicator"]];
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
    headerView.backgroundColor = [UIColor darkGrayColor];

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
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:Nil];
    
    PlayMatch *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PlayMatch"];
    NSArray *zeile = self.topPageArray[indexPath.row];
    NSDictionary *match = zeile[8];
    vc.matchLink = [match objectForKey:@"href"];

    [self.navigationController pushViewController:vc animated:NO];

    
}
#pragma mark - Sort

- (IBAction)sortGrace:(id)sender {
}
- (IBAction)sortPool:(id)sender {
}
- (IBAction)sortGracePool:(id)sender {
}
- (IBAction)sortRecent:(id)sender {
}

#pragma mark - Header
#include "HeaderInclude.h"

@end
