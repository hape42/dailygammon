//
//  PlayMatch.m
//  DailyGammon
//
//  Created by Peter on 29.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "PlayMatch.h"
#import "TopPageCV.h"
#import "SetUpVC.h"
#import "Design.h"
#import "TFHpple.h"
#import "Match.h"
#import "Rating.h"
#import "AppDelegate.h"
#import "DbConnect.h"
#import "RatingVC.h"
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <SafariServices/SafariServices.h>
#import "PlayerVC.h"
#import "Tools.h"
#import "LoginVC.h"
#import "DGButton.h"
#import "TextTools.h"

#import "ConstantsMatch.h"
#import "MatchTools.h"

#import "PlayerLists.h"
#import "Constants.h"

#import "Review.h"
#import "NoBoard.h"
#import "PlayerDetail.h"

@interface PlayMatch ()

@property (weak, nonatomic) IBOutlet DGLabel *matchName;
@property (weak, nonatomic) IBOutlet DGLabel *matchInfo;

@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@property (weak, nonatomic) IBOutlet UILabel *matchCountLabel;

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

@property (readwrite, retain, nonatomic) NSString *matchString;

@property (assign, atomic) unsigned long memory_start;
@property (assign, atomic) BOOL first;

@property (readwrite, retain, nonatomic) DGButton *topPageButton;

@property (assign, atomic) int matchCount;

@property (nonatomic, strong) NSLayoutConstraint *matchNameRightAnchor;
@property (nonatomic, strong) NSLayoutConstraint *matchNameLeftAnchor;
@property (nonatomic, strong) NSLayoutConstraint *matchNameCenterXAnchor;

@property (nonatomic, strong) NSLayoutConstraint *matchInfoLeftAnchor;
@property (nonatomic, strong) NSLayoutConstraint *matchInfoRightAnchor;
@property (nonatomic, strong) NSLayoutConstraint *matchInfoTopAnchor;
@property (nonatomic, strong) NSLayoutConstraint *matchInfoCenterXAnchor;

@property (nonatomic, strong) NSDate *lastTapDate;

@end

@implementation PlayMatch

@synthesize design, match, rating, tools, textTools;
//@synthesize matchLink, isReview;
@synthesize isReview;
@synthesize ratingDict;

@synthesize topPageArray;

@synthesize matchTools;

@synthesize chatView;

@synthesize boardView, actionView;
@synthesize zoomFactor;
@synthesize actionViewWidth;
@synthesize isPortrait;

#define BUTTONHEIGHT 35
#define BUTTONWIDTH 80

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self
           selector:@selector(chatTopButton:)
               name:chatViewTopButtonNotification
             object:nil];

    [nc addObserver:self
           selector:@selector(chatNextButton:)
               name:chatViewNextButtonNotification
             object:nil];

    [nc addObserver:self 
           selector:@selector(drawPlayingAreas)
               name:changeSchemaNotification
             object:nil];
    
    [nc addObserver:self 
           selector:@selector(showMatchCount)
               name:matchCountChangedNotification
             object:nil];
    
    [nc addObserver:self 
           selector:@selector(analyzeMatch)
               name:@"analyzeMatch"
             object:nil];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;
    
    design = [[Design alloc] init];
    match  = [[Match alloc] init];
    rating = [[Rating alloc] init];
    tools = [[Tools alloc] init];
    matchTools = [[MatchTools alloc] init];
    textTools = [[TextTools alloc] init];

    [self.view addSubview:self.matchName];
    
    UITapGestureRecognizer *oneFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTouched:)];
    oneFingerTap.numberOfTapsRequired = 1;
    oneFingerTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:oneFingerTap];
    
    self.first = TRUE;

    self.matchCount = [[[NSUserDefaults standardUserDefaults] valueForKey:@"matchCount"]intValue];
    [self.matchCountLabel setText:[NSString stringWithFormat:@"%d", self.matchCount]];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.moreButton.menu = [app mainMenu:self.navigationController button:self.moreButton];
    self.moreButton.showsMenuAsPrimaryAction = YES;

    self.lastTapDate = [NSDate date];

    self.matchName.text = @"";
    self.matchInfo.text = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [self layoutObjects];
    
    self.matchName.textColor       = [design getTintColorSchema];
    self.matchCountLabel.textColor = [design getTintColorSchema];
    self.moreButton                = [design designMoreButton:self.moreButton];

    [self drawViewsInSuperView:self.view.frame.size.width andWith:self.view.frame.size.height];
    app.playMatchAktiv = YES;
    [self showMatch:YES];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.chatBuffer = @"";
}

