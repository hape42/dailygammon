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
#import "AppDelegate.h"
#import "Tools.h"
#import "DGButton.h"
#import "DGLabel.h"
#import "Tournament.h"
#import "Review.h"
#import "Constants.h"
#import "DGRequest.h"
#import "LoginVC.h"
#import "PlayMatch.h"
#import "PlayerVC.h"
#import "PlayerDetail.h"

@interface PlayerLists ()<NSURLSessionDataDelegate>

@property (weak, nonatomic) IBOutlet DGButton *chooseButton;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (readwrite, retain, nonatomic) NSMutableData *datenData;
@property (assign, atomic) BOOL loginOk;

@property (readwrite, retain, nonatomic) NSMutableArray *listArray;
@property (readwrite, retain, nonatomic) NSMutableArray *listHeaderArray;

@property (readwrite, retain, nonatomic) NSString *matchString;

@end

@implementation PlayerLists

@synthesize design, tools;
@synthesize listTyp;
@synthesize waitView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
    
    self.collectionView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];

    design      = [[Design alloc] init];
    tools       = [[Tools alloc] init];

    listTyp = 1;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
  
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.moreButton.menu = [app mainMenu:self.navigationController button:self.moreButton];
    self.moreButton.showsMenuAsPrimaryAction = YES;

    NSMutableArray  *menuArray = [[NSMutableArray alloc] initWithCapacity:3];

    [menuArray addObject:[UIAction actionWithTitle:@"active matches"
                                             image:nil
                                        identifier:@"1"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self activeMatches:nil];
    }]];

    [menuArray addObject:[UIAction actionWithTitle:@"active tournaments"
                                             image:nil
                                        identifier:@"2"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self activeTournaments:nil];
    }]];

    [menuArray addObject:[UIAction actionWithTitle:@"finished matches"
                                             image:nil
                                        identifier:@"3"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self finishedMatches:nil];
    }]];

    [menuArray addObject:[UIAction actionWithTitle:@"tournament wins"
                                             image:nil
                                        identifier:@"4"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self tournamentWins:nil];
    }]];

    self.chooseButton.menu = [UIMenu menuWithChildren:menuArray];
    self.chooseButton.showsMenuAsPrimaryAction = YES;

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


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.navigationItem.hidesBackButton = YES;

    self.loginOk = YES;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self layoutObjects];

    self.header.textColor = [design getTintColorSchema];
    self.moreButton = [design designMoreButton:self.moreButton];
    
    switch(listTyp)
    {
        case 1:
            [self readActiveMatches];
            break;
        case 2:
            [self readActiveTournaments];
            break;
        case 3:
            [self readFinishedMatches];
            break;
        case 4:
            [self readTournamentWins];
            break;
        default:
            [self readActiveMatches];
            break;
    }
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

