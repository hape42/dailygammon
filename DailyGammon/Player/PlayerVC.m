//
//  Player.m
//  DailyGammon
//
//  Created by Peter on 04.06.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import "PlayerVC.h"
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
#import "PlayerDetail.h"
#import "DGRequest.h"
#import "TextTools.h"

@interface PlayerVC ()

@property (readwrite, retain, nonatomic) NSMutableArray *playerArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet DGButton *chooseButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (readwrite, retain, nonatomic) NSMutableData *datenData;
@property (readwrite, retain, nonatomic) NSURLConnection *downloadConnection;
@property (assign, atomic) BOOL loginOk;

@property (readwrite, retain, nonatomic) DGButton *topPageButton;

@end

@implementation PlayerVC

@synthesize design, tools, textTools;

@synthesize name;
@synthesize waitView;

@synthesize chooseArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.playerArray = [[NSMutableArray alloc]init];
    chooseArray = [[NSMutableArray alloc]init];

    design = [[Design alloc] init];
    tools = [[Tools alloc] init];
    textTools = [[TextTools alloc] init];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    self.searchBar.delegate = self;
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;
    self.collectionView.backgroundColor = [UIColor colorNamed:@"ColorTableView"];;
    self.searchBar.backgroundColor = [UIColor colorNamed:@"ColorTableView"];;

    NSString *searchLinkUnquoted = [NSString stringWithFormat:@"http://dailygammon.com/bg/plist"];
    NSString *searchLink = [searchLinkUnquoted stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    [self readPlayerArray:searchLink];
 
    [self.collectionView reloadData];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.moreButton.menu = [app mainMenu:self.navigationController button:self.moreButton];
    self.moreButton.showsMenuAsPrimaryAction = YES;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
        
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self layoutObjects];
    
    self.header.textColor = [design getTintColorSchema];
    self.moreButton = [design designMoreButton:self.moreButton];
    
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
    [self stopActivityIndicator];

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
    [self.searchBar resignFirstResponder];

    NSArray *row = self.playerArray[indexPath.row];
    NSDictionary *userDict = row[3];
    
    PlayerDetail *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"PlayerDetail"];
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.userID = [[userDict objectForKey:@"href"] lastPathComponent];
    UIPopoverPresentationController *popController = [vc popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

    popController.sourceView = cell;
    popController.sourceRect = cell.bounds;
    [self.navigationController presentViewController:vc animated:NO completion:nil];

}



#pragma mark - Search Implementation

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    XLog(@"searchBarTextDidBeginEditing");
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchText = [textTools cleanChatString:searchText];

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
    
    NSURL *url = [NSURL URLWithString:searchLink];
    [self startActivityIndicator: @"Getting Player data from www.dailygammon.com"];
    DGRequest *request = [[DGRequest alloc] initWithURL:url completionHandler:^(BOOL success, NSError *error, NSString *result)
                          {
        if (success)
        {
            [ self analyzeHTML:result];
        }
        else
        {
            XLog(@"Error: %@", error.localizedDescription);
        }
    }];
    request = nil;
}

-(void)analyzeHTML:(NSString *)htmlString
{
    self.playerArray = [[NSMutableArray alloc]init];
    
    NSData *htmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    self.playerArray = [[NSMutableArray alloc]init];
    NSString *queryString = [NSString stringWithFormat:@"//table[2]/tr"];
    NSArray *rown  = [xpathParser searchWithXPathQuery:queryString];
    for(int row = 2; row <= rown.count; row ++)
    {
        NSMutableArray *playerRow = [[NSMutableArray alloc]init];
        
        NSString * searchString = [NSString stringWithFormat:@"//table[2]/tr[%d]/td",row];
        NSArray *elementRow  = [xpathParser searchWithXPathQuery:searchString];
        for(TFHppleElement *element in elementRow)
        {
            NSMutableDictionary *playerRowColumn = [[NSMutableDictionary alloc]init];
            
            for (TFHppleElement *child in element.children)
            {
                //                XLog(@"Child %@", child);
                
                if ([child.tagName isEqualToString:@"a"])
                {
                    [playerRowColumn setValue:[child content] forKey:@"Text"];
                    [playerRowColumn setValue:[[child attributes] objectForKey:@"href"]forKey:@"href"];
                    
                    //                    XLog(@"gefunden %@", [child attributes]);
                }
                else
                {
                    [playerRowColumn setValue:[element content] forKey:@"Text"];
                }
            }
            [playerRow addObject:playerRowColumn];
        }
        
        [self.playerArray addObject:playerRow];
    }
    [self updateCollectionView];
    
}

@end
