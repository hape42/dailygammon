//
//  NoBoard.m
//  DailyGammon
//
/*
 During a game html pages keep coming up that do not contain a board.

 I had initially tried to handle everything in a routine. But this routine "showMatch" has grown more and more to handle all special cases.

 This routine is hardly maintainable.

 I now try to handle everything in the "noBoard". The change is large and therefore unfortunately also susceptible to errors or to overlook something.

 Translated with www.DeepL.com/Translator (free version)
 */
 
//  Created by Peter Schneider on 31.03.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import "NoBoard.h"
#import <WebKit/WebKit.h>
#import "Design.h"
#import "TFHpple.h"
#import "PlayMatch.h"
#import "Preferences.h"
#import "Rating.h"
#import "LoginVC.h"
#import "TopPageCV.h"
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
#import "TextModul.h"
#import "PlayerDetail.h"
#import "TextTools.h"
#import "ChatHistory.h"
#import "QuickMessage.h"

@interface NoBoard ()

@property (readwrite, retain, nonatomic) DGButton *topPageButton;

@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@property (readwrite, retain, nonatomic) NSArray       *landscapeConstraints;
@property (readwrite, retain, nonatomic) NSArray       *portraitConstraints;
@property (strong, readwrite, retain, atomic) DGButton *buttonPlayer1;
@property (strong, readwrite, retain, atomic) DGButton *buttonPlayer2;
@property (strong, readwrite, retain, atomic) UILabel  *player1Score;
@property (strong, readwrite, retain, atomic) UILabel  *player2Score;
@property (strong, readwrite, retain, atomic) UIView   *infoView;

@end

@implementation NoBoard

@synthesize boardDict;

@synthesize design, preferences, rating, tools, textTools, chatHistory;
@synthesize waitView;

@synthesize finishedMatchChat, finishedmatchChatViewFrame, isFinishedMatch;

@synthesize presentingVC;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    design = [[Design alloc] init];
    preferences = [[Preferences alloc] init];
    rating = [[Rating alloc] init];
    tools = [[Tools alloc] init];
    textTools = [[TextTools alloc] init];
    chatHistory = [[ChatHistory alloc] init];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;
    
    UITapGestureRecognizer *oneFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDidHide:)];
    oneFingerTap.numberOfTapsRequired = 1;
    oneFingerTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:oneFingerTap];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.moreButton.menu = [app mainMenu:self.navigationController button:self.moreButton];
    self.moreButton.showsMenuAsPrimaryAction = YES;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    else
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.navigationItem.hidesBackButton = YES;
    
#pragma mark moreButton design & autoLayout
    
    self.moreButton = [design designMoreButton:self.moreButton];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    float edge = 5.0;

    [self.moreButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.moreButton.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge].active = YES;
    [self.moreButton.heightAnchor constraintEqualToConstant:40].active = YES;
    [self.moreButton.widthAnchor constraintEqualToConstant:40].active = YES;
    [self.moreButton.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;

    [self analyze];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tools removeAllSubviewsRecursively:self.view];
    [self.view removeFromSuperview];

}

-(void)analyze
{
#pragma mark finishedMatch
    NSMutableDictionary *finishedMatchDict = [self.boardDict objectForKey:@"finishedMatch"] ;
    if( finishedMatchDict != nil)
    {
        if([[self.boardDict objectForKey:@"isReview"]boolValue])
            [self finishedMatchReview];
        else
            [self finishedMatch];

        return;
    }
#pragma mark TopPage
    if([[self.boardDict objectForKey:@"TopPage"] length] != 0)
    {
        [self.navigationController popToRootViewControllerAnimated:NO];

        TopPageCV *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"TopPageCV"];

        [self.navigationController pushViewController:vc animated:NO];
        return;
    }
#pragma mark telegramm message
    if([[self.boardDict objectForKey:@"message"] length] != 0)
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:[self.boardDict objectForKey:@"message"]
                                     message:[self.boardDict objectForKey:@"chat"]
                                     preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"NEXT"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [self playMatch:[NSString stringWithFormat:@"/bg/nextgame?submit=Next"]];
                                      }];

        [alert addAction:yesButton];
        alert.view.tag = ALERT_VIEW_TAG;

        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
#pragma mark messageSent
    if([[self.boardDict objectForKey:@"messageSent"] length] != 0)
    {
        // just do nothing, go ahead
        [self playMatch:[NSString stringWithFormat:@"/bg/nextgame?submit=Next"]];
        return;
    }
#pragma mark DailyGammon Backups
    if([[self.boardDict objectForKey:@"Backups"] length] != 0)
    {

        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"DailyGammon Backups"
                                     message:@"DailyGammon is sleeping -- SHH!!\n\nCome back in half an hour or so when the daily backups are done, and your games will be here waiting. Gwan! Scoot!"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        exit(0);
                                     }];
 
        [alert addAction:okButton];
        alert.view.tag = ALERT_VIEW_TAG;

        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
#pragma mark You have received the following quick message from
    if([[self.boardDict objectForKey:@"quickMessage"] length] != 0)
    {
        [self quickMessage];
        return;
    }
#pragma mark invite
    NSMutableDictionary *inviteDict = [self.boardDict objectForKey:@"inviteDict"] ;
    if( inviteDict != nil)
    {
        [self invite];
        return;
    }
#pragma mark There has been an internal error.
    if([[self.boardDict objectForKey:@"internal error"] length] != 0)
    {
        [self internalError];
        return;
    }

#pragma mark unknown HTML found
    [self unknownHTML];

}

#pragma mark - back to playMatch

-(void)playMatch:(NSString *)matchLink
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    app.matchLink = matchLink;
    
    PlayMatch *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"PlayMatch"];
    if([[self.boardDict objectForKey:@"isReview"]boolValue])
        vc.isReview = YES;
    vc.topPageArray = [[NSMutableArray alloc]init];
    [self.navigationController pushViewController:vc animated:NO];
    
    [self dismissViewControllerAnimated:YES completion:Nil];

    return;
}
#pragma mark - unknown HTML

