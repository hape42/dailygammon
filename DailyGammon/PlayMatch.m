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

@interface PlayMatch ()

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *matchName;
@property (weak, nonatomic) IBOutlet UILabel *unexpectedMove;

@property (weak, nonatomic) IBOutlet UIView  *opponentView;
@property (weak, nonatomic) IBOutlet UILabel *opponentName;
@property (weak, nonatomic) IBOutlet UILabel *opponentRating;
@property (weak, nonatomic) IBOutlet UILabel *opponentWinLoss;
@property (weak, nonatomic) IBOutlet UILabel *opponentPips;
@property (weak, nonatomic) IBOutlet UILabel *opponentScore;

@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UILabel *playerName;
@property (weak, nonatomic) IBOutlet UILabel *playerRating;
@property (weak, nonatomic) IBOutlet UILabel *playerWinLoss;
@property (weak, nonatomic) IBOutlet UILabel *playerPips;
@property (weak, nonatomic) IBOutlet UILabel *playerScore;

@property (weak, nonatomic) IBOutlet UIView *chatView;
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

@property (readwrite, retain, nonatomic) NSString *matchString;

@property (assign, atomic) BOOL isChatView, isFinishedMatch;
@property (assign, atomic) CGRect finishedMatchFrame;

@end

@implementation PlayMatch

@synthesize design, match, rating;
@synthesize matchLink;
@synthesize ratingDict;

#define NEXT 1
#define ROLL 2
#define ROLL_DOUBLE 3
#define CHECKER_MOVE 4
#define SWAP_DICE 5
#define UNDO_MOVE 6
#define SUBMIT_MOVE 7
#define CHAT 8
#define GREEDY 9
#define ONLY_MESSAGE 10
#define NEXT__ 11
#define ACCEPT_DECLINE 12
#define SUBMIT_FORCED_MOVE 13

#define FINISHED_MATCH_VIEW 43
#define CHAT_VIEW 42

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    self.view.backgroundColor = VIEWBACKGROUNDCOLOR;
    
    design = [[Design alloc] init];
    match  = [[Match alloc] init];
    rating = [[Rating alloc] init];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(viewWillAppear:) name:@"changeSchemaNotification" object:nil];

    [self.view addSubview:[self makeHeader]];
    [self.view addSubview:self.matchName];
    
    UITapGestureRecognizer *oneFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTouched:)];
    oneFingerTap.numberOfTapsRequired = 1;
    oneFingerTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:oneFingerTap];

    [self.playerChat setDelegate:self];

    self.quoteSwitchFrame = self.quoteSwitch.frame;
    self.quoteMessageFrame = self.quoteMessage.frame;
    
    int maxBreite = [UIScreen mainScreen].bounds.size.width;
    int maxHoehe  = [UIScreen mainScreen].bounds.size.height;
    
    self.finishedMatchView = [[UIView alloc] initWithFrame:CGRectMake(20, 80, maxBreite - 40,  maxHoehe - 160)];
