//
//  GameLounge.m
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "GameLoungeCV.h"
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
#import "About.h"
#import "DGButton.h"
#import "PlayerLists.h"
#import "Constants.h"
#import "DGRequest.h"
#import "DGLabel.h"

@interface GameLoungeCV ()

@property (readwrite, retain, nonatomic) NSMutableData *datenData;
@property (assign, atomic) BOOL loginOk;
@property (readwrite, retain, nonatomic) NSMutableArray *gameLoungeArray;

@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@end

@implementation GameLoungeCV

@synthesize design, preferences, rating, tools;
@synthesize waitView;
@synthesize menueView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;
    self.collectionView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reDrawHeader) name:changeSchemaNotification object:nil];

    design = [[Design alloc] init];
    preferences = [[Preferences alloc] init];
    rating = [[Rating alloc] init];
    tools = [[Tools alloc] init];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
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

-(void) reDrawHeader
{
    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
    self.header.textColor = [schemaDict objectForKey:@"TintColor"];
    self.moreButton = [design designMoreButton:self.moreButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:YES animated:animated];

    [self reDrawHeader];

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

    [self startActivityIndicator:@"Getting Game Lounge data from www.dailygammon.com"];
    
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
    XLog(@"cookie %ld",[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies].count);
    if([[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies].count < 1)
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        LoginVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"LoginVC"];
        [self.navigationController pushViewController:vc animated:NO];
    }
    else
    {
        [self readGameLounge];
    }
}


#pragma mark - Hpple

-(void)readGameLounge
{
    DGRequest *request = [[DGRequest alloc] initWithString:@"http://dailygammon.com/bg/lounge" completionHandler:^(BOOL success, NSError *error, NSString *result)
                          {
        if (success)
        {

            NSData *topPageHtmlData = [result dataUsingEncoding:NSUnicodeStringEncoding];

            TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:topPageHtmlData];
            
            // sind "waiting games "da, dann stehen die Turniere in der 3 tabelle, sonst in der 2.
            //  Header, Waiting, Turniere, Footer = 4 Tabellen
            //  Header, Turniere, Footer = 3 Tabellen
            NSArray *tableArray  = [xpathParser searchWithXPathQuery:@"//table"];
            int tabelleNummer = tableArray.count == 4 ? 3 : 2;

            NSString *searchString = [NSString stringWithFormat:@"//table[%d]/tr[1]/th",tabelleNummer];
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
                [event setObject:[self->tools readPlayers:[event objectForKey:@"href"]] forKey:@"player"];

                [self.gameLoungeArray addObject:topPageZeile];
                if(topPageZeile.count == 9)
                {
                    NSMutableDictionary *note = topPageZeile[8];
                    [note setObject:[self->tools readNote:[event objectForKey:@"href"]] forKey:@"note"];
                }
                [self.collectionView reloadData];

                [self stopActivityIndicator];

            }
        }
        else
        {
            XLog(@"Error: %@", error.localizedDescription);
        }
                
    }];
    request = nil;


}


#pragma mark - CollectionView dataSource


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.gameLoungeArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(300, 200);
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
    }

    NSArray *row = self.gameLoungeArray[indexPath.row];
    float edge = 5;
    float gap = 5;
    float x = edge;
    float y = 0;
    float maxWidth = cell.frame.size.width - edge - edge;
    float firstRowWidth = maxWidth * 0.6;
    float secondRowWidth = maxWidth * 0.4;

#pragma mark 1. Line Tournament name
    DGLabel *nameLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x,y,maxWidth, 40)];
    NSDictionary *name = row[0];
    nameLabel.text = [name objectForKey:@"Text"];
    [nameLabel setFont:[UIFont boldSystemFontOfSize: 25.0]];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:nameLabel];

    y += nameLabel.frame.size.height + gap;
    
    DGLabel *variantLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x,y,maxWidth, 20)];
    variantLabel.textAlignment = NSTextAlignmentLeft;
    NSDictionary *variant = row[1];
    variantLabel.text = [NSString stringWithFormat: @"Variant: %@",[variant objectForKey:@"Text"]];
    [cell.contentView addSubview:variantLabel];

#pragma mark 2. Line length & rounds
    y += variantLabel.frame.size.height + gap;

    DGLabel *lengthLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,firstRowWidth,20)];
    lengthLabel.textAlignment = NSTextAlignmentLeft;
    NSDictionary *length = row[2];
    lengthLabel.text = [NSString stringWithFormat: @"Length: %@",[length objectForKey:@"Text"]];
    [cell.contentView addSubview:lengthLabel];

    x += lengthLabel.frame.size.width;
    
    DGLabel *roundsLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,secondRowWidth,20)];
    roundsLabel.textAlignment = NSTextAlignmentLeft;
    NSDictionary *rounds = row[3];
    roundsLabel.text = [NSString stringWithFormat: @"Rounds: %@",[rounds objectForKey:@"Text"]];
    [cell.contentView addSubview:roundsLabel];