-(void)unknownHTML
{
    if([ [self.boardDict objectForKey:@"htmlString"] isEqualToString:@""])
    {
        XLog(@"---------> empty htmlString");
        [self.navigationController popToRootViewControllerAnimated:NO];

        TopPageCV *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"TopPageCV"];
        [self.navigationController pushViewController:vc animated:NO];
        return;
    }
    int y = 10;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        y = 70;
    DGLabel *label  = [[DGLabel alloc] initWithFrame:CGRectMake(10, y, 250, 30)];
    label.textColor = [UIColor redColor];
    [label setFont:[UIFont boldSystemFontOfSize: label.font.pointSize]];
    label.text = @"unknown HTML Page found";

    DGButton *sendHTML = [[DGButton alloc] initWithFrame:CGRectMake(270,y, 300, 30)];
    [sendHTML setTitle:@"send unkonwn HTML to support" forState: UIControlStateNormal];
    [sendHTML addTarget:self action:@selector(sendEmail:) forControlEvents:UIControlEventTouchUpInside];

    y += 40;
    WKWebView *htmlView = [[WKWebView alloc] initWithFrame:CGRectMake(10, y, self.view.bounds.size.width - 20,  self.view.bounds.size.height - 110)];
    [htmlView loadHTMLString:[self.boardDict objectForKey:@"htmlString"] baseURL:nil];

    [self.view addSubview:label];
    [self.view addSubview:sendHTML];
    [self.view addSubview:htmlView];

}
#pragma mark  Support Email
- (IBAction)sendEmail:(id)sender
{
    if (![MFMailComposeViewController canSendMail])
    {
        UIAlertController * alert = [UIAlertController
                                      alertControllerWithTitle:@"Problem found"
                                      message:@"Normally the email is sent with Apple Mail. There seems to be a problem with Apple Mail. Please select your email program and send a screenshot of the problem to DG@hape42.de"
                                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* cancelButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleCancel
                                    handler:^(UIAlertAction * action)
                                    {
                                        return;
                                    }];

        [alert addAction:cancelButton];
        alert.view.tag = ALERT_VIEW_TAG;
        [self presentViewController:alert animated:YES completion:nil];
        XLog(@"Fehler: Mail kann nicht versendet werden");
        return;
    }
    NSString *betreff = [NSString stringWithFormat:@"found unknown HTML"];
    
    NSString *emailText = [self.boardDict objectForKey:@"htmlString"];
    
    
    MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
    emailController.mailComposeDelegate = self;
    NSArray *toSupport = [NSArray arrayWithObjects:@"dg@hape42.de",nil];
    
    [emailController setToRecipients:toSupport];
    [emailController setSubject:betreff];
    [emailController setMessageBody:emailText isHTML:YES];
    
    NSString *dictPath = @"";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    dictPath = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"boardDict.txt"];
    NSError *error;

    [[NSString stringWithFormat:@"%@",self.boardDict] writeToFile:dictPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    NSData *myData = [NSData dataWithContentsOfFile:dictPath];
    [emailController addAttachmentData:myData mimeType:@"text/plain" fileName:@"boardDict.txt"];

    [self presentViewController:emailController animated:YES completion:NULL];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (error)
    {
        XLog(@"Fehler MFMailComposeViewController: %@", error);
    }
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - finishedMatch
- (void)finishedMatch
{
    NSMutableDictionary *finishedMatchDict = [self.boardDict objectForKey:@"finishedMatch"] ;
    BOOL isReview = [[self.boardDict objectForKey:@"isReview"]boolValue] ;
    NSString *href = @"";

    for(NSDictionary *dict in [finishedMatchDict objectForKey:@"attributes"])
    {
        href = [dict objectForKey:@"action"];
    }
    isFinishedMatch = YES;
    NSArray *chatArray = [finishedMatchDict objectForKey:@"chat"];
    bool withChat = NO;
    if(!isReview)
        if([chatArray[0] containsString:@"chat"] || ([chatArray[0] containsString:@"Quote previous message"]))
            withChat = YES;
    int edge = 10;
    int gap = 10;
    float buttonWidth = 150.0;
    float buttonHight = 30;
    float scoreWidth = 50;
    
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;

#pragma mark infoView
    self.infoView = [[UIView alloc] initWithFrame:CGRectZero];
    self.infoView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
    [self.view addSubview:self.infoView];

    [self.infoView setTranslatesAutoresizingMaskIntoConstraints:NO];

    if(withChat)
    {
        [self.infoView.heightAnchor constraintEqualToAnchor:safe.heightAnchor constant:-edge].active = YES;
        [self.infoView.bottomAnchor constraintEqualToAnchor:self.view.keyboardLayoutGuide.topAnchor constant:-edge].active = YES;
    }
    else
    {
        [self.infoView.heightAnchor constraintEqualToConstant:350].active = YES;
        [self.infoView.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge].active = YES;
    }
    [self.infoView.leftAnchor   constraintEqualToAnchor:safe.leftAnchor            constant:edge].active  = YES;
    [self.infoView.rightAnchor  constraintEqualToAnchor:self.moreButton.leftAnchor constant:0].active     = YES;

#pragma mark matchName

    UILabel *matchName = [[UILabel alloc] initWithFrame:CGRectZero];
    matchName.text = [finishedMatchDict objectForKey:@"matchName"];
    matchName.textAlignment = NSTextAlignmentCenter;
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[finishedMatchDict objectForKey:@"matchName"]];
    [attr addAttribute:NSFontAttributeName
                  value:[UIFont systemFontOfSize:40.0]
                  range:NSMakeRange(0, [attr length])];
    [matchName setAttributedText:attr];
    matchName.adjustsFontSizeToFitWidth = YES;
    matchName.numberOfLines = 0;
    matchName.minimumScaleFactor = 0.5;
    matchName.adjustsFontSizeToFitWidth = YES;
    [self.infoView addSubview:matchName];
    
    [matchName setTranslatesAutoresizingMaskIntoConstraints:NO];

    [matchName.topAnchor    constraintEqualToAnchor:self.infoView.topAnchor   constant:0].active     = YES;
    [matchName.leftAnchor   constraintEqualToAnchor:self.infoView.leftAnchor  constant:edge].active  = YES;
    [matchName.rightAnchor  constraintEqualToAnchor:self.infoView.rightAnchor constant:-edge].active = YES;
    [matchName.heightAnchor constraintEqualToConstant:30].active                                     = YES;

#pragma mark winner

    NSString *htmlString = [self.boardDict objectForKey:@"htmlString"];

    NSString *winnerText = [finishedMatchDict objectForKey:@"winnerName"];
    if([htmlString containsString:@"Predicted"])
        winnerText = [NSString stringWithFormat:@"(Predicted result) %@", winnerText];
        
    UILabel *winner = [[UILabel alloc] initWithFrame:CGRectZero];
    winner.textAlignment = NSTextAlignmentLeft;
    attr = [[NSMutableAttributedString alloc] initWithString:winnerText];
    [attr addAttribute:NSFontAttributeName
                 value:[UIFont systemFontOfSize:30.0]
                 range:NSMakeRange(0, [attr length])];
    [winner setAttributedText:attr];
    winner.adjustsFontSizeToFitWidth = YES;
    winner.numberOfLines = 0;
    winner.minimumScaleFactor = 0.1;
    winner.adjustsFontSizeToFitWidth = YES;
    
    [self.infoView addSubview:winner];
    
    [winner setTranslatesAutoresizingMaskIntoConstraints:NO];

    [winner.topAnchor    constraintEqualToAnchor:matchName.bottomAnchor    constant:0].active     = YES;
    [winner.leftAnchor   constraintEqualToAnchor:self.infoView.leftAnchor  constant:edge].active  = YES;
    [winner.rightAnchor  constraintEqualToAnchor:self.infoView.rightAnchor constant:-edge].active = YES;
    [winner.heightAnchor constraintEqualToConstant:30].active                                     = YES;

#pragma mark length

    UILabel *length = [[UILabel alloc] initWithFrame:CGRectZero];
    length.textAlignment = NSTextAlignmentLeft;
    NSArray *lengthArray = [finishedMatchDict objectForKey:@"matchLength"];
    length.text = [NSString stringWithFormat:@"%@ %@",lengthArray[0], lengthArray[1]];
    [self.infoView addSubview:length];
    
    [length setTranslatesAutoresizingMaskIntoConstraints:NO];

    [length.topAnchor    constraintEqualToAnchor:winner.bottomAnchor       constant:0].active     = YES;
    [length.leftAnchor   constraintEqualToAnchor:self.infoView.leftAnchor  constant:edge].active  = YES;
    [length.rightAnchor  constraintEqualToAnchor:self.infoView.rightAnchor constant:-edge].active = YES;
    [length.heightAnchor constraintEqualToConstant:30].active                                     = YES;

#pragma mark buttonPlayer1 player1Score buttonPlayer2 player2Score

    NSArray *playerArray = [finishedMatchDict objectForKey:@"matchPlayer"];
    NSArray *playerIDArray = [finishedMatchDict objectForKey:@"href"];
    
    self.buttonPlayer1 = [[DGButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHight)];
    [self.buttonPlayer1 setTitle:playerArray[0] forState: UIControlStateNormal];
    [self.buttonPlayer1.layer setValue:playerArray[0] forKey:@"name"];
    [self.buttonPlayer1.layer setValue:[playerIDArray[0] lastPathComponent] forKey:@"userID"];
    [self.buttonPlayer1 addTarget:self action:@selector(player:) forControlEvents:UIControlEventTouchUpInside];
    [self.infoView addSubview:self.buttonPlayer1];

    self.player1Score = [[UILabel alloc] initWithFrame:CGRectZero];
    self.player1Score.textAlignment = NSTextAlignmentCenter;
    self.player1Score.text = playerArray[1];
    [self.infoView addSubview:self.player1Score];

    self.buttonPlayer2 = [[DGButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHight)];
    [self.buttonPlayer2 setTitle:playerArray[2] forState: UIControlStateNormal];
    [self.buttonPlayer2.layer setValue:playerArray[2] forKey:@"name"];
    [self.buttonPlayer2.layer setValue:[playerIDArray[1] lastPathComponent] forKey:@"userID"];
    [self.buttonPlayer2 addTarget:self action:@selector(player:) forControlEvents:UIControlEventTouchUpInside];
    [self.infoView addSubview:self.buttonPlayer2];

    self.player2Score = [[UILabel alloc] initWithFrame:CGRectZero];
    self.player2Score.textAlignment = NSTextAlignmentCenter;
    self.player2Score.text = playerArray[3];
    [self.infoView addSubview:self.player2Score];

#pragma mark autoLayout buttonPlayer1 player1Score buttonPlayer2 player2Score

    [self.buttonPlayer1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.player1Score  setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.buttonPlayer2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.player2Score  setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.buttonPlayer1.topAnchor    constraintEqualToAnchor:length.bottomAnchor      constant:gap].active  = YES;
    [self.buttonPlayer1.leftAnchor   constraintEqualToAnchor:self.infoView.leftAnchor constant:edge].active = YES;
    [self.buttonPlayer1.widthAnchor  constraintEqualToConstant:buttonWidth].active                          = YES;
    [self.buttonPlayer1.heightAnchor constraintEqualToConstant:buttonHight].active                          = YES;

    [self.player1Score.topAnchor    constraintEqualToAnchor:length.bottomAnchor            constant:gap].active = YES;
    [self.player1Score.leftAnchor   constraintEqualToAnchor:self.buttonPlayer1.rightAnchor constant:gap].active = YES;
    [self.player1Score.widthAnchor  constraintEqualToConstant:scoreWidth].active  = YES;
    [self.player1Score.heightAnchor constraintEqualToConstant:buttonHight].active = YES;

    [self.buttonPlayer2.heightAnchor constraintEqualToConstant:buttonHight].active  = YES;
    [self.buttonPlayer2.widthAnchor  constraintEqualToConstant:buttonWidth].active  = YES;

    [self.player2Score.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.player2Score.widthAnchor constraintEqualToConstant:scoreWidth].active   = YES;

    self.landscapeConstraints = @[
        [self.buttonPlayer2.topAnchor  constraintEqualToAnchor:length.bottomAnchor            constant:gap],
        [self.buttonPlayer2.leftAnchor constraintEqualToAnchor:self.player1Score.rightAnchor  constant:gap],
        [self.player2Score.topAnchor   constraintEqualToAnchor:self.buttonPlayer2.topAnchor   constant:0],
        [self.player2Score.leftAnchor  constraintEqualToAnchor:self.buttonPlayer2.rightAnchor constant:gap]

    ];
    self.portraitConstraints = @[
        [self.buttonPlayer2.topAnchor  constraintEqualToAnchor:self.buttonPlayer1.bottomAnchor constant:gap],
        [self.buttonPlayer2.leftAnchor constraintEqualToAnchor:self.infoView.leftAnchor        constant:edge] ,
        [self.player2Score.topAnchor   constraintEqualToAnchor:self.buttonPlayer2.topAnchor    constant:0],
        [self.player2Score.leftAnchor  constraintEqualToAnchor:self.buttonPlayer2.rightAnchor  constant:gap]
    ];

    if(safe.layoutFrame.size.width > (edge + buttonWidth + gap + scoreWidth + gap + buttonWidth + gap + scoreWidth + edge) )
    {
        [NSLayoutConstraint deactivateConstraints:self.portraitConstraints];
        [NSLayoutConstraint activateConstraints:self.landscapeConstraints];
    } 
    else 
    {
        [NSLayoutConstraint deactivateConstraints:self.landscapeConstraints];
        [NSLayoutConstraint activateConstraints:self.portraitConstraints];
    }
 
#pragma mark buttonNext & buttonToTop & keyboardButton
    
    DGButton *buttonNext = [[DGButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHight)];
    [buttonNext setTitle:@"Next" forState: UIControlStateNormal];
    [buttonNext addTarget:self action:@selector(actionNextFinishedMatch:) forControlEvents:UIControlEventTouchUpInside];
    [buttonNext.layer setValue:href forKey:@"href"];
    [buttonNext.layer setValue:finishedMatchChat.text forKey:@"chat"];

    [self.infoView addSubview:buttonNext];
    
    [buttonNext setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [buttonNext.bottomAnchor constraintEqualToAnchor:self.infoView.bottomAnchor constant:-edge].active = YES;
    [buttonNext.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [buttonNext.leftAnchor constraintEqualToAnchor:self.infoView.leftAnchor constant:edge].active = YES;
    [buttonNext.widthAnchor constraintEqualToConstant:70].active = YES;

    NSMutableArray *buttonArray = [finishedMatchDict objectForKey:@"buttonArray"];
    if(buttonArray.count == 2)
    {
        DGButton *buttonToTop = [[DGButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHight)];
        [buttonToTop setTitle:@"ToTop" forState: UIControlStateNormal];
        [buttonToTop addTarget:self action:@selector(actionToTopFinishedMatch:) forControlEvents:UIControlEventTouchUpInside];
        [buttonToTop.layer setValue:href forKey:@"href"];
        [buttonToTop.layer setValue:finishedMatchChat.text forKey:@"chat"];
        
        [self.infoView addSubview:buttonToTop];
    
        [buttonToTop setTranslatesAutoresizingMaskIntoConstraints:NO];
    
        [buttonToTop.bottomAnchor constraintEqualToAnchor:self.infoView.bottomAnchor constant:-edge].active = YES;
        [buttonToTop.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
        [buttonToTop.leftAnchor constraintEqualToAnchor:buttonNext.rightAnchor constant:gap ].active = YES;
        [buttonToTop.widthAnchor constraintEqualToConstant:70].active = YES;
    }
    if(withChat)
    {
        UIButton *keyboardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, buttonHight)];
        keyboardButton = [design designKeyBoardDownButton:keyboardButton];
        [keyboardButton addTarget:self action:@selector(textViewShouldEndEditing:) forControlEvents:UIControlEventTouchUpInside];
        [self.infoView addSubview:keyboardButton];
        
        [keyboardButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [keyboardButton.bottomAnchor constraintEqualToAnchor:self.infoView.bottomAnchor constant:-edge].active = YES;
        [keyboardButton.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
        [keyboardButton.widthAnchor constraintEqualToConstant:40].active = YES;
        [keyboardButton.rightAnchor constraintEqualToAnchor:self.infoView.rightAnchor constant:-edge].active = YES;
        
#pragma mark historyButton
        UIButton *historyButton = [[UIButton alloc] init];
        historyButton = [design designChatHistoryButton:historyButton];
        [historyButton addTarget:self action:@selector(chatHistory:) forControlEvents:UIControlEventTouchUpInside];
        historyButton.tag = 1;
        [self.infoView addSubview:historyButton];

        [historyButton setTranslatesAutoresizingMaskIntoConstraints:NO];

        [historyButton.topAnchor constraintEqualToAnchor:keyboardButton.topAnchor constant:0].active = YES;
        [historyButton.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
        [historyButton.widthAnchor constraintEqualToConstant:buttonHight].active = YES;
        [historyButton.rightAnchor constraintEqualToAnchor:keyboardButton.leftAnchor constant:-gap].active = YES;

#pragma mark phrasesButton
        UIButton *phrasesButton = [[UIButton alloc] init];
        phrasesButton = [design designChatPhrasesButton:phrasesButton];
        [phrasesButton addTarget:self action:@selector(textModul:) forControlEvents:UIControlEventTouchUpInside];
        phrasesButton.tag = 2;
        [self.infoView addSubview:phrasesButton];

        [phrasesButton setTranslatesAutoresizingMaskIntoConstraints:NO];

        [phrasesButton.topAnchor constraintEqualToAnchor:historyButton.topAnchor constant:0].active = YES;
        [phrasesButton.rightAnchor constraintEqualToAnchor:historyButton.leftAnchor constant:-gap].active = YES;
        [phrasesButton.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
        [phrasesButton.widthAnchor constraintEqualToConstant:buttonHight].active = YES;

    }
    
#pragma mark finishedMatchChat & opponentChat
    if(withChat)
    {
        XLog(@"with chat");
        finishedMatchChat  = [[UITextView alloc] initWithFrame:CGRectZero];
        finishedmatchChatViewFrame = finishedMatchChat.frame;
        finishedMatchChat.textAlignment = NSTextAlignmentLeft;
        finishedMatchChat.editable = YES;
        [finishedMatchChat setDelegate:self];
        finishedMatchChat.tag = 1000;
        [finishedMatchChat setFont:[UIFont systemFontOfSize:20]];
        [self.infoView addSubview:finishedMatchChat];

        [finishedMatchChat setTranslatesAutoresizingMaskIntoConstraints:NO];

        [finishedMatchChat.bottomAnchor constraintEqualToAnchor:buttonNext.topAnchor constant:-edge].active = YES;
        [finishedMatchChat.heightAnchor constraintEqualToConstant:90].active = YES;
        [finishedMatchChat.leftAnchor constraintEqualToAnchor:self.infoView.leftAnchor constant:edge].active = YES;
        [finishedMatchChat.rightAnchor constraintEqualToAnchor:self.infoView.rightAnchor constant:-edge].active = YES;

    }

    NSString *opponentMessage = chatArray[0];
    NSRange range = [opponentMessage rangeOfString:@"Quote previous message"];

    if (range.location != NSNotFound) 
    {
        opponentMessage = [opponentMessage substringToIndex:range.location];
    }
    if ([opponentMessage hasPrefix:@"\n"]) 
    {
        opponentMessage = [opponentMessage substringFromIndex:1];
    }
    if(![opponentMessage isEqualToString: @""])
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        [chatHistory saveChat:opponentMessage
                   opponentID:[app.boardDict objectForKey:@"opponentID"]
                      autorID:[[NSUserDefaults standardUserDefaults] stringForKey:@"USERID"]
                          typ:CHATHISTORY_MATCH
                  matchNumber:0
                    matchName:matchName.text];
    }

    UITextView *opponentChat = [[UITextView alloc] init];
    opponentChat.editable = NO;
    [opponentChat setFont:[UIFont systemFontOfSize:15]];
    opponentChat.backgroundColor = [UIColor clearColor];
    opponentChat.textColor = [design getTintColorSchema];
    opponentChat.text = opponentMessage;
    opponentChat.layer.borderColor = [design getTintColorSchema].CGColor;
    [self.infoView addSubview:opponentChat];

    [opponentChat setTranslatesAutoresizingMaskIntoConstraints:NO];

    [opponentChat.topAnchor constraintEqualToAnchor:self.buttonPlayer2.bottomAnchor constant:gap].active = YES;
    if(withChat)
        [opponentChat.bottomAnchor constraintEqualToAnchor:finishedMatchChat.topAnchor constant:0].active = YES;
    else
        [opponentChat.bottomAnchor constraintEqualToAnchor:buttonNext.topAnchor constant:-edge].active = YES;

    [opponentChat.leftAnchor constraintEqualToAnchor:self.infoView.leftAnchor constant:edge].active = YES;
    [opponentChat.rightAnchor constraintEqualToAnchor:self.infoView.rightAnchor constant:-edge].active = YES;

    

    return;
}

- (void)finishedMatchReview
{
    NSMutableDictionary *finishedMatchDict = [self.boardDict objectForKey:@"finishedMatch"] ;
    BOOL isReview = [[self.boardDict objectForKey:@"isReview"]boolValue] ;
    NSString *href = @"";

    for(NSDictionary *dict in [finishedMatchDict objectForKey:@"attributes"])
    {
        href = [dict objectForKey:@"action"];
    }
    isFinishedMatch = YES;
    int edge = 10;
    int gap = 10;
    float buttonWidth = 150.0;
    float buttonHight = 30;
    float scoreWidth = 50;
    
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;

#pragma mark infoView
    self.infoView = [[UIView alloc] initWithFrame:CGRectZero];
    self.infoView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
    [self.view addSubview:self.infoView];

    [self.infoView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.infoView.heightAnchor constraintEqualToConstant:350].active = YES;
    [self.infoView.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge].active = YES;
    [self.infoView.leftAnchor   constraintEqualToAnchor:safe.leftAnchor            constant:edge].active  = YES;
    [self.infoView.rightAnchor  constraintEqualToAnchor:self.moreButton.leftAnchor constant:0].active     = YES;

#pragma mark matchName

    UILabel *matchName = [[UILabel alloc] initWithFrame:CGRectZero];
    matchName.text = [finishedMatchDict objectForKey:@"matchName"];
    matchName.textAlignment = NSTextAlignmentCenter;
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[finishedMatchDict objectForKey:@"matchName"]];
    [attr addAttribute:NSFontAttributeName
                  value:[UIFont systemFontOfSize:40.0]
                  range:NSMakeRange(0, [attr length])];
    [matchName setAttributedText:attr];
    matchName.adjustsFontSizeToFitWidth = YES;
    matchName.numberOfLines = 0;
    matchName.minimumScaleFactor = 0.5;
    matchName.adjustsFontSizeToFitWidth = YES;
    [self.infoView addSubview:matchName];
    
    [matchName setTranslatesAutoresizingMaskIntoConstraints:NO];

    [matchName.topAnchor    constraintEqualToAnchor:self.infoView.topAnchor   constant:0].active     = YES;
    [matchName.leftAnchor   constraintEqualToAnchor:self.infoView.leftAnchor  constant:edge].active  = YES;
    [matchName.rightAnchor  constraintEqualToAnchor:self.infoView.rightAnchor constant:-edge].active = YES;
    [matchName.heightAnchor constraintEqualToConstant:30].active                                     = YES;

#pragma mark move

    NSString *moveText = [finishedMatchDict objectForKey:@"move"];
        
    UILabel *move = [[UILabel alloc] initWithFrame:CGRectZero];
    move.textAlignment = NSTextAlignmentLeft;
    attr = [[NSMutableAttributedString alloc] initWithString:moveText];
    [attr addAttribute:NSFontAttributeName
                 value:[UIFont systemFontOfSize:20.0]
                 range:NSMakeRange(0, [attr length])];
    [move setAttributedText:attr];
    move.adjustsFontSizeToFitWidth = YES;
    move.numberOfLines = 0;
    move.minimumScaleFactor = 0.1;
    move.adjustsFontSizeToFitWidth = YES;
    
    [self.infoView addSubview:move];
    
    [move setTranslatesAutoresizingMaskIntoConstraints:NO];

    [move.topAnchor    constraintEqualToAnchor:matchName.bottomAnchor    constant:0].active     = YES;
    [move.leftAnchor   constraintEqualToAnchor:self.infoView.leftAnchor  constant:edge].active  = YES;
    [move.rightAnchor  constraintEqualToAnchor:self.infoView.rightAnchor constant:-edge].active = YES;
    [move.heightAnchor constraintEqualToConstant:30].active                                     = YES;

#pragma mark winner

    NSString *htmlString = [self.boardDict objectForKey:@"htmlString"];

    NSString *winnerText = [finishedMatchDict objectForKey:@"winnerName"];
        
    UILabel *winner = [[UILabel alloc] initWithFrame:CGRectZero];
    winner.textAlignment = NSTextAlignmentLeft;
    attr = [[NSMutableAttributedString alloc] initWithString:winnerText];
    [attr addAttribute:NSFontAttributeName
                 value:[UIFont systemFontOfSize:30.0]
                 range:NSMakeRange(0, [attr length])];
    [winner setAttributedText:attr];
    winner.adjustsFontSizeToFitWidth = YES;
    winner.numberOfLines = 0;
    winner.minimumScaleFactor = 0.1;
    winner.adjustsFontSizeToFitWidth = YES;
    
    [self.infoView addSubview:winner];
    
    [winner setTranslatesAutoresizingMaskIntoConstraints:NO];

    [winner.topAnchor    constraintEqualToAnchor:move.bottomAnchor    constant:0].active     = YES;
    [winner.leftAnchor   constraintEqualToAnchor:self.infoView.leftAnchor  constant:edge].active  = YES;
    [winner.rightAnchor  constraintEqualToAnchor:self.infoView.rightAnchor constant:-edge].active = YES;
    [winner.heightAnchor constraintEqualToConstant:30].active                                     = YES;

#pragma mark length

    UILabel *length = [[UILabel alloc] initWithFrame:CGRectZero];
    length.textAlignment = NSTextAlignmentLeft;
    NSArray *lengthArray = [finishedMatchDict objectForKey:@"matchLength"];
    length.text = [NSString stringWithFormat:@"%@ %@",lengthArray[0], lengthArray[1]];
    [self.infoView addSubview:length];
    
    [length setTranslatesAutoresizingMaskIntoConstraints:NO];

    [length.topAnchor    constraintEqualToAnchor:winner.bottomAnchor       constant:0].active     = YES;
    [length.leftAnchor   constraintEqualToAnchor:self.infoView.leftAnchor  constant:edge].active  = YES;
    [length.rightAnchor  constraintEqualToAnchor:self.infoView.rightAnchor constant:-edge].active = YES;
    [length.heightAnchor constraintEqualToConstant:30].active                                     = YES;

#pragma mark buttonPlayer1 player1Score buttonPlayer2 player2Score

    NSArray *playerArray = [finishedMatchDict objectForKey:@"matchPlayer"];
    NSArray *playerIDArray = [finishedMatchDict objectForKey:@"href"];
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];

    self.buttonPlayer1 = [[DGButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHight)];
    [self.buttonPlayer1 setTitle:playerArray[0] forState: UIControlStateNormal];
    [self.buttonPlayer1.layer setValue:playerArray[0] forKey:@"name"];
    [self.buttonPlayer1.layer setValue:[playerIDArray[0] lastPathComponent] forKey:@"userID"];
    if(![userID isEqualToString:[playerIDArray[0] lastPathComponent] ])
        [self.buttonPlayer1 addTarget:self action:@selector(player:) forControlEvents:UIControlEventTouchUpInside];
    [self.infoView addSubview:self.buttonPlayer1];

    self.player1Score = [[UILabel alloc] initWithFrame:CGRectZero];
    self.player1Score.textAlignment = NSTextAlignmentCenter;
    self.player1Score.text = playerArray[1];
    [self.infoView addSubview:self.player1Score];

    self.buttonPlayer2 = [[DGButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHight)];
    [self.buttonPlayer2 setTitle:playerArray[2] forState: UIControlStateNormal];
    [self.buttonPlayer2.layer setValue:playerArray[2] forKey:@"name"];
    [self.buttonPlayer2.layer setValue:[playerIDArray[1] lastPathComponent] forKey:@"userID"];
    if(![userID isEqualToString:[playerIDArray[1] lastPathComponent] ])
        [self.buttonPlayer2 addTarget:self action:@selector(player:) forControlEvents:UIControlEventTouchUpInside];
    [self.infoView addSubview:self.buttonPlayer2];

    self.player2Score = [[UILabel alloc] initWithFrame:CGRectZero];
    self.player2Score.textAlignment = NSTextAlignmentCenter;
    self.player2Score.text = playerArray[3];
    [self.infoView addSubview:self.player2Score];

#pragma mark autoLayout buttonPlayer1 player1Score buttonPlayer2 player2Score

    [self.buttonPlayer1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.player1Score  setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.buttonPlayer2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.player2Score  setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.buttonPlayer1.topAnchor    constraintEqualToAnchor:length.bottomAnchor      constant:gap].active  = YES;
    [self.buttonPlayer1.leftAnchor   constraintEqualToAnchor:self.infoView.leftAnchor constant:edge].active = YES;
    [self.buttonPlayer1.widthAnchor  constraintEqualToConstant:buttonWidth].active                          = YES;
    [self.buttonPlayer1.heightAnchor constraintEqualToConstant:buttonHight].active                          = YES;

    [self.player1Score.topAnchor    constraintEqualToAnchor:length.bottomAnchor            constant:gap].active = YES;
    [self.player1Score.leftAnchor   constraintEqualToAnchor:self.buttonPlayer1.rightAnchor constant:gap].active = YES;
    [self.player1Score.widthAnchor  constraintEqualToConstant:scoreWidth].active  = YES;
    [self.player1Score.heightAnchor constraintEqualToConstant:buttonHight].active = YES;

    [self.buttonPlayer2.heightAnchor constraintEqualToConstant:buttonHight].active  = YES;
    [self.buttonPlayer2.widthAnchor  constraintEqualToConstant:buttonWidth].active  = YES;

    [self.player2Score.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.player2Score.widthAnchor constraintEqualToConstant:scoreWidth].active   = YES;

    self.landscapeConstraints = @[
        [self.buttonPlayer2.topAnchor  constraintEqualToAnchor:length.bottomAnchor            constant:gap],
        [self.buttonPlayer2.leftAnchor constraintEqualToAnchor:self.player1Score.rightAnchor  constant:gap],
        [self.player2Score.topAnchor   constraintEqualToAnchor:self.buttonPlayer2.topAnchor   constant:0],
        [self.player2Score.leftAnchor  constraintEqualToAnchor:self.buttonPlayer2.rightAnchor constant:gap]

    ];
    self.portraitConstraints = @[
        [self.buttonPlayer2.topAnchor  constraintEqualToAnchor:self.buttonPlayer1.bottomAnchor constant:gap],
        [self.buttonPlayer2.leftAnchor constraintEqualToAnchor:self.infoView.leftAnchor        constant:edge] ,
        [self.player2Score.topAnchor   constraintEqualToAnchor:self.buttonPlayer2.topAnchor    constant:0],
        [self.player2Score.leftAnchor  constraintEqualToAnchor:self.buttonPlayer2.rightAnchor  constant:gap]
    ];

    if(safe.layoutFrame.size.width > (edge + buttonWidth + gap + scoreWidth + gap + buttonWidth + gap + scoreWidth + edge) )
    {
        [NSLayoutConstraint deactivateConstraints:self.portraitConstraints];
        [NSLayoutConstraint activateConstraints:self.landscapeConstraints];
    }
    else
    {
        [NSLayoutConstraint deactivateConstraints:self.landscapeConstraints];
        [NSLayoutConstraint activateConstraints:self.portraitConstraints];
    }
 
#pragma mark First Prev Next Last / Move
    
    NSMutableArray *buttonArray = [finishedMatchDict objectForKey:@"buttonArray"];

    DGButton *buttonFirst = [[DGButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHight)];
    [buttonFirst setTitle:@"First" forState: UIControlStateNormal];
    [buttonFirst addTarget:self action:@selector(actionReview:) forControlEvents:UIControlEventTouchUpInside];
    [buttonFirst.layer setValue:buttonArray[0] forKey:@"href"];

    [self.infoView addSubview:buttonFirst];
    
    [buttonFirst setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [buttonFirst.topAnchor constraintEqualToAnchor:self.buttonPlayer2.bottomAnchor constant:gap*3].active = YES;
    [buttonFirst.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [buttonFirst.leftAnchor constraintEqualToAnchor:self.infoView.leftAnchor constant:edge].active = YES;
    [buttonFirst.widthAnchor constraintEqualToConstant:70].active = YES;

    DGButton *buttonPrev = [[DGButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHight)];
    [buttonPrev setTitle:@"Prev" forState: UIControlStateNormal];
    [buttonPrev addTarget:self action:@selector(actionReview:) forControlEvents:UIControlEventTouchUpInside];
    [buttonPrev.layer setValue:buttonArray[1] forKey:@"href"];

    [self.infoView addSubview:buttonPrev];
    
    [buttonPrev setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [buttonPrev.topAnchor constraintEqualToAnchor:buttonFirst.topAnchor constant:0].active = YES;
    [buttonPrev.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [buttonPrev.leftAnchor constraintEqualToAnchor:buttonFirst.rightAnchor constant:gap].active = YES;
    [buttonPrev.widthAnchor constraintEqualToConstant:70].active = YES;

    NSString *url = buttonArray[2];
    if(url.length == 0) // no next and no last move Button
    {
        
    }
    else
    {
        DGButton *buttonNext = [[DGButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHight)];
        [buttonNext setTitle:@"Next" forState: UIControlStateNormal];
        [buttonNext addTarget:self action:@selector(actionReview:) forControlEvents:UIControlEventTouchUpInside];
        [buttonNext.layer setValue:buttonArray[2] forKey:@"href"];
        
        [self.infoView addSubview:buttonNext];
        
        [buttonNext setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [buttonNext.topAnchor constraintEqualToAnchor:buttonFirst.topAnchor constant:0].active = YES;
        [buttonNext.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
        [buttonNext.leftAnchor constraintEqualToAnchor:buttonPrev.rightAnchor constant:gap].active = YES;
        [buttonNext.widthAnchor constraintEqualToConstant:70].active = YES;
        
        DGButton *buttonLast = [[DGButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHight)];
        [buttonLast setTitle:@"Last" forState: UIControlStateNormal];
        [buttonLast addTarget:self action:@selector(actionReview:) forControlEvents:UIControlEventTouchUpInside];
        [buttonLast.layer setValue:buttonArray[3] forKey:@"href"];
        
        [self.infoView addSubview:buttonLast];
        
        [buttonLast setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [buttonLast.topAnchor constraintEqualToAnchor:buttonFirst.topAnchor constant:0].active = YES;
        [buttonLast.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
        [buttonLast.leftAnchor constraintEqualToAnchor:buttonNext.rightAnchor constant:gap].active = YES;
        [buttonLast.widthAnchor constraintEqualToConstant:70].active = YES;
    }
    url = [finishedMatchDict objectForKey:@"Export match"];
    if(url.length == 0) // Export Button
        return;

#pragma mark Export Button
    
    DGButton *buttonExport = [[DGButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHight)];
    [buttonExport setTitle:@"Export match URL" forState: UIControlStateNormal];
    [buttonExport addTarget:self action:@selector(exportAction:) forControlEvents:UIControlEventTouchUpInside];
    [buttonExport.layer setValue:url forKey:@"href"];

    [self.infoView addSubview:buttonExport];
    
    [buttonExport setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [buttonExport.bottomAnchor constraintEqualToAnchor:self.infoView.bottomAnchor constant:-edge].active = YES;
    [buttonExport.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [buttonExport.leftAnchor constraintEqualToAnchor:self.infoView.leftAnchor constant:edge].active = YES;
    [buttonExport.widthAnchor constraintEqualToConstant:140+gap].active = YES;

    return;
}
- (void)actionReview:(UIButton*)button
{
    [self playMatch:(NSString *)[button.layer valueForKey:@"href"]];
}

- (IBAction)exportAction:(UIButton*)button
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@", (NSString *)[button.layer valueForKey:@"href"]]];

    UIActivityViewController *shareVC = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    
    shareVC.popoverPresentationController.sourceView    = self.view;
    shareVC.popoverPresentationController.sourceRect = button.frame;
    [self presentViewController:shareVC animated:YES completion:nil];

    return;

}

-(void)notYetImplemented:(id)sender
{
    NSString *title = @"not yet implemented";
    NSString *message = @"---";
    UIButton *button = (UIButton *)sender;

    switch(button.tag)
    {
        case 1:
            message = @"hier kann ich eine Chat History mit diesem User einsehen. Das wird auch von dem hauptmenüpunkt Player aus möglich sein \n\n derr jeweilige Text wird mit einem zeitstempel und einer info der Quelle ( match (mit link) oder shortmessage versehen.\n\nSuchen kopieren und löschen werden möglich sein";
            break;
        case 2:
            message = @"hier wird mal aus textbausteinen wie zum Beispiel \"Hi from germany. good luck\" oder \"Good match, congratulation\" auswählen können.\n\n Textbausteine anlegen, ändern löschen und verschieben in der Liste wird auch möglich sein";
            break;
        default:
            message = @"unknown Button";
            break;
            
    }
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
   [self presentViewController:alert animated:YES completion:nil];
}

- (void)player:(UIButton*)sender
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

-(void)textModul:(id)sender
{
    TextModul *controller = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"TextModul"];
    
    controller.modalPresentationStyle = UIModalPresentationPopover;
    controller.textView = finishedMatchChat;
    controller.isSetup = NO;
    [self presentViewController:controller animated:NO completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
    popController.delegate = self;
    
    UIButton *button = (UIButton *)sender;
    popController.sourceView = button;
    popController.sourceRect = button.bounds;
}

- (IBAction)chatHistory:(id)sender
{

    ChatHistory *controller = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatHistory"];
    
    NSMutableDictionary *finishedMatchDict = [boardDict objectForKey:@"finishedMatch"];
    NSArray *playerArray = [finishedMatchDict objectForKey:@"matchPlayer"];
    NSArray *playerIDArray = [finishedMatchDict objectForKey:@"href"];

    controller.playerName = playerArray[0];
    controller.playerID = [playerIDArray[0] lastPathComponent];

    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:NO completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
    popController.delegate = self;
    
    UIButton *button = (UIButton *)sender;
    popController.sourceView = button;
    popController.sourceRect = button.bounds;
}
#pragma mark - There has been an internal error.

- (void)internalError

{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"There has been an internal error."
                                 message:@"The Dailygammon Server responds with: \n\n The error has been logged and the administrators will be alerted. Our apologies.\n\nThis is a message from the server. The app did not cause this. This is usually not a big deal and you can just keep playing."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:@"TopPage"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
        [self.navigationController popToRootViewControllerAnimated:NO];

        TopPageCV *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"TopPageCV"];
        [self.navigationController pushViewController:vc animated:NO];
                                 }];

    [alert addAction:okButton];
    alert.view.tag = ALERT_VIEW_TAG;

    
    [self presentViewController:alert animated:YES completion:nil];
    
}
#pragma mark - invite
-(void)invite
{
    if([[self.boardDict objectForKey:@"Invite"] length] != 0)
    {
        NSMutableDictionary *inviteDict = [self.boardDict objectForKey:@"inviteDict"] ;
        NSMutableArray *inviteArray = [inviteDict objectForKey:@"inviteDetails"];
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Message"
                                     message:inviteArray[1]
                                     preferredStyle:UIAlertControllerStyleAlert];
        NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ \n%@ \n%@",
                                                                                                inviteArray[0],
                                                                                                inviteArray[1],
                                                                                                inviteArray[2]]];
        [message addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:15.0]
                        range:NSMakeRange(0, [message length])];
        [alert setValue:message forKey:@"attributedMessage"];
        
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:@"Accept"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       NSMutableDictionary * acceptDict = [inviteDict objectForKey:@"AcceptButton"];
                                       NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@?submit=Accept%%20Invitation&action=accept",
                                                                               [acceptDict objectForKey:@"action"]]];
                                       
                                       NSError *error = nil;
                                       NSStringEncoding encoding = 0;
                                       NSString *returnString = [[NSString alloc] initWithContentsOfURL:urlMatch
                                                                                           usedEncoding:&encoding
                                                                                                  error:&error]; // this line accepts the invitation
            //TODO:Synchronous URL loading of http://dailygammon.com/bg/invite/455161?submit=Accept%20Invitation&action=accept should not occur on this application's main thread as it may lead to UI unresponsiveness. Please switch to an asynchronous networking API such as URLSession.
                                       [self playMatch:[NSString stringWithFormat:@"/bg/nextgame?submit=Next"]];

                                   }];
        [okButton setValue:[design designSystemImage:@"checkmark.circle"] forKey:@"image"];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"Decline"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       NSMutableDictionary * acceptDict = [inviteDict objectForKey:@"DeclineButton"];
                                       NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@?submit=Decline%%20Invitation&action=decline",
                                                                               [acceptDict objectForKey:@"action"]]];
                                       
                                       NSError *error = nil;
                                       NSStringEncoding encoding = 0;
                                       NSString *returnString = [[NSString alloc] initWithContentsOfURL:urlMatch
                                                                                           usedEncoding:&encoding
                                                                                                  error:&error]; // this line declines the invitation
            //TODO:Synchronous URL loading of http://dailygammon.com/bg/invite/455161?submit=Decline%20Invitation&action=decline should not occur on this application's main thread as it may lead to UI unresponsiveness. Please switch to an asynchronous networking API such as URLSession.
                                       [self playMatch:[NSString stringWithFormat:@"/bg/nextgame?submit=Next"]];
                                   }];
        
        [noButton setValue:[design designSystemImage:@"x.circle"] forKey:@"image"];

        UIAlertAction* playerButton = [UIAlertAction
                                    actionWithTitle:@"Show player details"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
            PlayerDetail *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"PlayerDetail"];
            vc.modalPresentationStyle = UIModalPresentationPopover;
            vc.userID = [inviteDict objectForKey:@"user"];
            vc.navController = self.navigationController;

            UIPopoverPresentationController *popController = [vc popoverPresentationController];
            popController.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
            
            popController.sourceView = self.view;
            popController.sourceRect = CGRectMake(self.view.center.x, 50, 50, 50);
            [self.navigationController presentViewController:vc animated:NO completion:nil];
            
                                    }];
        [playerButton setValue:[design designSystemImage:@"person.circle"] forKey:@"image"];

        [alert addAction:okButton];
        [alert addAction:noButton];
        [alert addAction:playerButton];
        alert.view.tag = ALERT_VIEW_TAG;

        [self presentViewController:alert animated:YES completion:nil];
    }

}
#pragma mark - quickMessage

