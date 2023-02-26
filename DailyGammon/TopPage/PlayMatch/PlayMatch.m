//
//  PlayMatch.m
//  DailyGammon
//
//  Created by Peter on 29.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "PlayMatch.h"
#import "TopPageVC.h"
#import "SetUpVC.h"
#import "Design.h"
#import "TFHpple.h"
#import "Match.h"
#import "GameLounge.h"
#import "Rating.h"
#import "AppDelegate.h"
#import "DbConnect.h"
#import "RatingVC.h"
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <SafariServices/SafariServices.h>
#import "Player.h"
#import "Tools.h"
#import "Player.h"
#import "LoginVC.h"
#import "About.h"
#import "DGButton.h"

#import "ConstantsMatch.h"
#import "MatchTools.h"

#import "PlayerLists.h"
#import "Constants.h"

@interface PlayMatch ()

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *matchName;
@property (weak, nonatomic) IBOutlet UILabel *unexpectedMove;

@property (weak, nonatomic) IBOutlet UIView *chatView;
@property (weak, nonatomic) IBOutlet UIButton *transparentButton;
@property (assign, atomic) BOOL chatIsTransparent;

@property (weak, nonatomic) IBOutlet UITextView *opponentChat;
@property (weak, nonatomic) IBOutlet UITextView *playerChat;
@property (weak, nonatomic) IBOutlet UIButton *NextButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *ToTopOutlet;
@property (weak, nonatomic) IBOutlet UISwitch *quoteSwitch;
@property (weak, nonatomic) IBOutlet UILabel *quoteMessage;
@property (weak, nonatomic) IBOutlet UILabel *chatHeaderText;
@property (assign, atomic) CGRect chatViewFrame;
@property (assign, atomic) CGRect quoteSwitchFrame;
@property (assign, atomic) CGRect quoteMessageFrame;
@property (assign, atomic) CGRect chatNextButtonFrame;
@property (assign, atomic) CGRect chatTopPageButtonFrame;
@property (assign, atomic) CGRect opponentChatViewFrame;
@property (assign, atomic) CGRect playerChatViewFrame;
@property (assign, atomic) CGRect chatViewFrameSave;


@property (readwrite, retain, nonatomic) NSMutableDictionary *boardDict;
@property (readwrite, retain, nonatomic) NSMutableDictionary *actionDict;
@property (assign, atomic) int boardSchema;
@property (readwrite, retain, nonatomic) UIColor *boardColor;
@property (readwrite, retain, nonatomic) UIColor *randColor;
@property (readwrite, retain, nonatomic) UIColor *barMittelstreifenColor;
@property (readwrite, retain, nonatomic) UIColor *nummerColor;
@property (readwrite, retain, nonatomic) NSString *matchLaengeText;

@property (assign, atomic) BOOL verifiedDouble;
@property (assign, atomic) BOOL verifiedTake;
@property (assign, atomic) BOOL verifiedPass;

@property (readwrite, retain, nonatomic) NSMutableArray *moveArray;

@property (weak, nonatomic) UIPopoverController *presentingPopoverController;

@property (readwrite, retain, nonatomic) UIView *finishedMatchView;
@property (readwrite, retain, nonatomic) UITextView *finishedMatchChat;

@property (readwrite, retain, nonatomic) UIView *messageAnswerView;
@property (readwrite, retain, nonatomic) UITextView *answerMessage;
@property (assign, atomic) CGRect answerMessageFrameSave;

@property (readwrite, retain, nonatomic) NSString *matchString;

@property (assign, atomic) BOOL isChatView, isFinishedMatch, isMessageAnswerView;
@property (assign, atomic) CGRect finishedMatchFrame;

@property (assign, atomic) unsigned long memory_start;
@property (assign, atomic) BOOL first;

@property (readwrite, retain, nonatomic) DGButton *topPageButton;

@property (assign, atomic) int matchCount;

@end

@implementation PlayMatch

@synthesize design, match, rating, tools;
@synthesize matchLink;
@synthesize ratingDict;

@synthesize topPageArray;

@synthesize matchTools;

#define BUTTONHEIGHT 35
#define BUTTONWIDTH 80

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;
    
    self.chatView.layer.borderWidth = 1.0f;
    self.opponentChat.layer.borderWidth = 1.0f;
    self.playerChat.layer.borderWidth = 1.0f;

    design = [[Design alloc] init];
    match  = [[Match alloc] init];
    rating = [[Rating alloc] init];
    tools = [[Tools alloc] init];
    matchTools = [[MatchTools alloc] init];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(drawPlayingAreas) name:changeSchemaNotification object:nil];
    [nc addObserver:self selector:@selector(showMatchCount) name:matchCountChangedNotification object:nil];

    [self.view addSubview:[self makeHeader]];
    [self.view addSubview:self.matchName];
    
    UITapGestureRecognizer *oneFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTouched:)];
    oneFingerTap.numberOfTapsRequired = 1;
    oneFingerTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:oneFingerTap];

    [self.playerChat setDelegate:self];
    [self.answerMessage setDelegate:self];

    self.chatIsTransparent = FALSE;
    [self.transparentButton setTitle:@"" forState: UIControlStateNormal];
    UIImage *image = [[UIImage imageNamed:@"Brille"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.transparentButton setImage:image forState:UIControlStateNormal];
    self.transparentButton.tintColor = [UIColor colorNamed:@"ColorSwitch"];
    
    self.quoteSwitchFrame = self.quoteSwitch.frame;
    self.quoteMessageFrame = self.quoteMessage.frame;
    
    self.chatNextButtonFrame    = self.NextButtonOutlet.frame;
    self.chatTopPageButtonFrame = self.ToTopOutlet.frame;
    self.opponentChatViewFrame  = self.opponentChat.frame;
    self.playerChatViewFrame    = self.playerChat.frame;
    self.chatViewFrameSave      = self.chatView.frame;
    
    int maxBreite = [UIScreen mainScreen].bounds.size.width;
    int maxHoehe  = [UIScreen mainScreen].bounds.size.height;
    float breite = maxBreite * 0.6;
    float hoehe = 5+50+5+100+5+100+5+50;
    self.messageAnswerView = [[UIView alloc] initWithFrame:CGRectMake((maxBreite - breite)/2,
                                                                      (maxHoehe - hoehe)/2,
                                                                      breite,
                                                                      hoehe)];

    self.answerMessageFrameSave = self.messageAnswerView.frame;

    
    self.finishedMatchView = [[UIView alloc] initWithFrame:CGRectMake(20, 80, maxBreite - 40,  maxHoehe - 160)];
//    self.finishedMatchView.backgroundColor = [UIColor whiteColor];
    self.finishedMatchFrame = self.finishedMatchView.frame;
    self.first = TRUE;

    self.matchCount = [[[NSUserDefaults standardUserDefaults] valueForKey:@"matchCount"]intValue];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self.view addSubview:[self makeHeader]];

    [self showMatch];
}