- (void) showMatchCount
{
    [self.matchCountLabel setText:[NSString stringWithFormat:@"%d", [[[NSUserDefaults standardUserDefaults] valueForKey:@"matchCount"]intValue]]];
}
-(void)showMatch:(BOOL)readMatch
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

 //   XLog(@"app.playMatchAktiv %d matchLink %@", app.playMatchAktiv, app.matchLink);
    
    if(readMatch || (app.boardDict == nil))
    {
        app.boardDict  = [[NSMutableDictionary alloc]init];
        app.actionDict = [[NSMutableDictionary alloc]init];

        [match readMatch:app.matchLink reviewMatch:isReview ];
    }
    else
    {
        [self analyzeMatch];
    }
}
-(void)analyzeMatch
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if((app.actionDict == nil) || (app.boardDict == nil))
    {

        XLog(@"");
        [self errorAction:5];
        return;
    }
    if ([app.actionDict count] == 0)
    {
        
        self.matchName.text = [NSString stringWithFormat:@"if ([app.actionDict count] == 0) %@ ", app.matchLink];
        TopPageCV *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"TopPageCV"];
        [self.navigationController pushViewController:vc animated:NO];

//        app.matchLink = @"/bg/nextgame";
//    //    [self errorAction:0];
//        [self showMatch:YES];
        return;
    }
    if ([app.boardDict count] == 0)
    {
        self.matchName.text = [NSString stringWithFormat:@"if ([app.boardDict count] == 0) %@ ", app.matchLink];
        TopPageCV *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"TopPageCV"];
        [self.navigationController pushViewController:vc animated:NO];
//       app.matchLink = @"/bg/nextgame";
//    //    [self errorAction:0];
//        [self showMatch:YES];
        return;
    }

    [tools matchCount];

   // [chatView dismiss];

    UIView *removeView;
    while((removeView = [self.view viewWithTag:FINISHED_MATCH_VIEW]) != nil)
    {
        [removeView removeFromSuperview];
    }
    while((removeView = [self.view viewWithTag:ANSWERREPLY_VIEW]) != nil)
    {
        [removeView removeFromSuperview];
    }

    self.boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(self.boardSchema < 1) self.boardSchema = 4;
    
    NSMutableDictionary *schemaDict = [design schema:self.boardSchema];

    self.boardColor             = [schemaDict objectForKey:@"BoardSchemaColor"];
    self.randColor              = [schemaDict objectForKey:@"RandSchemaColor"];
    self.barMittelstreifenColor = [schemaDict objectForKey:@"barMittelstreifenColor"];
    self.nummerColor            = [schemaDict objectForKey:@"nummerColor"];

    if([[app.boardDict objectForKey:@"NoBoard"] length] != 0)
    {
        NoBoard *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"NoBoard"];
        vc.boardDict = app.boardDict;
        vc.presentingVC = self;
        [self.navigationController pushViewController:vc animated:NO];
        return;
    }

    if ([[app.boardDict objectForKey:@"htmlString"] containsString:@"cubedr.gif"])
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
            TopPageCV *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"TopPageCV"];
            [self.navigationController pushViewController:vc animated:NO];
                                     }];
 
        [alert addAction:okButton];

        [self presentViewController:alert animated:YES completion:nil];

        return;
    }
    if([[app.boardDict objectForKey:@"TopPage"] length] != 0)
    {
        TopPageCV *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"TopPageCV"];
        [self.navigationController pushViewController:vc animated:NO];
        return;
    }
    if([[app.boardDict objectForKey:@"unknown"] length] != 0)
        [self errorAction:1];

    if([[app.boardDict objectForKey:@"noMatches"] length] != 0)
    {
        TopPageCV *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"TopPageCV"];
        [self.navigationController pushViewController:vc animated:NO];
        return;
    }

    if(![app.boardDict objectForKey:@"matchName"] || ![app.boardDict objectForKey:@"matchLaengeText"])
    {
        self.matchName.text = @"";
        self.matchInfo.text = @"";

    }
    else
    {
        NSMutableArray *opponentArray = [app.boardDict objectForKey:@"opponent"];
        NSString *opponentScore = @"";
        if([opponentArray[2] rangeOfString:@"pip"].location != NSNotFound)
            opponentScore  = opponentArray[5];
        else
            opponentScore  = opponentArray[3];
        
        NSMutableArray *playerArray   = [app.boardDict objectForKey:@"player"];
        NSString *playerScore = @"";
        if([playerArray[2] rangeOfString:@"pip"].location != NSNotFound)
            playerScore  = playerArray[5];
        else
            playerScore  = playerArray[3];

        self.matchName.text = [app.boardDict objectForKey:@"matchName"] ;
        self.matchInfo.text = [NSString stringWithFormat:@"%@ %@ %@:%@",
                           [app.boardDict objectForKey:@"matchLaengeText"],@" ",
                               playerScore, opponentScore] ;

    }
    self.moveArray = [[NSMutableArray alloc]init];
    
    [self drawPlayingAreas];
    
}

