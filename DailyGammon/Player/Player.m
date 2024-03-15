//
//  Player.m
//  DailyGammon
//
//  Created by Peter on 04.06.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import "Player.h"
#import "AppDelegate.h"
#import "Design.h"
#import "TFHpple.h"
#import "InviteDetail.h"
#import "RatingVC.h"
#import "TopPageCV.h"
#import "DbConnect.h"
#import "Tools.h"
#import <SafariServices/SafariServices.h>
#import "LoginVC.h"
#import "About.h"
#import "DGButton.h"
#import "PlayerLists.h"
#import "Constants.h"
#import "SetupVC.h"

@interface Player ()

@property (readwrite, retain, nonatomic) NSMutableArray *playerArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet DGButton *chooseButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (readwrite, retain, nonatomic) UIView *messageView;
@property (readwrite, retain, nonatomic) UITextView *message;
@property (assign, atomic) CGRect messageFrameSave;
@property (assign, atomic) BOOL isMessageView;

@property (readwrite, retain, nonatomic) NSMutableData *datenData;
@property (readwrite, retain, nonatomic) NSURLConnection *downloadConnection;
@property (assign, atomic) BOOL loginOk;

@property (readwrite, retain, nonatomic) DGButton *topPageButton;

@end

@implementation Player

@synthesize design, tools;

@synthesize name;
@synthesize menueView;

@synthesize chooseArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.playerArray = [[NSMutableArray alloc]init];
    chooseArray = [[NSMutableArray alloc]init];

    design = [[Design alloc] init];
    tools = [[Tools alloc] init];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    self.searchBar.delegate = self;
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;
    self.collectionView.backgroundColor = [UIColor colorNamed:@"ColorTableView"];;
    self.searchBar.backgroundColor = [UIColor colorNamed:@"ColorTableView"];;

    self.isMessageView = FALSE;
    int maxWidth = [UIScreen mainScreen].bounds.size.width;
    int maxHeight  = [UIScreen mainScreen].bounds.size.height;
    float width = maxWidth * 0.6;
    float hight = maxHeight-20;
    self.messageView = [[UIView alloc] initWithFrame:CGRectMake((maxWidth - width)/2,
                                                                (maxHeight - hight)/2,
                                                                width,
                                                                hight)];
    self.messageFrameSave = self.messageView.frame;
    self.messageView.layer.cornerRadius = 14.0f;
    self.messageView.layer.borderWidth = 1.0f;

    NSString *searchLinkUnquoted = [NSString stringWithFormat:@"http://dailygammon.com/bg/plist"];
    NSString *searchLink = [searchLinkUnquoted stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    [self readPlayerArray:searchLink];
 
//    [self searchBar:self.suche textDidChange:name];

    [self.collectionView reloadData];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.moreButton.menu = [app mainMenu:self.navigationController button:self.moreButton];
    self.moreButton.showsMenuAsPrimaryAction = YES;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
        
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(messageDoneButtonPressed)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    self.message.inputAccessoryView = keyboardToolbar;

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self layoutObjects];
    
    self.header.textColor = [design getTintColorSchema];
    self.moreButton = [design designMoreButton:self.moreButton];
    
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

#pragma mark searchBar autoLayout
    [self.searchBar setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.searchBar.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.searchBar.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.searchBar.topAnchor constraintEqualToAnchor:self.chooseButton.bottomAnchor constant:20].active = YES;


#pragma mark collectionView autoLayout
    [self.collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.collectionView.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.collectionView.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.collectionView.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor constant:20].active = YES;
    [self.collectionView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-edge].active = YES;

    [self.view layoutIfNeeded];

}