//    self.finishedMatchView.backgroundColor = [UIColor whiteColor];
    self.finishedMatchFrame = self.finishedMatchView.frame;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self.view addSubview:[self makeHeader]];

    [self showMatch];
}
-(void)showMatch
{
    self.isChatView = FALSE;
    self.isFinishedMatch = FALSE;
    
    UIView *removeView;
    while((removeView = [self.view viewWithTag:FINISHED_MATCH_VIEW]) != nil)
    {
        [removeView removeFromSuperview];
    }

    // schieb den chatView aus dem sichtbaren bereich
    CGRect frame = self.chatView.frame;
    frame.origin.x = 5000;
    frame.origin.y = 5000;
    self.chatView.frame = frame;
    self.infoLabel.frame = frame;
    self.NextButtonOutlet = [design makeNiceButton:self.NextButtonOutlet];
    self.ToTopOutlet = [design makeNiceButton:self.ToTopOutlet];

//    [self.view addSubview:[self makeHeader]];
    self.boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(self.boardSchema < 1) self.boardSchema = 4;
    
    NSMutableDictionary *schemaDict = [design schema:self.boardSchema];

    self.opponentRating.text  = @"";
    self.opponentWinLoss.text = @"";
    self.playerRating.text    = @"";
    self.playerWinLoss.text   = @"";

    self.boardColor             = [schemaDict objectForKey:@"BoardSchemaColor"];
    self.randColor              = [schemaDict objectForKey:@"RandSchemaColor"];
    self.barMittelstreifenColor = [schemaDict objectForKey:@"barMittelstreifenColor"];
    self.nummerColor            = [schemaDict objectForKey:@"nummerColor"];

    self.boardDict = [match readMatch:matchLink];
    
    if([[self.boardDict objectForKey:@"noMatches"] length] != 0)
    {
        TopPageVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TopPageVC"];
        [self.navigationController pushViewController:vc animated:NO];
        return;
    }
#warning error abfangen
    self.unexpectedMove.text   = [self.boardDict objectForKey:@"unexpectedMove"];
    self.matchName.text = [NSString stringWithFormat:@"%@, \t %@",
                           [self.boardDict objectForKey:@"matchName"],
                           [self.boardDict objectForKey:@"matchLaengeText"]] ;
    
    self.actionDict = [match readActionForm:[self.boardDict objectForKey:@"htmlData"] withChat:(NSString *)[self.boardDict objectForKey:@"chat"]];
    self.moveArray = [[NSMutableArray alloc]init];
    
    NSMutableDictionary *finishedMatchDict = [self.boardDict objectForKey:@"finishedMatch"] ;
    if( finishedMatchDict != nil)
    {
        XLog(@"%@", finishedMatchDict);
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
    else
    {
        [self drawBoard];
    }
}

-(void)drawBoard
{
    int maxBreite = [UIScreen mainScreen].bounds.size.width;
    int maxHoehe  = [UIScreen mainScreen].bounds.size.height;
    
    int x = 20;
    int y = 200;

    float zoomFaktor = 1.0;
    // fixe Höhe war mal 484
    // fixe Breite war mal 700
    zoomFaktor = (maxHoehe - y - 50) / 484.0;
    zoomFaktor *= .98; // damit actionView nicht zu schmal wird
    
    int checkerBreite = 40 * zoomFaktor;
    int offBreite = 70 * zoomFaktor;
    int barBreite = 80 * zoomFaktor;
    int cubeBreite = offBreite;
    int zungenHoehe = 200 * zoomFaktor;
    int nummerHoehe = 15 * zoomFaktor;
    int indicatorHoehe = 22 * zoomFaktor;
    
    UIView *boardView = [[UIView alloc] initWithFrame:CGRectMake(x,
                                                                 y,
                                                                 offBreite + (6 * checkerBreite) + barBreite + (6 * checkerBreite)  + cubeBreite,
                                                                 zungenHoehe + indicatorHoehe + checkerBreite + indicatorHoehe + zungenHoehe)];

    self.infoLabel.text = [NSString stringWithFormat:@"%d, %d",maxBreite,maxHoehe];

    self.infoLabel.text = [NSString stringWithFormat:@"%@ %5.0f, %5.0f , %5.2f",self.infoLabel.text, boardView.frame.size.width, boardView.frame.size.height, zoomFaktor];

    boardView.backgroundColor = self.boardColor;
    
#pragma mark - Ränder
    UIView *offView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, offBreite, boardView.frame.size.height)];
    offView.backgroundColor = self.randColor;

    UIView *offInnenObenView = [[UIView alloc] initWithFrame:CGRectMake((offBreite-checkerBreite)/2, 0, checkerBreite, zungenHoehe)];
    offInnenObenView.backgroundColor = self.boardColor;
    offInnenObenView.layer.borderWidth = 1;
    offInnenObenView.layer.borderColor = [UIColor grayColor].CGColor;
    [offView addSubview:offInnenObenView];
    
    UIView *offInnenUntenView = [[UIView alloc] initWithFrame:CGRectMake((offBreite-checkerBreite)/2, zungenHoehe + indicatorHoehe + checkerBreite + indicatorHoehe, checkerBreite, zungenHoehe)];
    offInnenUntenView.backgroundColor = self.boardColor;
    offInnenUntenView.layer.borderWidth = 1;
    offInnenUntenView.layer.borderColor = [UIColor grayColor].CGColor;
    [offView addSubview:offInnenUntenView];

    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(offBreite+(6*checkerBreite), 0, barBreite, boardView.frame.size.height)];
    barView.backgroundColor = self.randColor;

    UIView *barMitteView = [[UIView alloc] initWithFrame:CGRectMake(((barBreite/2) - 2),
                                                                    -nummerHoehe,
                                                                    2,
                                                                    boardView.frame.size.height + (2 * nummerHoehe))];
    barMitteView.backgroundColor = self.barMittelstreifenColor;
    [barView addSubview:barMitteView];
    
    UIView *cubeView = [[UIView alloc] initWithFrame:CGRectMake(offBreite+(6*checkerBreite)+barBreite+(6*checkerBreite), 0, cubeBreite, boardView.frame.size.height)];
    cubeView.backgroundColor = self.randColor;

    UIView *cubeInnenObenView = [[UIView alloc] initWithFrame:CGRectMake((offBreite-checkerBreite)/2, 0, checkerBreite, zungenHoehe)];
    cubeInnenObenView.backgroundColor = self.boardColor;
    cubeInnenObenView.layer.borderWidth = 1;
    cubeInnenObenView.layer.borderColor = [UIColor grayColor].CGColor;
    [cubeView addSubview:cubeInnenObenView];
    
    UIView *cubeInnenUntenView = [[UIView alloc] initWithFrame:CGRectMake((offBreite-checkerBreite)/2, zungenHoehe + indicatorHoehe + checkerBreite + indicatorHoehe, checkerBreite, zungenHoehe)];
    cubeInnenUntenView.backgroundColor = self.boardColor;
    cubeInnenUntenView.layer.borderWidth = 1;
    cubeInnenUntenView.layer.borderColor = [UIColor grayColor].CGColor;
    [cubeView addSubview:cubeInnenUntenView];
    
    UIView *nummerObenView = [[UIView alloc] initWithFrame:CGRectMake(x,
                                                                      boardView.frame.origin.y - nummerHoehe,
                                                                      boardView.frame.size.width,
                                                                      nummerHoehe)];
    nummerObenView.backgroundColor = self.randColor;
 
    UIView *nummerUntenView = [[UIView alloc] initWithFrame:CGRectMake(x,
                                                                      boardView.frame.origin.y + boardView.frame.size.height,
                                                                      boardView.frame.size.width,
                                                                      nummerHoehe)];
    nummerUntenView.backgroundColor = self.randColor;

    [self.view addSubview:nummerObenView];
    [self.view addSubview:nummerUntenView];
    [boardView addSubview:offView];
    [boardView addSubview:barView];
    [boardView addSubview:cubeView];