#pragma mark header autoLayout
    [self.header setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.header.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge].active = YES;
    [self.header.heightAnchor constraintEqualToConstant:40].active = YES;
    [self.header.rightAnchor constraintEqualToAnchor:self.moreButton.leftAnchor constant:-edge].active = YES;
    [self.header.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;

#pragma mark chooseButton autoLayout
    [self.chooseButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.chooseButton.topAnchor constraintEqualToAnchor:self.header.bottomAnchor constant:20].active = YES;
    [self.chooseButton.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.chooseButton.heightAnchor constraintEqualToConstant:35].active = YES;

#pragma mark collectionView autoLayout
    [self.collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.collectionView.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.collectionView.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.collectionView.topAnchor constraintEqualToAnchor:self.chooseButton.bottomAnchor constant:20].active = YES;
    [self.collectionView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-edge].active = YES;

    [self.view setNeedsUpdateConstraints];

    [self.view layoutIfNeeded];

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
            [self updateCollectionView];
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
            [self updateCollectionView];
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
            [self updateCollectionView];
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
            [self updateCollectionView];
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
    return self.listArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float edge = 5;
    float gap = 5;

    int labelHeight = 20;
    int buttonHeight = 35;

    int height = 300 ;
    
    switch(listTyp)
    {
        case 1:
            height = edge + buttonHeight + gap + labelHeight + gap + labelHeight + gap + buttonHeight + gap + gap + buttonHeight + edge;
            break;
        case 2:
            height = edge + buttonHeight + gap + gap + buttonHeight + edge;
          break;
        case 3:
            height = edge + buttonHeight + gap + labelHeight + gap + buttonHeight + gap + gap + buttonHeight + edge;
           break;
        case 4:
            height = edge + buttonHeight + gap + labelHeight + edge;
           break;
        default:
            break;
   }

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

    if(self.listArray.count < 1)
        return cell;

    NSArray *row = self.listArray[indexPath.row];

    float edge = 5;
    float gap = 5;
    float x = edge;
    float y = edge;
    float maxWidth = cell.frame.size.width - edge - edge;
    float firstRowWidth = maxWidth * 0.5;
    float secondRowWidth = maxWidth * 0.5;
    int labelHeight = 20;
    int buttonHeight = 35;
    
    switch(listTyp)
    {
#pragma mark - active matches
        case 1:
        {
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
            
#pragma mark 4. Line opponent
            
            y += graceLabel.frame.size.height + gap;
            x = edge;
            
             NSDictionary *opponent = row[6];
            DGButton *opponentButton = [[DGButton alloc] initWithFrame:CGRectMake(x,y,maxWidth, buttonHeight)];
            [opponentButton setTitle:[opponent objectForKey:@"Text"] forState: UIControlStateNormal];
            opponentButton.tag = indexPath.row;
            [opponentButton addTarget:self action:@selector(opponentAction:) forControlEvents:UIControlEventTouchUpInside];
            [opponentButton.layer setValue:[opponent objectForKey:@"Text"] forKey:@"name"];
            [opponentButton.layer setValue:[[opponent objectForKey:@"href"] lastPathComponent] forKey:@"userID"];

            [cell.contentView addSubview:opponentButton];

#pragma mark 5. Line Review
            y += opponentButton.frame.size.height + gap + gap;

            float reviewWidth = 70;
            x = edge + ((maxWidth - reviewWidth)/2);

            DGButton *reviewButton = [[DGButton alloc] initWithFrame:CGRectMake(x, y, reviewWidth, buttonHeight)];
            [reviewButton setTitle:@"Review" forState: UIControlStateNormal];
            reviewButton.tag = indexPath.row;
            [reviewButton addTarget:self action:@selector(reviewAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:reviewButton];

        }
            break;
        case 2:
#pragma mark - active tournaments
        {
#pragma mark 1. Line Tournament name
            NSDictionary *event = row[3];
            
            DGButton *eventButton = [[DGButton alloc] initWithFrame:CGRectMake(x, y ,maxWidth,buttonHeight)];
            [eventButton setTitle:[event objectForKey:@"Text"] forState: UIControlStateNormal];
            eventButton.tag = indexPath.row;
            [eventButton.layer setValue:[event objectForKey:@"href"] forKey:@"href"];
            [eventButton.layer setValue:[event objectForKey:@"Text"] forKey:@"Text"];
            [eventButton addTarget:self action:@selector(eventAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:eventButton];
            
#pragma mark 2. Line wins & active game
            y += eventButton.frame.size.height + gap + gap;
            
            DGLabel *winsLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,60,buttonHeight)];
            winsLabel.textAlignment = NSTextAlignmentLeft;
            NSDictionary *wins = row[4];

            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"Wins: %@",[wins objectForKey:@"Text"]]];
            NSRange range = NSMakeRange(7, attributedString.length - 7);
            NSDictionary *boldAttributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize: winsLabel.font.pointSize]};
            NSDictionary *colorAttributes = @{NSForegroundColorAttributeName: tintColor};
            NSMutableDictionary *combinedAttributes = [NSMutableDictionary dictionaryWithDictionary:boldAttributes];
            [combinedAttributes addEntriesFromDictionary:colorAttributes];
            [attributedString setAttributes:combinedAttributes range:range];
            winsLabel.attributedText = attributedString;
            
            [cell.contentView addSubview:winsLabel];
            
            winsLabel.adjustsFontSizeToFitWidth = YES;
            
            x += winsLabel.frame.size.width;

            DGButton *activeGameButton = [[DGButton alloc] initWithFrame:CGRectMake(x, y ,maxWidth - winsLabel.frame.size.width,buttonHeight)];

            if(row.count == 6)
            {
                [activeGameButton setTitle:@"Active Game" forState: UIControlStateNormal];
                activeGameButton.tag = indexPath.row;
                [activeGameButton addTarget:self action:@selector(activeGameAction:) forControlEvents:UIControlEventTouchUpInside];
            }
            if(row.count == 6)
                [cell.contentView addSubview:activeGameButton];


        }
           break;
        case 3:
