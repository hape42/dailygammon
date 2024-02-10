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

#import "Review.h"
#import "NoBoard.h"

@interface PlayMatch ()

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *matchName;
@property (weak, nonatomic) IBOutlet UILabel *unexpectedMove;
@property (weak, nonatomic) IBOutlet UILabel *makeYourMove;

@property (weak, nonatomic) IBOutlet UIButton *moreButton;

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

@property (weak, nonatomic) IBOutlet UILabel *matchCountLabel;

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

@property (readwrite, retain, nonatomic) NSString *matchString;

@property (assign, atomic) BOOL isChatView;

@property (assign, atomic) unsigned long memory_start;
@property (assign, atomic) BOOL first;

@property (readwrite, retain, nonatomic) DGButton *topPageButton;

@property (assign, atomic) int matchCount;

@end

@implementation PlayMatch

@synthesize design, match, rating, tools;
@synthesize matchLink, isReview;
@synthesize ratingDict;

@synthesize topPageArray;

@synthesize matchTools;

@synthesize menueView;

@synthesize boardView, actionView;
@synthesize zoomFactor;
@synthesize actionViewWidth;

#define BUTTONHEIGHT 35
#define BUTTONWIDTH 80

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

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

    [self.view addSubview:self.matchName];
    
    UITapGestureRecognizer *oneFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTouched:)];
    oneFingerTap.numberOfTapsRequired = 1;
    oneFingerTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:oneFingerTap];

    [self.playerChat setDelegate:self];

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
    
    self.first = TRUE;

    self.matchCount = [[[NSUserDefaults standardUserDefaults] valueForKey:@"matchCount"]intValue];
    [self.matchCountLabel setText:[NSString stringWithFormat:@"%d", self.matchCount]];

    if(isReview)
    {
        self.unexpectedMove.text = @"";
        self.makeYourMove.text = @"";
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self layoutObjects];
    [self drawViewsInSuperView:self.view.frame.size.width andWith:self.view.frame.size.height];

    [self showMatch];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)orientationDidChange:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

    switch (orientation) {
        case UIDeviceOrientationPortrait:
            //NSLog(@"Portrait orientation");
            break;
        case UIDeviceOrientationLandscapeLeft:
            //NSLog(@"Landscape Left orientation");
            break;
        case UIDeviceOrientationLandscapeRight:
            //NSLog(@"Landscape Right orientation");
            break;
        // ... weitere Orientierungen je nach Bedarf
        default:
            break;
    }
    [self drawViewsInSuperView:self.view.frame.size.width andWith:self.view.frame.size.height];

    [self showMatch];

}
- (IBAction)moreAction:(id)sender
{
    if(!menueView)
    {
        menueView = [[MenueView alloc]init];
        menueView.navigationController = self.navigationController;
    }
    [menueView showMenueInView:self.view];
}


- (void) showMatchCount
{
    [self.matchCountLabel setText:[NSString stringWithFormat:@"%d", [[[NSUserDefaults standardUserDefaults] valueForKey:@"matchCount"]intValue]]];
}
-(void)showMatch
{
    [tools matchCount];

    self.isChatView = FALSE;

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

    self.boardDict = [match readMatch:matchLink reviewMatch:isReview];
    
    if([[self.boardDict objectForKey:@"NoBoard"] length] != 0)
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        NoBoard *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"NoBoard"];
        vc.boardDict = self.boardDict;
        [self.navigationController pushViewController:vc animated:NO];
        return;
    }

    if ([[self.boardDict objectForKey:@"htmlString"] containsString:@"cubedr.gif"])
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Double Repeat"
                                     message:@"Unfortunately, this app does not support \"Double Repeat\" matches."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction
                                    actionWithTitle:@"TopPage"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

            TopPageVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"TopPageVC"];
            [self.navigationController pushViewController:vc animated:NO];
                                     }];
 
        [alert addAction:okButton];

        [self presentViewController:alert animated:YES completion:nil];

        return;
    }
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
    
    [self drawPlayingAreas];
    
}

