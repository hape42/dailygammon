//
//  PlayMatch.m
//  DailyGammon
//
//  Created by Peter on 29.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "PlayMatch.h"
#import "TopPageVC.h"
#import "Header.h"
#import "Design.h"

@interface PlayMatch ()

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (strong, nonatomic) UILabel *matchName;
@property (strong, nonatomic) UILabel *unexpectedMove;
@property (strong, nonatomic) UILabel *actionHint;

@end

@implementation PlayMatch

@synthesize header, design;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    int maxBreite = [UIScreen mainScreen].bounds.size.width;
    int maxHoehe  = [UIScreen mainScreen].bounds.size.height;
    self.infoLabel.text = [NSString stringWithFormat:@"%d, %d",maxBreite,maxHoehe];

    self.view.backgroundColor = VIEWBACKGROUNDCOLOR;
    header = [[Header alloc] init];
    design = [[Design alloc] init];
    
    [self.view addSubview:[self makeHeader]];
    
    [self drawBoard];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    
}
-(void)drawBoard
{
    int maxBreite = [UIScreen mainScreen].bounds.size.width;
    int maxHoehe  = [UIScreen mainScreen].bounds.size.height;
    
    int x = 50;
    int y = 200;

    int checkerBreite = 40;
    int zungenHoehe = 200;
    UIView *boardView = [[UIView alloc] initWithFrame:CGRectMake(x,
                                                                 y,
                                                                 60 + (6 * checkerBreite) + checkerBreite + (6 * checkerBreite)  + checkerBreite,
                                                                 zungenHoehe + checkerBreite + zungenHoehe)];
    boardView.backgroundColor = [UIColor lightGrayColor];
    boardView.backgroundColor = HEADERBACKGROUNDCOLOR;
    UIView *offView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, boardView.frame.size.height)];
    offView.backgroundColor = [UIColor blackColor];

    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(60+(6*checkerBreite), 0, checkerBreite, boardView.frame.size.height)];
    barView.backgroundColor = [UIColor blackColor];

    UIView *cubeView = [[UIView alloc] initWithFrame:CGRectMake(60+(6*checkerBreite)+checkerBreite+(6*checkerBreite), 0, checkerBreite, boardView.frame.size.height)];
    cubeView.backgroundColor = [UIColor blackColor];

    UIImageView *checker24View =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pt_dk_down_b1.gif"]];
    checker24View.frame = CGRectMake(60, 0, checkerBreite, zungenHoehe);

    UIImageView *checker23View =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pt_lt_down0.gif"]];
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
