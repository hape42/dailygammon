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

@property (readwrite, retain, nonatomic) NSMutableDictionary *boardDict;
@property (assign, atomic) int boardSchema;
@property (readwrite, retain, nonatomic) UIColor *boardColor;
@property (readwrite, retain, nonatomic) UIColor *randColor;
@property (readwrite, retain, nonatomic) UIColor *barMittelstreifenColor;
@property (readwrite, retain, nonatomic) UIColor *nummerColor;
@property (readwrite, retain, nonatomic) NSString *matchLaengeText;

@end

@implementation PlayMatch

@synthesize design;
@synthesize matchLink;
@synthesize ratingDict;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    int maxBreite = [UIScreen mainScreen].bounds.size.width;
    int maxHoehe  = [UIScreen mainScreen].bounds.size.height;
    self.infoLabel.text = [NSString stringWithFormat:@"%d, %d",maxBreite,maxHoehe];

    self.view.backgroundColor = VIEWBACKGROUNDCOLOR;
    design = [[Design alloc] init];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(showMatch) name:@"changeSchemaNotification" object:nil];

    [self.view addSubview:[self makeHeader]];
    [self.view addSubview:self.matchName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self showMatch];
}
-(void)showMatch
{
    self.boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(self.boardSchema < 1) self.boardSchema = 4;
    
    NSMutableDictionary *schemaDict = [design schema:self.boardSchema];

    self.opponentRating.text  = @"";
    self.opponentWinLoss.text = @"";
    self.playerRating.text  = @"";
    self.playerWinLoss.text = @"";

    self.boardColor             = [schemaDict objectForKey:@"BoardSchemaColor"];
    self.randColor              = [schemaDict objectForKey:@"RandSchemaColor"];
    self.barMittelstreifenColor = [schemaDict objectForKey:@"barMittelstreifenColor"];
    self.nummerColor            = [schemaDict objectForKey:@"nummerColor"];

    [self readMatch];
    [self drawBoard];

}
-(void)readMatch
{
    self.boardDict = [[NSMutableDictionary alloc]init];
    
#pragma mark - matchName
    NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",matchLink]];
    
    NSData *matchHtmlData = [NSData dataWithContentsOfURL:urlMatch];
    NSError *error = nil;
    NSStringEncoding encoding;
    NSString *matchString = [[NSString alloc] initWithContentsOfURL:urlMatch
                                                     usedEncoding:&encoding
                                                            error:&error];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:matchHtmlData];
    
    NSArray *matchHeader  = [xpathParser searchWithXPathQuery:@"//h3"];
    NSMutableString *matchName = [[NSMutableString alloc]init];
    for(TFHppleElement *element in matchHeader)
    {
        for (TFHppleElement *child in element.children)
        {
            [matchName appendString:[child content]];
        }
    }
    self.matchName.text = matchName;
#pragma mark - unexpected Move
    if ([matchString rangeOfString:@"unexpected"].location == NSNotFound)
        self.unexpectedMove.text = @"";
    else
        self.unexpectedMove.text = @"Your opponent made an unexpected move, and the game has been rolled back to that point.";

#pragma mark - obere Nummern Reihe
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[1]/td"];
    NSMutableArray *elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        [elementArray addObject:[element text]];
    }
    [self.boardDict setObject:elementArray forKey:@"nummernOben"];

#pragma mark - obere Grafik Reihe
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[2]/td"];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        NSString *image = @"";
        NSString *href = @"";
        NSMutableArray *imgArray = [[NSMutableArray alloc]init];
        for (TFHppleElement *child in element.children)
        {
            NSDictionary *hrefChild = [child attributes];
            href = [hrefChild objectForKey:@"href"];
            TFHppleElement *childFirst = [child firstChild];
            NSDictionary *imgChild = [childFirst attributes];
            image = [imgChild objectForKey:@"src"];
            if ([child.tagName isEqualToString:@"img"])
            {
                image = [child objectForKey:@"src"];
                [imgArray addObject:image];
            }
            if(imgArray.count == 0)
                if(image != nil)
                    [imgArray addObject:image];

        }
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:imgArray forKey:@"img"];
        [dict setValue:href forKey:@"href"];

        [elementArray addObject:dict];
    }
    [self.boardDict setObject:elementArray forKey:@"grafikOben"];