-(void)drawPlayingAreas
{

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    self.boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(self.boardSchema < 1) self.boardSchema = 4;

    NSMutableDictionary * returnDict = [matchTools drawBoard:self.boardSchema boardInfo:app.boardDict boardView:boardView zoom:zoomFactor];
#warning könnte aich noch boarddict problematisch sein
    if(returnDict.count == 0)
    {
        return;
    }
    boardView = [returnDict objectForKey:@"boardView"];

    CGRect frame = CGRectZero;
    
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
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;

    returnDict = [matchTools drawActionView:app.boardDict bordView:boardView actionViewWidth:actionViewWidth isPortrait:isPortrait maxHeight:safe.layoutFrame.size.height];
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

    float gap = 10;
    float verifyTextWidth = 50;

    int buttonHeight = 35;
    int buttonWidth = 110;
    
    float switchWidth = 50;
    float buttonLargeWidth = MIN(buttonWidth *2, actionViewWidth - 10);

    self.verifiedDouble = FALSE;
    self.verifiedTake   = FALSE;
    self.verifiedPass   = FALSE;

    float thirdX = (actionViewWidth / 2) - (buttonWidth / 2); // center button
    float thirdXForLargeButton = (actionViewWidth / 2) - (buttonLargeWidth / 2); // center button
    float thirdXwithVerify = (actionViewWidth / 2) - (buttonWidth / 2) - (gap / 2) - (switchWidth / 2) - (gap / 2) - (verifyTextWidth / 2); // center button
    
    float thirdY = (upperThird.frame.size.height / 2) - (buttonHeight / 2); // center button

    switch([matchTools analyzeAction:app.actionDict isChat:[self isChat] isReview:isReview])
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

            app.matchLink = [NSString stringWithFormat:@"%@?submit=Next%%20Game&commit=1", [app.actionDict objectForKey:@"action"]];
            NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",app.matchLink]];
            //    XLog(@"%@",urlMatch);
            NSData *matchHtmlData = [NSData dataWithContentsOfURL:urlMatch];
            
            //    [match readMatch:matchLink];
            TopPageCV *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"TopPageCV"];
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
            
            NSMutableArray *attributesArray = [app.actionDict objectForKey:@"attributes"];
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
            
            NSMutableArray *attributesArray = [app.actionDict objectForKey:@"attributes"];
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
            
            NSMutableArray *attributesArray = [app.actionDict objectForKey:@"attributes"];
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
            
            NSMutableArray *attributesArray = [app.actionDict objectForKey:@"attributes"];
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
           // XLog(@"Chat");
            if(chatView)
            {
                [tools removeAllSubviewsRecursively:chatView];
                UIView *removeView;
                while((removeView = [self.view viewWithTag:123]) != nil)
                {
                    [removeView removeFromSuperview];
                }

            }
            chatView = [[ChatView alloc]init];
            chatView.navigationController = self.navigationController;
            chatView.boardDict = app.boardDict;
            chatView.actionDict = app.actionDict;
            chatView.boardView = boardView;
            chatView.presentingVC = self;
            //XLog(@"%@",self);
            [chatView showChatInView:self.view];
            break;
        }
        case ONLY_MESSAGE:
        {
            XLog(@"ONLY_MESSAGE");
            break;
        }
        case REVIEW:
        {
#pragma mark - review match
            
            float skipHeight = 40;
            float gap = 20;
            
            float reviewButtonHeight  = MIN(30,(actionView.layer.frame.size.height / 4) - gap - 5);
            
            reviewButtonHeight  = MIN(30,((actionView.layer.frame.size.height-skipHeight) / 2)/4);
            gap  = MIN(20,((actionView.layer.frame.size.height-skipHeight) / 2)/5);

            NSMutableArray *reviewArray = [app.actionDict objectForKey:@"review"];
            float width = 150;
            float x = (actionView.frame.size.width/2) - (width / 2);
            float y = gap;
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
            XLog(@"Hier sollte das Programm nie hin kommen %@ %@", app.matchLink,app.actionDict);
            self.matchName.text = [NSString stringWithFormat:@"Hier sollte das Programm nie hin kommen %@ ", app.matchLink];
            app.matchLink = @"/bg/nextgame";
        //    [self errorAction:0];
            [self showMatch:YES];
            return;
        }
    }
    
    if([[app.actionDict objectForKey:@"Message"] length] != 0)
    {
        DGLabel *messageText = [[DGLabel alloc] initWithFrame:CGRectMake(10,
                                                                         actionView.frame.size.height - 40 - 10 - 40,
                                                                         actionView.frame.size.width - 20,
                                                                         35)];
        messageText.text = [app.actionDict objectForKey:@"Message"];
        messageText.textAlignment = NSTextAlignmentCenter;
        messageText.textColor   = [UIColor colorNamed:@"ColorSwitch"];
        messageText.numberOfLines = 0;

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
        [buttonAllMoves.layer setValue: [app.actionDict objectForKey:@"List of Moves"] forKey:@"href"];
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

#pragma mark - actions
- (void)actionSubmitMove
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    NSMutableArray *attributesArray = [app.actionDict objectForKey:@"attributes"];
    NSMutableDictionary *dict = attributesArray[0];

    app.matchLink = [NSString stringWithFormat:@"%@?submit=Submit%%20Move&move=%@", [app.actionDict objectForKey:@"action"], [dict objectForKey:@"value"]];
    [self showMatch:YES];
}
- (void)actionSubmitForcedMove
{
    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    //NSMutableArray *attributesArray = [self.actionDict objectForKey:@"attributes"];
    //NSMutableDictionary *dict = attributesArray[0];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    app.matchLink = [NSString stringWithFormat:@"%@?submit=Submit%%20Forced%%20Move", [app.actionDict objectForKey:@"action"]];
    [self showMatch:YES];
}

