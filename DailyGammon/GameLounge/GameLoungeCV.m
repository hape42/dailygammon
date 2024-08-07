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
#import "AppDelegate.h"
#import "DbConnect.h"
#import "RatingVC.h"
#import "PlayerVC.h"
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCollectionView) name:@"updateGameLoungeCollectionView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCollectionView) name:changeSchemaNotification object:nil];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;
    self.collectionView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;

    design = [[Design alloc] init];
    preferences = [[Preferences alloc] init];
    rating = [[Rating alloc] init];
    tools = [[Tools alloc] init];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.moreButton.menu = [app mainMenu:self.navigationController button:self.moreButton];
    self.moreButton.showsMenuAsPrimaryAction = YES;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:YES animated:animated];

    [self startActivityIndicator:@"Getting Game Lounge data from www.dailygammon.com"];
    
    [self readGameLounge];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self layoutObjects];

    self.header.textColor = [design getTintColorSchema];
    self.moreButton = [design designMoreButton:self.moreButton];

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
                NSMutableDictionary *event = topPageZeile[0];
                [self->tools readPlayers:[event objectForKey:@"href"] inDict:event];

                [self.gameLoungeArray addObject:topPageZeile];
                if(topPageZeile.count == 9)
                {
                    NSMutableDictionary *note = topPageZeile[8];
                   [self->tools readNote:[event objectForKey:@"href"] inDict:note];
                }

                [self stopActivityIndicator];
                [self readActiveTournaments];
            }
        }
        else
        {
            XLog(@"Error: %@", error.localizedDescription);
        }
                
    }];
    request = nil;
    [self.collectionView reloadData];

}

-(void)readActiveTournaments
{
    [self startActivityIndicator:@"Getting active tournaments from www.dailygammon.com"];

    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];

    DGRequest *request = [[DGRequest alloc] initWithString:[NSString stringWithFormat:@"http://dailygammon.com/bg/userevent/%@", userID] completionHandler:^(BOOL success, NSError *error, NSString *result)
                          {
        if (success)
        {
            
            NSData *htmlData = [result dataUsingEncoding:NSUnicodeStringEncoding];
            
            TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
            
            int tableNo = 2;
            NSString *queryString = [NSString stringWithFormat:@"//table[%d]/tr[1]/th",tableNo];
            NSArray *elementHeader  = [xpathParser searchWithXPathQuery:queryString];
            NSMutableArray *listHeaderArray = [[NSMutableArray alloc]init];
            
            for(TFHppleElement *element in elementHeader)
            {
                if([element text] != nil)
                    [listHeaderArray addObject:[element text]];
            }
            NSMutableArray *listArray = [[NSMutableArray alloc]init];
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
                
                [listArray addObject:topPageZeile];
            }
            self.header.text = [NSString stringWithFormat:@"Tournament Sign-Up (%lu active Tournaments)", (unsigned long)listArray.count];
            [self stopActivityIndicator];

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
    variantLabel.attributedText = [self formatLabel:variantLabel 
                                    withDescription:@"Variant:"
                                         andDetails:[variant objectForKey:@"Text"]];
    [cell.contentView addSubview:variantLabel];

#pragma mark 2. Line length & rounds
    y += variantLabel.frame.size.height + gap;

    DGLabel *lengthLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,firstRowWidth,20)];
    lengthLabel.textAlignment = NSTextAlignmentLeft;
    NSDictionary *length = row[2];
    lengthLabel.attributedText = [self formatLabel:lengthLabel 
                                   withDescription:@"Length:"
                                        andDetails:[length objectForKey:@"Text"]];
    [cell.contentView addSubview:lengthLabel];

    x += lengthLabel.frame.size.width;
    
    DGLabel *roundsLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,secondRowWidth,20)];
    roundsLabel.textAlignment = NSTextAlignmentLeft;
    NSDictionary *rounds = row[3];
    roundsLabel.attributedText = [self formatLabel:roundsLabel 
                                   withDescription:@"Rounds:"
                                        andDetails:[rounds objectForKey:@"Text"]];
    [cell.contentView addSubview:roundsLabel];

#pragma mark 3. Line time & grace
    y += roundsLabel.frame.size.height + gap;
    x = edge;
    
    DGLabel *timeLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,firstRowWidth,20)];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    NSDictionary *time = row[4];
    NSDictionary *timePlus = row[5];
    timeLabel.attributedText = [self formatLabel:timeLabel
                                 withDescription:@"Time:"
                                      andDetails:[NSString stringWithFormat:@"%@ %@",[time objectForKey:@"Text"], [timePlus objectForKey:@"Text"]]];

    [cell.contentView addSubview:timeLabel];

    x += timeLabel.frame.size.width;
    
    DGLabel *graceLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,secondRowWidth,20)];
    graceLabel.textAlignment = NSTextAlignmentLeft;
    NSDictionary *grace = row[6];
    graceLabel.attributedText = [self formatLabel:graceLabel
                                   withDescription:@"Grace:"
                                        andDetails:[grace objectForKey:@"Text"]];
    [cell.contentView addSubview:graceLabel];