- (void)updateCollectionView
{
    NSArray *row = self.playerArray.lastObject;
    NSMutableDictionary *dict = row[1];
    int numberLast = [[dict objectForKey:@"Text"]intValue];
    row = self.playerArray.firstObject;
    dict = row[1];
    int numberFirst = [[dict objectForKey:@"Text"]intValue];
    
    UIImageSymbolConfiguration *configurationColor = [UIImageSymbolConfiguration configurationWithPaletteColors:@[[UIColor blackColor], [design getTintColorSchema]]];
    UIImageSymbolConfiguration *configurationSize = [UIImageSymbolConfiguration configurationWithPointSize:20];
    UIImageSymbolConfiguration *total = [configurationColor configurationByApplyingConfiguration:configurationSize];
    
    UIImage *imageForward = [UIImage systemImageNamed:@"forward.circle" withConfiguration:total];
    UIImage *imageBackward = [UIImage systemImageNamed:@"backward.circle" withConfiguration:total];

   // Previous 100 | Sort By Name | Sort By Rating | Sort By Experience | Next 100

    NSMutableArray  *menuArray = [[NSMutableArray alloc] initWithCapacity:3];

    if(numberLast > 100)
    {
        [menuArray addObject:[UIAction actionWithTitle:@"Previous 100"
                                                 image:imageBackward
                                            identifier:@"0"
                                               handler:^(__kindof UIAction* _Nonnull action) {
            [self.chooseButton setTitle:@"Previous 100" forState: UIControlStateNormal];
            [self readPlayerArray:[NSString stringWithFormat: @"http://dailygammon.com/bg/plist?type=rate&start=%d&length=100", numberFirst-100]];
       }]];
    }
    [menuArray addObject:[UIAction actionWithTitle:@"Sort By Name"
                                             image:nil
                                        identifier:@"1"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self.chooseButton setTitle:@"Sort By Name" forState: UIControlStateNormal];
        [self readPlayerArray:@"http://dailygammon.com/bg/plist?type=name&length=100"];
    }]];

    [menuArray addObject:[UIAction actionWithTitle:@"Sort By Rating"
                                             image:nil
                                        identifier:@"2"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self.chooseButton setTitle:@"Sort By Rating" forState: UIControlStateNormal];
        [self readPlayerArray:@"http://dailygammon.com/bg/plist?type=rate&length=100"];
    }]];

    [menuArray addObject:[UIAction actionWithTitle:@"Sort By Experience"
                                             image:nil
                                        identifier:@"3"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [self.chooseButton setTitle:@"Sort By Experience" forState: UIControlStateNormal];
        [self readPlayerArray:@"http://dailygammon.com/bg/plist?type=exp&length=100"];

    }]];
    
    if(numberLast >= 100)
    {
        
        [menuArray addObject:[UIAction actionWithTitle:@"Next 100"
                                                 image:imageForward
                                            identifier:@"4"
                                               handler:^(__kindof UIAction* _Nonnull action) {
            [self.chooseButton setTitle:@"Next 100" forState: UIControlStateNormal];
            [self readPlayerArray:[NSString stringWithFormat: @"http://dailygammon.com/bg/plist?type=rate&start=%d&length=100", numberLast+1]];

        }]];
    }

    self.chooseButton.menu = [UIMenu menuWithChildren:menuArray];
    self.chooseButton.showsMenuAsPrimaryAction = YES;

    [self.collectionView reloadData];

}