-(void)drawPlayingAreas
{
    self.boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(self.boardSchema < 1) self.boardSchema = 4;

    NSMutableDictionary * returnDict = [matchTools drawBoard:self.boardSchema boardInfo:self.boardDict boardView:boardView zoom:zoomFactor];
    boardView = [returnDict objectForKey:@"boardView"];
    // passe chatView an boardView an
    CGRect frame = self.chatView.frame;
    frame.size.width = boardView.frame.size.width * .8;
    self.chatView.frame = frame;

    self.moveArray = [returnDict objectForKey:@"moveArray"];
        
    UIView *removeView;
    while((removeView = [self.view viewWithTag:BOARD_VIEW]) != nil)
    {
        [removeView removeFromSuperview];
    }

    while((removeView = [self.view viewWithTag:ACTION_VIEW]) != nil)
    {
        for (UIView *subUIView in removeView.subviews)
        {
            for (UIView *subsubUIView in subUIView.subviews)
            {
                [subsubUIView removeFromSuperview];
            }
            [subUIView removeFromSuperview];
        }
        [removeView removeFromSuperview];
    }
    [self.view addSubview:boardView];
   // return;
    returnDict = [matchTools drawActionView:self.boardDict bordView:boardView actionViewWidth:actionViewWidth];
    UIView *actionView = [returnDict objectForKey:@"actionView"];
    UIView *playerView = [returnDict objectForKey:@"playerView"];
    UIView *opponentView = [returnDict objectForKey:@"opponentView"];
  
    UIButton *buttonOpponent = [returnDict objectForKey:@"buttonOpponent"];
    [buttonOpponent addTarget:self action:@selector(opponent:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonPlayer = [returnDict objectForKey:@"buttonPlayer"];
    [buttonPlayer addTarget:self action:@selector(playerLists:) forControlEvents:UIControlEventTouchUpInside];

    while((removeView = [self.view viewWithTag:ACTION_VIEW]) != nil)
    {
        [tools removeAllSubviewsRecursively:removeView];
    }
    [self.view addSubview:actionView];
    [self.view addSubview:playerView];
    [self.view addSubview:opponentView];

    float actionViewHeight  = actionView.layer.frame.size.height - 50 ; // skip Button
    float actionViewWidth = actionView.layer.frame.size.width;

    UIView *upperThird = [[UIView alloc]initWithFrame:CGRectMake(0, 0,  actionViewWidth, actionViewHeight /3)];
//    upperThird.backgroundColor = UIColor.redColor;
//    upperThird.layer.borderWidth = 1;
    [actionView addSubview:upperThird];
    
    UIView *middleThird = [[UIView alloc]initWithFrame:CGRectMake(0, upperThird.frame.origin.y + upperThird.frame.size.height,  actionViewWidth, actionViewHeight /3)];
//    middleThird.backgroundColor = UIColor.yellowColor;
//    middleThird.layer.borderWidth = 1;
    [actionView addSubview:middleThird];
    
    UIView *lowerThird = [[UIView alloc]initWithFrame:CGRectMake(0, middleThird.frame.origin.y + middleThird.frame.size.height,  actionViewWidth, actionViewHeight /3)];
//    lowerThird.backgroundColor = UIColor.greenColor;
//    lowerThird.layer.borderWidth = 1;
    [actionView addSubview:lowerThird];

    int edge = 10;
    float gap = 10;
    float verifyTextWidth = 50;

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
    float switchWidth = 50;
    float buttonLargeWidth = MIN(buttonWidth *2, actionViewWidth - 10);

    self.verifiedDouble = FALSE;
    self.verifiedTake   = FALSE;
    self.verifiedPass   = FALSE;

    float thirdX = (actionViewWidth / 2) - (buttonWidth / 2); // center button
    float thirdXForLargeButton = (actionViewWidth / 2) - (buttonLargeWidth / 2); // center button
    float thirdXwithVerify = (actionViewWidth / 2) - (buttonWidth / 2) - (gap / 2) - (switchWidth / 2) - (gap / 2) - (verifyTextWidth / 2); // center button
    
    float thirdY = (upperThird.frame.size.height / 2) - (buttonHeight / 2); // center button

    switch([matchTools analyzeAction:self.actionDict isChat:[self isChat] isReview:isReview])
    {
        case NEXT:
        {
#pragma mark - Button Next
            DGButton *buttonNext = [[DGButton alloc] initWithFrame:CGRectMake(thirdX, thirdY, buttonWidth, buttonHeight)];
            [buttonNext setTitle:@"Next" forState: UIControlStateNormal];
            [buttonNext addTarget:self action:@selector(actionNext) forControlEvents:UIControlEventTouchUpInside];
            [middleThird addSubview:buttonNext];
            break;
        }
        case NEXT__:
        {
#pragma mark - Button Next>>
            DGButton *buttonNext = [[DGButton alloc] initWithFrame:CGRectMake(thirdX, thirdY, buttonWidth, buttonHeight)];
            [buttonNext setTitle:@"Next>>" forState: UIControlStateNormal];
            [buttonNext addTarget:self action:@selector(actionNext__) forControlEvents:UIControlEventTouchUpInside];
            [middleThird addSubview:buttonNext];
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
            DGButton *buttonRoll = [[DGButton alloc] initWithFrame:CGRectMake(thirdX, thirdY, buttonWidth, buttonHeight)];
            [buttonRoll setTitle:@"Roll Dice" forState: UIControlStateNormal];
            [buttonRoll addTarget:self action:@selector(actionRoll) forControlEvents:UIControlEventTouchUpInside];
            [middleThird addSubview:buttonRoll];
            break;
        }
        case ROLL_DOUBLE:
        {
#pragma mark - Button Roll Double
            
            DGButton *buttonRoll = [[DGButton alloc] initWithFrame:CGRectMake(thirdX, thirdY, buttonWidth, buttonHeight)];
            [buttonRoll setTitle:@"Roll Dice" forState: UIControlStateNormal];
            [buttonRoll addTarget:self action:@selector(actionRoll) forControlEvents:UIControlEventTouchUpInside];
            
            [upperThird addSubview:buttonRoll];
            
            DGButton *buttonDouble = [[DGButton alloc] initWithFrame:CGRectMake(thirdX, thirdY, buttonWidth, buttonHeight)];
            [buttonDouble setTitle:@"Double" forState: UIControlStateNormal];
            [buttonDouble addTarget:self action:@selector(actionDouble) forControlEvents:UIControlEventTouchUpInside];
            [middleThird addSubview:buttonDouble];
            
            NSMutableArray *attributesArray = [self.actionDict objectForKey:@"attributes"];
            if(attributesArray.count == 3) // verify double
            {
                buttonDouble.frame = CGRectMake(thirdXwithVerify, thirdY, buttonWidth, buttonHeight);
                
                UISwitch *verifyDouble = [[UISwitch alloc] initWithFrame:
                                          CGRectMake(buttonDouble.frame.origin.x + buttonWidth + gap,
                                                     thirdY  ,
                                                     switchWidth,
                                                     buttonHeight)];
//                verifyDouble.transform = CGAffineTransformMakeScale(buttonHeight / 31.0, buttonHeight / 31.0); // größe genau wie Doubel Button
                frame = verifyDouble.frame;
                frame.origin.y = buttonDouble.frame.origin.y; // Yposition wie double Button
                verifyDouble.frame = frame;
                
                [verifyDouble addTarget: self action: @selector(actionVerifyDouble:) forControlEvents:UIControlEventValueChanged];
                verifyDouble = [design makeNiceSwitch:verifyDouble];
                [middleThird addSubview: verifyDouble];
                
                UILabel *verifyDoubleText = [[UILabel alloc] initWithFrame:CGRectMake(verifyDouble.frame.origin.x + verifyDouble.frame.size.width + gap,
                                                                                      thirdY,
                                                                                      verifyTextWidth,
                                                                                      buttonHeight)];
                verifyDoubleText.text = @"Verify";
                [middleThird addSubview: verifyDoubleText];
            }
            break;
        }
        case ACCEPT_DECLINE:
        {
#pragma mark - Button Accept Pass
            
            DGButton *buttonAccept = [[DGButton alloc] initWithFrame:CGRectMake(thirdX, thirdY, buttonWidth, buttonHeight)];
            [buttonAccept setTitle:@"Accept" forState: UIControlStateNormal];
            [buttonAccept addTarget:self action:@selector(actionTake) forControlEvents:UIControlEventTouchUpInside];
            [upperThird addSubview:buttonAccept];
            
            DGButton *buttonPass =  [[DGButton alloc] initWithFrame:CGRectMake(thirdX, thirdY, buttonWidth, buttonHeight)];
            [buttonPass setTitle:@"Decline" forState: UIControlStateNormal];
            [buttonPass addTarget:self action:@selector(actionPass) forControlEvents:UIControlEventTouchUpInside];
            [middleThird addSubview:buttonPass];
            
            NSMutableArray *attributesArray = [self.actionDict objectForKey:@"attributes"];
            if(attributesArray.count > 2)
            {
                buttonAccept.frame = CGRectMake(thirdXwithVerify, thirdY, buttonWidth, buttonHeight);
                buttonPass.frame   = CGRectMake(thirdXwithVerify, thirdY, buttonWidth, buttonHeight);
                
                for(NSDictionary * dict in attributesArray)
                {
                    if([[dict objectForKey:@"name"]isEqualToString:@"verify"])
                    {
                        if([[dict objectForKey:@"value"]isEqualToString:@"Accept"])
                        {
                            UISwitch *verifyAccept = [[UISwitch alloc] initWithFrame:CGRectMake(buttonAccept.frame.origin.x + buttonWidth + gap,
                                                                                                thirdY  ,
                                                                                                switchWidth,
                                                                                                buttonHeight)];
//                            verifyAccept.transform = CGAffineTransformMakeScale(buttonHeight / 31.0, buttonHeight / 31.0);
                            frame = verifyAccept.frame;
                            frame.origin.y = buttonAccept.frame.origin.y;
                            verifyAccept.frame = frame;
                            
                            [verifyAccept addTarget: self action: @selector(actionVerifyAccept:) forControlEvents:UIControlEventValueChanged];
                            verifyAccept = [design makeNiceSwitch:verifyAccept];
                            [upperThird addSubview: verifyAccept];
                            
                            UILabel *verifyAcceptText = [[UILabel alloc] initWithFrame:CGRectMake(verifyAccept.frame.origin.x + verifyAccept.frame.size.width + gap,
                                                                                                  thirdY,
                                                                                                  verifyTextWidth,
                                                                                                  buttonHeight)];
                            verifyAcceptText.text = @"Verify";
                            [upperThird addSubview: verifyAcceptText];
                        }
                        if([[dict objectForKey:@"value"]isEqualToString:@"Decline"])
                        {
                            UISwitch *verifyDecline = [[UISwitch alloc] initWithFrame:CGRectMake(buttonAccept.frame.origin.x + buttonWidth + gap,
                                                                                                 thirdY  ,
                                                                                                 switchWidth,
                                                                                                 buttonHeight)];
//                            verifyDecline.transform = CGAffineTransformMakeScale(buttonHeight / 31.0, buttonHeight / 31.0);
                            frame = verifyDecline.frame;
                            frame.origin.y = buttonPass.frame.origin.y; // Yposition wie double Button
                            verifyDecline.frame = frame;
                            
                            [verifyDecline addTarget: self action: @selector(actionVerifyDecline:) forControlEvents:UIControlEventValueChanged];
                            verifyDecline = [design makeNiceSwitch:verifyDecline];
                            [middleThird addSubview: verifyDecline];
                            
                            UILabel *verifyDeclineText = [[UILabel alloc] initWithFrame:CGRectMake(verifyDecline.frame.origin.x + verifyDecline.frame.size.width + gap,
                                                                                                   thirdY,
                                                                                                   verifyTextWidth,
                                                                                                   buttonHeight)];
                            verifyDeclineText.text = @"Verify";
                            [middleThird addSubview: verifyDeclineText];
                        }
                        
                    }
                }
            }
            break;
        }
        case ACCEPT_BEAVER_DECLINE:
        {
#pragma mark - Button Accept/Beaver/Pass
            
            DGButton *buttonAccept = [[DGButton alloc] initWithFrame:CGRectMake(thirdX, thirdY, buttonWidth, buttonHeight)];
            [buttonAccept setTitle:@"Accept" forState: UIControlStateNormal];
            [buttonAccept addTarget:self action:@selector(actionTake) forControlEvents:UIControlEventTouchUpInside];
            [upperThird addSubview:buttonAccept];
            
            DGButton *buttonBeaver = [[DGButton alloc] initWithFrame:CGRectMake(thirdX, thirdY, buttonWidth, buttonHeight)];
            [buttonBeaver setTitle:@"Beaver!" forState: UIControlStateNormal];
            [buttonBeaver addTarget:self action:@selector(actionBeaver) forControlEvents:UIControlEventTouchUpInside];
            [middleThird addSubview:buttonBeaver];

            DGButton *buttonPass =  [[DGButton alloc] initWithFrame:CGRectMake(thirdX, thirdY, buttonWidth, buttonHeight)];
            [buttonPass setTitle:@"Decline" forState: UIControlStateNormal];
            [buttonPass addTarget:self action:@selector(actionPass) forControlEvents:UIControlEventTouchUpInside];
            [lowerThird addSubview:buttonPass];
            
            NSMutableArray *attributesArray = [self.actionDict objectForKey:@"attributes"];
            if(attributesArray.count > 2)
            {
                buttonAccept.frame = CGRectMake(thirdXwithVerify, thirdY, buttonWidth, buttonHeight);
                buttonBeaver.frame   = CGRectMake(thirdXwithVerify, thirdY, buttonWidth, buttonHeight);
                buttonPass.frame   = CGRectMake(thirdXwithVerify, thirdY, buttonWidth, buttonHeight);
                
                for(NSDictionary * dict in attributesArray)
                {
                    if([[dict objectForKey:@"name"]isEqualToString:@"verify"])
                    {
                        if([[dict objectForKey:@"value"]isEqualToString:@"Accept"])
                        {
                            UISwitch *verifyAccept = [[UISwitch alloc] initWithFrame:CGRectMake(buttonAccept.frame.origin.x + buttonWidth + gap,
                                                                                                thirdY  ,
                                                                                                switchWidth,
                                                                                                buttonHeight)];
                            verifyAccept.transform = CGAffineTransformMakeScale(buttonHeight / 31.0, buttonHeight / 31.0);
                            frame = verifyAccept.frame;
                            frame.origin.y = buttonAccept.frame.origin.y;
                            verifyAccept.frame = frame;
                            
                            [verifyAccept addTarget: self action: @selector(actionVerifyAccept:) forControlEvents:UIControlEventValueChanged];
                            verifyAccept = [design makeNiceSwitch:verifyAccept];
                            [upperThird addSubview: verifyAccept];
                            
                            UILabel *verifyAcceptText = [[UILabel alloc] initWithFrame:CGRectMake(verifyAccept.frame.origin.x + verifyAccept.frame.size.width + gap,
                                                                                                  thirdY,
                                                                                                  verifyTextWidth,
                                                                                                  buttonHeight)];
                            verifyAcceptText.text = @"Verify";
                            [upperThird addSubview: verifyAcceptText];
                        }
                        if([[dict objectForKey:@"value"]isEqualToString:@"Decline"])
                        {
                            UISwitch *verifyDecline = [[UISwitch alloc] initWithFrame:CGRectMake(buttonAccept.frame.origin.x + buttonWidth + gap,
                                                                                                 thirdY  ,
                                                                                                 switchWidth,
                                                                                                 buttonHeight)];
                            verifyDecline.transform = CGAffineTransformMakeScale(buttonHeight / 31.0, buttonHeight / 31.0);
                            frame = verifyDecline.frame;
                            frame.origin.y = buttonPass.frame.origin.y; // Yposition wie double Button
                            verifyDecline.frame = frame;
                            
                            [verifyDecline addTarget: self action: @selector(actionVerifyDecline:) forControlEvents:UIControlEventValueChanged];
                            verifyDecline = [design makeNiceSwitch:verifyDecline];
                            [lowerThird addSubview: verifyDecline];
                            
                            UILabel *verifyDeclineText = [[UILabel alloc] initWithFrame:CGRectMake(verifyDecline.frame.origin.x + verifyDecline.frame.size.width + gap,
                                                                                                   thirdY,
                                                                                                   verifyTextWidth,
                                                                                                   buttonHeight)];
                            verifyDeclineText.text = @"Verify";
                            [lowerThird addSubview: verifyDeclineText];
                        }
                        
                    }
                }
            }
            break;
        }
        case BEAVER_ACCEPT:
        {
#pragma mark - Button Beaver Accept
            
            DGButton *buttonAccept = [[DGButton alloc] initWithFrame:CGRectMake(thirdX, thirdY, buttonWidth, buttonHeight)];
            [buttonAccept setTitle:@"Accept Beaver" forState: UIControlStateNormal];
            [buttonAccept addTarget:self action:@selector(actionTakeBeaver) forControlEvents:UIControlEventTouchUpInside];
            [upperThird addSubview:buttonAccept];
            

            DGButton *buttonPass =  [[DGButton alloc] initWithFrame:CGRectMake(thirdX, thirdY, buttonWidth, buttonHeight)];
            [buttonPass setTitle:@"Decline" forState: UIControlStateNormal];
            [buttonPass addTarget:self action:@selector(actionPass) forControlEvents:UIControlEventTouchUpInside];
            [middleThird addSubview:buttonPass];
            
            NSMutableArray *attributesArray = [self.actionDict objectForKey:@"attributes"];
            if(attributesArray.count > 2)
            {
                buttonAccept.frame = CGRectMake(thirdXwithVerify, thirdY, buttonWidth, buttonHeight);
                buttonPass.frame   = CGRectMake(thirdXwithVerify, thirdY, buttonWidth, buttonHeight);
                
                for(NSDictionary * dict in attributesArray)
                {
                    if([[dict objectForKey:@"name"]isEqualToString:@"verify"])
                    {
                        if([[dict objectForKey:@"value"]isEqualToString:@"Decline"])
                        {
                            UISwitch *verifyDecline = [[UISwitch alloc] initWithFrame:CGRectMake(buttonAccept.frame.origin.x + buttonWidth + gap,
                                                                                                 thirdY  ,
                                                                                                 switchWidth,
                                                                                                 buttonHeight)];
                            verifyDecline.transform = CGAffineTransformMakeScale(buttonHeight / 31.0, buttonHeight / 31.0);
                            frame = verifyDecline.frame;
                            frame.origin.y = buttonPass.frame.origin.y; // Yposition wie double Button
                            verifyDecline.frame = frame;
                            
                            [verifyDecline addTarget: self action: @selector(actionVerifyDecline:) forControlEvents:UIControlEventValueChanged];
                            verifyDecline = [design makeNiceSwitch:verifyDecline];
                            [middleThird addSubview: verifyDecline];
                            
                            UILabel *verifyDeclineText = [[UILabel alloc] initWithFrame:CGRectMake(verifyDecline.frame.origin.x + verifyDecline.frame.size.width + gap,
                                                                                                   thirdY,
                                                                                                   verifyTextWidth,
                                                                                                   buttonHeight)];
                            verifyDeclineText.text = @"Verify";
                            [middleThird addSubview: verifyDeclineText];
                        }
                        
                    }
                }
            }
            break;

        }
        case SWAP_DICE:
        {
#pragma mark - Button Swap Dice
            DGButton *buttonSwap = [[DGButton alloc] initWithFrame:CGRectMake(thirdX, thirdY, buttonWidth, buttonHeight)];
            [buttonSwap setTitle:@"Swap Dice" forState: UIControlStateNormal];
            [buttonSwap addTarget:self action:@selector(actionSwap) forControlEvents:UIControlEventTouchUpInside];
            [middleThird addSubview:buttonSwap];
            break;
        }
        case GREEDY:
        {
#pragma mark - Submit Greedy Bearoff
            
            DGButton *buttonGreedy = [[DGButton alloc] initWithFrame:CGRectMake(thirdXForLargeButton, thirdY, buttonLargeWidth, buttonHeight)];
            [buttonGreedy setTitle:@"Submit Greedy Bearoff" forState: UIControlStateNormal];
            [buttonGreedy addTarget:self action:@selector(actionGreedy) forControlEvents:UIControlEventTouchUpInside];
            [middleThird addSubview:buttonGreedy];
            break;
        }
        case UNDO_MOVE:
        {
#pragma mark - Button Undo Move
            DGButton *buttonUndoMove = [[DGButton alloc] initWithFrame:CGRectMake(thirdX, thirdY, buttonWidth, buttonHeight)];
            [buttonUndoMove setTitle:@"Undo Move" forState: UIControlStateNormal];
            [buttonUndoMove addTarget:self action:@selector(actionUnDoMove) forControlEvents:UIControlEventTouchUpInside];
            [middleThird addSubview:buttonUndoMove];
            break;
        }
        case SUBMIT_MOVE:
        {
#pragma mark - Button Submit Move & Undo
            DGButton *buttonSubmitMove = [[DGButton alloc] initWithFrame:CGRectMake(thirdX, thirdY, buttonWidth, buttonHeight)];
            [buttonSubmitMove setTitle:@"Submit Move" forState: UIControlStateNormal];
            [buttonSubmitMove addTarget:self action:@selector(actionSubmitMove) forControlEvents:UIControlEventTouchUpInside];
            [upperThird addSubview:buttonSubmitMove];
            
            DGButton *buttonUndoMove = [[DGButton alloc] initWithFrame:CGRectMake(thirdX, thirdY, buttonWidth, buttonHeight)];
            [buttonUndoMove setTitle:@"Undo Move" forState: UIControlStateNormal];
            [buttonUndoMove addTarget:self action:@selector(actionUnDoMove) forControlEvents:UIControlEventTouchUpInside];
            [middleThird addSubview:buttonUndoMove];
            
            break;
        }
        case SUBMIT_FORCED_MOVE:
        {
#pragma mark - Button Submit Forced Move
            
            DGButton *buttonSubmitMove = [[DGButton alloc] initWithFrame:CGRectMake(thirdXForLargeButton, thirdY, buttonLargeWidth, buttonHeight)];
            [buttonSubmitMove setTitle:@"Submit Forced Move" forState: UIControlStateNormal];
            [buttonSubmitMove addTarget:self action:@selector(actionSubmitForcedMove) forControlEvents:UIControlEventTouchUpInside];
            [middleThird addSubview:buttonSubmitMove];
            break;
        }
        case CHAT:
        {
#pragma mark - Chat
            // schieb den chatView mittig in den sichtbaren Bereich
            CGRect frame = self.chatView.frame;
            
            [self.view bringSubviewToFront:self.chatView ];
            //        self.opponentChat.text = [self.actionDict objectForKey:@"content"];
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
            
            //        self.quoteMessage.textColor   = [schemaDict objectForKey:@"TintColor"];
            
            self.opponentChat.text = [self.boardDict objectForKey:@"chat"];
            if(([self.opponentChat.text length] == 0) && (isCheckbox == FALSE))
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
                [self.opponentChat flashScrollIndicators];
                [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(flashIndicator) userInfo:nil repeats:YES]; // set time interval as per your requirement.
                
                
            }
            frame = self.chatView.frame;
            frame.origin.x = boardView.frame.origin.x + ((boardView.frame.size.width - self.chatView.frame.size.width) / 2);
            frame.origin.y = boardView.frame.origin.y + ((boardView.frame.size.height - self.chatView.frame.size.height) / 2);
            self.chatView.frame = frame;
            
            self.NextButtonOutlet.backgroundColor = [UIColor whiteColor];
            self.ToTopOutlet.backgroundColor = [UIColor whiteColor];
            
            self.playerChat.text = @"you may chat here";
            //         self.chatHeaderText.textColor   = [schemaDict objectForKey:@"TintColor"];
            self.chatView.layer.cornerRadius = 14.0f;
            self.chatView.layer.masksToBounds = YES;
            
            self.chatViewFrame = self.chatView.frame; // position merken um bei keyboard reinfahren view zu verschieben und wieder an die richtige Stelle zurück
            break;
        }
        case ONLY_MESSAGE:
        {
            XLog(@"ONLY_MESSAGE");
            break;
        }
        case REVIEW:
        {
#pragma mark - preview match
            float gap = 20;
            
            float reviewButtonHeight  = MIN(30,(actionView.layer.frame.size.height / 4) - gap - 5);
            
            NSMutableArray *reviewArray = [self.actionDict objectForKey:@"review"];
            float width = 150;
            float x = (actionView.frame.size.width/2) - (width / 2);
            float y = 20;
            NSArray *reviewText = [NSArray arrayWithObjects: @"First Move", @"Prev Move", @"Next Move", @"Last Move",nil];
            for(int i = 0; i < reviewText.count; i++)
            {
                NSString *url = reviewArray[i];
                if(!url.length)
                {
                    DGLabel *label = [[DGLabel alloc] initWithFrame:CGRectMake(x, y, width, reviewButtonHeight)];
                    label.text = reviewText[i];
                    label.textAlignment = NSTextAlignmentCenter;
                    [actionView addSubview:label];
                }
                else
                {
                    DGButton *buttonReview = [[DGButton alloc] initWithFrame:CGRectMake(x, y, width, reviewButtonHeight)];
                    [buttonReview setTitle:reviewText[i] forState: UIControlStateNormal];
                    [buttonReview addTarget:self action:@selector(actionReview:) forControlEvents:UIControlEventTouchUpInside];
                    [buttonReview.layer setValue:url forKey:@"href"];
                    [actionView addSubview:buttonReview];
                }
                y += reviewButtonHeight + gap;
            }
            
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
    
    UIView *linie = [[UIView alloc] initWithFrame:CGRectMake(5, actionView.frame.size.height - 40 - 10, actionView.frame.size.width - 10, 1)];
    linie.backgroundColor = [UIColor blackColor];
    [actionView addSubview:linie];

    if(isReview)
    {
        DGButton *buttonAllMoves = [[DGButton alloc] initWithFrame:CGRectMake((actionView.frame.size.width/2) - 75, actionView.frame.size.height - 45, 150, 35)];
        [buttonAllMoves setTitle:@"List of Moves" forState: UIControlStateNormal];
        [buttonAllMoves addTarget:self action:@selector(actionAllMoves:) forControlEvents:UIControlEventTouchUpInside];
        [buttonAllMoves.layer setValue: [self.actionDict objectForKey:@"List of Moves"] forKey:@"href"];
        [actionView addSubview:buttonAllMoves];

    }
    else
    {
        DGButton *buttonSkipGame = [[DGButton alloc] initWithFrame:CGRectMake((actionView.frame.size.width/2) - 50, actionView.frame.size.height - 45, 100, 35)];
        [buttonSkipGame setTitle:@"Skip Game" forState: UIControlStateNormal];
        [buttonSkipGame addTarget:self action:@selector(actionSkipGame) forControlEvents:UIControlEventTouchUpInside];
        [actionView addSubview:buttonSkipGame];
    }
}
-(void)flashIndicator
{
    [self.opponentChat flashScrollIndicators];
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
- (void)actionBeaver
{
    matchLink = [NSString stringWithFormat:@"%@?submit=Beaver!", [self.actionDict objectForKey:@"action"]];
    [self showMatch];
}
- (void)actionTakeBeaver
{
    matchLink = [NSString stringWithFormat:@"%@?submit=Accept%%20Beaver", [self.actionDict objectForKey:@"action"]];
    [self showMatch];
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

- (void)actionReview:(UIButton*)button
{
    matchLink = (NSString *)[button.layer valueForKey:@"href"];
    [self showMatch];
}

- (void)actionAllMoves:(UIButton*)button
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Review *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"Review"];
    vc.reviewURL = [NSURL URLWithString: [NSString stringWithFormat:@"http://dailygammon.com%@", (NSString *)[button.layer valueForKey:@"href"]]];

    [self.navigationController pushViewController:vc animated:NO];
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

    if(isReview)
        return REVIEW;
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
    }

    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self.playerChat endEditing:YES];
    return YES;
}


- (void)keyboardDidShow:(NSNotification *)notification
{
    if(self.isChatView)
    {
        CGRect frame = self.chatViewFrame;
        frame.origin.y -= 330;
        self.chatView.frame = frame;
    }
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    if(self.isChatView)
    {
        self.chatView.frame = self.chatViewFrame;
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
                                                 [[NSString stringWithFormat:@"%@",self.actionDict] writeToFile:dictPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                                                 NSData *myData = [NSData dataWithContentsOfFile:dictPath];
                                                 [emailController addAttachmentData:myData mimeType:@"text/plain" fileName:@"actionDict.txt"];
                                                 break;
                                             }
                                             case 1:
                                             case 2:
                                             {
                                                 dictPath = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"boardDict.txt"];
                                                 [[NSString stringWithFormat:@"%@",self.boardDict] writeToFile:dictPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
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

#pragma mark - autoLayout

-(BOOL)prefersStatusBarHidden
{
    // maximize view
    return YES;
}

-(void)layoutObjects
{
    UIView *superview = self.view;
    UILayoutGuide *safe = superview.safeAreaLayoutGuide;

    float edge = 5.0;
    
#pragma mark moreButton autoLayout
    [self.moreButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    // Top space to superview Y
    NSLayoutConstraint *moreButtonYConstraint = [NSLayoutConstraint constraintWithItem:self.moreButton
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:safe
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0f
                                                                              constant:0];
    //  position X
    NSLayoutConstraint *moreButtonXConstraint = [NSLayoutConstraint constraintWithItem:self.moreButton
                                                                             attribute:NSLayoutAttributeRight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:superview
                                                                             attribute: NSLayoutAttributeRight
                                                                            multiplier:1.0
                                                                              constant:-edge];

    // Fixed width
    NSLayoutConstraint *moreButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:self.moreButton
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0
                                                                                  constant:40];
    // Fixed Height
    NSLayoutConstraint *moreButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:self.moreButton
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1.0
                                                                                   constant:40];

    [superview addConstraints:@[moreButtonXConstraint, moreButtonYConstraint, moreButtonWidthConstraint, moreButtonHeightConstraint]];

#pragma mark matchCountLabel autoLayout
    [self.matchCountLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSLayoutConstraint *matchCountYConstraint = [NSLayoutConstraint constraintWithItem:self.matchCountLabel
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:safe
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0f
                                                                              constant:0];

    NSLayoutConstraint *matchCountRightConstraint = [NSLayoutConstraint constraintWithItem:self.matchCountLabel
                                                                                 attribute:NSLayoutAttributeRight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self.moreButton
                                                                                 attribute: NSLayoutAttributeLeft
                                                                                multiplier:1.0
                                                                                  constant:-edge];

    // Fixed width
    NSLayoutConstraint *matchCountWidthConstraint = [NSLayoutConstraint constraintWithItem:self.matchCountLabel
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0
                                                                                  constant:40];
    // Fixed Height
    NSLayoutConstraint *matchCountHeightConstraint = [NSLayoutConstraint constraintWithItem:self.matchCountLabel
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1.0
                                                                                   constant:40];

    [superview addConstraints:@[matchCountYConstraint, matchCountRightConstraint, matchCountWidthConstraint, matchCountHeightConstraint]];

#pragma mark matchName autoLayout
    [self.matchName setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSLayoutConstraint *headerYConstraint = [NSLayoutConstraint constraintWithItem:self.matchName
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:safe
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0f
                                                                              constant:0];
    NSLayoutConstraint *headerLeftConstraint = [NSLayoutConstraint constraintWithItem:self.matchName
                                                                                 attribute:NSLayoutAttributeLeft
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:safe
                                                                                 attribute: NSLayoutAttributeLeft
                                                                                multiplier:1.0
                                                                                  constant:edge];
    NSLayoutConstraint *headerRightConstraint = [NSLayoutConstraint constraintWithItem:self.matchName
                                                                                 attribute:NSLayoutAttributeRight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self.matchCountLabel
                                                                                 attribute: NSLayoutAttributeLeft
                                                                                multiplier:1.0
                                                                                  constant:-edge];
    // Fixed Height
    NSLayoutConstraint *headerHeightConstraint = [NSLayoutConstraint constraintWithItem:self.matchName
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1.0
                                                                                   constant:40];

    [superview addConstraints:@[headerYConstraint, headerLeftConstraint, headerRightConstraint, headerHeightConstraint]];
}

- (void) drawViewsInSuperView:(float)superViewWidth andWith:(float)superViewheight
{
    float edge = 20;
    float gap = 10;
    int notch = 0;
    if([design isX] && (superViewWidth > superViewheight) ) //Notch
        notch = 50;
    float x = edge;
    float y = 40 + gap ;
    float maxHeight = superViewheight - y - edge;
    float maxWidth  = superViewWidth - edge - edge;

    // I have determined these numbers when planning on paper in order to optimally represent a game board.
    // float boardWidth  = cubeWidth + (6 * checkerWidth) + barWidth + (6 * checkerWidth) + offWidth; // 70 + (6 * 40) + 40 + (6 * 40) + 70 = 660
    // float boardHeight = numberHeight + pointsHeight + indicatorHeight + checkerWidth + indicatorHeight + pointsHeight + numberHeight; // 15 + 200 + 22 + 40 + 22 + 200 + 15 = 514

    float boardWidth  = 660;
    float boardHeight = 514;
    zoomFactor = 1.0;
    
    actionViewWidth = 100;
    UIColor *actionColor = UIColor.redColor;
    
    if(maxWidth > maxHeight) // views Side by side
    {
        maxWidth = maxWidth - ( 2 * notch); // to be sure that it does not interfere with either the right or left side
        x += notch;

        zoomFactor = maxHeight / boardHeight;

        boardWidth  = boardWidth * zoomFactor;
        boardHeight = boardHeight * zoomFactor;
        
        actionViewWidth = maxWidth - boardWidth;
        // for the actionView we need a minimum width of 250 and a maximum of 300

        if(actionViewWidth < 250)
        {
            float resizeFactor = (boardWidth - (250 - actionViewWidth)) / boardWidth;
            boardWidth = boardWidth - (250 - actionViewWidth);
            actionViewWidth = 250;

            boardHeight *= resizeFactor;
            zoomFactor =  boardWidth / 660;

            y += ((maxHeight - y) - boardHeight) / 2; // center views vertical if we had du resize boardView
            actionColor = UIColor.yellowColor;
        }
        if(actionViewWidth > 250)
        {
            x += (actionViewWidth - 250) / 2;
            actionViewWidth = 250;
            actionColor = UIColor.greenColor;
        }
    }
    else // views among each other
    {
        y = self.matchName.frame.origin.y + self.matchName.frame.size.height + 50;
        maxHeight = maxHeight - notch;
        zoomFactor = maxWidth / boardWidth;

        boardWidth  = maxWidth;
        boardHeight = boardHeight *zoomFactor;
        
        actionViewWidth = boardWidth;
    }

    boardView = [[UIView alloc] initWithFrame:CGRectMake(x, y, boardWidth, boardHeight)];
    boardView.tag = BOARD_VIEW;

//    actionView = [[UIView alloc] initWithFrame:CGRectMake(x + boardWidth + gap, y, actionViewWidth, boardHeight)];
//    actionView.backgroundColor = actionColor;
//    [self.view addSubview:actionView];
    
//    XLog(@"w %3.1f  h %3.1f", superViewWidth, superViewheight);
    XLog(@"boardView w %3.1f  h %3.1f", boardWidth, boardHeight);

    return;
 }

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator 
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    XLog(@"Neue Breite: %.2f, Neue Höhe: %.2f", size.width, size.height);
    
    [self drawViewsInSuperView:size.width andWith:size.height];
    [self showMatch];

}

@end
