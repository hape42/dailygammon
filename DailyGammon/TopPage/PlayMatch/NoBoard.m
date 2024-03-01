//
//  NoBoard.m
//  DailyGammon
//
/*
 During a game html pages keep coming up that do not contain a board.

 I had initially tried to handle everything in a routine. But this routine "showMatch" has grown more and more to handle all special cases.

 This routine is hardly maintainable.

 I now try to handle everything in the "noBoard". The change is large and therefore unfortunately also susceptible to errors or to overlook something.

 The outsourcing to "noBoard" is also a very good opportunity to streamline "PlayMatch" and" iPhonePlayMatch", which will eventually make it easier to merge the two "playMatch".


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
#import "Player.h"
#import "Tools.h"
#import <SafariServices/SafariServices.h>
#import "About.h"
#import "DGButton.h"
#import "PlayerLists.h"
#import "Constants.h"
#import "DGRequest.h"
#import "DGLabel.h"

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

@synthesize design, preferences, rating, tools;
@synthesize waitView;
@synthesize menueView;

@synthesize finishedMatchChat, finishedmatchChatViewFrame, isFinishedMatch;
@synthesize quickmessageChat, quickmessageChatViewFrame, isQuickmessage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    design = [[Design alloc] init];
    preferences = [[Preferences alloc] init];
    rating = [[Rating alloc] init];
    tools = [[Tools alloc] init];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;
    
    UITapGestureRecognizer *oneFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDidHide:)];
    oneFingerTap.numberOfTapsRequired = 1;
    oneFingerTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:oneFingerTap];

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
        [self finishedMatch];
        return;
    }
#pragma mark TopPage
    if([[self.boardDict objectForKey:@"TopPage"] length] != 0)
    {
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

    PlayMatch *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"PlayMatch"];
    vc.matchLink = matchLink;
    [self.navigationController pushViewController:vc animated:NO];

    return;
}
#pragma mark - unknown HTML

-(void)unknownHTML
{
    if([ [self.boardDict objectForKey:@"htmlString"] isEqualToString:@""])
    {
        XLog(@"---------> empty htmlString");
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
    NSString *href = @"";

    for(NSDictionary *dict in [finishedMatchDict objectForKey:@"attributes"])
    {
        href = [dict objectForKey:@"action"];
    }
    isFinishedMatch = YES;
    NSArray *chatArray = [finishedMatchDict objectForKey:@"chat"];
    bool withChat = NO;
    if([chatArray[0] containsString:@"chat"])
        withChat = YES;
    int edge = 10;
    int gap = 10;
    float buttonWidth = 150.0;
    float buttonHight = 30;

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;

    self.infoView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.infoView];
//    self.infoView.layer.borderWidth = 3;
    [self.infoView setTranslatesAutoresizingMaskIntoConstraints:NO];

    if(withChat)
    {
        [self.infoView.heightAnchor constraintEqualToAnchor:safe.heightAnchor constant:-50].active = YES;
        [self.infoView.bottomAnchor constraintEqualToAnchor:self.view.keyboardLayoutGuide.topAnchor constant:-edge].active = YES;
    }
    else
    {
        [self.infoView.heightAnchor constraintEqualToConstant:300].active = YES;
        [self.infoView.topAnchor constraintEqualToAnchor:safe.topAnchor constant:50].active = YES;
    }
    [self.infoView.leftAnchor   constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.infoView.rightAnchor  constraintEqualToAnchor:self.moreButton.leftAnchor constant:0].active = YES;

    self.infoView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
//    self.infoView.backgroundColor = [UIColor yellowColor];

    UILabel *matchName = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.infoView addSubview:matchName];
    [matchName setTranslatesAutoresizingMaskIntoConstraints:NO];

    matchName.text = [finishedMatchDict objectForKey:@"matchName"];
    matchName.textAlignment = NSTextAlignmentCenter;
//    matchName.backgroundColor = [UIColor redColor];

    [matchName.topAnchor constraintEqualToAnchor:self.infoView.topAnchor constant:edge].active = YES;
    [matchName.heightAnchor constraintEqualToConstant:40].active = YES;
    [matchName.leftAnchor constraintEqualToAnchor:self.infoView.leftAnchor constant:edge].active = YES;
    [matchName.rightAnchor constraintEqualToAnchor:self.infoView.rightAnchor constant:-edge].active = YES;

    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[finishedMatchDict objectForKey:@"matchName"]];
    [attr addAttribute:NSFontAttributeName
                  value:[UIFont systemFontOfSize:40.0]
                  range:NSMakeRange(0, [attr length])];
    [matchName setAttributedText:attr];
    matchName.adjustsFontSizeToFitWidth = YES;
    matchName.numberOfLines = 0;
    matchName.minimumScaleFactor = 0.5;
    matchName.adjustsFontSizeToFitWidth = YES;
    
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
    winner.minimumScaleFactor = 0.5;
    winner.adjustsFontSizeToFitWidth = YES;
    
    [self.infoView addSubview:winner];
    [winner setTranslatesAutoresizingMaskIntoConstraints:NO];

    [winner.topAnchor constraintEqualToAnchor:matchName.bottomAnchor constant:0].active = YES;
    [winner.heightAnchor constraintEqualToConstant:30].active = YES;
    [winner.leftAnchor constraintEqualToAnchor:self.infoView.leftAnchor constant:edge].active = YES;
    [winner.rightAnchor constraintEqualToAnchor:self.infoView.rightAnchor constant:-edge].active = YES;

    UILabel *length = [[UILabel alloc] initWithFrame:CGRectZero];
    length.textAlignment = NSTextAlignmentLeft;
    NSArray *lengthArray = [finishedMatchDict objectForKey:@"matchLength"];
    length.text = [NSString stringWithFormat:@"%@ %@",lengthArray[0], lengthArray[1]];
    [self.infoView addSubview:length];
    [length setTranslatesAutoresizingMaskIntoConstraints:NO];

    [length.topAnchor constraintEqualToAnchor:winner.bottomAnchor constant:0].active = YES;
    [length.heightAnchor constraintEqualToConstant:30].active = YES;
    [length.leftAnchor constraintEqualToAnchor:self.infoView.leftAnchor constant:edge].active = YES;
    [length.rightAnchor constraintEqualToAnchor:self.infoView.rightAnchor constant:-edge].active = YES;

    NSArray *playerArray = [finishedMatchDict objectForKey:@"matchPlayer"];

    self.buttonPlayer1 = [[DGButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHight)];
    [self.buttonPlayer1 setTitle:playerArray[0] forState: UIControlStateNormal];
    [self.buttonPlayer1.layer setValue:playerArray[0] forKey:@"name"];
    [self.buttonPlayer1 addTarget:self action:@selector(player:) forControlEvents:UIControlEventTouchUpInside];
    [self.infoView addSubview:self.buttonPlayer1];


    self.player1Score = [[UILabel alloc] initWithFrame:CGRectZero];
    self.player1Score.textAlignment = NSTextAlignmentCenter;
    self.player1Score.text = playerArray[1];
    [self.infoView addSubview:self.player1Score];
//    self.player1Score.backgroundColor = [UIColor systemBlueColor];


    self.buttonPlayer2 = [[DGButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHight)];
    [self.buttonPlayer2 setTitle:playerArray[2] forState: UIControlStateNormal];
    [self.buttonPlayer2.layer setValue:playerArray[2] forKey:@"name"];
    [self.buttonPlayer2 addTarget:self action:@selector(player:) forControlEvents:UIControlEventTouchUpInside];
    [self.infoView addSubview:self.buttonPlayer2];

    [self.buttonPlayer2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    

    self.player2Score = [[UILabel alloc] initWithFrame:CGRectZero];
    self.player2Score.textAlignment = NSTextAlignmentCenter;
    self.player2Score.text = playerArray[3];
    [self.infoView addSubview:self.player2Score];
//    self.player2Score.backgroundColor = [UIColor systemBlueColor];


    [self.buttonPlayer1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.buttonPlayer1.topAnchor constraintEqualToAnchor:length.bottomAnchor constant:gap].active = YES;
    [self.buttonPlayer1.heightAnchor constraintEqualToConstant:30].active = YES;
    [self.buttonPlayer1.leftAnchor constraintEqualToAnchor:self.infoView.leftAnchor constant:edge].active = YES;
    [self.buttonPlayer1.widthAnchor constraintEqualToConstant:150].active = YES;

    [self.player1Score setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.player1Score.topAnchor constraintEqualToAnchor:length.bottomAnchor constant:gap].active = YES;
    [self.player1Score.heightAnchor constraintEqualToConstant:30].active = YES;
    [self.player1Score.leftAnchor constraintEqualToAnchor:self.buttonPlayer1.rightAnchor constant:gap].active = YES;
    [self.player1Score.widthAnchor constraintEqualToConstant:50].active = YES;

    [self.buttonPlayer2.heightAnchor constraintEqualToConstant:30].active = YES;
    [self.buttonPlayer2.widthAnchor constraintEqualToConstant:150].active = YES;

    [self.player2Score setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.player2Score.heightAnchor constraintEqualToConstant:30].active = YES;
    [self.player2Score.widthAnchor constraintEqualToConstant:50].active = YES;

    self.landscapeConstraints = @[
        [self.buttonPlayer2.topAnchor constraintEqualToAnchor:length.bottomAnchor constant:gap],
        [self.buttonPlayer2.leftAnchor constraintEqualToAnchor:self.player1Score.rightAnchor constant:gap],
        [self.player2Score.topAnchor constraintEqualToAnchor:self.buttonPlayer2.topAnchor constant:0],
        [self.player2Score.leftAnchor constraintEqualToAnchor:self.buttonPlayer2.rightAnchor constant:gap]

    ];
    self.portraitConstraints = @[
        [self.buttonPlayer2.topAnchor constraintEqualToAnchor:self.buttonPlayer1.bottomAnchor constant:gap],
        [self.buttonPlayer2.leftAnchor constraintEqualToAnchor:self.infoView.leftAnchor constant:edge] ,
        [self.player2Score.topAnchor constraintEqualToAnchor:self.buttonPlayer2.topAnchor constant:0],
        [self.player2Score.leftAnchor constraintEqualToAnchor:self.buttonPlayer2.rightAnchor constant:gap]
    ];

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
    [buttonNext.widthAnchor constraintEqualToConstant:80].active = YES;

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
    [buttonToTop.widthAnchor constraintEqualToConstant:80].active = YES;

    if(withChat)
    {
        
        DGButton *keyboardButton = [[DGButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth * 2, buttonHight)];
        [keyboardButton setTitle:@"hide keyboard" forState: UIControlStateNormal];
        [keyboardButton addTarget:self action:@selector(textViewShouldEndEditing:) forControlEvents:UIControlEventTouchUpInside];
        [self.infoView addSubview:keyboardButton];
        
        [keyboardButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [keyboardButton.bottomAnchor constraintEqualToAnchor:self.infoView.bottomAnchor constant:-edge].active = YES;
        [keyboardButton.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
        [keyboardButton.widthAnchor constraintEqualToConstant:160].active = YES;
        [keyboardButton.rightAnchor constraintEqualToAnchor:self.infoView.rightAnchor constant:-edge].active = YES;
    }
    if(withChat)
    {
        // Calculate maximum window height
        XLog(@"with chat");
        finishedMatchChat  = [[UITextView alloc] initWithFrame:CGRectZero];
        finishedmatchChatViewFrame = finishedMatchChat.frame;
        finishedMatchChat.textAlignment = NSTextAlignmentLeft;
        NSArray *chatArray = [finishedMatchDict objectForKey:@"chat"];
        NSString *chatString = @"";
        for( NSString *chatZeile in chatArray)
        {
            if(![chatZeile containsString:@"You may chat with"])
                chatString = [NSString stringWithFormat:@"%@ %@", chatString, chatZeile];
        }
        finishedMatchChat.text = chatString;
        finishedMatchChat.editable = YES;
        [finishedMatchChat setDelegate:self];
        finishedMatchChat.tag = 1000;
        [finishedMatchChat setFont:[UIFont systemFontOfSize:20]];
        [self.infoView addSubview:finishedMatchChat];

        [finishedMatchChat setTranslatesAutoresizingMaskIntoConstraints:NO];

        [finishedMatchChat.bottomAnchor constraintEqualToAnchor:buttonNext.topAnchor constant:-edge].active = YES;
        [finishedMatchChat.heightAnchor constraintEqualToConstant:100].active = YES;
        [finishedMatchChat.leftAnchor constraintEqualToAnchor:self.infoView.leftAnchor constant:edge].active = YES;
        [finishedMatchChat.rightAnchor constraintEqualToAnchor:self.infoView.rightAnchor constant:-edge].active = YES;

    }
    else
    {
        XLog(@"no chat, just a message");

        UITextView *opponentChat = [[UITextView alloc] init];
        opponentChat.editable = NO;
        [opponentChat setFont:[UIFont systemFontOfSize:15]];
        opponentChat.backgroundColor = [UIColor clearColor];
        opponentChat.textColor = [design getTintColorSchema];
        opponentChat.text = chatArray[0];
        opponentChat.layer.borderWidth = 1;
        opponentChat.layer.borderColor = [design getTintColorSchema].CGColor;
        opponentChat.layer.cornerRadius = 14.0f;
        opponentChat.layer.masksToBounds = YES;
        [self.infoView addSubview:opponentChat];

        
        [opponentChat setTranslatesAutoresizingMaskIntoConstraints:NO];

        [opponentChat.bottomAnchor constraintEqualToAnchor:buttonNext.topAnchor constant:-edge].active = YES;
        [opponentChat.heightAnchor constraintEqualToConstant:80].active = YES;
        [opponentChat.leftAnchor constraintEqualToAnchor:self.infoView.leftAnchor constant:edge].active = YES;
        [opponentChat.rightAnchor constraintEqualToAnchor:self.infoView.rightAnchor constant:-edge].active = YES;

//        [chatLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
//
//        [chatLabel.bottomAnchor constraintEqualToAnchor:buttonNext.topAnchor constant:-edge].active = YES;
//        [chatLabel.heightAnchor constraintEqualToConstant:100].active = YES;
//        [chatLabel.leftAnchor constraintEqualToAnchor:self.infoView.leftAnchor constant:edge].active = YES;
//        [chatLabel.rightAnchor constraintEqualToAnchor:self.infoView.rightAnchor constant:-edge].active = YES;

    }

    return;
}

- (void)player:(UIButton*)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Player *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"PlayerVC"];
    vc.name   = (NSString *)[sender.layer valueForKey:@"name"];

    [self.navigationController pushViewController:vc animated:NO];

}

#pragma mark - There has been an internal error.

- (void)internalError

{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"There has been an internal error."
                                 message:@" The error has been logged and the administrators will be alerted. Our apologies.\nThis is a message from the server. The app did not cause this. This is usually not a big deal and you can just keep playing."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:@"TopPage"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
        TopPageCV *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"TopPageCV"];
        [self.navigationController pushViewController:vc animated:NO];
                                 }];

    [alert addAction:okButton];
    alert.view.tag = ALERT_VIEW_TAG;

    alert = [design makeBackgroundColor:alert];
    
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
        NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",inviteArray[0],inviteArray[1]]];
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
        
        UIAlertAction* webButton = [UIAlertAction
                                    actionWithTitle:@"Go to Website"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com/bg/nextgame"]];
                                        if ([SFSafariViewController class] != nil) {
                                            SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:URL];
                                            [self presentViewController:sfvc animated:YES completion:nil];
                                        } else {
                                            [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
                                        }
                                                TopPageCV *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"TopPageCV"];

                                                [self.navigationController pushViewController:vc animated:NO];

                                    }];
        
        [alert addAction:okButton];
        [alert addAction:noButton];
        [alert addAction:webButton];
        alert.view.tag = ALERT_VIEW_TAG;

        [self presentViewController:alert animated:YES completion:nil];
    }

}
#pragma mark - quickMessage

-(void) quickMessage
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:[self.boardDict objectForKey:@"quickMessage"]
                                 message:[self.boardDict objectForKey:@"chat"]
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"NEXT"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [self playMatch:[NSString stringWithFormat:@"/bg/nextgame?submit=Next"]];
                                }];
    UIAlertAction* answerButton = [UIAlertAction
                                actionWithTitle:@"Answer"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    self->isQuickmessage = YES;
                                    int gap = 5;
                                    int edge = 5;
                                    int titleHeight = 50; int messageHeight = 100; int chatHeight = 100;
                                    int maxWidth = [UIScreen mainScreen].bounds.size.width;
                                    int maxHeight  = [UIScreen mainScreen].bounds.size.height;
                                    float viewWidth = maxWidth * 0.6;
                                    float viewHeight = edge + titleHeight + gap + messageHeight + gap + chatHeight + gap + 50;
                                    float x = edge;
                                    float y = edge;

                                    UIView *messageAnswerView = [[UIView alloc] initWithFrame:CGRectMake((maxWidth - viewWidth)/2,
                                                                                                         (maxHeight - viewHeight)/2,
                                                                                                         viewWidth,
                                                                                                         viewHeight)];
                                  //  messageAnswerView.tag = ANSWERREPLY_VIEW;
                                    messageAnswerView.backgroundColor = [UIColor colorNamed:@"ColorAnswerView"];
                                    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(x,
                                                                                               y,
                                                                                               viewWidth - edge - edge,
                                                                                               titleHeight)];
                                    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[self.boardDict objectForKey:@"quickMessage"]];
                                    [attr addAttribute:NSFontAttributeName
                                                 value:[UIFont systemFontOfSize:30.0]
                                                 range:NSMakeRange(0, [attr length])];
                                    [title setAttributedText:attr];

                                    title.adjustsFontSizeToFitWidth = YES;
                                    title.numberOfLines = 0;
                                    title.minimumScaleFactor = 0.5;
                                    title.backgroundColor = [UIColor colorNamed:@"ColorAnswerTitle"];
                                    title.textAlignment = NSTextAlignmentCenter;
                                    y += titleHeight + gap;
                                    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(x,
                                                                                               y,
                                                                                               viewWidth - edge - edge,
                                                                                               messageHeight)];
                                    attr = [[NSMutableAttributedString alloc] initWithString:[self.boardDict objectForKey:@"chat"]];
                                    [attr addAttribute:NSFontAttributeName
                                                 value:[UIFont systemFontOfSize:20.0]
                                                 range:NSMakeRange(0, [attr length])];
                                    [message setAttributedText:attr];
                                    message.backgroundColor = [UIColor colorNamed:@"ColorAnswerMessage"];
                                    message.adjustsFontSizeToFitWidth = YES;
                                    message.numberOfLines = 0;
                                    message.minimumScaleFactor = 0.5;
                                    message.textAlignment = NSTextAlignmentCenter;
                                    y += messageHeight + gap;
        
                                    self->quickmessageChat = [[UITextView alloc] initWithFrame:CGRectMake(x,
                                                                                                          y,
                                                                                                          viewWidth - edge - edge,
                                                                                                          chatHeight)];
                                    [self->quickmessageChat setFont:[UIFont systemFontOfSize:20]];
                                    self->quickmessageChat.text = @"You may chat here";
                                    self->quickmessageChat.delegate = self;
                                    self->quickmessageChat.backgroundColor = [UIColor colorNamed:@"ColorAnswerChat"];
                                    self->quickmessageChatViewFrame = self->quickmessageChat.frame;
                                    y += chatHeight + gap + gap;

                                    DGButton *buttonNext = [[DGButton alloc] initWithFrame:CGRectMake(messageAnswerView.frame.size.width - 120 - edge - gap, y, 120, 35)];
                                    [buttonNext setTitle:@"Send Reply" forState: UIControlStateNormal];
                                    [buttonNext addTarget:self action:@selector(actionSendReplay) forControlEvents:UIControlEventTouchUpInside];

                                    DGButton *buttonCancel = [[DGButton alloc] initWithFrame:CGRectMake(x + gap, y, 120, 35)];
                                    [buttonCancel setTitle:@"Cancel" forState: UIControlStateNormal];
                                    [buttonCancel addTarget:self action:@selector(actionCancelReplay) forControlEvents:UIControlEventTouchUpInside];

                                    [messageAnswerView addSubview:buttonCancel];
                                    [messageAnswerView addSubview:buttonNext];
                                    [messageAnswerView addSubview:title];
                                    [messageAnswerView addSubview:message];
                                    [messageAnswerView addSubview:self->quickmessageChat];
                                    messageAnswerView.layer.borderWidth = 1.0;

                                    [self.view addSubview:messageAnswerView];
                                }];

    [alert addAction:yesButton];
    [alert addAction:answerButton];
    alert.view.tag = ALERT_VIEW_TAG;

    [self presentViewController:alert animated:YES completion:nil];
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
    if(isQuickmessage)
    {
        CGRect frame = quickmessageChatViewFrame;
        frame.origin.y = 50;
        quickmessageChat.frame = frame;
    }
//    if(isFinishedMatch)
//    {
//        CGRect frame = finishedmatchChatViewFrame;
//        frame.origin.y = 50;
//        finishedMatchChat.frame = frame;
//    }
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [self.view endEditing:YES];
//    if(isFinishedMatch)
//        finishedMatchChat.frame = finishedmatchChatViewFrame;
    if(isQuickmessage)
        quickmessageChat.frame = quickmessageChatViewFrame;

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
        NSString *chatString = [tools cleanChatString:finishedMatchChat.text];

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

    NSString *href = (NSString *)[button.layer valueForKey:@"href"];
    NSString *chatString = [tools cleanChatString:finishedMatchChat.text];
    if(chatString)
        chatString = [NSString stringWithFormat:@"&chat=%@",chatString];

    NSString *matchLink = [NSString stringWithFormat:@"%@?submit=To%%20Top&commit=1&chat=%@", href, chatString];
    NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",matchLink]];
    
    DGRequest *request = [[DGRequest alloc] initWithURL:urlMatch completionHandler:^(BOOL success, NSError *error, NSString *result)
                          {
        if (success)
        {
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

#pragma mark - actions textView reply quickmessage

- (void) actionSendReplay
{

    [quickmessageChat endEditing:YES];

    NSMutableDictionary *actionDict = [self.boardDict objectForKey:@"messageDict"];
    NSMutableArray *attributesArray = [actionDict objectForKey:@"attributes"];
    NSMutableDictionary *dict = attributesArray[0];

    NSString *chatString = [tools cleanChatString:quickmessageChat.text];
    NSString *matchLink = @"";

    matchLink = [NSString stringWithFormat:@"%@?submit=Send%%20Reply&text=%@",
                 [dict objectForKey:@"action"],
                 chatString];
    [self playMatch:matchLink];
}
- (void) actionCancelReplay
{
    [quickmessageChat endEditing:YES];

    NSString *matchLink = [NSString stringWithFormat:@"/bg/nextgame?submit=Next"];
    [self playMatch:matchLink];
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
