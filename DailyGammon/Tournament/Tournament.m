//
//  Tournament.m
//  DailyGammon
//
//  Created by Peter Schneider on 06.02.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import "Tournament.h"
#import "RatingVC.h"
#import "TopPageVC.h"
#import "Design.h"
#import "TFHpple.h"
#import "PlayMatch.h"
#import "Preferences.h"
#import "Rating.h"
#import "LoginVC.h"
#import "GameLounge.h"
#import "DbConnect.h"
#import "AppDelegate.h"
#import "Player.h"
#import "iPhoneMenue.h"
#import "Tools.h"
#import <SafariServices/SafariServices.h>
#import "RatingTools.h"
#import "SetUpVC.h"
#import "LoginVC.h"
#import "About.h"
#import "DGButton.h"
#import "PlayerLists.h"
#import "DGLabel.h"
#import "CellConnector.h"

@interface Tournament ()

@property (readwrite, retain, nonatomic) DGButton *topPageButton;
@property (weak, nonatomic) IBOutlet UILabel *nameTournament;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@end

@implementation Tournament

@synthesize drawArray;
@synthesize design, preferences, rating, tools, ratingTools;
@synthesize scrollView;
@synthesize url, name;
@synthesize xFound, yFound;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    design      = [[Design alloc] init];
    preferences = [[Preferences alloc] init];
    rating      = [[Rating alloc] init];
    tools       = [[Tools alloc] init];
    ratingTools = [[RatingTools alloc] init];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];

    self.nameTournament.text = name;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self.view addSubview:[self makeHeader]];

    int maxHeigth = [UIScreen mainScreen].bounds.size.height - self.navigationController.navigationBar.frame.size.height - 20;
    int maxWidth = [UIScreen mainScreen].bounds.size.width ;
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 10, self.navigationController.navigationBar.frame.size.height + 20 + 50 , maxWidth, maxHeigth)];

    if([design isX])
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        UIWindow *keyWindow = (UIWindow *) windows[0];
        UIEdgeInsets safeArea = keyWindow.safeAreaInsets;

        CGRect frame = scrollView.frame;
        frame.origin.x = safeArea.left ;
        frame.size.width = scrollView.frame.size.width - safeArea.left ;
        scrollView.frame = frame;
    }

    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(2000, 2000);
    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
    scrollView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];

    [self.view addSubview:scrollView];

    [self readTournament];

    [self drawTournament];
}

#pragma mark - Hpple

-(void)readTournament
{
    NSData *tournamentHtmlData = [NSData dataWithContentsOfURL:url];

    NSString *htmlString = [NSString stringWithUTF8String:[tournamentHtmlData bytes]];
    htmlString = [[NSString alloc]
                  initWithData:tournamentHtmlData encoding: NSISOLatin1StringEncoding];
    NSMutableArray *tournamentArray = [[NSMutableArray alloc]init];
    
    NSData *htmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];

    int tableNo = 2;

    NSString * searchString = [NSString stringWithFormat:@"//table[%d]/tr[%d]/th",tableNo,1];
    NSArray *rounds  = [xpathParser searchWithXPathQuery:searchString];

    NSString *queryString = [NSString stringWithFormat:@"//table[%d]/tr",tableNo];
    NSArray *rows  = [xpathParser searchWithXPathQuery:queryString];
    for(int row = 2; row <= rows.count; row ++)
    {
        NSMutableArray *topPageZeile = [[NSMutableArray alloc]init];

        NSString * searchString = [NSString stringWithFormat:@"//table[%d]/tr[%d]/td",tableNo,row];
        NSArray *elementZeile  = [xpathParser searchWithXPathQuery:searchString];
        for(TFHppleElement *element in elementZeile)
        {
            NSMutableDictionary *topPageZeileSpalte = [[NSMutableDictionary alloc]init];

            for (TFHppleElement *child in element.children)
            {
                if ([child.tagName isEqualToString:@"a"])
                {
                   // NSDictionary *href = [child attributes];
                    [topPageZeileSpalte setValue:[child content] forKey:@"Text"];
                    [topPageZeileSpalte setValue:[[child attributes] objectForKey:@"href"]forKey:@"href"];
                }
                else
                {
                    [topPageZeileSpalte setValue:[element content] forKey:@"Text"];
                }
            }
            [topPageZeile addObject:topPageZeileSpalte];
        }

        [tournamentArray addObject:topPageZeile];
    }
    drawArray = [[NSMutableArray alloc]initWithCapacity:tournamentArray.count];
    for(int i = 0; i < tournamentArray.count; i++)
    {
        NSMutableArray *zeile = [[NSMutableArray alloc]initWithCapacity:rounds.count];
        for(int j = 0; j < rounds.count; j++)
        {
            [zeile addObject:@"-"];
        }
        [drawArray addObject:zeile];
    }
    int z = 0;
    int s = 0;
    for(NSArray *zeile in tournamentArray)
    {
        for(NSDictionary *spalte in zeile)
        {
            NSString *name =  [[spalte objectForKey:@"Text"] stringByReplacingOccurrencesOfString:@"<" withString:@""];
            name =  [name stringByReplacingOccurrencesOfString:@">" withString:@""];

            drawArray[z][s] = name;
            s++;
        }
        z++;
        s = 0;
    }
    