- (void) showMatchCount
{
    [self updateMatchCount:self.view];
}
-(void)showMatch
{
    [self showMatchCount];
    self.isChatView = FALSE;
    self.isFinishedMatch = FALSE;
    self.isMessageAnswerView = FALSE;

    UIView *removeView;
    while((removeView = [self.view viewWithTag:FINISHED_MATCH_VIEW]) != nil)
    {
        [removeView removeFromSuperview];
    }
    while((removeView = [self.view viewWithTag:ANSWERREPLY_VIEW]) != nil)
    {
        [removeView removeFromSuperview];
    }

    // schieb den chatView aus dem sichtbaren bereich
    CGRect frame = self.chatView.frame;
    frame.origin.x = 5000;
    frame.origin.y = 5000;
    self.chatView.frame = frame;
    self.infoLabel.frame = frame;

    self.boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(self.boardSchema < 1) self.boardSchema = 4;
    
    NSMutableDictionary *schemaDict = [design schema:self.boardSchema];

    self.boardColor             = [schemaDict objectForKey:@"BoardSchemaColor"];
    self.randColor              = [schemaDict objectForKey:@"RandSchemaColor"];
    self.barMittelstreifenColor = [schemaDict objectForKey:@"barMittelstreifenColor"];
    self.nummerColor            = [schemaDict objectForKey:@"nummerColor"];

    self.boardDict = [match readMatch:matchLink];
    
    if([[self.boardDict objectForKey:@"TopPage"] length] != 0)
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        TopPageVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"TopPageVC"];
        [self.navigationController pushViewController:vc animated:NO];
        return;
    }
    
    if([[self.boardDict objectForKey:@"unknown"] length] != 0)
        [self errorAction:1];

    if([[self.boardDict objectForKey:@"noMatches"] length] != 0)
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        TopPageVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"TopPageVC"];
        [self.navigationController pushViewController:vc animated:NO];
        return;
    }
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

        [self presentViewController:alert animated:YES completion:nil];
        
    }

    self.unexpectedMove.text   = [self.boardDict objectForKey:@"unexpectedMove"];
    if(![self.boardDict objectForKey:@"matchName"] || ![self.boardDict objectForKey:@"matchLaengeText"])
    {
        self.matchName.text = @"";
    }
    else
    {
        self.matchName.text = [NSString stringWithFormat:@"%@, \t %@",
                           [self.boardDict objectForKey:@"matchName"],
                           [self.boardDict objectForKey:@"matchLaengeText"]] ;
    }
    self.actionDict = [match readActionForm:[self.boardDict objectForKey:@"htmlData"] withChat:(NSString *)[self.boardDict objectForKey:@"chat"]];
    self.moveArray = [[NSMutableArray alloc]init];
    
    NSMutableDictionary *finishedMatchDict = [self.boardDict objectForKey:@"finishedMatch"] ;
    if( finishedMatchDict != nil)
    {
//        XLog(@"%@", finishedMatchDict);
        self.isFinishedMatch = TRUE;
        [self finishedMatchView:finishedMatchDict];
    }
    else if([[self.boardDict objectForKey:@"message"] length] != 0)
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
                                        self->matchLink = [NSString stringWithFormat:@"/bg/nextgame?submit=Next"];
                                        [self showMatch];
                                    }];

        [alert addAction:yesButton];

        [self presentViewController:alert animated:YES completion:nil];
    }
    else if([[self.boardDict objectForKey:@"messageSent"] length] != 0)
    {
        self.matchLink = [NSString stringWithFormat:@"/bg/nextgame?submit=Next"];
        [self showMatch];
    }
   else if([[self.boardDict objectForKey:@"quickMessage"] length] != 0)
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
                                        self->matchLink = [NSString stringWithFormat:@"/bg/nextgame?submit=Next"];
                                        [self showMatch];
                                    }];
        UIAlertAction* answerButton = [UIAlertAction
                                    actionWithTitle:@"Answer"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        self.isMessageAnswerView = TRUE;
                                        //hier muss ein ChatWindow erscheinen
                                        int maxBreite = [UIScreen mainScreen].bounds.size.width;
                                        int maxHoehe  = [UIScreen mainScreen].bounds.size.height;
                                        float breite = maxBreite * 0.6;
                                        float hoehe = 5+50+5+100+5+100+5+50;
                                        self.messageAnswerView = [[UIView alloc] initWithFrame:CGRectMake((maxBreite - breite)/2,
                                                                                                    (maxHoehe - hoehe)/2,
                                                                                                     breite,
                                                                                                    hoehe)];
                                        self.messageAnswerView.tag = ANSWERREPLY_VIEW;
                                        self.messageAnswerView.backgroundColor = [UIColor darkGrayColor];
                                        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(5,
                                                                                                    0,
                                                                                                    breite - 10,
                                                                                                    50)];
                                        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[self.boardDict objectForKey:@"quickMessage"]];
                                        [attr addAttribute:NSFontAttributeName
                                                     value:[UIFont systemFontOfSize:30.0]
                                                     range:NSMakeRange(0, [attr length])];
                                        [title setAttributedText:attr];

                                        title.adjustsFontSizeToFitWidth = YES;
                                        title.numberOfLines = 0;
                                        title.minimumScaleFactor = 0.5;
                                        title.backgroundColor = [UIColor grayColor];
                                        title.textAlignment = NSTextAlignmentCenter;
                                        
                                        UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(5,
                                                                                                   55,
                                                                                                   breite - 10,
                                                                                                   100)];
                                        attr = [[NSMutableAttributedString alloc] initWithString:[self.boardDict objectForKey:@"chat"]];
                                        [attr addAttribute:NSFontAttributeName
                                                     value:[UIFont systemFontOfSize:20.0]
                                                     range:NSMakeRange(0, [attr length])];
                                        [message setAttributedText:attr];
                                        message.backgroundColor = [UIColor grayColor];
                                        message.adjustsFontSizeToFitWidth = YES;
                                        message.numberOfLines = 0;
                                        message.minimumScaleFactor = 0.5;
                                        message.textAlignment = NSTextAlignmentCenter;

                                        self.answerMessage = [[UITextView alloc] initWithFrame:CGRectMake(5,
                                                                                                     160,
                                                                                                     breite - 10,
                                                                                                     100)];
                                        [self.answerMessage setFont:[UIFont systemFontOfSize:20]];
                                        self.answerMessage.text = @"you may chat here";
                                        self.answerMessage.delegate = self;
                                        self.answerMessage.backgroundColor = [UIColor lightGrayColor];

                                        DGButton *buttonNext = [[DGButton alloc] initWithFrame:CGRectMake(self.messageAnswerView.frame.size.width - 150, 270, 120, 35)];
                                        [buttonNext setTitle:@"Send Reply" forState: UIControlStateNormal];
                                        [buttonNext addTarget:self action:@selector(actionSendReplay) forControlEvents:UIControlEventTouchUpInside];
                                        
                                        DGButton *buttonCancel = [[DGButton alloc] initWithFrame:CGRectMake(10, 270, 120, 35)];
                                        [buttonCancel setTitle:@"Cancel" forState: UIControlStateNormal];
                                        [buttonCancel addTarget:self action:@selector(actionCancelReplay) forControlEvents:UIControlEventTouchUpInside];
                                        
                                        [self.messageAnswerView addSubview:buttonCancel];
                                        [self.messageAnswerView addSubview:buttonNext];
                                        [self.messageAnswerView addSubview:title];
                                        [self.messageAnswerView addSubview:message];
                                        [self.messageAnswerView addSubview:self.answerMessage];
                                        self.messageAnswerView.layer.borderWidth = 1.0;

                                        [self.view addSubview:self.messageAnswerView];
                                    }];

        [alert addAction:yesButton];
        [alert addAction:answerButton];

        [self presentViewController:alert animated:YES completion:nil];
    }
    else if([[self.boardDict objectForKey:@"Invite"] length] != 0)
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
                                                                                                  error:&error];
//                                       XLog(@"matchString:%@",returnString);
                                       self->matchLink = [NSString stringWithFormat:@"/bg/nextgame?submit=Next"];
                                       [self showMatch];
                                       
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
                                                                                                  error:&error];
//                                       XLog(@"matchString:%@",returnString);
                                       self->matchLink = [NSString stringWithFormat:@"/bg/nextgame?submit=Next"];
                                       [self showMatch];
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
                                        
                                        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                        
                                        TopPageVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneTopPageVC"];
                                        [self.navigationController pushViewController:vc animated:NO];
                                        
                                    }];
        
        [alert addAction:okButton];
        [alert addAction:noButton];
        [alert addAction:webButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [self drawPlayingAreas];
    }
}