-(void) quickMessage 
{
    NSMutableDictionary *actionDict = [self.boardDict objectForKey:@"messageDict"];
    NSMutableArray *attributesArray = [actionDict objectForKey:@"attributes"];
    NSMutableDictionary *dict = attributesArray[0];

    [chatHistory saveChat:[self.boardDict objectForKey:@"chat"]
                     opponentID:[[dict objectForKey:@"action"] lastPathComponent]
                        autorID:[[dict objectForKey:@"action"] lastPathComponent]
                            typ:CHATHISTORY_QUICKMESSAGE
                    matchNumber:0
                      matchName:@""];

    QuickMessage *controller = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"QuickMessage"];
    controller.playerName = [[self.boardDict objectForKey:@"matchName"]
                             stringByReplacingOccurrencesOfString:@"You have received the following quick message from "
                             withString:@""];
    controller.playerNumber = [[dict objectForKey:@"action"] lastPathComponent];
    controller.receivedMessage = YES;
    controller.boardDict = self.boardDict;
    controller.navController = self.navigationController;
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:NO completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    popController.delegate = self;
    
    popController.sourceView = self.view;
    popController.sourceRect = CGRectMake(self.view.center.x, 50, 50, 50);

    return;
}

#pragma mark - textView
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    if (!([textView.text rangeOfString:@"You may chat with"].location == NSNotFound))
    {
        textView.text = @"";
    }
    if (!([textView.text rangeOfString:@"You may chat here"].location == NSNotFound))
    {
        textView.text = @"";
    }

    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [finishedMatchChat endEditing:YES];
    
    return YES;
}