- (void)actionGreedy
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    NSMutableArray *attributesArray = [app.actionDict objectForKey:@"attributes"];
    NSMutableDictionary *dict = attributesArray[0];

    app.matchLink = [NSString stringWithFormat:@"%@?submit=Submit%%20Greedy%%20Bearoff&move=%@", [app.actionDict objectForKey:@"action"], [dict objectForKey:@"value"]];
    [self showMatch:YES];
}

- (void)actionUnDoMove
{
    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    app.matchLink = [app.actionDict objectForKey:@"UndoMove"];
    [self showMatch:YES];
}

- (void)actionSwap
{
    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    app.matchLink = [app.actionDict objectForKey:@"SwapDice"];
    [self showMatch:YES];
}

- (void)actionVerifyDouble:(id)sender
{
    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    self.verifiedDouble = [(UISwitch *)sender isOn];
}
- (void)actionVerifyAccept:(id)sender
{
    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    self.verifiedTake = [(UISwitch *)sender isOn];
}
- (void)actionVerifyDecline:(id)sender
{
    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    self.verifiedPass = [(UISwitch *)sender isOn];
}

- (void)actionRoll
{
    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    app.matchLink = [NSString stringWithFormat:@"%@?submit=Roll%%20Dice", [app.actionDict objectForKey:@"action"]];
    [self showMatch:YES];
}
- (void)actionDouble
{
    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSMutableArray *attributesArray = [app.actionDict objectForKey:@"attributes"];
    if(attributesArray.count == 3)
    {
        if(self.verifiedDouble)
        {
            app.matchLink = [NSString stringWithFormat:@"%@?submit=Double&verify=Double", [app.actionDict objectForKey:@"action"]];
            [self showMatch:YES];
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
        app.matchLink = [NSString stringWithFormat:@"%@?submit=Double", [app.actionDict objectForKey:@"action"]];
        [self showMatch:YES];
    }
}
- (void)actionBeaver
{
    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    app.matchLink = [NSString stringWithFormat:@"%@?submit=Beaver!", [app.actionDict objectForKey:@"action"]];
    [self showMatch:YES];
}
- (void)actionTakeBeaver
{
    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    app.matchLink = [NSString stringWithFormat:@"%@?submit=Accept%%20Beaver", [app.actionDict objectForKey:@"action"]];
    [self showMatch:YES];
}

- (void)actionTake
{
    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSMutableArray *attributesArray = [app.actionDict objectForKey:@"attributes"];
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
            app.matchLink = [NSString stringWithFormat:@"%@?submit=Accept&verify=Accept", [app.actionDict objectForKey:@"action"]];
            [self showMatch:YES];
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
        app.matchLink = [NSString stringWithFormat:@"%@?submit=Accept", [app.actionDict objectForKey:@"action"]];
        [self showMatch:YES];
    }
}
- (void)actionPass
{
    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSMutableArray *attributesArray = [app.actionDict objectForKey:@"attributes"];
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
            app.matchLink = [NSString stringWithFormat:@"%@?submit=Decline&verify=Decline", [app.actionDict objectForKey:@"action"]];
            [self showMatch:YES];
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
        app.matchLink = [NSString stringWithFormat:@"%@?submit=Decline", [app.actionDict objectForKey:@"action"]];
        [self showMatch:YES];
    }
}