#pragma mark - finished matches
        {
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
            
            DGLabel *roundLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,maxWidth/2,labelHeight)];
            roundLabel.textAlignment = NSTextAlignmentLeft;
            NSDictionary *round = row[2];
            
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"Round: %@",[round objectForKey:@"Text"]]];
            NSRange range = NSMakeRange(7, attributedString.length - 7);
            NSDictionary *boldAttributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize: roundLabel.font.pointSize]};
            NSDictionary *colorAttributes = @{NSForegroundColorAttributeName: tintColor};
            NSMutableDictionary *combinedAttributes = [NSMutableDictionary dictionaryWithDictionary:boldAttributes];
            [combinedAttributes addEntriesFromDictionary:colorAttributes];
            [attributedString setAttributes:combinedAttributes range:range];    roundLabel.attributedText = attributedString;
            
            [cell.contentView addSubview:roundLabel];

            x += roundLabel.frame.size.width;

            DGLabel *lengthLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,maxWidth/2,labelHeight)];
            lengthLabel.textAlignment = NSTextAlignmentLeft;
            NSDictionary *length = row[3];
            
            attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"Length: %@",[length objectForKey:@"Text"]]];
            range = NSMakeRange(7, attributedString.length - 7);
            boldAttributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize: lengthLabel.font.pointSize]};
            combinedAttributes = [NSMutableDictionary dictionaryWithDictionary:boldAttributes];
            [combinedAttributes addEntriesFromDictionary:colorAttributes];
            [attributedString setAttributes:combinedAttributes range:range];
            lengthLabel.attributedText = attributedString;
            
            [cell.contentView addSubview:lengthLabel];
            
#pragma mark 3. Line opponent
            
            y += lengthLabel.frame.size.height + gap;
            x = edge;
            
            NSDictionary *opponent = row[4];
            DGButton *opponentButton = [[DGButton alloc] initWithFrame:CGRectMake(x,y,maxWidth, buttonHeight)];
            [opponentButton setTitle:[opponent objectForKey:@"Text"] forState: UIControlStateNormal];
            opponentButton.tag = indexPath.row;
            [opponentButton addTarget:self action:@selector(opponentAction:) forControlEvents:UIControlEventTouchUpInside];
            [opponentButton.layer setValue:[opponent objectForKey:@"Text"] forKey:@"name"];
            [opponentButton.layer setValue:[[opponent objectForKey:@"href"] lastPathComponent] forKey:@"userID"];
            [cell.contentView addSubview:opponentButton];

#pragma mark 4. Line Review
            y += opponentButton.frame.size.height + gap + gap;

            float buttonWidth = (maxWidth - gap) / 2;
            x = edge ;

            DGButton *reviewButton = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHeight)];
            [reviewButton setTitle:@"Review" forState: UIControlStateNormal];
            reviewButton.tag = indexPath.row;
            [reviewButton addTarget:self action:@selector(reviewAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:reviewButton];

            x += reviewButton.frame.size.width + gap;
            
            DGButton *exportButton = [[DGButton alloc] initWithFrame:CGRectMake(x, y ,buttonWidth, buttonHeight)];
            [exportButton setTitle:@"Export" forState: UIControlStateNormal];
            exportButton.tag = indexPath.row;
            [exportButton addTarget:self action:@selector(exportAction:) forControlEvents:UIControlEventTouchUpInside];

            [cell.contentView addSubview:exportButton];

        }
          break;
        case 4:
#pragma mark - tournament wins
        {
#pragma mark 1. Line Tournament name
            NSDictionary *event = row[0];
            
            DGButton *eventButton = [[DGButton alloc] initWithFrame:CGRectMake(x, y ,maxWidth,buttonHeight)];
            [eventButton setTitle:[event objectForKey:@"Text"] forState: UIControlStateNormal];
            eventButton.tag = indexPath.row;
            [eventButton.layer setValue:[event objectForKey:@"href"] forKey:@"href"];
            [eventButton.layer setValue:[event objectForKey:@"Text"] forKey:@"Text"];
            [eventButton addTarget:self action:@selector(eventAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:eventButton];

#pragma mark 2. Line date

            y += eventButton.frame.size.height + gap ;

            DGLabel *dateLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,maxWidth,labelHeight)];
            dateLabel.textAlignment = NSTextAlignmentCenter;
            NSDictionary *wins = row[1];
            dateLabel.text = [wins objectForKey:@"Text"];
            dateLabel.adjustsFontSizeToFitWidth = YES;
            
            [cell.contentView addSubview:dateLabel];

        }
           break;
        default:
            break;
   }

    
    return cell;
}

#pragma mark - CollectionView delegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)updateCollectionView
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
    [self.collectionView reloadData];

    [self stopActivityIndicator];
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

- (IBAction)eventAction:(UIButton*)button
{

    Tournament *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"Tournament"];
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


    Review *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"Review"];
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

    PlayMatch *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"PlayMatch"];
    app.matchLink = [match objectForKey:@"href"];
    vc.isReview = TRUE;
    vc.topPageArray = [[NSMutableArray alloc]init];
    [self.navigationController pushViewController:vc animated:NO];
    return;

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

- (IBAction)opponentAction:(UIButton*)sender
{
    PlayerDetail *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"PlayerDetail"];
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.userID = (NSString *)[sender.layer valueForKey:@"userID"];
    UIPopoverPresentationController *popController = [vc popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
    
    popController.sourceView = sender;
    popController.sourceRect = sender.bounds;
    [self.navigationController presentViewController:vc animated:NO completion:nil];

}

@end