#pragma mark - CollectionView dataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.playerArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(175, 60);
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

    if(self.playerArray.count < 1)
        return cell;

    NSArray *row = self.playerArray[indexPath.row];

    float edge = 5;
    float x = edge;
    float y = edge;
    float maxWidth = cell.frame.size.width - edge - edge;
    
    float numberLabelWidth = 30;
    
    NSMutableDictionary *dict = row[1];

    DGLabel *numberLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y,numberLabelWidth ,30)];
    numberLabel.textAlignment = NSTextAlignmentRight;
    numberLabel.text = [dict objectForKey:@"Text"];
    numberLabel.adjustsFontSizeToFitWidth = YES;
    numberLabel.numberOfLines = 0;

    x += numberLabel.frame.size.width;
    
    dict = row[3];

    DGLabel *playerLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 5, maxWidth - numberLabel.frame.size.width, 30)];
    playerLabel.textAlignment = NSTextAlignmentCenter;
    playerLabel.text = [dict objectForKey:@"Text"];
    playerLabel.textColor = [design getTintColorSchema];
    playerLabel.adjustsFontSizeToFitWidth = YES;
    playerLabel.numberOfLines = 0;
    playerLabel.minimumScaleFactor = 0.5;
    [playerLabel setFont:[UIFont boldSystemFontOfSize: playerLabel.font.pointSize]];

    y += 35;
    
    DGLabel *ratingLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y, (maxWidth - numberLabel.frame.size.width)/2, 20)];
    ratingLabel.textAlignment = NSTextAlignmentRight;
    dict = row[4];
    ratingLabel.text = [dict objectForKey:@"Text"];
    ratingLabel.adjustsFontSizeToFitWidth = YES;
    ratingLabel.numberOfLines = 0;
    ratingLabel.minimumScaleFactor = 0.5;

    x += ratingLabel.frame.size.width;
    
    DGLabel *experienceLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, y, (maxWidth - numberLabel.frame.size.width)/2, 20)];
    experienceLabel.textAlignment = NSTextAlignmentRight;
    dict = row[6];
    experienceLabel.text = [dict objectForKey:@"Text"];
    experienceLabel.text = [experienceLabel.text stringByReplacingOccurrencesOfString:@"[\r\n]"
                                                         withString:@""
                                                            options:NSRegularExpressionSearch
                                                              range:NSMakeRange(0, experienceLabel.text.length)];

    experienceLabel.adjustsFontSizeToFitWidth = YES;
    experienceLabel.numberOfLines = 0;
    experienceLabel.minimumScaleFactor = 0.5;

    [cell.contentView addSubview:numberLabel];
    [cell.contentView addSubview:playerLabel];
    [cell.contentView addSubview:ratingLabel];
    [cell.contentView addSubview:experienceLabel];

    return cell;
}

#pragma mark - CollectionView delegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self notYetImplemented];
}