- (void)actionNext
{
    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    app.matchLink = [NSString stringWithFormat:@"%@?submit=Next", [app.actionDict objectForKey:@"action"]];
    [self showMatch:YES];
}
- (void)actionNext__
{
    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    app.matchLink = [NSString stringWithFormat:@"%@?submit=Next", [app.actionDict objectForKey:@"Next Game>>"]];
    [self showMatch:YES];
}

- (void)actionSkipGame
{
    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [chatView dismiss];
    app.matchLink = [app.actionDict objectForKey:@"SkipGame"];
    [self showMatch:YES];
}

- (void)actionReview:(UIButton*)button
{
    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    app.matchLink = (NSString *)[button.layer valueForKey:@"href"];
    [self showMatch:YES];
}

- (void)actionAllMoves:(UIButton*)button
{    
    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );
        return;
    }
    self.lastTapDate = [NSDate date];

    Review *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"Review"];
    vc.reviewURL = [NSURL URLWithString: [NSString stringWithFormat:@"http://dailygammon.com%@", (NSString *)[button.layer valueForKey:@"href"]]];

    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark - player details

- (void)playerLists:(UIButton*)sender
{
    PlayerLists *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"PlayerLists"];

    [self.navigationController pushViewController:vc animated:NO];
}

- (void)opponent:(UIButton*)sender
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

#pragma mark - chat Buttons