-(void)drawPlayingAreas
{
    self.boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(self.boardSchema < 1) self.boardSchema = 4;

    NSMutableDictionary * returnDict = [matchTools drawBoard:self.boardSchema boardInfo:self.boardDict];
    UIView *boardView = [returnDict objectForKey:@"boardView"];
    self.moveArray = [returnDict objectForKey:@"moveArray"];
        
    UIView *removeView;
    
    while((removeView = [self.view viewWithTag:BOARD_VIEW]) != nil)
    {
        for (UIView *subUIView in removeView.subviews)
        {
            [subUIView removeFromSuperview];
        }
        [removeView removeFromSuperview];
    }

    [self.view addSubview:boardView];

    returnDict = [matchTools drawActionView:self.boardDict bordView:boardView];
    UIView *actionView = [returnDict objectForKey:@"actionView"];
    UIView *playerView = [returnDict objectForKey:@"playerView"];
    UIView *opponentView = [returnDict objectForKey:@"opponentView"];
  
    UIButton *buttonOpponent = [returnDict objectForKey:@"buttonOpponent"];
    [buttonOpponent addTarget:self action:@selector(opponent:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonPlayer = [returnDict objectForKey:@"buttonPlayer"];
    [buttonPlayer addTarget:self action:@selector(playerLists:) forControlEvents:UIControlEventTouchUpInside];

    while((removeView = [self.view viewWithTag:ACTION_VIEW]) != nil)
    {
        for (UIView *subUIView in removeView.subviews)
        {
            [subUIView removeFromSuperview];
        }
        [removeView removeFromSuperview];
    }
    [self.view addSubview:actionView];
    [self.view addSubview:playerView];
    [self.view addSubview:opponentView];

    
    int buttonHeight = 0;
    int buttonWidth = 0;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        buttonHeight = 35;
        buttonWidth  = 100;
    }
    else
    {
        buttonHeight = 30;
        buttonWidth  = 80;
    }

    switch([self analyzeAction])
    {
        case NEXT:
        {
#pragma mark - Button Next
            DGButton *buttonNext = [[DGButton alloc] initWithFrame:CGRectMake((actionView.frame.size.width/2) - 50, (actionView.frame.size.height/2) -40, 100, 35)];
            [buttonNext setTitle:@"Next" forState: UIControlStateNormal];
            [buttonNext addTarget:self action:@selector(actionNext) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonNext];
            break;
        }
        case NEXT__:
        {
#pragma mark - Button Next>>
            DGButton *buttonNext = [[DGButton alloc] initWithFrame:CGRectMake((actionView.frame.size.width/2) - 50, (actionView.frame.size.height/2) -40, 100, 35)];
            [buttonNext setTitle:@"Next>>" forState: UIControlStateNormal];
            [buttonNext addTarget:self action:@selector(actionNext__) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonNext];
            break;
        }
#pragma mark - Button NextGame
        case NEXTGAME:
        {
                // seltsamer -0- Something unexpected happend!

                matchLink = [NSString stringWithFormat:@"%@?submit=Next%%20Game&commit=1", [self.actionDict objectForKey:@"action"]];
                NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",matchLink]];
                //    XLog(@"%@",urlMatch);
                NSData *matchHtmlData = [NSData dataWithContentsOfURL:urlMatch];

            //    [match readMatch:matchLink];
                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

                TopPageVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"TopPageVC"];
                [self.navigationController pushViewController:vc animated:NO];
                return;

        }
       case ROLL:
        {
#pragma mark - Button Roll
            DGButton *buttonRoll = [[DGButton alloc] initWithFrame:CGRectMake((actionView.frame.size.width/2) - 50, (actionView.frame.size.height/2) -40, 100, 35)];
            [buttonRoll setTitle:@"Roll Dice" forState: UIControlStateNormal];
            [buttonRoll addTarget:self action:@selector(actionRoll) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonRoll];
            break;
        }
        case ROLL_DOUBLE:
        {
#pragma mark - Button Roll Double
            DGButton *buttonRoll = [[DGButton alloc] initWithFrame:CGRectMake(10, 10, 100, 35)];
            [buttonRoll setTitle:@"Roll Dice" forState: UIControlStateNormal];
            [buttonRoll addTarget:self action:@selector(actionRoll) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonRoll];
 
            DGButton *buttonDouble = [[DGButton alloc] initWithFrame:CGRectMake(10,  buttonRoll.frame.origin.y + 100 , 100, 35)];
            [buttonDouble setTitle:@"Double" forState: UIControlStateNormal];
            [buttonDouble addTarget:self action:@selector(actionDouble) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonDouble];

            NSMutableArray *attributesArray = [self.actionDict objectForKey:@"attributes"];
            if(attributesArray.count == 3)
            {
                UISwitch *verifyDouble = [[UISwitch alloc] initWithFrame: CGRectMake(120, buttonDouble.frame.origin.y + 4, 50, 35)];
                [verifyDouble addTarget: self action: @selector(actionVerifyDouble:) forControlEvents:UIControlEventValueChanged];
                verifyDouble = [design makeNiceSwitch:verifyDouble];
                [actionView addSubview: verifyDouble];
                
                UILabel *verifyDoubleText = [[UILabel alloc] initWithFrame:CGRectMake(120 + 60, buttonDouble.frame.origin.y,100, 35)];
                verifyDoubleText.text = @"Verify";
                [actionView addSubview: verifyDoubleText];
            }
            break;
        }
        case ACCEPT_DECLINE:
        {
#pragma mark - Button Accept Pass
            DGButton *buttonAccept = [[DGButton alloc] initWithFrame:CGRectMake(10, 10, 100, 35)];
            [buttonAccept setTitle:@"Accept" forState: UIControlStateNormal];
            [buttonAccept addTarget:self action:@selector(actionTake) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonAccept];
            
            DGButton *buttonPass = [[DGButton alloc] initWithFrame:CGRectMake(10,  buttonAccept.frame.origin.y + 100 , 100, 35)];
            [buttonPass setTitle:@"Decline" forState: UIControlStateNormal];
            [buttonPass addTarget:self action:@selector(actionPass) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonPass];
            
            NSMutableArray *attributesArray = [self.actionDict objectForKey:@"attributes"];
            if(attributesArray.count > 2)
            {
                for(NSDictionary * dict in attributesArray)
                {
                    if([[dict objectForKey:@"name"]isEqualToString:@"verify"])
                    {
                        if([[dict objectForKey:@"value"]isEqualToString:@"Accept"])
                        {
                            UISwitch *verifyAccept = [[UISwitch alloc] initWithFrame: CGRectMake(120, buttonAccept.frame.origin.y + 4, 50, 35)];
                            [verifyAccept addTarget: self action: @selector(actionVerifyAccept:) forControlEvents:UIControlEventValueChanged];
                            verifyAccept = [design makeNiceSwitch:verifyAccept];
                            [actionView addSubview: verifyAccept];
            
                            UILabel *verifyAcceptText = [[UILabel alloc] initWithFrame:CGRectMake(120 + 60, buttonAccept.frame.origin.y,100, 35)];
                            verifyAcceptText.text = @"Verify";
                            [actionView addSubview: verifyAcceptText];
                        }
                        if([[dict objectForKey:@"value"]isEqualToString:@"Decline"])
                        {
                            UISwitch *verifyDecline = [[UISwitch alloc] initWithFrame: CGRectMake(120, buttonPass.frame.origin.y + 4, 50, 35)];
                            [verifyDecline addTarget: self action: @selector(actionVerifyDecline:) forControlEvents:UIControlEventValueChanged];
                            verifyDecline = [design makeNiceSwitch:verifyDecline];
                            [actionView addSubview: verifyDecline];
                            
                            UILabel *verifyDeclineText = [[UILabel alloc] initWithFrame:CGRectMake(120 + 60, buttonPass.frame.origin.y,100, 35)];
                            verifyDeclineText.text = @"Verify";
                            [actionView addSubview: verifyDeclineText];
                        }

                    }
                }
            }
            break;
        }
       case SWAP_DICE:
        {
#pragma mark - Button Swap Dice
            DGButton *buttonSwap = [[DGButton alloc] initWithFrame:CGRectMake((actionView.frame.size.width/2) - 50, (actionView.frame.size.height/2) -40, 100, 35)];
            [buttonSwap setTitle:@"Swap Dice" forState: UIControlStateNormal];
            [buttonSwap addTarget:self action:@selector(actionSwap) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonSwap];
            break;
        }
        case GREEDY:
        {
#pragma mark - Submit Greedy Bearoff
            DGButton *buttonGreedy = [[DGButton alloc] initWithFrame:CGRectMake((actionView.frame.size.width/2) - 100, (actionView.frame.size.height/2) -40, 200, 35)];
            [buttonGreedy setTitle:@"Submit Greedy Bearoff" forState: UIControlStateNormal];
            [buttonGreedy addTarget:self action:@selector(actionGreedy) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonGreedy];
            break;
        }
        case UNDO_MOVE:
        {
#pragma mark - Button Undo Move
            DGButton *buttonUndoMove = [[DGButton alloc] initWithFrame:CGRectMake((actionView.frame.size.width/2) - 50, (actionView.frame.size.height/2) -40, 100, 35)];
            [buttonUndoMove setTitle:@"Undo Move" forState: UIControlStateNormal];
            [buttonUndoMove addTarget:self action:@selector(actionUnDoMove) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonUndoMove];
            break;
        }
        case SUBMIT_MOVE:
        {
#pragma mark - Button Submit Move
            DGButton *buttonSubmitMove = [[DGButton alloc] initWithFrame:CGRectMake((actionView.frame.size.width/2) - 50, 10, 100, 35)];
            [buttonSubmitMove setTitle:@"Submit Move" forState: UIControlStateNormal];
            [buttonSubmitMove addTarget:self action:@selector(actionSubmitMove) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonSubmitMove];
            
            DGButton *buttonUndoMove = [[DGButton alloc] initWithFrame:CGRectMake((actionView.frame.size.width/2) - 50, (actionView.frame.size.height/2) -40, 100, 35)];
            [buttonUndoMove setTitle:@"Undo Move" forState: UIControlStateNormal];
            [buttonUndoMove addTarget:self action:@selector(actionUnDoMove) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonUndoMove];
            break;
        }
        case SUBMIT_FORCED_MOVE:
        {
#pragma mark - Button Submit Forced Move
            DGButton *buttonSubmitMove = [[DGButton alloc] initWithFrame:CGRectMake((actionView.frame.size.width/2) - 75, 50, 150, 35)];
            [buttonSubmitMove setTitle:@"Submit Forced Move" forState: UIControlStateNormal];
            [buttonSubmitMove addTarget:self action:@selector(actionSubmitForcedMove) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonSubmitMove];
            break;
        }
        case CHAT:
        {
#pragma mark - CHAT
            // schieb den chatView in den sichtbaren Bereich
            CGRect frame = self.chatView.frame;
            frame.origin.x = 185;
            frame.origin.y = actionView.frame.origin.y-85;
            self.chatView.frame = frame;
            [self.view bringSubviewToFront:self.chatView ];
            self.opponentChat.text = [self.boardDict objectForKey:@"chat"];
            if([self.opponentChat.text length] == 0)
            {
                // opponentChat nicht anzeigen
                frame = self.opponentChat.frame;
                float opponentChatHoehe = self.opponentChat.frame.size.height;
                frame.size.height = 0;
                self.opponentChat.frame = frame;
                frame = self.chatView.frame;
                frame.origin.y += opponentChatHoehe;
                frame.size.height -= opponentChatHoehe;
                self.chatView.frame = frame;
                frame = self.playerChat.frame;
                frame.origin.y -= opponentChatHoehe;
                self.playerChat.frame = frame;

                frame = self.NextButtonOutlet.frame;
                frame.origin.y -= opponentChatHoehe;
                self.NextButtonOutlet.frame = frame;

                frame = self.ToTopOutlet.frame;
                frame.origin.y -= opponentChatHoehe;
                self.ToTopOutlet.frame = frame;
            }
            else
            {
                // opponentChat anzeigen
                self.NextButtonOutlet.frame = self.chatNextButtonFrame;
                self.ToTopOutlet.frame      = self.chatTopPageButtonFrame;
                self.opponentChat.frame     = self.opponentChatViewFrame;
                self.chatView.frame         = self.chatViewFrameSave;
                self.playerChat.frame       = self.playerChatViewFrame;
            }

            frame = self.chatView.frame;
            frame.origin.x = boardView.frame.origin.x + ((boardView.frame.size.width - self.chatView.frame.size.width) / 2);
            frame.origin.y = boardView.frame.origin.y + ((boardView.frame.size.height - self.chatView.frame.size.height) / 2);
            self.chatView.frame = frame;

            self.playerChat.text = @"you may chat here";
            NSMutableArray *attributesArray = [self.actionDict objectForKey:@"attributes"];
            BOOL isCheckbox = FALSE;
            for(NSMutableDictionary *dict in attributesArray)
            {
                if([[dict objectForKey:@"type"] isEqualToString:@"checkbox"])
                {
                    isCheckbox = TRUE;;
                }
            }
            if(!isCheckbox)
            {
                // schiebe switch und Text weg
                frame = self.quoteSwitch.frame;
                frame.origin.x = 9999;
                frame.origin.y = 9999;
                self.quoteSwitch.frame = frame;
                self.quoteMessage.frame = frame;
            }
            else
            {
                self.quoteSwitch.frame = self.quoteSwitchFrame;
                self.quoteMessage.frame = self.quoteMessageFrame;
            }
            self.quoteSwitch = [design makeNiceSwitch:self.quoteSwitch];
            self.chatView.layer.cornerRadius = 14.0f;
            self.chatView.layer.masksToBounds = YES;

            self.chatViewFrame = self.chatView.frame; // position merken um bei keyboard reinfahren view zu verschieben und wieder an die richtige Stelle zurück
            break;
        }
        case ONLY_MESSAGE:
        {
//            XLog(@"ONLY_MESSAGE");
            break;
        }
        default:
        {
            XLog(@"Hier sollte das Programm nie hin kommen %@",self.actionDict);
            [self errorAction:0];
            break;
        }
    }
    
    if([[self.actionDict objectForKey:@"Message"] length] != 0)
    {
        UILabel *messageText = [[UILabel alloc] initWithFrame:CGRectMake(10,
                                                                         actionView.frame.size.height - 40 - 10 - 40,
                                                                         actionView.frame.size.width - 20,
                                                                         35)];
        messageText.text = [self.actionDict objectForKey:@"Message"];
        messageText.textAlignment = NSTextAlignmentCenter;
        messageText.textColor   = [UIColor colorNamed:@"ColorSwitch"];
        
        [actionView addSubview: messageText];

    }

#pragma mark - Button Skip Game
    DGButton *buttonSkipGame = [[DGButton alloc] initWithFrame:CGRectMake((actionView.frame.size.width/2) - 50, actionView.frame.size.height - 45, 100, 35)];
    [buttonSkipGame setTitle:@"Skip Game" forState: UIControlStateNormal];
    [buttonSkipGame addTarget:self action:@selector(actionSkipGame) forControlEvents:UIControlEventTouchUpInside];
    [actionView addSubview:buttonSkipGame];
    UIView *linie = [[UIView alloc] initWithFrame:CGRectMake(5, actionView.frame.size.height - 40 - 10, actionView.frame.size.width - 10, 1)];
    linie.backgroundColor = [UIColor blackColor];
    [actionView addSubview:linie];


}

