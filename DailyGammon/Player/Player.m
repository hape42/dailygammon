//
//  Player.m
//  DailyGammon
//
//  Created by Peter on 04.06.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import "Player.h"
#import "iPhoneMenue.h"
#import "AppDelegate.h"
#import "iPhoneMenue.h"
#import "Design.h"
#import "TFHpple.h"
#import "InviteDetail.h"
#import "RatingVC.h"
#import "GameLounge.h"
#import "TopPageVC.h"
#import "DbConnect.h"
#import "Tools.h"
#import <SafariServices/SafariServices.h>
#import "LoginVC.h"
#import "About.h"
#import "DGButton.h"


@interface Player ()

@property (readwrite, retain, nonatomic) NSMutableArray *playerArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UISearchBar *suche;

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

#define PLAYER_WIDTH .6
#define RATING_WIDTH .19
#define EXPERIENCE_WIDTH .19

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.playerArray = [[NSMutableArray alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reDrawHeader) name:@"changeSchemaNotification" object:nil];
    
    design = [[Design alloc] init];
    tools = [[Tools alloc] init];

    UIImage *image = [[UIImage imageNamed:@"menue.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.moreButton setImage:image forState:UIControlStateNormal];
    
    self.moreButton.tintColor = [UIColor colorNamed:@"ColorSwitch"];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.suche.delegate = self;
    [self.suche setShowsCancelButton:YES animated:YES];
    
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
    
    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;
    self.tableView.backgroundColor = [UIColor colorNamed:@"ColorTableView"];;
    self.suche.backgroundColor = [UIColor colorNamed:@"ColorTableView"];;

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

    NSString *searchLinkUnquoted = [NSString stringWithFormat:@"http://dailygammon.com/bg/plist?like=%@&type=name",
                 name];
    NSString *searchLink = [searchLinkUnquoted stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    [self readPlayerArray:searchLink];
 
    [self searchBar:self.suche textDidChange:name];

    [self.tableView reloadData];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self.view addSubview:[self makeHeader]];
    
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
-(void) reDrawHeader
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self.view addSubview:[self makeHeader]];

    [self updateTableView];
}

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

- (IBAction)moreAction:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    iPhoneMenue *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneMenue"];
    [self.navigationController pushViewController:vc animated:NO];
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
    [self.suche resignFirstResponder];

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    XLog(@"Search Clicked");
    [self.suche resignFirstResponder];

}

-(void)dismissKeyboard
{
    [self.suche resignFirstResponder];
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
    [self updateTableView];
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
        popController.sourceView = self.suche;
        CGRect rect = self.suche.frame;
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

#pragma mark - Header
#include "HeaderInclude.h"

@end