- (void)keyboardDidShow:(NSNotification *)notification
{
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [self.view endEditing:YES];
}

#pragma mark - actions textView finished match
- (void)actionNextFinishedMatch:(UIButton*)button
{
    [finishedMatchChat endEditing:YES];

    NSString *href = (NSString *)[button.layer valueForKey:@"href"];
    NSString *nextButtonText = @"Next%20Game";
    NSString * matchLink = @"";

    NSMutableDictionary *finishedMatchDict = [self.boardDict objectForKey:@"finishedMatch"] ;
    
    if([[finishedMatchDict objectForKey:@"NextButton"] isEqualToString:@"Next"])
        nextButtonText = @"Next";
    
    NSArray *chatArray = [finishedMatchDict objectForKey:@"chat"];
    if([chatArray[0] containsString:@"chat"])
    {
        NSString *chatString = [textTools cleanChatString:finishedMatchChat.text];
        if(![chatString isEqualToString: @""])
        {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

            [chatHistory saveChat:chatString
                       opponentID:[app.boardDict objectForKey:@"opponentID"]
                          autorID:[[NSUserDefaults standardUserDefaults] stringForKey:@"USERID"]
                              typ:CHATHISTORY_MATCH
                      matchNumber:0
                        matchName:[finishedMatchDict objectForKey:@"matchName"]];
        }

        if(chatString)
            chatString = [NSString stringWithFormat:@"&chat=%@",chatString];
        if([href isEqualToString:@""])
            matchLink = @"/bg/nextgame";
        else
            matchLink = [NSString stringWithFormat:@"%@?submit=%@&commit=1%@", href,nextButtonText, chatString];
    }
    else
    {
        if([href isEqualToString:@""])
            matchLink = @"/bg/nextgame";
        else
            matchLink = [NSString stringWithFormat:@"%@?submit=%@&commit=1", href, nextButtonText];
    }

    [self playMatch:matchLink];
}

