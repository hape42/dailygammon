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

@property (readwrite, retain, nonatomic) UIButton *topPageButton;

@end

@implementation Player

@synthesize design, tools;

@synthesize name;

#define PLAYER_BREITE .6
#define RATING_BREITE .19
#define EXPERIENCE_BREITE .19

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.playerArray = [[NSMutableArray alloc]init];
    
    self.view.backgroundColor = VIEWBACKGROUNDCOLOR;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reDrawHeader) name:@"changeSchemaNotification" object:nil];
    
    design = [[Design alloc] init];
    tools = [[Tools alloc] init];

    UIImage *image = [[UIImage imageNamed:@"menue.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.moreButton setImage:image forState:UIControlStateNormal];
    
    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
    self.moreButton.tintColor = [schemaDict objectForKey:@"TintColor"];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
//        self.view.backgroundColor = [schemaDict objectForKey:@"TintColor"];
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.suche.delegate = self;
    [self.suche setShowsCancelButton:YES animated:YES];

//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
//
//    [self.view addGestureRecognizer:tap];
    if([design isX])
    {
        //        CGRect frame = self.tableView.frame;
        //        frame.size.width -= 30;
        //        self.tableView.frame = frame;
        UIEdgeInsets safeArea = [[UIApplication sharedApplication] keyWindow].safeAreaInsets;
        
        CGRect frame = self.tableView.frame;
        frame.origin.x = safeArea.left ;
        frame.size.width = self.tableView.frame.size.width - safeArea.left ;
        self.tableView.frame = frame;
        
    }
    
    self.isMessageView = FALSE;
    int maxBreite = [UIScreen mainScreen].bounds.size.width;
    int maxHoehe  = [UIScreen mainScreen].bounds.size.height;
    float breite = maxBreite * 0.6;
    float hoehe = maxHoehe-20;
    self.messageView = [[UIView alloc] initWithFrame:CGRectMake((maxBreite - breite)/2,
                                                                (maxHoehe - hoehe)/2,
                                                                breite,
                                                                hoehe)];
    self.messageFrameSave = self.messageView.frame;
    self.messageView.layer.cornerRadius = 14.0f;
    self.messageView.layer.borderWidth = 1.0f;

    NSString *searchLink = [NSString stringWithFormat:@"http://dailygammon.com/bg/plist?like=%@&type=name",
                 name];

    [self readPlayerArray:searchLink];
 
    [self searchBar:self.suche textDidChange:name];

    [self.tableView reloadData];

  //  self.message.returnKeyType = UIReturnKeyDone;
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
    
    cell.backgroundColor = [UIColor whiteColor];
    
    NSArray *zeile = self.playerArray[indexPath.row];
    NSMutableDictionary *dict = zeile[3];

    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeSystem];
    messageButton = [design makeNiceButton:messageButton];
    [messageButton setTitle:@"Message" forState: UIControlStateNormal];
    messageButton.frame = CGRectMake(tableView.frame.size.width - 100, 5, 100 , 35);
    messageButton.tag = indexPath.row;
    [messageButton addTarget:self action:@selector(messageAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    inviteButton = [design makeNiceButton:inviteButton];
    [inviteButton setTitle:@"Invite" forState: UIControlStateNormal];
    inviteButton.frame = CGRectMake(messageButton.frame.origin.x - 110, 5, 100 , 35);
    inviteButton.tag = indexPath.row;
    [inviteButton addTarget:self action:@selector(inviteAction:) forControlEvents:UIControlEventTouchUpInside];
    
    float restBreite = tableView.frame.size.width - 220;
    
    UILabel *playerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,
                                                                     5,
                                                                     restBreite * PLAYER_BREITE ,
                                                                     30)];
    playerLabel.textAlignment = NSTextAlignmentLeft;
    playerLabel.text = [dict objectForKey:@"Text"];
    playerLabel.textColor = [UIColor darkTextColor];
    playerLabel.adjustsFontSizeToFitWidth = YES;
    playerLabel.numberOfLines = 0;
    playerLabel.minimumScaleFactor = 0.5;

    UILabel *ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(5 + playerLabel.frame.size.width,
                                                                     5,
                                                                     restBreite * RATING_BREITE ,
                                                                     30)];
    ratingLabel.textAlignment = NSTextAlignmentLeft;
    dict = zeile[4];
    ratingLabel.text = [dict objectForKey:@"Text"];
    ratingLabel.textColor = [UIColor darkTextColor];
    ratingLabel.adjustsFontSizeToFitWidth = YES;
    ratingLabel.numberOfLines = 0;
    ratingLabel.minimumScaleFactor = 0.5;

    UILabel *experienceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5 + ratingLabel.frame.origin.x + ratingLabel.frame.size.width,
                                                                         5,
                                                                         restBreite * EXPERIENCE_BREITE ,
                                                                         30)];
    experienceLabel.textAlignment = NSTextAlignmentRight;
    dict = zeile[6];
    experienceLabel.text = [dict objectForKey:@"Text"];
    experienceLabel.text = [experienceLabel.text stringByReplacingOccurrencesOfString:@"[\r\n]"
                                                         withString:@""
                                                            options:NSRegularExpressionSearch
                                                              range:NSMakeRange(0, experienceLabel.text.length)];

    experienceLabel.textColor = [UIColor darkTextColor];
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
    
    float restBreite = tableView.frame.size.width - 220;

    UILabel *playerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,
                                                                     0,
                                                                     restBreite * PLAYER_BREITE ,
                                                                     30)];
    playerLabel.textAlignment = NSTextAlignmentLeft;
    playerLabel.text = @"Player";
    playerLabel.textColor = [UIColor whiteColor];
    playerLabel.adjustsFontSizeToFitWidth = YES;
    playerLabel.numberOfLines = 0;
    playerLabel.minimumScaleFactor = 0.5;

    UILabel *ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(5 + playerLabel.frame.size.width,
                                                                     0,
                                                                     restBreite * RATING_BREITE ,
                                                                     30)];
    ratingLabel.textAlignment = NSTextAlignmentLeft;
    ratingLabel.text = @"Rating";
    ratingLabel.textColor = [UIColor whiteColor];
    ratingLabel.adjustsFontSizeToFitWidth = YES;
    ratingLabel.numberOfLines = 0;
    ratingLabel.minimumScaleFactor = 0.5;
    UILabel *experienceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5 + ratingLabel.frame.origin.x + ratingLabel.frame.size.width,
                                                                     0,
                                                                     restBreite * EXPERIENCE_BREITE ,
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
    NSArray *zeile = self.playerArray[indexPath.row];
    NSMutableDictionary *dict = zeile[3];

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        InviteDetail *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"InviteDetailVC"];
        vc.playerName = [dict objectForKey:@"Text"];
        vc.playerNummer = [[dict objectForKey:@"href"] lastPathComponent];
        [self.navigationController pushViewController:vc animated:NO];

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
//    XLog(@"Text change - %@",searchText);
    
    __block NSString *str = @"";
    [searchText enumerateSubstringsInRange:NSMakeRange(0, searchText.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop)
     {
         if([substring isEqualToString:@"‘"])
             str = [NSString stringWithFormat:@"%@%@",str, @"'"];
         else if([substring isEqualToString:@"„"])
             str = [NSString stringWithFormat:@"%@%@",str, @"?"];
         else if([substring isEqualToString:@"“"])
             str = [NSString stringWithFormat:@"%@%@",str, @"?"];
         else
             str = [NSString stringWithFormat:@"%@%@",str, substring];
         
     }];
    
    NSString *escapedString = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString *searchLink = [NSString stringWithFormat:@"http://dailygammon.com/bg/plist?like=%@&type=name",
                 escapedString];

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
    NSArray *zeilen  = [xpathParser searchWithXPathQuery:queryString];
    for(int zeile = 2; zeile <= zeilen.count; zeile ++)
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
        
        [self.playerArray addObject:topPageZeile];
    }
    [self updateTableView];
}