#pragma mark - actions
- (void)actionSubmitMove
{
    NSMutableArray *attributesArray = [self.actionDict objectForKey:@"attributes"];
    NSMutableDictionary *dict = attributesArray[0];

    matchLink = [NSString stringWithFormat:@"%@?submit=Submit%%20Move&move=%@", [self.actionDict objectForKey:@"action"], [dict objectForKey:@"value"]];
    [self showMatch];
}
- (void)actionSubmitForcedMove
{
    //NSMutableArray *attributesArray = [self.actionDict objectForKey:@"attributes"];
    //NSMutableDictionary *dict = attributesArray[0];
    
    matchLink = [NSString stringWithFormat:@"%@?submit=Submit%%20Forced%%20Move", [self.actionDict objectForKey:@"action"]];
    [self showMatch];
}

- (void)actionGreedy
{
    NSMutableArray *attributesArray = [self.actionDict objectForKey:@"attributes"];
    NSMutableDictionary *dict = attributesArray[0];
    
    matchLink = [NSString stringWithFormat:@"%@?submit=Submit%%20Greedy%%20Bearoff&move=%@", [self.actionDict objectForKey:@"action"], [dict objectForKey:@"value"]];
    [self showMatch];
}

- (void)actionUnDoMove
{
    matchLink = [self.actionDict objectForKey:@"UndoMove"];
    [self showMatch];
}