/*
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return self.playerArray.count;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
    }
        
    NSArray *row = self.playerArray[indexPath.row];
    NSMutableDictionary *dict = row[3];

    DGButton *messageButton = [[DGButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 100, 5, 100 , 35)];
    [messageButton setTitle:@"Message" forState: UIControlStateNormal];
    messageButton.tag = indexPath.row;
    [messageButton addTarget:self action:@selector(messageAction:) forControlEvents:UIControlEventTouchUpInside];
    
    DGButton *inviteButton = [[DGButton alloc] initWithFrame:CGRectMake(messageButton.frame.origin.x - 110, 5, 100 , 35)];
    [inviteButton setTitle:@"Invite" forState: UIControlStateNormal];
    inviteButton.tag = indexPath.row;
    [inviteButton addTarget:self action:@selector(inviteAction:) forControlEvents:UIControlEventTouchUpInside];
    
    float restWidth = tableView.frame.size.width - 220;
    
    UILabel *playerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,
                                                                     5,
                                                                     restWidth * PLAYER_WIDTH ,
                                                                     30)];
    playerLabel.textAlignment = NSTextAlignmentLeft;
    playerLabel.text = [dict objectForKey:@"Text"];
    playerLabel.adjustsFontSizeToFitWidth = YES;
    playerLabel.numberOfLines = 0;
    playerLabel.minimumScaleFactor = 0.5;

    UILabel *ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(5 + playerLabel.frame.size.width,
                                                                     5,
                                                                     restWidth * RATING_WIDTH ,
                                                                     30)];
    ratingLabel.textAlignment = NSTextAlignmentLeft;
    dict = row[4];
    ratingLabel.text = [dict objectForKey:@"Text"];
    ratingLabel.adjustsFontSizeToFitWidth = YES;
    ratingLabel.numberOfLines = 0;
    ratingLabel.minimumScaleFactor = 0.5;

    UILabel *experienceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5 + ratingLabel.frame.origin.x + ratingLabel.frame.size.width,
                                                                         5,
                                                                         restWidth * EXPERIENCE_WIDTH ,
                                                                         30)];
    experienceLabel.textAlignment = NSTextAlignmentRight;
    dict = row[6];
    experienceLabel.text = [dict objectForKey:@"Text"];
    experienceLabel.text = [experienceLabel.text stringByReplacingOccurrencesOfString:@"[\r\n]"
                                                         withString:@""
                                                            options:NSRegularExpressionSearch
                                                              range:NSMakeRange(0, experienceLabel.text.length)];

    experienceLabel.adjustsFontSizeToFitWidth = YES;
    experienceLabel.numberOfLines = 0;
    experienceLabel.minimumScaleFactor = 0.5;

    [cell.contentView addSubview:playerLabel];
    [cell.contentView addSubview:ratingLabel];
    [cell.contentView addSubview:experienceLabel];
    [cell.contentView addSubview:inviteButton];
    [cell.contentView addSubview:messageButton];

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(tableView.frame.origin.x,0,tableView.frame.size.width,30)];
    headerView.backgroundColor = [UIColor lightGrayColor];
    
    float restWidth = tableView.frame.size.width - 220;

    UILabel *playerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,
                                                                     0,
                                                                     restWidth * PLAYER_WIDTH ,
                                                                     30)];
    playerLabel.textAlignment = NSTextAlignmentLeft;
    playerLabel.text = @"Player";
    playerLabel.textColor = [UIColor whiteColor];
    playerLabel.adjustsFontSizeToFitWidth = YES;
    playerLabel.numberOfLines = 0;
    playerLabel.minimumScaleFactor = 0.5;

    UILabel *ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(5 + playerLabel.frame.size.width,
                                                                     0,
                                                                     restWidth * RATING_WIDTH ,
                                                                     30)];
    ratingLabel.textAlignment = NSTextAlignmentLeft;
    ratingLabel.text = @"Rating";
    ratingLabel.textColor = [UIColor whiteColor];
    ratingLabel.adjustsFontSizeToFitWidth = YES;
    ratingLabel.numberOfLines = 0;
    ratingLabel.minimumScaleFactor = 0.5;
    UILabel *experienceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5 + ratingLabel.frame.origin.x + ratingLabel.frame.size.width,
                                                                     0,
                                                                     restWidth * EXPERIENCE_WIDTH ,
                                                                     30)];
    experienceLabel.textAlignment = NSTextAlignmentRight;
    experienceLabel.text = @"Experience";
    experienceLabel.textColor = [UIColor whiteColor];
    experienceLabel.adjustsFontSizeToFitWidth = YES;
    experienceLabel.numberOfLines = 0;
    experienceLabel.minimumScaleFactor = 0.5;

    [headerView addSubview:playerLabel];
    [headerView addSubview:ratingLabel];
    [headerView addSubview:experienceLabel];
    
    return headerView;
    
}

- (void)updateTableView
{
    
    [self.tableView reloadData];
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *row = self.playerArray[indexPath.row];
    NSMutableDictionary *dict = row[3];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    InviteDetail *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"InviteDetailVC"];
    vc.playerName = [dict objectForKey:@"Text"];
    vc.playerNummer = [[dict objectForKey:@"href"] lastPathComponent];
    [self.navigationController pushViewController:vc animated:NO];
}
*/
- (IBAction)moreAction:(id)sender
{
    return;
    if(!menueView)
    {
        menueView = [[MenueView alloc]init];
        menueView.navigationController = self.navigationController;
    }
    [menueView showMenueInView:self.view];
}

#pragma mark - Search Implementation

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    XLog(@"searchBarTextDidBeginEditing");
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchText = [tools cleanChatString:searchText];

    NSString *searchLink = [NSString stringWithFormat:@"http://dailygammon.com/bg/plist?like=%@&type=name",
                            searchText];

    [self readPlayerArray:searchLink];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    XLog(@"Cancel clicked");
    [self.searchBar resignFirstResponder];

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    XLog(@"Search Clicked");
    [self.searchBar resignFirstResponder];

}

-(void)dismissKeyboard
{
    [self.searchBar resignFirstResponder];
}


#pragma mark - Hpple