// are triggered by notification from chatView
- (IBAction)chatNextButton:(NSNotification *)notification
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSString *chat = notification.userInfo[@"playerChat"] ;
    BOOL quote     = [notification.userInfo[@"quoteSwitch"] boolValue];
    
    NSMutableArray *attributesArray = [app.actionDict objectForKey:@"attributes"];
    NSString *checkbox = @"";
    for(NSMutableDictionary *dict in attributesArray)
    {
        if([[dict objectForKey:@"type"] isEqualToString:@"checkbox"])
        {
            if(quote)
                checkbox = @"&quote=on";
            else
                checkbox = @"&quote=off";
       }
    }

    NSString *chatString = [textTools cleanChatString:chat];
    app.matchLink = [NSString stringWithFormat:@"%@?submit=Next%%20Game&commit=1%@&chat=%@",
                 [app.actionDict objectForKey:@"action"],
                 checkbox,
                 chatString];
    
    // send matchlink here already, if sort = round or length
    // get first element from the array
    // build matchLink from it
    // delete first element from the array
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"orderTyp"]intValue] > SORT_RECENT_OPPONENT_MOVE)
    {
        
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        NSString *chat = notification.userInfo[@"playerChat"] ;
        BOOL quote     = [notification.userInfo[@"quoteSwitch"] boolValue];

        NSMutableArray *attributesArray = [app.actionDict objectForKey:@"attributes"];
        NSString *checkbox = @"";
        for(NSMutableDictionary *dict in attributesArray)
        {
            if([[dict objectForKey:@"type"] isEqualToString:@"checkbox"])
            {
                if(quote)
                    checkbox = @"&quote=on";
                else
                    checkbox = @"&quote=off";
            }
        }
        NSString *chatString = [textTools cleanChatString:chat];

        app.matchLink = [NSString stringWithFormat:@"%@?submit=Top%%20Page&commit=1%@&chat=%@",
                     [app.actionDict objectForKey:@"action"],
                     checkbox,
                     chatString];

        NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",app.matchLink]];
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
            app.matchLink = [match objectForKey:@"href"];
        }
    }
    [self showMatch:YES];

}
- (IBAction)chatTopButton:(NSNotification *)notification
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSString *chat = notification.userInfo[@"playerChat"] ;
    BOOL quote     = [notification.userInfo[@"quoteSwitch"] boolValue];

    NSMutableArray *attributesArray = [app.actionDict objectForKey:@"attributes"];
    NSString *checkbox = @"";
    for(NSMutableDictionary *dict in attributesArray)
    {
        if([[dict objectForKey:@"type"] isEqualToString:@"checkbox"])
        {
            if(quote)
                checkbox = @"&quote=on";
            else
                checkbox = @"&quote=off";
        }
    }
    NSString *chatString = [textTools cleanChatString:chat];

    app.matchLink = [NSString stringWithFormat:@"%@?submit=Top%%20Page&commit=1%@&chat=%@",
                 [app.actionDict objectForKey:@"action"],
                 checkbox,
                 chatString];

    [self showMatch:YES];

}

#pragma mark - analyzeAction
- (int) analyzeAction
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    self.verifiedDouble = FALSE;
    self.verifiedTake   = FALSE;
    self.verifiedPass   = FALSE;

    if([self isChat])
        return CHAT;

    if(isReview)
        return REVIEW;
    NSMutableArray *attributesArray = [app.actionDict objectForKey:@"attributes"];
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
    
    if([[app.actionDict objectForKey:@"SwapDice"] length] != 0)
        return SWAP_DICE;
    if([[app.actionDict objectForKey:@"UndoMove"] length] != 0)
        return UNDO_MOVE;
    if([[app.actionDict objectForKey:@"Next Game>>"] length] != 0)
        return NEXT__;

    if(attributesArray == nil)
    {
        if([[app.actionDict objectForKey:@"Message"] length] != 0)
            return ONLY_MESSAGE;
    }
    XLog(@"unknown action %@", app.actionDict);
    return 0;
}
-(BOOL)isChat
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSString *chatString = [app.boardDict objectForKey:@"chat"];
    if(chatString.length > 0)
        return TRUE;

    NSString *contentString = [app.actionDict objectForKey:@"content"];
    if(contentString.length > 0)
    {
        if([contentString rangeOfString:@"You may chat with"].location != NSNotFound)
            return TRUE;
        if([contentString rangeOfString:@"says"].location != NSNotFound)
            return TRUE;
    }
    return FALSE;
}
- (void)cellTouched:(UIGestureRecognizer *)gesture
{

    if (self.lastTapDate && [[NSDate date] timeIntervalSinceDate:self.lastTapDate] < 0.4)
    {
        // User retyped too fast, ignore the tap
        XLog(@"User retyped too fast: %3.1f" , [[NSDate date] timeIntervalSinceDate:self.lastTapDate] );

        return;
    }
    self.lastTapDate = [NSDate date];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

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
                app.matchLink = [dict objectForKey:@"href"];
                [self showMatch:YES];
            }
        }
    }
}