- (void)actionSwap
{
    matchLink = [self.actionDict objectForKey:@"SwapDice"];
    [self showMatch];
}

- (void)actionVerifyDouble:(id)sender
{
    self.verifiedDouble = [(UISwitch *)sender isOn];
}
- (void)actionVerifyAccept:(id)sender
{
    self.verifiedTake = [(UISwitch *)sender isOn];
}
- (void)actionVerifyDecline:(id)sender
{
    self.verifiedPass = [(UISwitch *)sender isOn];
}

- (void)actionRoll
{
    matchLink = [NSString stringWithFormat:@"%@?submit=Roll%%20Dice", [self.actionDict objectForKey:@"action"]];
    [self showMatch];
}
- (void)actionDouble
{
    NSMutableArray *attributesArray = [self.actionDict objectForKey:@"attributes"];
    if(attributesArray.count == 3)
    {
        if(self.verifiedDouble)
        {
            matchLink = [NSString stringWithFormat:@"%@?submit=Double&verify=Double", [self.actionDict objectForKey:@"action"]];
            [self showMatch];
        }
        else
        {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Information"
                                         message:@"Previous move not verified!"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"OK"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {

                                        }];
            
            [alert addAction:yesButton];
            
            [self presentViewController:alert animated:YES completion:nil];

        }
    }
    else
    {
        matchLink = [NSString stringWithFormat:@"%@?submit=Double", [self.actionDict objectForKey:@"action"]];
        [self showMatch];
    }
}

- (void)actionTake
{
    NSMutableArray *attributesArray = [self.actionDict objectForKey:@"attributes"];
    BOOL verify = FALSE;
    if(attributesArray.count > 2)
    {
        for(NSDictionary * dict in attributesArray)
        {
            if([[dict objectForKey:@"name"]isEqualToString:@"verify"])
            {
                if([[dict objectForKey:@"value"]isEqualToString:@"Accept"])
                {
                    verify = TRUE;
                }
            }
        }
    }
    if(verify)
    {
        if(self.verifiedTake)
        {
            matchLink = [NSString stringWithFormat:@"%@?submit=Accept&verify=Accept", [self.actionDict objectForKey:@"action"]];
            [self showMatch];
        }
        else
        {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Information"
                                         message:@"Previous move not verified!"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"OK"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            
                                        }];
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else
    {
        matchLink = [NSString stringWithFormat:@"%@?submit=Accept", [self.actionDict objectForKey:@"action"]];
        [self showMatch];
    } 
}
- (void)actionPass
{
    NSMutableArray *attributesArray = [self.actionDict objectForKey:@"attributes"];
    BOOL verify = FALSE;
    if(attributesArray.count > 2)
    {
        for(NSDictionary * dict in attributesArray)
        {
            if([[dict objectForKey:@"name"]isEqualToString:@"verify"])
            {
                if([[dict objectForKey:@"value"]isEqualToString:@"Decline"])
                {
                    verify = TRUE;
                }
            }
        }
    }
    if(verify)
    {
        if(self.verifiedPass)
        {
            matchLink = [NSString stringWithFormat:@"%@?submit=Decline&verify=Decline", [self.actionDict objectForKey:@"action"]];
            [self showMatch];
        }
        else
        {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Information"
                                         message:@"Previous move not verified!"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"OK"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            
                                        }];
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else
    {
        matchLink = [NSString stringWithFormat:@"%@?submit=Decline", [self.actionDict objectForKey:@"action"]];
        [self showMatch];
    }
}

- (void)actionNext
{
    matchLink = [NSString stringWithFormat:@"%@?submit=Next", [self.actionDict objectForKey:@"action"]];
    [self showMatch];
}
- (void)actionNext__
{
    matchLink = [NSString stringWithFormat:@"%@?submit=Next", [self.actionDict objectForKey:@"Next Game>>"]];
    [self showMatch];
}

- (void)actionSkipGame
{
    matchLink = [self.actionDict objectForKey:@"SkipGame"];
    [self showMatch];
}

#pragma mark - player details

- (void)playerLists:(UIButton*)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PlayerLists *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"PlayerLists"];

    [self.navigationController pushViewController:vc animated:NO];
}

- (void)opponent:(UIButton*)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Player *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"PlayerVC"];
    vc.name   = (NSString *)[sender.layer valueForKey:@"name"];

    [self.navigationController pushViewController:vc animated:NO];

}

#pragma mark - chat Buttons

- (IBAction)chatTransparent:(id)sender
{

    if(self.chatIsTransparent)
    {
        self.chatIsTransparent = FALSE;
        self.chatView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
        UIImage *image = [[UIImage imageNamed:@"Brille"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.transparentButton setImage:image forState:UIControlStateNormal];
        self.transparentButton.tintColor = [UIColor colorNamed:@"ColorSwitch"];
    }
    else
    {
        self.chatIsTransparent = TRUE;
        self.chatView.backgroundColor = [UIColor clearColor];
        UIImage *image = [[UIImage imageNamed:@"Brille_voll"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.transparentButton setImage:image forState:UIControlStateNormal];
        self.transparentButton.tintColor = [UIColor colorNamed:@"ColorSwitch"];
    }


}
- (IBAction)chatNextButton:(id)sender
{
    
    if([self.playerChat.text isEqualToString:@"you may chat here"])
        self.playerChat.text = @"";

    NSMutableArray *attributesArray = [self.actionDict objectForKey:@"attributes"];
    NSString *checkbox = @"";
    for(NSMutableDictionary *dict in attributesArray)
    {
        if([[dict objectForKey:@"type"] isEqualToString:@"checkbox"])
        {
            if([self.quoteSwitch isOn])
                checkbox = @"&quote=on";
            else
                checkbox = @"&quote=off";
       }
    }

    NSString *chatString = [tools cleanChatString:self.playerChat.text];

    matchLink = [NSString stringWithFormat:@"%@?submit=Next%%20Game&commit=1%@&chat=%@",
                 [self.actionDict objectForKey:@"action"],
                 checkbox,
                 chatString];
    
//    schicke matchlink hier schon ab, wenn sort = round oder length
//    hole erstes element aus dem Array
//    baue daraus matchLink
//    lösche erstes elemnt aus dem array
   
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] > 3)
    {
        NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",matchLink]];
        //    XLog(@"%@",urlMatch);
        NSError *error = nil;
        [NSData dataWithContentsOfURL:urlMatch options:NSDataReadingUncached error:&error];
        if(error)
            XLog(@"error %@ %@",error ,urlMatch);
        if(topPageArray.count > 1)
        {
            [topPageArray removeObjectAtIndex:0];
            NSArray *zeile = topPageArray[0];
            NSDictionary *match = zeile[8];
            matchLink = [match objectForKey:@"href"];
        }
    }
    [self showMatch];

}
- (IBAction)chatTopButton:(id)sender
{
    if([self.playerChat.text isEqualToString:@"you may chat here"])
        self.playerChat.text = @"";

    NSMutableArray *attributesArray = [self.actionDict objectForKey:@"attributes"];
    NSString *checkbox = @"";
    for(NSMutableDictionary *dict in attributesArray)
    {
        if([[dict objectForKey:@"type"] isEqualToString:@"checkbox"])
        {
            if([self.quoteSwitch isOn])
                checkbox = @"&quote=on";
            else
                checkbox = @"&quote=off";
        }
    }
    NSString *chatString = [tools cleanChatString:self.playerChat.text];

    matchLink = [NSString stringWithFormat:@"%@?submit=Top%%20Page&commit=1%@&chat=%@",
                 [self.actionDict objectForKey:@"action"],
                 checkbox,
                 chatString];

    [self showMatch];

}