- (void)actionToTopFinishedMatch:(UIButton*)button
{
    [finishedMatchChat endEditing:YES];
    NSMutableDictionary *finishedMatchDict = [self.boardDict objectForKey:@"finishedMatch"] ;

    NSString *href = (NSString *)[button.layer valueForKey:@"href"];
    NSString *chatString = [textTools cleanChatString:finishedMatchChat.text];
    if(![chatString isEqualToString: @""])
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        [chatHistory saveChat:chatString
                   opponentID:[app.boardDict objectForKey:@"opponentID"]
                      autorID:[[NSUserDefaults standardUserDefaults] stringForKey:@"USERID"]
                          typ:CHATHISTORY_MATCH
                  matchNumber:0
                    matchName:[finishedMatchDict objectForKey:@"matchName"]];
    }

    NSString *matchLink = [NSString stringWithFormat:@"%@?submit=To%%20Top&commit=1&chat=%@", href, chatString];
    NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",matchLink]];
    
    DGRequest *request = [[DGRequest alloc] initWithURL:urlMatch completionHandler:^(BOOL success, NSError *error, NSString *result)
                          {
        if (success)
        {
            [self.navigationController popToRootViewControllerAnimated:NO];

            TopPageCV *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"TopPageCV"];

            [self.navigationController pushViewController:vc animated:NO];
        }
        else
        {
            XLog(@"Error: %@", error.localizedDescription);
        }
    }];
    request = nil;

}


#pragma mark - Header

//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//
//    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
//     {
//         // Code to be executed during the animation
//        
//     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
//     {
//         // Code to be executed after the animation is completed
//     }];
//
//    XLog(@"Neue Breite: %.2f, Neue Höhe: %.2f", size.width, size.height);
//    
//}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
       
    if (![self.navigationController.topViewController isKindOfClass:NoBoard.class])
        return;

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;

    if(safe.layoutFrame.size.width > (10 + 150 + 10 + 50 + 10 + 150 + 10 + 50 + 10) )
    {
        [NSLayoutConstraint deactivateConstraints:self.portraitConstraints];
        [NSLayoutConstraint activateConstraints:self.landscapeConstraints];
    }
    else
    {
        [NSLayoutConstraint deactivateConstraints:self.landscapeConstraints];
        [NSLayoutConstraint activateConstraints:self.portraitConstraints];
    }

}
@end