-(void)readPlayerArray:(NSString*)searchLink
{
    
    NSURL *urlTopPage = [NSURL URLWithString:searchLink];
    NSData *topPageHtmlData = [NSData dataWithContentsOfURL:urlTopPage];
    
    NSString *htmlString = [NSString stringWithUTF8String:[topPageHtmlData bytes]];
    htmlString = [[NSString alloc]
                  initWithData:topPageHtmlData encoding: NSISOLatin1StringEncoding];
    self.playerArray = [[NSMutableArray alloc]init];
    
    
    NSData *htmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    self.playerArray = [[NSMutableArray alloc]init];
    NSString *queryString = [NSString stringWithFormat:@"//table[2]/tr"];
    NSArray *rown  = [xpathParser searchWithXPathQuery:queryString];
    for(int row = 2; row <= rown.count; row ++)
    {
        NSMutableArray *topPageRow = [[NSMutableArray alloc]init];
        
        NSString * searchString = [NSString stringWithFormat:@"//table[2]/tr[%d]/td",row];
        NSArray *elementRow  = [xpathParser searchWithXPathQuery:searchString];
        for(TFHppleElement *element in elementRow)
        {
            NSMutableDictionary *topPageRowColumn = [[NSMutableDictionary alloc]init];
            
            for (TFHppleElement *child in element.children)
            {
                //                XLog(@"Child %@", child);
                
                if ([child.tagName isEqualToString:@"a"])
                {
                    // NSDictionary *href = [child attributes];
                    [topPageRowColumn setValue:[child content] forKey:@"Text"];
                    [topPageRowColumn setValue:[[child attributes] objectForKey:@"href"]forKey:@"href"];
                    
                    //                    XLog(@"gefunden %@", [child attributes]);
                }
                else
                {
                    [topPageRowColumn setValue:[element content] forKey:@"Text"];
                }
            }
            [topPageRow addObject:topPageRowColumn];
        }
        //        XLog(@"%@", topPageRow);
        
        [self.playerArray addObject:topPageRow];
    }
    [self updateCollectionView];
    
}

#pragma mark - Invite
- (IBAction)inviteAction:(UIButton*)button
{
    [self dismissKeyboard];
    NSArray *row = self.playerArray[button.tag];

    NSMutableDictionary *dict = row[3];

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        InviteDetail *controller = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"InviteDetailVC"];
        
        controller.playerName = [dict objectForKey:@"Text"];
        controller.playerNummer = [[dict objectForKey:@"href"] lastPathComponent];

        controller.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:controller animated:YES completion:nil];
        
        UIPopoverPresentationController *popController = [controller popoverPresentationController];
        popController.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
        popController.delegate = self;
        popController.sourceView = self.searchBar;
        CGRect rect = self.searchBar.frame;
        rect.origin.x = rect.origin.x + (rect.size.width / 2);
        rect.origin.y = 0;
        rect.size.width = 0;
        rect.size.height = 50;
        popController.sourceRect = rect;

    }
    else
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        InviteDetail *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"InviteDetailVC"];
        vc.playerName = [dict objectForKey:@"Text"];
        vc.playerNummer = [[dict objectForKey:@"href"] lastPathComponent];
        [self.navigationController pushViewController:vc animated:NO];
    }
}
#pragma mark - Quick message
- (IBAction)messageAction:(UIButton*)button
{
    [self dismissKeyboard];
    
    UIView *removeView = [self.view viewWithTag:42+1];
    for (UIView *subUIView in removeView.subviews)
    {
        [subUIView removeFromSuperview];
    }
    
    NSArray *row = self.playerArray[button.tag];
    
    NSMutableDictionary *dict = row[3];

    self.isMessageView = TRUE;
    int maxWidth = [UIScreen mainScreen].bounds.size.width;
    int maxHeight  = [UIScreen mainScreen].bounds.size.height;
    float width = maxWidth * 0.6;
    float hight = maxHeight * 0.5;
    CGRect frame = CGRectMake((maxWidth - width)/2,
                              (maxHeight - hight)/2,
                              width,
                              hight);
    self.messageView.frame = frame;
    self.messageFrameSave = self.messageView.frame;

    self.messageView.tag = 42+1;
    self.messageView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(5,
                                                               0,
                                                               width - 10,
                                                               50)];

    [title setText:[NSString stringWithFormat:@"Quick message to %@",[dict objectForKey:@"Text"]]];
    title.adjustsFontSizeToFitWidth = YES;
    title.numberOfLines = 0;
    title.minimumScaleFactor = 0.1;
    title.textAlignment = NSTextAlignmentCenter;
    
    
    self.message = [[UITextView alloc] initWithFrame:CGRectMake(5,
                                                                      55,
                                                                      width - 10,
                                                                      hight - 110)];
    [self.message setFont:[UIFont systemFontOfSize:14]];
    self.message.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
    self.message.delegate = self;
    self.message.text = @"";
    
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(messageDoneButtonPressed)];
    doneBarButton = [design makeNiceBarButton:doneBarButton];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    self.message.inputAccessoryView = keyboardToolbar;

    DGButton *buttonSend = [[DGButton alloc] initWithFrame:CGRectMake(self.messageView.frame.size.width - 150,
                                                                      self.messageView.frame.size.height - 50,
                                                                      120,
                                                                      40)];
    [buttonSend setTitle:@"Send" forState: UIControlStateNormal];
    buttonSend.tag = button.tag;
    [buttonSend addTarget:self action:@selector(actionSend:) forControlEvents:UIControlEventTouchUpInside];
    
    DGButton *buttonCancel = [[DGButton alloc] initWithFrame:CGRectMake(10, self.messageView.frame.size.height - 50, 120, 40)];
    [buttonCancel setTitle:@"Cancel" forState: UIControlStateNormal];
    [buttonCancel addTarget:self action:@selector(actionCancelSend) forControlEvents:UIControlEventTouchUpInside];
    
    [self.messageView addSubview:buttonCancel];
    [self.messageView addSubview:buttonSend];
    [self.messageView addSubview:title];
    [self.messageView addSubview:self.message];
    self.messageView.layer.borderWidth = 1.0;
    
    [self.view addSubview:self.messageView];
}