#pragma mark - analyzeAction
- (int) analyzeAction
{
    self.verifiedDouble = FALSE;
    self.verifiedTake   = FALSE;
    self.verifiedPass   = FALSE;

    if([self isChat])
        return CHAT;

    NSMutableArray *attributesArray = [self.actionDict objectForKey:@"attributes"];
    if(attributesArray.count == 1)
    {
        NSMutableDictionary *dict = attributesArray[0];
        if([[dict objectForKey:@"value"] isEqualToString:@"Next"])
            return NEXT;
        if([[dict objectForKey:@"value"] isEqualToString:@"1"])
            return NEXTGAME;
        if([[dict objectForKey:@"value"] isEqualToString:@"Roll Dice"])
            return ROLL;
        if([[dict objectForKey:@"value"] isEqualToString:@"Submit Forced Move"])
            return SUBMIT_FORCED_MOVE;
    }
    if(attributesArray.count > 1)
    {
        NSMutableDictionary *dict = attributesArray[0];
        if([[dict objectForKey:@"value"] isEqualToString:@"Roll Dice"])
        {
            dict = attributesArray[1];
            if([[dict objectForKey:@"value"] isEqualToString:@"Double"])
                return ROLL_DOUBLE;
        }
        if([[dict objectForKey:@"value"] isEqualToString:@"Accept"])
        {
            dict = attributesArray[1];
            if([[dict objectForKey:@"value"] isEqualToString:@"Decline"])
                return ACCEPT_DECLINE;
        }
        dict = attributesArray[1];
        if([[dict objectForKey:@"value"] isEqualToString:@"Submit Move"])
            return SUBMIT_MOVE;
        if([[dict objectForKey:@"value"] isEqualToString:@"Submit Greedy Bearoff"])
            return GREEDY;
   }
    
    if([[self.actionDict objectForKey:@"SwapDice"] length] != 0)
        return SWAP_DICE;
    if([[self.actionDict objectForKey:@"UndoMove"] length] != 0)
        return UNDO_MOVE;
    if([[self.actionDict objectForKey:@"Next Game>>"] length] != 0)
        return NEXT__;

    if(attributesArray == nil)
    {
        if([[self.actionDict objectForKey:@"Message"] length] != 0)
            return ONLY_MESSAGE;
    }
    XLog(@"unknown action %@", self.actionDict);
    return 0;
}
-(BOOL)isChat
{
    self.isChatView = TRUE;
    NSString *chatString = [self.boardDict objectForKey:@"chat"];
    if(chatString.length > 0)
        return TRUE;

    NSString *contentString = [self.actionDict objectForKey:@"content"];
    if(contentString.length > 0)
    {
        if([contentString rangeOfString:@"You may chat with"].location != NSNotFound)
            return TRUE;
        if([contentString rangeOfString:@"says"].location != NSNotFound)
            return TRUE;
    }
    self.isChatView = FALSE;
    return FALSE;
}
- (void)cellTouched:(UIGestureRecognizer *)gesture
{
    CGPoint tapLocation = [gesture locationInView:self.view];
    for(NSMutableDictionary *dict in self.moveArray)
    {
        CGRect frame = CGRectMake([[dict objectForKey:@"x"] floatValue],
                                  [[dict objectForKey:@"y"] floatValue],
                                  [[dict objectForKey:@"w"] floatValue],
                                  [[dict objectForKey:@"h"] floatValue]);
        if( CGRectContainsPoint(frame, tapLocation) )
        {
            if([[dict objectForKey:@"href"] length] != 0)
            {
                matchLink = [dict objectForKey:@"href"];
                [self showMatch];
            }
        }
    }
}

#pragma mark - textField
-(BOOL)textViewShouldBeginEditing:(UITextView *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    if([self.playerChat.text isEqualToString:@"you may chat here"])
    {
        self.playerChat.text = @"";
        self.answerMessage.text = @"";
    }
    if (!([self.finishedMatchChat.text rangeOfString:@"You may chat with"].location == NSNotFound))
    {
        self.finishedMatchChat.text = @"";
    }

    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self.playerChat endEditing:YES];
    [self.answerMessage endEditing:YES];
    return YES;
}


- (void)keyboardDidShow:(NSNotification *)notification
{
    if(self.isChatView)
    {
        CGRect frame = self.chatViewFrame;
        frame.origin.y -= 330;
        self.chatView.frame = frame;
//        XLog(@"keyboardDidShow %f",self.chatView.frame.origin.y );
    }
    if(self.isFinishedMatch)
    {
        CGRect frame = self.finishedMatchFrame;
        frame.origin.y -= 330;
        self.finishedMatchView.frame = frame;
    }
    if(self.isMessageAnswerView)
    {
        CGRect frame = self.answerMessageFrameSave;
        frame.origin.y = 10;
        self.messageAnswerView.frame = frame;
    }
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    if(self.isChatView)
    {
        self.chatView.frame = self.chatViewFrame;
//        XLog(@"keyboardDidHide %f",self.chatView.frame.origin.y );
    }
    if(self.isFinishedMatch)
    {
        self.finishedMatchView.frame = self.finishedMatchFrame;
    }
    if(self.isMessageAnswerView)
    {
        self.messageAnswerView.frame = self.answerMessageFrameSave;
    }

}

#pragma mark - Email
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (error)
    {
        XLog(@"Fehler MFMailComposeViewController: %@", error);
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.presentingPopoverController dismissPopoverAnimated:YES];
    }
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - errorAction