#pragma mark 3. Line time & grace
    y += roundsLabel.frame.size.height + gap;
    x = edge;
    
    DGLabel *timeLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,firstRowWidth,20)];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    NSDictionary *time = row[4];
    NSDictionary *timePlus = row[5];
    timeLabel.text = [NSString stringWithFormat:@"Time: %@ %@",[time objectForKey:@"Text"], [timePlus objectForKey:@"Text"]];
    [cell.contentView addSubview:timeLabel];

    x += timeLabel.frame.size.width;
    
    DGLabel *graceLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,secondRowWidth,20)];
    graceLabel.textAlignment = NSTextAlignmentLeft;
    NSDictionary *grace = row[6];
    graceLabel.text = [NSString stringWithFormat:@"Grace: %@",[grace objectForKey:@"Text"]];
    [cell.contentView addSubview:graceLabel];

#pragma mark 4. Line max. Player & signed up Players
    y += graceLabel.frame.size.height + gap;
    x = edge;
    
    NSArray *player = [[name objectForKey:@"player"] componentsSeparatedByString: @"/"];

    DGLabel *playerLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,firstRowWidth,20)];
    playerLabel.textAlignment = NSTextAlignmentLeft;
    playerLabel.text = [NSString stringWithFormat:@"max. Player: %@",player[0]];
    [cell.contentView addSubview:playerLabel];

    x += playerLabel.frame.size.width;
    
    DGLabel *signedUpLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,secondRowWidth,20)];
    signedUpLabel.textAlignment = NSTextAlignmentLeft;
    signedUpLabel.text = [NSString stringWithFormat:@"signed up: %@",player[1]];
    [cell.contentView addSubview:signedUpLabel];

#pragma mark 5. Line Buttons
    y += signedUpLabel.frame.size.height + gap + gap;
    x = edge;

    if(row.count == 9)
    {
        UIButton *infoButton = [[UIButton alloc]init];
        UIImage *image = [[UIImage imageNamed:@"Note"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        infoButton.frame = CGRectMake(x, y, 35, 35);
        [infoButton addTarget:self action:@selector(showNote:) forControlEvents:UIControlEventTouchUpInside];
        [infoButton setImage:image forState:UIControlStateNormal];
        
        [infoButton setTintColor:[design schemaColor]];
        [infoButton setTitleColor:[UIColor colorNamed:@"ColorSwitch"] forState:UIControlStateNormal];
        infoButton.imageView.tintColor = [UIColor colorNamed:@"ColorSwitch"];

        infoButton.tag = indexPath.row;
        [cell.contentView addSubview:infoButton];

    }

    NSDictionary *signUp = row[7];
    DGButton *button = [[DGButton alloc]initWithFrame:CGRectMake(0 , 0, 0 , 0)];

    if([[signUp objectForKey:@"Text"] isEqualToString:@"Sign Up\n"] || [[signUp objectForKey:@"Text"] isEqualToString:@"Cancel Signup\n"])
    {
        if([[signUp objectForKey:@"Text"] isEqualToString:@"Sign Up\n"])
        {
            button = [[DGButton alloc]initWithFrame:CGRectMake(x + ((maxWidth - 100)/2)  , y, 100 , 35)];
            cell.backgroundColor = [UIColor colorNamed:@"ColorCV"];

        }
        else
        {
            button = [[DGButton alloc]initWithFrame:CGRectMake(x  + ((maxWidth - 150)/2) , y, 150 , 35)];
            cell.backgroundColor = [UIColor colorNamed:@"ColorSignedUp"];
        }

        [button setTitle:[signUp objectForKey:@"Text"] forState: UIControlStateNormal];

        button.tag = indexPath.row;
        [button addTarget:self action:@selector(signUp:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];

    }
    else
    {
        cell.backgroundColor = [UIColor colorNamed:@"ColorCV"];

        XLog(@"no Button");
    }

    cell.layer.cornerRadius = 14.0f;
    cell.layer.masksToBounds = YES;

    return cell;



}


#pragma mark - CollectionView delegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath 
{
    return YES;
}



-(void)signUp:(UIButton*)sender
{
    NSArray *row = self.gameLoungeArray[sender.tag];
    NSDictionary *signUp = row[7];
    
    [self startActivityIndicator:@"Getting Game Lounge data from www.dailygammon.com"];
    
    DGRequest *request = [[DGRequest alloc] initWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",[signUp objectForKey:@"href"]] completionHandler:^(BOOL success, NSError *error, NSString *result)
                          {
        if (success)
        {
            [self readGameLounge];
        }
        else
        {
            XLog(@"Error: %@", error.localizedDescription);
        }
    }];
    request = nil;
    
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
    alert.view.tag = 42;
    [alert addAction:okButton];
    
    alert = [design makeBackgroundColor:alert];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Header

- (IBAction)moreAction:(id)sender
{
    if(!menueView)
    {
        menueView = [[MenueView alloc]init];
        menueView.navigationController = self.navigationController;
    }
    [menueView showMenueInView:self.view];
}




@end