#pragma mark - Invite
- (IBAction)inviteAction:(UIButton*)button
{
    [self dismissKeyboard];
    NSArray *zeile = self.playerArray[button.tag];

    NSMutableDictionary *dict = zeile[3];

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
    
    NSArray *zeile = self.playerArray[button.tag];
    
    NSMutableDictionary *dict = zeile[3];

    self.isMessageView = TRUE;
    int maxBreite = [UIScreen mainScreen].bounds.size.width;
    int maxHoehe  = [UIScreen mainScreen].bounds.size.height;
    float breite = maxBreite * 0.6;
    float hoehe = maxHoehe * 0.8;
    CGRect frame = CGRectMake((maxBreite - breite)/2,
                              (maxHoehe - hoehe)/2,
                              breite,
                              hoehe);
    self.messageView.frame = frame;
    self.messageFrameSave = self.messageView.frame;

    self.messageView.tag = 42+1;
    self.messageView.backgroundColor = GRAYLIGHT;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(5,
                                                               0,
                                                               breite - 10,
                                                               50)];

    [title setText:[NSString stringWithFormat:@"Quick message to %@",[dict objectForKey:@"Text"]]];
    title.adjustsFontSizeToFitWidth = YES;
    title.numberOfLines = 0;
    title.minimumScaleFactor = 0.1;
    title.textAlignment = NSTextAlignmentCenter;
    
    
    self.message = [[UITextView alloc] initWithFrame:CGRectMake(5,
                                                                      55,
                                                                      breite - 10,
                                                                      hoehe - 110)];
    [self.message setFont:[UIFont systemFontOfSize:20]];
    self.message.backgroundColor = [UIColor whiteColor];
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

    UIButton *buttonSend = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonSend = [self->design makeNiceButton:buttonSend];
    [buttonSend setTitle:@"Send" forState: UIControlStateNormal];
    buttonSend.frame = CGRectMake(self.messageView.frame.size.width - 150,
                                  self.messageView.frame.size.height - 50,
                                  120,
                                  40);
    buttonSend.tag = button.tag;
    [buttonSend addTarget:self action:@selector(actionSend:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonCancel = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonCancel = [self->design makeNiceButton:buttonCancel];
    [buttonCancel setTitle:@"Cancel" forState: UIControlStateNormal];
    buttonCancel.frame = CGRectMake(10, self.messageView.frame.size.height - 50, 120, 40);
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
    NSArray *zeile = self.playerArray[button.tag];
    
    NSMutableDictionary *dict = zeile[3];
    
    __block NSString *str = @"";
    [self.message.text enumerateSubstringsInRange:NSMakeRange(0, self.message.text.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop)
     {
         
         //NSLog(@"substring: %@ substringRange: %@, enclosingRange %@", substring, NSStringFromRange(substringRange), NSStringFromRange(enclosingRange));
         if([substring isEqualToString:@"‘"])
             str = [NSString stringWithFormat:@"%@%@",str, @"'"];
         else if([substring isEqualToString:@"„"])
             str = [NSString stringWithFormat:@"%@%@",str, @"?"];
         else if([substring isEqualToString:@"“"])
             str = [NSString stringWithFormat:@"%@%@",str, @"?"];
         else
             str = [NSString stringWithFormat:@"%@%@",str, substring];
         
     }];
    
    NSString *escapedString = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

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