-(void)actionSend:(UIButton*)button
{
    NSArray *row = self.playerArray[button.tag];
    
    NSMutableDictionary *dict = row[3];
    
    NSString *escapedString = [tools cleanChatString:self.message.text];

    NSURL *urlSendQuickMessage = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com/bg/sendmsg/%@?text=%@",[[dict objectForKey:@"href"] lastPathComponent],escapedString]];

    NSError *error = nil;
    [NSData dataWithContentsOfURL:urlSendQuickMessage options:NSDataReadingUncached error:&error];
    XLog(@"Error: %@", error);
    CGRect frame = CGRectMake(9999,9999,5,5);
    self.messageView.frame = frame;

    if(!error)
    {
        CGRect frame = CGRectMake(9999,9999,5,5);
        self.messageView.frame = frame;
        [self dismissKeyboard];

        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Quick message"
                                     message:[NSString stringWithFormat:@"Your message has been sent to %@",[dict objectForKey:@"Text"]]
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       CGRect frame = CGRectMake(9999,9999,5,5);
                                       self.messageView.frame = frame;
                                       [self dismissKeyboard];

                                   }];
        
        [alert addAction:okButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [self dismissKeyboard];

}

-(void)actionCancelSend
{
    CGRect frame = CGRectMake(9999,9999,5,5);
    self.messageView.frame = frame;
}


#pragma mark - textView
-(BOOL)textViewShouldBeginEditing:(UITextView *)textField
{
    self.isMessageView = TRUE;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self.message endEditing:YES];
    
    return YES;
}
-(void)messageDoneButtonPressed
{
    [self.message resignFirstResponder];
}
- (void)keyboardDidShow:(NSNotification *)notification
{
    CGRect frame = self.messageView.frame;
    frame.origin.y = 10;
    self.messageView.frame = frame;
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    CGRect frame = self.messageFrameSave;
    self.messageView.frame = frame;
    self.isMessageView = FALSE;
}

-(void)notYetImplemented
{
    NSString *title = @"not yet implemented";
    NSString *message = @"comming soon";
       
    UIAlertController * alert = [UIAlertController
                                  alertControllerWithTitle: title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont systemFontOfSize:20.0]
                             range:NSMakeRange(0, title.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor]  range:NSMakeRange(0, title.length)];
    [alert setValue:attributedString forKey:@"attributedTitle"];


    alert.view.tintColor = [UIColor blackColor];
    UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    return;
                                }];
    [alert addAction:okButton];
   [self.navigationController presentViewController:alert animated:YES completion:nil];
}

@end