#pragma mark - opponent
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[2]/td[17]"];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        for (TFHppleElement *child in element.children)
        {
            [elementArray addObject:[child content]];
        }
    }
    [self.boardDict setObject:elementArray forKey:@"opponent"];
    
#pragma mark - obere Reihe moveIndicator
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[3]/td"];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        NSString *image = @"";
        for (TFHppleElement *child in element.children)
        {
            if ([child.tagName isEqualToString:@"img"])
            {
                image = [child objectForKey:@"src"];
            }
        }
        [elementArray addObject:image];
    }
    [self.boardDict setObject:elementArray forKey:@"moveIndicatorOben"];

#pragma mark - Würfel Reihe
#warning colspan macht evtl. noch Probleme
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[4]/td"];
    elementArray = [[NSMutableArray alloc]init];
    self.matchLaengeText = @"?";
    for(TFHppleElement *element in elements)
    {
        self.matchLaengeText = [element  content]; // im letzten TD steht "3 Point Match"

        NSString *image = @"";
        for (TFHppleElement *child in element.children)
        {
            if ([child.tagName isEqualToString:@"img"])
            {
                image = [child objectForKey:@"src"];
            }
        }
        [elementArray addObject:image];
    }
    [self.boardDict setObject:elementArray forKey:@"dice"];

#pragma mark - untere Reihe moveIndicator
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[5]/td"];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        NSString *image = @"";
        for (TFHppleElement *child in element.children)
        {
            if ([child.tagName isEqualToString:@"img"])
            {
                image = [child objectForKey:@"src"];
            }
        }
        [elementArray addObject:image];
    }
    [self.boardDict setObject:elementArray forKey:@"moveIndicatorUnten"];

#pragma mark - untere Grafik Reihe
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[6]/td"];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        NSString *image = @"";
        NSString *href = @"";
        NSMutableArray *imgArray = [[NSMutableArray alloc]init];
        for (TFHppleElement *child in element.children)
        {
            NSDictionary *hrefChild = [child attributes];
            href = [hrefChild objectForKey:@"href"];
            TFHppleElement *childFirst = [child firstChild];
            NSDictionary *imgChild = [childFirst attributes];
            image = [imgChild objectForKey:@"src"];
            if ([child.tagName isEqualToString:@"img"])
            {
                image = [child objectForKey:@"src"];
                [imgArray addObject:image];
            }
            if(imgArray.count == 0)
                if(image != nil)
                    [imgArray addObject:image];
        }
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:imgArray forKey:@"img"];
        [dict setValue:href forKey:@"href"];
        
        [elementArray addObject:dict];
    }
    [self.boardDict setObject:elementArray forKey:@"grafikUnten"];

#pragma mark - player
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[6]/td[17]"];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        for (TFHppleElement *child in element.children)
        {
            [elementArray addObject:[child content]];
        }
    }
    [self.boardDict setObject:elementArray forKey:@"player"];
    