#pragma mark 4. Line max. Player & signed up Players
    y += graceLabel.frame.size.height + gap;
    x = edge;
    
    NSArray *player = [[name objectForKey:@"player"] componentsSeparatedByString: @"/"];

    DGLabel *playerLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,firstRowWidth,20)];
    playerLabel.textAlignment = NSTextAlignmentLeft;
    playerLabel.attributedText = [self formatLabel:playerLabel
                                   withDescription:@"max. Player:"
                                        andDetails:player[0]];
    [cell.contentView addSubview:playerLabel];

    x += playerLabel.frame.size.width;
    
    DGLabel *signedUpLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,secondRowWidth,20)];
    signedUpLabel.textAlignment = NSTextAlignmentLeft;
    signedUpLabel.attributedText = [self formatLabel:signedUpLabel
                                     withDescription:@"signed up:"
                                          andDetails:player[1]];

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
            [button setTitle:@"Sign Up" forState: UIControlStateNormal];
        }
        else
        {
            button = [[DGButton alloc]initWithFrame:CGRectMake(x  + ((maxWidth - 150)/2) , y, 150 , 35)];
            cell.backgroundColor = [UIColor colorNamed:@"ColorSignedUp"];
            [button setTitle:@"Cancel Signup" forState: UIControlStateNormal];
        }

        button.tag = indexPath.row;
        [button addTarget:self action:@selector(signUp:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];

    }
    else
    {
        cell.backgroundColor = [UIColor colorNamed:@"ColorCV"];

        // no Button
    }

    cell.layer.cornerRadius = 14.0f;
    cell.layer.masksToBounds = YES;

    return cell;

}
-(NSMutableAttributedString *)formatLabel:(DGLabel *)label withDescription:(NSString *) description andDetails:(NSString *)details
{
    UIColor *tintColor =  [design getTintColorSchema];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"%@ %@",description, details]];
    long textLength = description.length;
    NSRange range = NSMakeRange(textLength, attributedString.length - textLength);
    NSDictionary *boldAttributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize: label.font.pointSize]};
    NSDictionary *colorAttributes = @{NSForegroundColorAttributeName: tintColor};
    NSMutableDictionary *combinedAttributes = [NSMutableDictionary dictionaryWithDictionary:boldAttributes];
    [combinedAttributes addEntriesFromDictionary:colorAttributes];
    [attributedString setAttributes:combinedAttributes range:range];
    
    return attributedString;
}
#pragma mark - CollectionView delegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath 
{
    return YES;
}

- (void)updateCollectionView
{
    [self startActivityIndicator:@"Getting Game Lounge data from www.dailygammon.com"];

    self.header.textColor = [design getTintColorSchema];
    self.moreButton = [design designMoreButton:self.moreButton];

    [self.collectionView reloadData];

    [self stopActivityIndicator];
}


-(void)signUp:(UIButton*)sender
{
    [self startActivityIndicator:@"Getting Game Lounge data from www.dailygammon.com"];
    
    NSArray *row = self.gameLoungeArray[sender.tag];
    NSDictionary *signUp = row[7];
    NSDictionary *typ = row[1];
    if([[typ objectForKey:@"Text"] isEqualToString:@"double-repeat"] && ![[signUp objectForKey:@"Text"] isEqualToString:@"Cancel Signup\n"])
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Note"
                                     message:@"This App doesn't support Double-repeat variants. If you join, play must be in web browser, not this app. "
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* exitButton = [UIAlertAction
                                     actionWithTitle:@"Exit"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
            [self stopActivityIndicator];
            return;
        }];
        
        UIAlertAction* joinButton = [UIAlertAction
                                     actionWithTitle:@"Join anyway"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
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
        
    }];

        alert.view.tag = ALERT_VIEW_TAG;
        [alert addAction:exitButton];
        [alert addAction:joinButton];

        [self presentViewController:alert animated:YES completion:nil];

    }
    else
    {
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
    alert.view.tag = ALERT_VIEW_TAG;
    [alert addAction:okButton];
        
    [self presentViewController:alert animated:YES completion:nil];
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

#pragma mark collectionView autoLayout
    [self.collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.collectionView.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.collectionView.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.collectionView.topAnchor constraintEqualToAnchor:self.header.bottomAnchor constant:20].active = YES;
    [self.collectionView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-edge].active = YES;

}
@end