-(void)errorAction:(int)typ
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"oops"
                                 message:@"something unexpected happend! Better go to TopPage"
                                 preferredStyle:UIAlertControllerStyleAlert];

    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"Oooops"];
    [title addAttribute:NSFontAttributeName
                  value:[UIFont systemFontOfSize:30.0]
                  range:NSMakeRange(0, [title length])];
    [alert setValue:title forKey:@"attributedTitle"];

    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"-%d-\n\nSomething unexpected happend!  \n\n Please send an Email to support.\n\n\nOr just go to the TopPage.", typ]];
    [message addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:20.0]
                    range:NSMakeRange(0, [message length])];
    [alert setValue:message forKey:@"attributedMessage"];

    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Top Page"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

                                    TopPageVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"TopPageVC"];

                                    [self.navigationController pushViewController:vc animated:NO];
                                }];

    UIAlertAction* mailButton = [UIAlertAction
                                 actionWithTitle:@"Mail to Support"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     if (![MFMailComposeViewController canSendMail])
                                     {
                                         XLog(@"Fehler: Mail kann nicht versendet werden");
                                         return;
                                     }
                                     NSString *betreff = [NSString stringWithFormat:@"-%d- Something unexpected happend!", typ];

                                     NSString *text = @"";
                                     NSString *emailText = @"";
                                     text = [NSString stringWithFormat:@"Hallo Support-Team of %@, <br><br> ", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
                                     emailText = [NSString stringWithFormat:@"%@%@", emailText, text];

                                     text = [NSString stringWithFormat:@"my Data: <br> "];
                                     emailText = [NSString stringWithFormat:@"%@%@", emailText, text];

                                     text = [NSString stringWithFormat:@"App <b>%@</b> <br> ", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
                                     emailText = [NSString stringWithFormat:@"%@%@", emailText, text];

                                     text = [NSString stringWithFormat:@"Version %@ Build %@", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleVersion"]];
                                     emailText = [NSString stringWithFormat:@"%@%@", emailText, text];

                                     text = [NSString stringWithFormat:@"Build from <b>%@</b> <br> ", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"DGBuildDate"] ];

                                     emailText = [NSString stringWithFormat:@"%@%@", emailText, text];

                                     text = [NSString stringWithFormat:@"Device <b>%@</b> IOS <b>%@</b><br> ", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion]];
                                     emailText = [NSString stringWithFormat:@"%@%@", emailText, text];

                                     text = [NSString stringWithFormat:@"<br> <br>my Name on DailyGammon <b>%@</b><br><br>",[[NSUserDefaults standardUserDefaults] valueForKey:@"user"]];
                                     emailText = [NSString stringWithFormat:@"%@%@", emailText, text];


                                     MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
                                     emailController.mailComposeDelegate = self;
                                     NSArray *toSupport = [NSArray arrayWithObjects:@"dg@hape42.de",nil];

                                     [emailController setToRecipients:toSupport];
                                     [emailController setSubject:betreff];
                                     [emailController setMessageBody:emailText isHTML:YES];
                                     NSString *dictPath = @"";
                                     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                                          NSUserDomainMask, YES);
                                     if([paths count] > 0)
                                     {
                                         switch (typ)
                                         {
                                             case 0:
                                             {
                                                 dictPath = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"actionDict.txt"];
                                                 [[NSString stringWithFormat:@"%@",self.actionDict] writeToFile:dictPath atomically:YES];
                                                 NSData *myData = [NSData dataWithContentsOfFile:dictPath];
                                                 [emailController addAttachmentData:myData mimeType:@"text/plain" fileName:@"actionDict.txt"];
                                                 break;
                                             }
                                             case 1:
                                             case 2:
                                             {
                                                 dictPath = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"boardDict.txt"];
                                                 [[NSString stringWithFormat:@"%@",self.boardDict] writeToFile:dictPath atomically:YES];
                                                 NSData *myData = [NSData dataWithContentsOfFile:dictPath];
                                                 [emailController addAttachmentData:myData mimeType:@"text/plain" fileName:@"boardDict.txt"];
                                                 break;
                                             }
                                         }
                                     }
                                     NSData *myData = [NSData dataWithContentsOfFile:dictPath];
                                     [emailController addAttachmentData:myData mimeType:@"text/plain" fileName:@"actionDict.txt"];

                                     [self presentViewController:emailController animated:YES completion:NULL];

                                 }];

    [alert addAction:yesButton];
    [alert addAction:mailButton];

    [self presentViewController:alert animated:YES completion:nil];


}
#pragma mark - finishedMatch
- (void)finishedMatchView:(NSMutableDictionary *)finishedMatchDict
{
    // ist es ein "finished match" ohne chat?

    if (!([[self.boardDict objectForKey:@"htmlString"] rangeOfString:@"<input type=hidden name=commit value=1>"].location == NSNotFound))
    {
        NSMutableDictionary *finishedMatchDict = [self.boardDict objectForKey:@"finishedMatch"] ;
        NSString *href = @"";
        for(NSDictionary * dict in [finishedMatchDict objectForKey:@"attributes"])
        {
            href = [dict objectForKey:@"action"];
        }
        matchLink = [NSString stringWithFormat:@"%@?submit=Next%%20Game&commit=1", href];

        [self showMatch];
        return;
    }
    if (!([[self.boardDict objectForKey:@"htmlString"] rangeOfString:@"<u>Score</u>"].location == NSNotFound))
    {
        NSMutableDictionary *finishedMatchDict = [self.boardDict objectForKey:@"finishedMatch"] ;
        NSString *href = @"";
        for(NSDictionary * dict in [finishedMatchDict objectForKey:@"attributes"])
        {
            href = [dict objectForKey:@"action"];
        }
        matchLink = [NSString stringWithFormat:@"%@?submit=Next&commit=1", href];

        [self showMatch];
        return;
    }

    int rand = 10;

    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.finishedMatchView.frame.size.width,  self.finishedMatchView.frame.size.height)];
    
    infoView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;
    infoView.tag = FINISHED_MATCH_VIEW;
    infoView.layer.borderWidth = 1;
    
    [self.view addSubview:self.finishedMatchView];
    
    UILabel * matchName = [[UILabel alloc] initWithFrame:CGRectMake(rand, rand, infoView.layer.frame.size.width - (2 * rand), 80)];
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
    [infoView addSubview:matchName];
    
    UILabel * winner = [[UILabel alloc] initWithFrame:CGRectMake(rand, rand + 80 + rand, infoView.layer.frame.size.width - (2 * rand), 60)];
    winner.textAlignment = NSTextAlignmentLeft;
    attr = [[NSMutableAttributedString alloc] initWithString:[finishedMatchDict objectForKey:@"winnerName"]];
    [attr addAttribute:NSFontAttributeName
                 value:[UIFont systemFontOfSize:30.0]
                 range:NSMakeRange(0, [attr length])];
    [winner setAttributedText:attr];
    winner.adjustsFontSizeToFitWidth = YES;
    winner.numberOfLines = 0;
    winner.minimumScaleFactor = 0.5;
    winner.adjustsFontSizeToFitWidth = YES;
    [infoView addSubview:winner];

    UILabel * length = [[UILabel alloc] initWithFrame:CGRectMake(rand, rand + 80 + rand + 60 + rand, infoView.layer.frame.size.width - (2 * rand), 30)];
    length.textAlignment = NSTextAlignmentLeft;
    NSArray *lengthArray = [finishedMatchDict objectForKey:@"matchLength"];
    length.text = [NSString stringWithFormat:@"%@ %@",lengthArray[0], lengthArray[1]];
    [infoView addSubview:length];

    NSArray *playerArray = [finishedMatchDict objectForKey:@"matchPlayer"];

    UILabel * player1Name  = [[UILabel alloc] initWithFrame:CGRectMake(rand, rand + 80 + rand + 60 + rand + 30 + rand , 150, 30)];
    UILabel * player1Score = [[UILabel alloc] initWithFrame:CGRectMake(rand + player1Name.layer.frame.size.width, rand + 80 + rand + 60 + rand + 30 + rand , 100, 30)];
    player1Name.textAlignment = NSTextAlignmentLeft;
    player1Name.text = playerArray[0];
    [infoView addSubview:player1Name];
    player1Score.textAlignment = NSTextAlignmentRight;
    player1Score.text = playerArray[1];
    [infoView addSubview:player1Score];

    UILabel * player2Name  = [[UILabel alloc] initWithFrame:CGRectMake(rand, rand + 80 + rand + 60 + rand + 30 + rand + 30 , 150, 30)];
    UILabel * player2Score = [[UILabel alloc] initWithFrame:CGRectMake(rand + player2Name.layer.frame.size.width, player2Name.layer.frame.origin.y, 100, 30)];
    player2Name.textAlignment = NSTextAlignmentLeft;
    player2Name.text = playerArray[2];
    [infoView addSubview:player2Name];
    player2Score.textAlignment = NSTextAlignmentRight;
    player2Score.text = playerArray[3];
    [infoView addSubview:player2Score];

    self.finishedMatchChat  = [[UITextView alloc] initWithFrame:CGRectMake(rand, player2Name.layer.frame.origin.y + 40 , infoView.layer.frame.size.width - (2 * rand), infoView.layer.frame.size.height - (player2Name.layer.frame.origin.y + 100 ))];
    self.finishedMatchChat.textAlignment = NSTextAlignmentLeft;
    NSArray *chatArray = [finishedMatchDict objectForKey:@"chat"];
    NSString *chatString = @"";
    for( NSString *chatZeile in chatArray)
    {
        if(![chatZeile isEqual:[NSString stringWithFormat:@"\nYou may chat with %@ here:\n\n ", playerArray[2]]])
            chatString = [NSString stringWithFormat:@"%@ %@", chatString, chatZeile];
    }
    self.finishedMatchChat.text = chatString;
    self.finishedMatchChat.editable = YES;
    [self.finishedMatchChat setDelegate:self];

    [self.finishedMatchChat setFont:[UIFont systemFontOfSize:20]];
    [infoView addSubview:self.finishedMatchChat];

    DGButton *buttonNext = [[DGButton alloc] initWithFrame:CGRectMake(50, infoView.layer.frame.size.height - 50, 100, 35)];
    [buttonNext setTitle:@"Next Game" forState: UIControlStateNormal];
    [buttonNext addTarget:self action:@selector(actionNextFinishedMatch) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:buttonNext];
 
    DGButton *buttonToTop = [[DGButton alloc] initWithFrame:CGRectMake(50 + 100 + 50, infoView.layer.frame.size.height - 50, 100, 35)];
    [buttonToTop setTitle:@"To Top" forState: UIControlStateNormal];
    [buttonToTop addTarget:self action:@selector(actionToTopFinishedMatch) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:buttonToTop];

    [self.finishedMatchView addSubview:infoView];
    return;
}
- (void)actionNextFinishedMatch
{

    self.finishedMatchView.frame = self.finishedMatchFrame;

    NSMutableDictionary *finishedMatchDict = [self.boardDict objectForKey:@"finishedMatch"] ;
    NSString *href = @"";
    for(NSDictionary *dict in [finishedMatchDict objectForKey:@"attributes"])
    {
        href = [dict objectForKey:@"action"];
    }
    UIView *removeView;
    while((removeView = [self.view viewWithTag:FINISHED_MATCH_VIEW]) != nil)
    {
        [removeView removeFromSuperview];
    }

    NSString *chatString = [tools cleanChatString:self.finishedMatchChat.text];

    if([href isEqualToString:@""])
        matchLink = @"/bg/nextgame";
    else
        matchLink = [NSString stringWithFormat:@"%@?submit=Next%%20Game&commit=1&chat=%@", href, chatString];
    [self showMatch];
}
- (void)actionToTopFinishedMatch
{
    self.finishedMatchView.frame = self.finishedMatchFrame;

    NSMutableDictionary *finishedMatchDict = [self.boardDict objectForKey:@"finishedMatch"] ;
    NSString *href = @"";
    for(NSDictionary * dict in [finishedMatchDict objectForKey:@"attributes"])
    {
        href = [dict objectForKey:@"action"];
    }
    matchLink = [NSString stringWithFormat:@"%@?submit=To%%20Top&commit=1", href];
    NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",matchLink]];
    
    NSError *error = nil;
    NSStringEncoding encoding = 0;
    self.matchString = [[NSString alloc] initWithContentsOfURL:urlMatch
                                                       usedEncoding:&encoding
                                                              error:&error];
    [self topPageVC];
}

