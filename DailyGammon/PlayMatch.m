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

@property (readwrite, retain, nonatomic) NSMutableDictionary *boardDict;
@property (assign, atomic) int boardSchema;
@property (readwrite, retain, nonatomic) UIColor *boardColor;
@property (readwrite, retain, nonatomic) UIColor *randColor;

@end

@implementation PlayMatch

@synthesize design;
@synthesize matchLink;

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
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"BoardSchemaColor"];
    self.boardColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"RandSchemaColor"];
    self.randColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    self.boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    
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
            }

        }
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:image forKey:@"img"];
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
            }
            
        }
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:image forKey:@"img"];
        [dict setValue:href forKey:@"href"];
        
        [elementArray addObject:dict];
    }
    [self.boardDict setObject:elementArray forKey:@"grafikUnten"];

#pragma mark - opponent
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

    XLog(@"fertig");
}
-(void)drawBoard
{
    int maxBreite = [UIScreen mainScreen].bounds.size.width;
    int maxHoehe  = [UIScreen mainScreen].bounds.size.height;
    
    int x = 20;
    int y = 200;

    int checkerBreite = 40;
    int zungenHoehe = 200;
    int nummerHoehe = 40;
    UIView *boardView = [[UIView alloc] initWithFrame:CGRectMake(x,
                                                                 y,
                                                                 60 + (6 * checkerBreite) + checkerBreite + (6 * checkerBreite)  + checkerBreite,
                                                                 zungenHoehe + checkerBreite + zungenHoehe + nummerHoehe+ nummerHoehe)];

#pragma mark - Ränder
    boardView.backgroundColor = self.boardColor;
    UIView *offView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, boardView.frame.size.height)];
    offView.backgroundColor = self.randColor;

    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(60+(6*checkerBreite), 0, checkerBreite, boardView.frame.size.height)];
    barView.backgroundColor = self.randColor;

    UIView *cubeView = [[UIView alloc] initWithFrame:CGRectMake(60+(6*checkerBreite)+checkerBreite+(6*checkerBreite), 0, checkerBreite, boardView.frame.size.height)];
    cubeView.backgroundColor = self.randColor;

#pragma mark obere Zungen
    UIImageView *checker24View =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pt_dk_down_b1.gif"]];
    checker24View.frame = CGRectMake(60, 0, checkerBreite, zungenHoehe);

    UIImageView *checker23View =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1/pt_dk_down_b8"]];
    checker23View.frame = CGRectMake(60 + checkerBreite, 0, checkerBreite , zungenHoehe);

    UIImageView *checker01View =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spitze_grau_1rot-1.png"]];
    checker01View.frame = CGRectMake(60, zungenHoehe + checkerBreite, checkerBreite , zungenHoehe);

    UIImageView *checker02View =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spitze_grau_1schwarz.png"]];
    checker02View.frame = CGRectMake(60 + checkerBreite, zungenHoehe + checkerBreite, checkerBreite , zungenHoehe);

    UIImageView *checker03View =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spitze_grau_3rot.png"]];
    checker03View.frame = CGRectMake(60 + (2 * checkerBreite), zungenHoehe + checkerBreite, checkerBreite , zungenHoehe);

    UIImageView *checker04View =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spitze_grau_3schwarz.png"]];
    checker04View.frame = CGRectMake(60 + (3 * checkerBreite), zungenHoehe + checkerBreite, checkerBreite , zungenHoehe);

    UIImageView *checker05View =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spitze_grau-1.png"]];
    checker05View.frame = CGRectMake(60 + (4 * checkerBreite), zungenHoehe + checkerBreite, checkerBreite , zungenHoehe);
    
    UIImageView *checker06View =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spitze_rot_3rot.png"]];
    checker06View.frame = CGRectMake(60 + (5 * checkerBreite), zungenHoehe + checkerBreite, checkerBreite , zungenHoehe);

    
    [boardView addSubview:offView];
    [boardView addSubview:barView];
    [boardView addSubview:cubeView];
    [boardView addSubview:checker24View];
    [boardView addSubview:checker23View];
    [boardView addSubview:checker01View];
    [boardView addSubview:checker02View];
    [boardView addSubview:checker03View];
    [boardView addSubview:checker04View];
    [boardView addSubview:checker05View];
    [boardView addSubview:checker06View];

    [self.view addSubview:boardView];
    
}
#include "HeaderInclude.h"

@end