#pragma mark - Nummern
    x = boardView.frame.origin.x + offBreite;
    y = boardView.frame.origin.y - nummerHoehe;
    NSMutableArray *nummernArray = [self.boardDict objectForKey:@"nummernOben"];
    for(int i = 1; i <= 6; i++)
    {
        UILabel *nummer = [[UILabel alloc]initWithFrame:CGRectMake(x, y, checkerBreite, nummerHoehe)];
        nummer.textAlignment = NSTextAlignmentCenter;
        nummer.text = nummernArray[i];
        nummer.textColor = self.nummerColor;
        [self.view addSubview:nummer];

        x += checkerBreite;
    }
    x += barBreite; // bar

    for(int i = 8; i <= 13; i++)
    {
        UILabel *nummer = [[UILabel alloc]initWithFrame:CGRectMake(x, y, checkerBreite, nummerHoehe)];
        nummer.textAlignment = NSTextAlignmentCenter;
        nummer.text = nummernArray[i];
        nummer.textColor = self.nummerColor;
        [self.view addSubview:nummer];
        
        x += checkerBreite;
    }

    x = boardView.frame.origin.x + offBreite;
    y = boardView.frame.origin.y + boardView.frame.size.height;
    nummernArray = [self.boardDict objectForKey:@"nummernUnten"];
    
    for(int i = 1; i <= 6; i++)
    {
        UILabel *nummer = [[UILabel alloc]initWithFrame:CGRectMake(x, y, checkerBreite, nummerHoehe)];
        nummer.textAlignment = NSTextAlignmentCenter;
        nummer.text = nummernArray[i];
        nummer.textColor = self.nummerColor;
       [self.view addSubview:nummer];
        
        x += checkerBreite;
    }
    x += barBreite; // bar
    
    for(int i = 8; i <= 13; i++)
    {
        UILabel *nummer = [[UILabel alloc]initWithFrame:CGRectMake(x, y, checkerBreite, nummerHoehe)];
        nummer.textAlignment = NSTextAlignmentCenter;
        nummer.text = nummernArray[i];
        nummer.textColor = self.nummerColor;
        [self.view addSubview:nummer];
        
        x += checkerBreite;
    }