//    for(NSMutableArray *zeileArray in drawArray) // this is just a test printout
//    {
//        NSString *zeile = @"";
//        for(NSString *spalte in zeileArray)
//        {
//            NSString *tmpText = [spalte stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
//            const char *spalteText = [tmpText UTF8String];
//            zeile = [NSString stringWithFormat:@"%@ \t%15.15s", zeile, spalteText];
//        }
//        XLog(@"%@",zeile);
//    }
    return;
}
-(void)drawTournament
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"user"];

    NSMutableArray *rootLabelArray = [[NSMutableArray alloc]initWithCapacity:16];
    NSMutableArray *topLabelArray = [[NSMutableArray alloc]initWithCapacity:16];
   
    xFound = 0;
    yFound = 0;
    
    int edge = 0;
    int x = edge;
    
    float y = edge;
    int labelHeight = 30;
    int labelWidth = 150;
    int gap = 20;
    
    float yOld = y;
    NSMutableArray *rounds = drawArray[0];
    for(int i = 0; i < rounds.count; i++)
    {
        int step = pow(2,i);
        int position = 1;
        NSString *labeltext = @"?";

        for(int j = 0; j < drawArray.count; j++)
        {
            NSString *arrayText = drawArray[j][i];
            if(![@"-" isEqualToString:arrayText])
            {
                labeltext = drawArray[j][i];
            }
            if(position == step)
            {

                DGLabel *namelabel = [[DGLabel alloc]initWithFrame:CGRectMake(x , y ,labelWidth, labelHeight)];
                namelabel.layer.cornerRadius = 14.0f;
                namelabel.layer.masksToBounds = YES;
                namelabel.layer.borderWidth = 1;
                namelabel.textAlignment = NSTextAlignmentCenter;
                namelabel.text = labeltext;
                if ([labeltext rangeOfString:userName].location == NSNotFound)
                {
                }
                else
                {
                    namelabel.backgroundColor = [UIColor colorNamed:@"ColorTournamentCell"];
                //    namelabel.textColor = [UIColor whiteColor];
                    xFound = x;
                    yFound = y;
                }
                [scrollView addSubview:namelabel];
                  
                position = 1;
                y += (((labelHeight+gap) )  * step)  ;
                
                [topLabelArray addObject:namelabel];
                if(step > 1)
                {
                    int index = (int)topLabelArray.count * 2;
                    DGLabel *root1 = rootLabelArray[index-2];
                    DGLabel *root2 = rootLabelArray[index-1];
                    CellConnector *connector = [[CellConnector alloc]initFromLabels:namelabel rootLabel1:root1 rootLabel2:root2];
                    [scrollView addSubview:connector];
                    // draw connector
                }
            }
            else
            {
                position++;
            }

            
        }

        rootLabelArray = [topLabelArray mutableCopy];
        topLabelArray = [[NSMutableArray alloc]initWithCapacity:16];

        x += labelWidth + gap;
        y = edge + (((labelHeight+gap) * step ) /2) + yOld;
        yOld = y-edge;
      //  XLog(@"y %3.1f step %d",y, step);
    }
    
    scrollView.contentSize = CGSizeMake((labelWidth+gap)*rounds.count, (labelHeight+gap)*drawArray.count);
//    [scrollView setNeedsDisplay];
}
- (IBAction)findMe:(id)sender
{
    [UIView animateWithDuration:2.0f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self->scrollView.contentOffset = CGPointMake(self->xFound, self->yFound);
    } completion:NULL];

}

- (IBAction)moreAction:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    iPhoneMenue *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneMenue"];
    [self.navigationController pushViewController:vc animated:NO];
    
}

#pragma mark - Header
#include "HeaderInclude.h"

@end