#pragma mark - invite Match
- (void)inviteMatchView:(NSMutableDictionary *)finishedMatchDict
{
    int rand = 10;
    int maxBreite = [UIScreen mainScreen].bounds.size.width;
    int maxHoehe  = [UIScreen mainScreen].bounds.size.height;
    
    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.finishedMatchView.frame.size.width,  self.finishedMatchView.frame.size.height)];
    
    infoView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;
    infoView.tag = FINISHED_MATCH_VIEW;
    infoView.layer.borderWidth = 1;
    
    [self.view addSubview:self.finishedMatchView];
    
    UILabel * matchName = [[UILabel alloc] initWithFrame:CGRectMake(rand, rand, infoView.layer.frame.size.width - (2 * rand), 80)];
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
    [infoView addSubview:matchName];
    
    UILabel * winner = [[UILabel alloc] initWithFrame:CGRectMake(rand, rand + 80 + rand, infoView.layer.frame.size.width - (2 * rand), 60)];
    winner.textAlignment = NSTextAlignmentLeft;
    attr = [[NSMutableAttributedString alloc] initWithString:[finishedMatchDict objectForKey:@"winnerName"]];
    [attr addAttribute:NSFontAttributeName
                 value:[UIFont systemFontOfSize:30.0]
                 range:NSMakeRange(0, [attr length])];
    [winner setAttributedText:attr];
    winner.adjustsFontSizeToFitWidth = YES;
    winner.numberOfLines = 0;
    winner.minimumScaleFactor = 0.5;
    winner.adjustsFontSizeToFitWidth = YES;
    [infoView addSubview:winner];
    
    UILabel * length = [[UILabel alloc] initWithFrame:CGRectMake(rand, rand + 80 + rand + 60 + rand, infoView.layer.frame.size.width - (2 * rand), 30)];
    length.textAlignment = NSTextAlignmentLeft;
    NSArray *lengthArray = [finishedMatchDict objectForKey:@"matchLength"];
    length.text = [NSString stringWithFormat:@"%@ %@",lengthArray[0], lengthArray[1]];
    [infoView addSubview:length];
    
    NSArray *playerArray = [finishedMatchDict objectForKey:@"matchPlayer"];
    
    UILabel * player1Name  = [[UILabel alloc] initWithFrame:CGRectMake(rand, rand + 80 + rand + 60 + rand + 30 + rand , 150, 30)];
    UILabel * player1Score = [[UILabel alloc] initWithFrame:CGRectMake(rand + player1Name.layer.frame.size.width, rand + 80 + rand + 60 + rand + 30 + rand , 100, 30)];
    player1Name.textAlignment = NSTextAlignmentLeft;
    player1Name.text = playerArray[0];
    [infoView addSubview:player1Name];
    player1Score.textAlignment = NSTextAlignmentRight;
    player1Score.text = playerArray[1];
    [infoView addSubview:player1Score];
    
    UILabel * player2Name  = [[UILabel alloc] initWithFrame:CGRectMake(rand, rand + 80 + rand + 60 + rand + 30 + rand + 30 , 150, 30)];
    UILabel * player2Score = [[UILabel alloc] initWithFrame:CGRectMake(rand + player2Name.layer.frame.size.width, player2Name.layer.frame.origin.y, 100, 30)];
    player2Name.textAlignment = NSTextAlignmentLeft;
    player2Name.text = playerArray[2];
    [infoView addSubview:player2Name];
    player2Score.textAlignment = NSTextAlignmentRight;
    player2Score.text = playerArray[3];
    [infoView addSubview:player2Score];
    
    UITextView *chat  = [[UITextView alloc] initWithFrame:CGRectMake(rand, player2Name.layer.frame.origin.y + 40 , infoView.layer.frame.size.width - (2 * rand), infoView.layer.frame.size.height - (player2Name.layer.frame.origin.y + 100 ))];
    chat.textAlignment = NSTextAlignmentLeft;
    NSArray *chatArray = [finishedMatchDict objectForKey:@"chat"];
    NSString *chatString = @"";
    for( NSString *chatZeile in chatArray)
    {
        chatString = [NSString stringWithFormat:@"%@ %@", chatString, chatZeile];
    }
    chat.text = chatString;
    chat.editable = YES;
    [chat setDelegate:self];
    
    [chat setFont:[UIFont systemFontOfSize:20]];
    [infoView addSubview:chat];
    
    DGButton *buttonNext = [[DGButton alloc] initWithFrame:CGRectMake(50, infoView.layer.frame.size.height - 50, 100, 35)];
    [buttonNext setTitle:@"Next Game" forState: UIControlStateNormal];
    [buttonNext addTarget:self action:@selector(actionNextFinishedMatch) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:buttonNext];
    
    DGButton *buttonToTop = [[DGButton alloc] initWithFrame:CGRectMake(50 + 100 + 50, infoView.layer.frame.size.height - 50, 100, 35)];
    [buttonToTop setTitle:@"To Top" forState: UIControlStateNormal];
    [buttonToTop addTarget:self action:@selector(actionToTopFinishedMatch) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:buttonToTop];
    
    [self.finishedMatchView addSubview:infoView];
    return;
}

#pragma mark - reply message

- (void) actionSendReplay
{
    if([self.answerMessage.text isEqualToString:@"you may chat here"])
        self.answerMessage.text = @"";
    
    NSMutableDictionary *actionDict = [self.boardDict objectForKey:@"messageDict"];
    NSMutableArray *attributesArray = [actionDict objectForKey:@"attributes"];
    NSMutableDictionary *dict = attributesArray[0];

    NSString *chatString = [tools cleanChatString:self.answerMessage.text];

    matchLink = [NSString stringWithFormat:@"%@?submit=Send%%20Reply&text=%@",
                 [dict objectForKey:@"action"],
                 chatString];
    [self showMatch];
}
- (void) actionCancelReplay
{
    self->matchLink = [NSString stringWithFormat:@"/bg/nextgame?submit=Next"];
    [self showMatch];
}

#include "HeaderInclude.h"

@end