#pragma mark - obere Grafiken
    x = 0;
    y = 0;

    NSMutableArray *grafikObenArray = [self.boardDict objectForKey:@"grafikOben"];
    for(int i = 0; i < grafikObenArray.count; i++)
    {
        NSMutableDictionary *zunge = grafikObenArray[i];
        NSMutableArray *bilder = [zunge objectForKey:@"img"];
        switch(i)
        {
            case 0:
                // linke Seite
                y = 0;
                for(int indexOffBoard = 0; indexOffBoard < bilder.count; indexOffBoard++)
                {
                    NSString *img = [[bilder[indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
                    UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    zungeView.frame = CGRectMake(x + ((offBreite-checkerBreite)/2), y, checkerBreite, zungenHoehe/3);
                    // ist es ein cube? dann besorge breite und höhe vom img für den view
                    if ([imgName containsString:@"cube"])
                    {
                        UIImage *cubeImg = [UIImage imageNamed:imgName];
                        float imgBreite = cubeImg.size.width;
                        float imgHoehe = cubeImg.size.height;
                        float faktor = checkerBreite / imgBreite;
                        imgHoehe *= faktor;
                        zungeView.frame = CGRectMake(x + ((offBreite-checkerBreite)/2), y, checkerBreite, imgHoehe);
                        
                    }

                    [boardView addSubview:zungeView];
                    y += zungenHoehe/3;
                }
                y = 0;
                x += offBreite;
                
                break;
            case 7:
                // bar
                {
                    if(bilder.count > 0)
                    {
                        NSString *img = [[bilder[0] lastPathComponent] stringByDeletingPathExtension];
                        //  img = @"bar_b5";
                        NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
                        UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                        int imgBreite = MAX(zungeView.frame.size.width,1);
                        int imgHoehe = zungeView.frame.size.height;
                        float faktor = imgHoehe / imgBreite;
                        zungeView.frame = CGRectMake(x + ((barBreite - checkerBreite) / 2) , y, checkerBreite, checkerBreite * faktor);
                        
                        [boardView addSubview:zungeView];
                        NSMutableDictionary *move = [[NSMutableDictionary alloc]init];
                        [move setValue:[NSNumber numberWithFloat:zungeView.frame.origin.x + boardView.frame.origin.x] forKey:@"x"];
                        [move setValue:[NSNumber numberWithFloat:zungeView.frame.origin.y + boardView.frame.origin.y] forKey:@"y"];
                        [move setValue:[NSNumber numberWithFloat:zungeView.frame.size.width] forKey:@"w"];
                        [move setValue:[NSNumber numberWithFloat:zungeView.frame.size.height] forKey:@"h"];
                        [move setValue:[zunge objectForKey:@"href"] forKey:@"href"];
                        [self.moveArray addObject:move];
                    }
                    x += barBreite;
                    
                }
                break;
            case 14:
                //cube
            {
                float cubeHoehe = cubeBreite * (39.0/29.0);
                
                y = 0;
                if(bilder.count > 0)
                {
                    NSString *img = [[bilder[0] lastPathComponent] stringByDeletingPathExtension];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
                    UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    zungeView.frame = CGRectMake(x, y, cubeBreite, cubeHoehe);
                    zungeView.frame = CGRectMake(x + ((offBreite-checkerBreite)/2), y, checkerBreite, zungenHoehe/3);
                    // ist es ein cube? dann besorge breite und höhe vom img für den view
                    if ([imgName containsString:@"cube"])
                    {
                        UIImage *cubeImg = [UIImage imageNamed:imgName];
                        float imgBreite = cubeImg.size.width;
                        float imgHoehe = cubeImg.size.height;
                        float faktor = checkerBreite / imgBreite;
                        imgHoehe *= faktor;
                        zungeView.frame = CGRectMake(x + ((offBreite-checkerBreite)/2), y, checkerBreite, imgHoehe);
                        
                    }

                    [boardView addSubview:zungeView];
                }
                y = zungenHoehe + indicatorHoehe + checkerBreite + indicatorHoehe;
                x += cubeBreite;
                
            }
                break;
            default:
                // zungen
                if(bilder.count > 0)
                {
                    NSString *img = [[bilder[0] lastPathComponent] stringByDeletingPathExtension];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
                    
                    UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    zungeView.frame = CGRectMake(x, y, checkerBreite, zungenHoehe);
                    
                    [boardView addSubview:zungeView];
                    x += checkerBreite;
                    NSMutableDictionary *move = [[NSMutableDictionary alloc]init];
                    [move setValue:[NSNumber numberWithFloat:zungeView.frame.origin.x + boardView.frame.origin.x] forKey:@"x"];
                    [move setValue:[NSNumber numberWithFloat:zungeView.frame.origin.y + boardView.frame.origin.y] forKey:@"y"];
                    [move setValue:[NSNumber numberWithFloat:zungeView.frame.size.width] forKey:@"w"];
                    [move setValue:[NSNumber numberWithFloat:zungeView.frame.size.height] forKey:@"h"];
                    [move setValue:[zunge objectForKey:@"href"] forKey:@"href"];
                    [self.moveArray addObject:move];
                }
                break;
                
        }

    }

#pragma mark - obere moveIndicator
    x = 0;
    y = zungenHoehe ;
    
    NSMutableArray *moveIndicatorObenArray = [self.boardDict objectForKey:@"moveIndicatorOben"];
    for(int i = 0; i < moveIndicatorObenArray.count; i++)
    {
        switch(i)
        {
            case 0:
                // off board
                x += offBreite;
                break;
            case 7:
                // bar
                x += barBreite;
                break;
            case 14:
                //cube
                x += cubeBreite;
                break;
            default:
                // zungen
                {
                    NSString *img = [[moveIndicatorObenArray[i] lastPathComponent] stringByDeletingPathExtension];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
                    
                    UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    zungeView.frame = CGRectMake(x, y, checkerBreite, indicatorHoehe);
                    
                    [boardView addSubview:zungeView];
                    x += checkerBreite;
                }
                break;
                
        }
    }
    x += checkerBreite;

#pragma mark - Würfel
    x = 0;
    y = zungenHoehe + indicatorHoehe ;
    
    NSMutableArray *diceArray = [self.boardDict objectForKey:@"dice"];
    if(diceArray.count < 8)
    {        //sind wohl gar keine Würfel auf dem Board, trotzdem muss der Cube auf 1 gezeichnet werden
        NSString *img = [[diceArray[0] lastPathComponent] stringByDeletingPathExtension];
        NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
        UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        zungeView.frame = CGRectMake(x + ((offBreite-checkerBreite)/2), y, checkerBreite, checkerBreite);
        
        [boardView addSubview:zungeView];

        x = offBreite + (6 * checkerBreite) + barBreite  + (6 * checkerBreite) ;

        img = [[diceArray[4] lastPathComponent] stringByDeletingPathExtension];
        imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
        zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        zungeView.frame = CGRectMake(x + ((offBreite-checkerBreite)/2), y, checkerBreite, checkerBreite);
        
        [boardView addSubview:zungeView];

    }
    else
    {
        for(int i = 0; i < diceArray.count; i++)
        {
            switch(i)
            {
                case 0:
                {// off board
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
                    UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    zungeView.frame = CGRectMake(x + ((offBreite-checkerBreite)/2), y, checkerBreite, checkerBreite);
                    
                    [boardView addSubview:zungeView];
                }
                   break;
                case 2:     // 1. Würfel linke Boardhälfte
                {
                    x += offBreite + (checkerBreite / 2) + checkerBreite;
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
                    
                    UIImageView *diceView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    diceView.frame = CGRectMake(x, y, checkerBreite, checkerBreite);
                    
                    [boardView addSubview:diceView];
                }
                    break;
                case 3:     // 2. Würfel linke Boardhälfte
                {
                    x += checkerBreite + checkerBreite;
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
                    
                    UIImageView *diceView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    diceView.frame = CGRectMake(x, y, checkerBreite, checkerBreite);
                    
                    [boardView addSubview:diceView];
                }
                    break;
                case 4:     // 1. Würfel rechte Boardhälfte
                {
                    x += checkerBreite + checkerBreite + barBreite + checkerBreite + checkerBreite;
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
                    
                    UIImageView *diceView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    diceView.frame = CGRectMake(x, y, checkerBreite, checkerBreite);
                    
                    [boardView addSubview:diceView];
                }
                    break;
                case 5:     // 2. Würfel rechte Boardhälfte
                {
                    x += checkerBreite + checkerBreite ;
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
                    
                    UIImageView *diceView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    diceView.frame = CGRectMake(x, y, checkerBreite, checkerBreite);
                    
                    [boardView addSubview:diceView];
                }
                   break;
                case 7:     //cube rechts
                {
                    x += (checkerBreite * 2.5);
                    
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
                    UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    zungeView.frame = CGRectMake(x + ((offBreite-checkerBreite)/2), y, checkerBreite, checkerBreite);
                    
                    [boardView addSubview:zungeView];
                    
                }
                    break;

            }
        }
    }
#pragma mark - untere moveIndicator
    x = 0;
    y = zungenHoehe + indicatorHoehe + checkerBreite;
    
    NSMutableArray *moveIndicatorUntenArray = [self.boardDict objectForKey:@"moveIndicatorUnten"];
    for(int i = 0; i < moveIndicatorUntenArray.count; i++)
    {
        switch(i)
        {
            case 0:
                // off board
                x += offBreite;
                break;
            case 7:
                // bar
                x += barBreite;
                break;
            case 14:
                //cube
                x += cubeBreite;
                break;
            default:
                // zungen
            {
                NSString *img = [[moveIndicatorUntenArray[i] lastPathComponent] stringByDeletingPathExtension];
                NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
                
                UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                zungeView.frame = CGRectMake(x, y, checkerBreite, indicatorHoehe);
                
                [boardView addSubview:zungeView];
                x += checkerBreite;
            }
                break;
                
        }
    }
    x += checkerBreite;

#pragma mark - untere Grafiken
    x = 0;
    y = zungenHoehe + indicatorHoehe + checkerBreite + indicatorHoehe;
    
    NSMutableArray *grafikUntenArray = [self.boardDict objectForKey:@"grafikUnten"];
    for(int i = 0; i < grafikUntenArray.count; i++)
    {
        NSMutableDictionary *zunge = grafikUntenArray[i];
        NSMutableArray *bilder = [zunge objectForKey:@"img"];
        switch(i)
        {
            case 0:
                // off board
                y += (2*(zungenHoehe/3));
                for(int indexOffBoard = 0; indexOffBoard < bilder.count; indexOffBoard++)
                {
                    NSString *img = [[bilder[(bilder.count-1) - indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
                    UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    zungeView.frame = CGRectMake(x + ((offBreite-checkerBreite)/2), y, checkerBreite, zungenHoehe/3);
                    // ist es ein cube? dann besorge breite und höhe vom img für den view
                    if ([imgName containsString:@"cube"])
                    {
                        UIImage *cubeImg = [UIImage imageNamed:imgName];
                        float imgBreite = cubeImg.size.width;
                        float imgHoehe = cubeImg.size.height;
                        float faktor = checkerBreite / imgBreite;
                        imgHoehe *= faktor;
                        zungeView.frame = CGRectMake(x + ((offBreite-checkerBreite)/2), y, checkerBreite, imgHoehe);

                    }
                    [boardView addSubview:zungeView];
                    y -= zungenHoehe/3;
                }
                y = zungenHoehe + indicatorHoehe + checkerBreite + indicatorHoehe;
                x += offBreite;

                break;
            case 7:
                // bar
                {
                    if(bilder.count > 0)
                    {
                        NSString *img = [[bilder[0] lastPathComponent] stringByDeletingPathExtension];
                      //  img = @"bar_b5";
                        NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
                        UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                        int imgBreite = MAX(zungeView.frame.size.width,1);
                        int imgHoehe = zungeView.frame.size.height;
                        float faktor = imgHoehe / imgBreite;
                        zungeView.frame = CGRectMake(x + ((barBreite - checkerBreite) / 2) , y, checkerBreite, checkerBreite * faktor);

                        [boardView addSubview:zungeView];
                        NSMutableDictionary *move = [[NSMutableDictionary alloc]init];
                        [move setValue:[NSNumber numberWithFloat:zungeView.frame.origin.x + boardView.frame.origin.x] forKey:@"x"];
                        [move setValue:[NSNumber numberWithFloat:zungeView.frame.origin.y + boardView.frame.origin.y] forKey:@"y"];
                        [move setValue:[NSNumber numberWithFloat:zungeView.frame.size.width] forKey:@"w"];
                        [move setValue:[NSNumber numberWithFloat:zungeView.frame.size.height] forKey:@"h"];
                        [move setValue:[zunge objectForKey:@"href"] forKey:@"href"];
                        [self.moveArray addObject:move];

                    }
                    x += barBreite;

                }
                break;
            case 14:
                // rechte Seite
                {

                    y += (2*(zungenHoehe/3));
                    for(int indexOffBoard = 0; indexOffBoard < bilder.count; indexOffBoard++)
                    {
                        NSString *img = [[bilder[(bilder.count-1) - indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                        NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
                        UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                        zungeView.frame = CGRectMake(x + ((offBreite-checkerBreite)/2), y, checkerBreite, zungenHoehe/3);
                        // ist es ein cube? dann besorge breite und höhe vom img für den view
                        if ([imgName containsString:@"cube"])
                        {
                            UIImage *cubeImg = [UIImage imageNamed:imgName];
                            float imgBreite = cubeImg.size.width;
                            float imgHoehe = cubeImg.size.height;
                            float faktor = checkerBreite / imgBreite;
                            imgHoehe *= faktor;
                            zungeView.frame = CGRectMake(x + ((offBreite-checkerBreite)/2), y, checkerBreite, imgHoehe);
                            
                        }

                        [boardView addSubview:zungeView];
                        y -= zungenHoehe/3;
                    }

                    y = zungenHoehe + indicatorHoehe + checkerBreite + indicatorHoehe;
                    x += cubeBreite;

                }
                break;
            default:
                // zungen
                if(bilder.count > 0)
                {
                    NSString *img = [[bilder[0] lastPathComponent] stringByDeletingPathExtension];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;

                    UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    zungeView.frame = CGRectMake(x, y, checkerBreite, zungenHoehe);
                    
                    [boardView addSubview:zungeView];
                    x += checkerBreite;
                    NSMutableDictionary *move = [[NSMutableDictionary alloc]init];
                    [move setValue:[NSNumber numberWithFloat:zungeView.frame.origin.x + boardView.frame.origin.x] forKey:@"x"];
                    [move setValue:[NSNumber numberWithFloat:zungeView.frame.origin.y + boardView.frame.origin.y] forKey:@"y"];
                    [move setValue:[NSNumber numberWithFloat:zungeView.frame.size.width] forKey:@"w"];
                    [move setValue:[NSNumber numberWithFloat:zungeView.frame.size.height] forKey:@"h"];
                    [move setValue:[zunge objectForKey:@"href"] forKey:@"href"];
                    [self.moveArray addObject:move];

                }
               break;
                
        }
    }
    x += checkerBreite;
    

    [self.view addSubview:boardView];
    
#pragma mark - opponent / player
    bool showRatings = [[[NSUserDefaults standardUserDefaults] valueForKey:@"showRatings"]boolValue];
    bool showWinLoss = [[[NSUserDefaults standardUserDefaults] valueForKey:@"showWinLoss"]boolValue];

    NSMutableDictionary *schemaDict = [design schema:self.boardSchema];

    if(showRatings || showWinLoss)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                    ^{
                        NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];
                        NSString *opponentID = [self.boardDict objectForKey:@"opponentID"];
            
                        self->ratingDict = [self->rating readRatingForPlayer:userID andOpponent:opponentID];

                        dispatch_async(dispatch_get_main_queue(),
                                       ^{
                                            if(showRatings)
                                            {
                                                self.playerRating.text        = [self->ratingDict objectForKey:@"ratingPlayer"];
                                                self.playerRating.textColor   = [schemaDict objectForKey:@"TintColor"];
                                                self.opponentRating.text      = [self->ratingDict objectForKey:@"ratingOpponent"];;
                                                self.opponentRating.textColor = [schemaDict objectForKey:@"TintColor"];
                                            }
                                            if(showWinLoss)
                                            {
                                                self.playerWinLoss.text        = [self->ratingDict objectForKey:@"wlaPlayer"];
                                                self.playerWinLoss.textColor   = [schemaDict objectForKey:@"TintColor"];
                                                self.opponentWinLoss.text      = [self->ratingDict objectForKey:@"wlaOpponent"];
                                                self.opponentWinLoss.textColor = [schemaDict objectForKey:@"TintColor"];
                                            }
                                       });
            
                    });

    }
    NSMutableArray *opponentArray = [self.boardDict objectForKey:@"opponent"];
    
    CGRect frame = self.opponentView.frame;
    frame.origin.x = boardView.frame.origin.x + boardView.frame.size.width + 5;
    frame.origin.y = boardView.frame.origin.y - nummerHoehe;
    self.opponentView.frame = frame;
    
    self.opponentName.text    = opponentArray[0]; self.opponentName.adjustsFontSizeToFitWidth = YES;
    self.opponentPips.text    = opponentArray[2];
    if([opponentArray[2] rangeOfString:@"pips"].location != NSNotFound)
    {
        self.opponentScore.text   = opponentArray[5];
        self.opponentPips.text    = opponentArray[2];
    }
    else
    {
        self.opponentScore.text   = opponentArray[3];
        self.opponentPips.text    = @"";
   }

    NSMutableArray *playerArray = [self.boardDict objectForKey:@"player"];
    
    frame = self.playerView.frame;
    frame.origin.x = boardView.frame.origin.x + boardView.frame.size.width + 5;
    frame.origin.y = boardView.frame.origin.y + boardView.frame.size.height - self.playerView.frame.size.height + nummerHoehe;
    self.playerView.frame = frame;
    
    self.playerName.text    = playerArray[0];
    self.playerPips.text    = playerArray[2];
    if([playerArray[2] rangeOfString:@"pips"].location != NSNotFound)
    {
        self.playerPips.text    = playerArray[2];
        self.playerScore.text   = playerArray[5];
    }
    else
    {
        self.playerScore.text   = playerArray[3];
        self.playerPips.text    = @"";
    }
    

//    self.matchName.text = [NSString stringWithFormat:@"%@, \t %@",self.matchName.text, self.matchLaengeText] ;
    UIView *removeView;
    while((removeView = [self.view viewWithTag:CHAT_VIEW]) != nil)
    {
        [removeView removeFromSuperview];
    }
    UIView *actionView = [[UIView alloc] initWithFrame:CGRectMake(self.opponentView.frame.origin.x,
                                                                  self.opponentView.frame.origin.y + self.opponentView.frame.size.height,
                                                                  maxBreite - self.opponentView.frame.origin.x -5,
                                                                  self.playerView.frame.origin.y - self.opponentView.frame.origin.y - self.playerView.frame.size.height)];
    
//    actionView.backgroundColor = [UIColor yellowColor];
    actionView.tag = CHAT_VIEW;
    actionView.layer.borderWidth = 1;

    [self.view addSubview:actionView];
    
    switch([self analyzeAction])
    {
        case NEXT:
        {
#pragma mark - Button Next
            UIButton *buttonNext = [UIButton buttonWithType:UIButtonTypeSystem];
            buttonNext = [design makeNiceButton:buttonNext];
            [buttonNext setTitle:@"Next" forState: UIControlStateNormal];
            buttonNext.frame = CGRectMake((actionView.frame.size.width/2) - 50, (actionView.frame.size.height/2) -40, 100, 35);
            [buttonNext addTarget:self action:@selector(actionNext) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonNext];
            break;
        }
        case NEXT__:
        {
#pragma mark - Button Next>>
            UIButton *buttonNext = [UIButton buttonWithType:UIButtonTypeSystem];
            buttonNext = [design makeNiceButton:buttonNext];
            [buttonNext setTitle:@"Next>>" forState: UIControlStateNormal];
            buttonNext.frame = CGRectMake((actionView.frame.size.width/2) - 50, (actionView.frame.size.height/2) -40, 100, 35);
            [buttonNext addTarget:self action:@selector(actionNext__) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonNext];
            break;
        }
       case ROLL:
        {
#pragma mark - Button Roll
            UIButton *buttonRoll = [UIButton buttonWithType:UIButtonTypeSystem];
            buttonRoll = [design makeNiceButton:buttonRoll];
            [buttonRoll setTitle:@"Roll Dice" forState: UIControlStateNormal];
            buttonRoll.frame = CGRectMake((actionView.frame.size.width/2) - 50, (actionView.frame.size.height/2) -40, 100, 35);
            [buttonRoll addTarget:self action:@selector(actionRoll) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonRoll];
            break;
        }
        case ROLL_DOUBLE:
        {
#pragma mark - Button Roll Double
            UIButton *buttonRoll = [UIButton buttonWithType:UIButtonTypeSystem];
            buttonRoll = [design makeNiceButton:buttonRoll];
            [buttonRoll setTitle:@"Roll Dice" forState: UIControlStateNormal];
            buttonRoll.frame = CGRectMake(10, 10, 100, 35);
            [buttonRoll addTarget:self action:@selector(actionRoll) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonRoll];
 
            UIButton *buttonDouble = [UIButton buttonWithType:UIButtonTypeSystem];
            buttonDouble = [design makeNiceButton:buttonDouble];
            [buttonDouble setTitle:@"Double" forState: UIControlStateNormal];
            buttonDouble.frame = CGRectMake(10,  buttonRoll.frame.origin.y + 100 , 100, 35);
            [buttonDouble addTarget:self action:@selector(actionDouble) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonDouble];

            NSMutableArray *attributesArray = [self.actionDict objectForKey:@"attributes"];
            if(attributesArray.count == 3)
            {
                UISwitch *verifyDouble = [[UISwitch alloc] initWithFrame: CGRectMake(120, buttonDouble.frame.origin.y + 4, 50, 35)];
                [verifyDouble addTarget: self action: @selector(actionVerifyDouble:) forControlEvents:UIControlEventValueChanged];
                [verifyDouble setTintColor:[schemaDict objectForKey:@"TintColor"]];
                [verifyDouble setOnTintColor:[schemaDict objectForKey:@"TintColor"]];
                [actionView addSubview: verifyDouble];
                
                UILabel *verifyDoubleText = [[UILabel alloc] initWithFrame:CGRectMake(120 + 60, buttonDouble.frame.origin.y,100, 35)];
                verifyDoubleText.text = @"Verify";
                verifyDoubleText.textColor   = [schemaDict objectForKey:@"TintColor"];
                [actionView addSubview: verifyDoubleText];
            }
            break;
        }
        case ACCEPT_DECLINE:
        {
#pragma mark - Button Accept Pass
            UIButton *buttonAccept = [UIButton buttonWithType:UIButtonTypeSystem];
            buttonAccept = [design makeNiceButton:buttonAccept];
            [buttonAccept setTitle:@"Accept" forState: UIControlStateNormal];
            buttonAccept.frame = CGRectMake(10, 20, 100, 35);
            [buttonAccept addTarget:self action:@selector(actionTake) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonAccept];
            
            UIButton *buttonPass = [UIButton buttonWithType:UIButtonTypeSystem];
            buttonPass = [design makeNiceButton:buttonPass];
            [buttonPass setTitle:@"Decline" forState: UIControlStateNormal];
            buttonPass.frame = CGRectMake(10,  buttonAccept.frame.origin.y + 100 , 100, 35);
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
                           [verifyAccept setTintColor:[schemaDict objectForKey:@"TintColor"]];
                            [verifyAccept setOnTintColor:[schemaDict objectForKey:@"TintColor"]];
                            [actionView addSubview: verifyAccept];
            
                            UILabel *verifyAcceptText = [[UILabel alloc] initWithFrame:CGRectMake(120 + 60, buttonAccept.frame.origin.y,100, 35)];
                            verifyAcceptText.text = @"Verify";
                            verifyAcceptText.textColor   = [schemaDict objectForKey:@"TintColor"];
                            [actionView addSubview: verifyAcceptText];
                        }
                        if([[dict objectForKey:@"value"]isEqualToString:@"Decline"])
                        {
                            UISwitch *verifyDecline = [[UISwitch alloc] initWithFrame: CGRectMake(120, buttonPass.frame.origin.y + 4, 50, 35)];
                            [verifyDecline addTarget: self action: @selector(actionVerifyDecline:) forControlEvents:UIControlEventValueChanged];
                            [verifyDecline setTintColor:[schemaDict objectForKey:@"TintColor"]];
                            [verifyDecline setOnTintColor:[schemaDict objectForKey:@"TintColor"]];
                            [actionView addSubview: verifyDecline];
                            
                            UILabel *verifyDeclineText = [[UILabel alloc] initWithFrame:CGRectMake(120 + 60, buttonPass.frame.origin.y,100, 35)];
                            verifyDeclineText.text = @"Verify";
                            verifyDeclineText.textColor   = [schemaDict objectForKey:@"TintColor"];
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
            UIButton *buttonSwap = [UIButton buttonWithType:UIButtonTypeSystem];
            buttonSwap = [design makeNiceButton:buttonSwap];
            [buttonSwap setTitle:@"Swap Dice" forState: UIControlStateNormal];
            buttonSwap.frame = CGRectMake((actionView.frame.size.width/2) - 50, (actionView.frame.size.height/2) -40, 100, 35);
            [buttonSwap addTarget:self action:@selector(actionSwap) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonSwap];
            break;
        }
        case GREEDY:
        {
#pragma mark - Submit Greedy Bearoff
            UIButton *buttonGreedy = [UIButton buttonWithType:UIButtonTypeSystem];
            buttonGreedy = [design makeNiceButton:buttonGreedy];
            [buttonGreedy setTitle:@"Submit Greedy Bearoff" forState: UIControlStateNormal];
            buttonGreedy.frame = CGRectMake((actionView.frame.size.width/2) - 100, (actionView.frame.size.height/2) -40, 200, 35);
            [buttonGreedy addTarget:self action:@selector(actionGreedy) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonGreedy];
            break;
        }
        case UNDO_MOVE:
        {
#pragma mark - Button Undo Move
            UIButton *buttonUndoMove = [UIButton buttonWithType:UIButtonTypeSystem];
            buttonUndoMove = [design makeNiceButton:buttonUndoMove];
            [buttonUndoMove setTitle:@"Undo Move" forState: UIControlStateNormal];
            buttonUndoMove.frame = CGRectMake((actionView.frame.size.width/2) - 50, (actionView.frame.size.height/2) -40, 100, 35);
            [buttonUndoMove addTarget:self action:@selector(actionUnDoMove) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonUndoMove];
            break;
        }
        case SUBMIT_MOVE:
        {
#pragma mark - Button Submit Move
            UIButton *buttonSubmitMove = [UIButton buttonWithType:UIButtonTypeSystem];
            buttonSubmitMove = [design makeNiceButton:buttonSubmitMove];
            [buttonSubmitMove setTitle:@"Submit Move" forState: UIControlStateNormal];
            buttonSubmitMove.frame = CGRectMake((actionView.frame.size.width/2) - 50, 10, 100, 35);
            [buttonSubmitMove addTarget:self action:@selector(actionSubmitMove) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonSubmitMove];
            
            UIButton *buttonUndoMove = [UIButton buttonWithType:UIButtonTypeSystem];
            buttonUndoMove = [design makeNiceButton:buttonUndoMove];
            [buttonUndoMove setTitle:@"Undo Move" forState: UIControlStateNormal];
            buttonUndoMove.frame = CGRectMake((actionView.frame.size.width/2) - 50, (actionView.frame.size.height/2) -40, 100, 35);
            [buttonUndoMove addTarget:self action:@selector(actionUnDoMove) forControlEvents:UIControlEventTouchUpInside];
            [actionView addSubview:buttonUndoMove];

            break;
        }
        case SUBMIT_FORCED_MOVE:
        {
#pragma mark - Button Submit Forced Move
            UIButton *buttonSubmitMove = [UIButton buttonWithType:UIButtonTypeSystem];
            buttonSubmitMove = [design makeNiceButton:buttonSubmitMove];
            [buttonSubmitMove setTitle:@"Submit Forced Move" forState: UIControlStateNormal];
            buttonSubmitMove.frame = CGRectMake((actionView.frame.size.width/2) - 75, 50, 150, 35);
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
    //        self.opponentChat.text = [self.actionDict objectForKey:@"content"];
            self.opponentChat.text = [self.boardDict objectForKey:@"chat"];
            self.playerChat.text = @"";
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
            [self.quoteSwitch setTintColor:[schemaDict objectForKey:@"TintColor"]];
            [self.quoteSwitch setOnTintColor:[schemaDict objectForKey:@"TintColor"]];
            self.quoteMessage.textColor   = [schemaDict objectForKey:@"TintColor"];
            self.chatHeaderText.textColor   = [schemaDict objectForKey:@"TintColor"];
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
        default:
        {
            XLog(@"Hier sollte das Programm nie hin kommen %@",self.actionDict);
            [self defaultAction];
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
        messageText.textColor   = [schemaDict objectForKey:@"TintColor"];
        [actionView addSubview: messageText];

    }

#pragma mark - Button Skip Game
    UIButton *buttonSkipGame = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonSkipGame = [design makeNiceButton:buttonSkipGame];
    [buttonSkipGame setTitle:@"Skip Game" forState: UIControlStateNormal];
    buttonSkipGame.frame = CGRectMake((actionView.frame.size.width/2) - 50, actionView.frame.size.height - 45, 100, 35);
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
#pragma mark - chat Buttons

- (IBAction)chatNextButton:(id)sender
{
    
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
    NSString *escapedString = [self.playerChat.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];

    matchLink = [NSString stringWithFormat:@"%@?submit=Next%%20Game&commit=1%@&chat=%@",
                 [self.actionDict objectForKey:@"action"],
                 checkbox,
                 escapedString];

    [self showMatch];

}
- (IBAction)chatTopButton:(id)sender
{
    TopPageVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TopPageVC"];
    
    [self.navigationController pushViewController:vc animated:NO];
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
    //    XLog(@"TapPoint = %@ ", NSStringFromCGPoint(tapLocation));
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
            }
        }
    }
    [self showMatch];

}

#pragma mark - textField
-(BOOL)textViewShouldBeginEditing:(UITextView *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
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
        XLog(@"keyboardDidShow %f",self.chatView.frame.origin.y );
    }
    if(self.isFinishedMatch)
    {
        CGRect frame = self.finishedMatchFrame;
        frame.origin.y -= 330;
        self.finishedMatchView.frame = frame;
    }
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    if(self.isChatView)
    {
        self.chatView.frame = self.chatViewFrame;
        XLog(@"keyboardDidHide %f",self.chatView.frame.origin.y );
    }
    if(self.isFinishedMatch)
    {
        self.finishedMatchView.frame = self.finishedMatchFrame;
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

-(void)defaultAction
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

    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:@"\n\nSomething unexpected happend!  \n\n Please send an Email to support.\n\n\nOr just go to the TopPage."];
    [message addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:20.0]
                    range:NSMakeRange(0, [message length])];
    [alert setValue:message forKey:@"attributedMessage"];

    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Top Page"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    TopPageVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TopPageVC"];

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
                                     NSString *betreff = [NSString stringWithFormat:@"Something unexpected happend!"];

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
                                     NSArray *toSupport = [NSArray arrayWithObjects:@"support@hape42.de",nil];

                                     [emailController setToRecipients:toSupport];
                                     [emailController setSubject:betreff];
                                     [emailController setMessageBody:emailText isHTML:YES];
                                     NSString *dictPath = @"";
                                     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                                          NSUserDomainMask, YES);
                                     if([paths count] > 0)
                                     {
                                         dictPath = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"actionDict.txt"];
                                         [[NSString stringWithFormat:@"%@",self.actionDict] writeToFile:dictPath atomically:YES];
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
    int rand = 10;
    int maxBreite = [UIScreen mainScreen].bounds.size.width;
    int maxHoehe  = [UIScreen mainScreen].bounds.size.height;

    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.finishedMatchView.frame.size.width,  self.finishedMatchView.frame.size.height)];
    
    infoView.backgroundColor = VIEWBACKGROUNDCOLOR;
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

    UIButton *buttonNext = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonNext = [design makeNiceButton:buttonNext];
    [buttonNext setTitle:@"Next Game" forState: UIControlStateNormal];
    buttonNext.frame = CGRectMake(50, infoView.layer.frame.size.height - 50, 100, 35);
    [buttonNext addTarget:self action:@selector(actionNextFinishedMatch) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:buttonNext];
 
    UIButton *buttonToTop = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonToTop = [design makeNiceButton:buttonToTop];
    [buttonToTop setTitle:@"To Top" forState: UIControlStateNormal];
    buttonToTop.frame = CGRectMake(50 + 100 + 50, infoView.layer.frame.size.height - 50, 100, 35);
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
    for(NSDictionary * dict in [finishedMatchDict objectForKey:@"attributes"])
    {
        href = [dict objectForKey:@"action"];
    }
    UIView *removeView;
    while((removeView = [self.view viewWithTag:FINISHED_MATCH_VIEW]) != nil)
    {
        [removeView removeFromSuperview];
    }
    NSString *nextButtonText = @"Next%%20Game";
    if( [finishedMatchDict objectForKey:@"NextButton"] != nil)
        nextButtonText = [finishedMatchDict objectForKey:@"NextButton"];
    
    if([href isEqualToString:@""])
        matchLink = @"/bg/nextgame";
    else
        matchLink = [NSString stringWithFormat:@"%@?submit=%@&commit=1", href, nextButtonText];
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

#include "HeaderInclude.h"

@end