#pragma mark - Email
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (error)
    {
        XLog(@"Fehler MFMailComposeViewController: %@", error);
    }
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - errorAction

-(void)errorAction:(int)typ
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"oops"
                                 message:@"something unexpected happend! Better go to TopPage"
                                 preferredStyle:UIAlertControllerStyleAlert];

    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"Oooops"];
    [title addAttribute:NSFontAttributeName
                  value:[UIFont systemFontOfSize:30.0]
                  range:NSMakeRange(0, [title length])];
    [alert setValue:title forKey:@"attributedTitle"];

    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"-%d-\n\nSomething unexpected happend!  \n%@\n Please send an Email to support.\n\n\nOr just go to the TopPage.", typ, app.matchLink]];
    [message addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:20.0]
                    range:NSMakeRange(0, [message length])];
    [alert setValue:message forKey:@"attributedMessage"];

    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Top Page"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    TopPageCV *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"TopPageCV"];

                                    [self.navigationController pushViewController:vc animated:NO];
                                }];
    UIAlertAction* goButton = [UIAlertAction
                                actionWithTitle:@"Try to go ahead"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [self showMatch:YES];
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

                                    text = [NSString stringWithFormat:@"URL <b>%@</b><br> ", app.matchLink];
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
                                                 [[NSString stringWithFormat:@"%@",app.actionDict] writeToFile:dictPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                                                 NSData *myData = [NSData dataWithContentsOfFile:dictPath];
                                                 [emailController addAttachmentData:myData mimeType:@"text/plain" fileName:@"actionDict.txt"];
                                                 break;
                                             }
                                             case 1:
                                             case 2:
                                             {
                                                 dictPath = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"boardDict.txt"];
                                                 [[NSString stringWithFormat:@"%@",app.boardDict] writeToFile:dictPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
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
    [alert addAction:goButton];
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

    [self.moreButton.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge].active = YES;
    [self.moreButton.heightAnchor constraintEqualToConstant:40].active = YES;
    [self.moreButton.widthAnchor constraintEqualToConstant:40].active = YES;
    [self.moreButton.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-1].active = YES;

#pragma mark matchCountLabel autoLayout
    [self.matchCountLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.matchCountLabel.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge].active = YES;
    [self.matchCountLabel.heightAnchor constraintEqualToConstant:40].active = YES;
    [self.matchCountLabel.widthAnchor constraintEqualToConstant:40].active = YES;
    [self.matchCountLabel.rightAnchor constraintEqualToAnchor:self.moreButton.leftAnchor constant:-2].active = YES;

#pragma mark matchInfo autoLayout
    [self.matchInfo setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.matchInfo.heightAnchor constraintEqualToConstant:40].active = YES;

#pragma mark matchName autoLayout
    [self.matchName setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.matchName.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge].active = YES;
    [self.matchName.heightAnchor constraintEqualToConstant:40].active = YES;
    [self.matchName.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:20].active = YES;

    if(safe.layoutFrame.size.width > safe.layoutFrame.size.height )
    {
        [self.view removeConstraint:self.matchNameRightAnchor];
        self.matchNameRightAnchor = [self.matchName.rightAnchor constraintEqualToAnchor:self.matchInfo.leftAnchor constant:-edge];
        self.matchNameRightAnchor.active = YES;
        
        [self.view removeConstraint:self.matchInfoTopAnchor];
        self.matchInfoTopAnchor = [self.matchInfo.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge];
        self.matchInfoTopAnchor.active = YES;
        
        [self.view removeConstraint:self.matchInfoLeftAnchor];
//        self.matchInfoLeftAnchor = [self.matchInfo.leftAnchor constraintEqualToAnchor:self.matchName.rightAnchor constant:edge];
//        self.matchInfoLeftAnchor.active = YES;
        
        [self.view removeConstraint:self.matchInfoRightAnchor];
        self.matchInfoRightAnchor = [self.matchInfo.rightAnchor constraintEqualToAnchor:self.matchCountLabel.leftAnchor constant:-edge];
        self.matchInfoRightAnchor.active = YES;
        [self.view removeConstraint:self.matchInfoCenterXAnchor];

    }
    else
    {
        [self.view removeConstraint:self.matchNameRightAnchor];
        self.matchNameRightAnchor = [self.matchName.rightAnchor constraintEqualToAnchor:self.matchCountLabel.leftAnchor constant:-edge];
        self.matchNameRightAnchor.active = YES;

        [self.view removeConstraint:self.matchInfoTopAnchor];
        self.matchInfoTopAnchor = [self.matchInfo.topAnchor constraintEqualToAnchor:self.matchName.bottomAnchor constant:edge];
        self.matchInfoTopAnchor.active = YES;

        [self.view removeConstraint:self.matchInfoLeftAnchor];
        [self.view removeConstraint:self.matchInfoRightAnchor];
        
        [self.view removeConstraint:self.matchInfoCenterXAnchor];
        self.matchInfoCenterXAnchor = [self.matchInfo.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor constant:0];
        self.matchInfoCenterXAnchor.active = YES;
    }
    [self.view layoutIfNeeded];

}

- (void) drawViewsInSuperView:(float)superViewWidth andWith:(float)superViewheight
{
 //   XLog(@"");
    float edge = 20;
    int notch = 0;
    if([design isX] && (superViewWidth > superViewheight) ) //Notch
        notch = 50;
    float x = edge;
    float y = 50 ;
    float maxHeight = superViewheight - y - edge;
    float maxWidth  = superViewWidth - edge - edge;

    // I have determined these numbers when planning on paper in order to optimally represent a game board.
    // float boardWidth  = cubeWidth + (6 * checkerWidth) + barWidth + (6 * checkerWidth) + offWidth; // 70 + (6 * 40) + 40 + (6 * 40) + 70 = 660
    // float boardHeight = numberHeight + pointsHeight + indicatorHeight + checkerWidth + indicatorHeight + pointsHeight + numberHeight; // 15 + 200 + 22 + 40 + 22 + 200 + 15 = 514

    float boardWidth  = 660;
    float boardHeight = 514;
    zoomFactor = 1.0;
    
    actionViewWidth = 100;
    isPortrait = FALSE;
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
        y = 150;
        maxHeight = maxHeight - notch;
        zoomFactor = maxWidth / boardWidth;

        boardWidth  = maxWidth;
        boardHeight = boardHeight *zoomFactor;
        
        actionViewWidth = boardWidth;
        isPortrait = TRUE;
    }

    boardView = [[UIView alloc] initWithFrame:CGRectMake(x, y, boardWidth, boardHeight)];
    boardView.tag = BOARD_VIEW;

    return;
 }

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator 
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    if (![self.navigationController.topViewController isKindOfClass:PlayMatch.class])
        return;
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
        // Code to be executed during the animation

        [self layoutObjects];
        [self->chatView dismiss];

        [self drawViewsInSuperView:size.width andWith:size.height];
        [self showMatch:NO];

        

     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) 
     {
         // Code to be executed after the animation is completed
     }];
    
}



@end