#pragma mark - untere Nummern Reihe
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[7]/td"];
    elementArray = [[NSMutableArray alloc]init];
    
    for(TFHppleElement *element in elements)
    {
        if([element text] != nil)
            [elementArray addObject:[element text]];
    }
    [self.boardDict setObject:elementArray forKey:@"nummernUnten"];

}
-(void)drawBoard
{
    int maxBreite = [UIScreen mainScreen].bounds.size.width;
    int maxHoehe  = [UIScreen mainScreen].bounds.size.height;
    
    int x = 20;
    int y = 250;

    int checkerBreite = 40;
    int offBreite = 70;
    int barBreite = 80;
    int cubeBreite = offBreite;
    int zungenHoehe = 200;
    int nummerHoehe = 15;
    int indicatorHoehe = 22;
    
    UIView *boardView = [[UIView alloc] initWithFrame:CGRectMake(x,
                                                                 y,
                                                                 offBreite + (6 * checkerBreite) + barBreite + (6 * checkerBreite)  + cubeBreite,
                                                                 zungenHoehe + indicatorHoehe + checkerBreite + indicatorHoehe + zungenHoehe)];

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
    {
        x = offBreite + (6 * checkerBreite) + barBreite  + (6 * checkerBreite) ;
        //sind wohl gar keine Würfel auf dem Board, trotzdem muss der Cube auf 1 gezeichnet werden
//        float cubeHoehe = cubeBreite * (39.0/29.0);
        float cubeHoehe = cubeBreite ;

        NSString *img = [[diceArray[4] lastPathComponent] stringByDeletingPathExtension];
        NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
        UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        zungeView.frame = CGRectMake(x, y, cubeBreite, cubeHoehe);
        
        [boardView addSubview:zungeView];

    }
    else
    {
        for(int i = 0; i < diceArray.count; i++)
        {
            switch(i)
            {
                case 0:                 // off board
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
                case 7:     // 2. Würfel rechte Boardhälfte
                    //cube
                {
                    x += (checkerBreite * 2.5);
                    float cubeHoehe = cubeBreite * (39.0/29.0);
                    
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",self.boardSchema, img] ;
                    UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    zungeView.frame = CGRectMake(x, y, cubeBreite, cubeHoehe);
                    
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

                }
               break;
                
        }
    }
    x += checkerBreite;
    

    [self.view addSubview:boardView];
    
#pragma mark - opponent / player
    bool showRatings = [[[NSUserDefaults standardUserDefaults] valueForKey:@"showRatings"]boolValue];
    bool showWinLoss = [[[NSUserDefaults standardUserDefaults] valueForKey:@"showWinLoss"]boolValue];

    NSMutableArray *opponentArray = [self.boardDict objectForKey:@"opponent"];
    
    CGRect frame = self.opponentView.frame;
    frame.origin.x = boardView.frame.origin.x + boardView.frame.size.width + 5;
    frame.origin.y = boardView.frame.origin.y - nummerHoehe;
    self.opponentView.frame = frame;
    
    self.opponentName.text    = opponentArray[0];
    self.opponentPips.text    = opponentArray[2];
    self.opponentScore.text   = opponentArray[5];

    NSMutableArray *playerArray = [self.boardDict objectForKey:@"player"];
    
    frame = self.playerView.frame;
    frame.origin.x = boardView.frame.origin.x + boardView.frame.size.width + 5;
    frame.origin.y = boardView.frame.origin.y + boardView.frame.size.height - self.playerView.frame.size.height + nummerHoehe;
    self.playerView.frame = frame;
    
    self.playerName.text    = playerArray[0];
    self.playerPips.text    = playerArray[2];
    self.playerScore.text   = playerArray[5];
    
    if(showRatings)
    {
        self.playerRating.text        = [ratingDict objectForKey:@"ratingPlayer"];
        self.playerRating.textColor   = [UIColor blueColor];
        self.opponentRating.text      = [ratingDict objectForKey:@"ratingOpponent"];;
        self.opponentRating.textColor = [UIColor blueColor];
    }
    if(showWinLoss)
    {
        self.playerWinLoss.text        = [ratingDict objectForKey:@"wlaPlayer"];
        self.playerWinLoss.textColor   = [UIColor blueColor];
        self.opponentWinLoss.text      = [ratingDict objectForKey:@"wlaOpponent"];
        self.opponentWinLoss.textColor = [UIColor blueColor];
    }


    self.matchName.text = [NSString stringWithFormat:@"%@, \t %@",self.matchName.text, self.matchLaengeText] ;
    
    UIView *actionView = [[UIView alloc] initWithFrame:CGRectMake(self.opponentView.frame.origin.x,
                                                                  self.opponentView.frame.origin.y + self.opponentView.frame.size.height,
                                                                  maxBreite - self.opponentView.frame.origin.x ,
                                                                  self.playerView.frame.origin.y - self.opponentView.frame.origin.y - self.playerView.frame.size.height)];
    
    actionView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:actionView];
}
#include "HeaderInclude.h"

@end
