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
@property (weak, nonatomic) IBOutlet DGButton *findMeButton;

@end

@implementation Tournament

/*
 * drawArray is the central data structure to draw the (reverse) tournament tree. Each line of the two-dimensional array represents the next path from a leaf up to the root of the tree (ie the winner in the end).
 * Each path except for the first one ends with array elements that contain a "-", which means "path merges into a previous path".
 * Each node can either contain a player name, "In Progress", " " meaning "empty - right of an 'in progress'" or "-" meaning "not relevant, merged into a row above".
 * How many elements of a line are filled depends solely on the line number because of the shape of a reverse binary tree that the array represents: all - 1 - 2 - 1 - 3 - 1 - ... 
 */
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

    UIImage *image = [[UIImage imageNamed:@"menue.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.moreButton setImage:image forState:UIControlStateNormal];
    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
    self.moreButton.tintColor = [schemaDict objectForKey:@"TintColor"];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];

    self.nameTournament.text = name;

//    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
//        [self.view addSubview:[self makeHeader]];

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

    if([self readTournament])
        [self drawTournament];
    else
    {
        self.nameTournament.text = @"Play has not yet begun.";
        CGRect frame = self.findMeButton.frame;
        frame.origin.y = 9999;
        self.findMeButton.frame = frame;
    }
}

#pragma mark - Hpple

-(BOOL)readTournament
{
    NSData *tournamentHtmlData = [NSData dataWithContentsOfURL:url];

    NSString *htmlString = [NSString stringWithUTF8String:[tournamentHtmlData bytes]];
    htmlString = [[NSString alloc]
                  initWithData:tournamentHtmlData encoding: NSISOLatin1StringEncoding];
    NSMutableArray *tournamentArray = [[NSMutableArray alloc]init];
    
    if ([htmlString rangeOfString:@"Play has not yet begun."].location != NSNotFound)
    {
        return FALSE;
    }

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
#warning hier muss der string  "drawArray[z][s] = name" durch ein dict ersetzt werden. dict muss name & href beinhalten. Überall wo drawarray benutzt wird, muss von string auf dict geändert werden.
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
    return TRUE;;
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
    
    [[NSUserDefaults standardUserDefaults] setInteger:labelHeight forKey:@"labelHeight"];
    [[NSUserDefaults standardUserDefaults] synchronize];

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
#warning DGLabel muss durch DGButton ersetzt werden. Aber nur, wenn im namen auch ein Inhalt ist. Der button braucht dann noch href um an die playerInfo zu kommen
#warning     [button.layer setValue:[event objectForKey:@"href"] forKey:@"href"];
#warning target für den Button ist quasi identisch wie bei PlayMatch Zeile 314 & Zeile 1052

                DGLabel *namelabel = [[DGLabel alloc]initWithFrame:CGRectMake(x , y ,labelWidth, labelHeight)];
                namelabel.layer.cornerRadius = 14.0f;
                namelabel.layer.masksToBounds = YES;
                namelabel.layer.borderWidth = 1;
                namelabel.textAlignment = NSTextAlignmentCenter;
                namelabel.text = labeltext;
                if([labeltext caseInsensitiveCompare:userName] == NSOrderedSame)
                {
                    namelabel.backgroundColor = [UIColor colorNamed:@"ColorTournamentCell"];
                    xFound = x;
                    yFound = y;
                }
                if ([labeltext rangeOfString:userName].location == NSNotFound)
                {
                }
                else
                {
                    namelabel.backgroundColor = [UIColor colorNamed:@"ColorTournamentCell"];
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
    int width = self.view.bounds.size.width;
    int height = self.view.bounds.size.height;
    int labelWidth = 150;
    int labelHeight = 30;
    
    int centerX = width/2 - labelWidth/2;
    int centerY = height/2 - labelHeight/2;
    
    [UIView animateWithDuration:2.0f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self->scrollView.contentOffset = CGPointMake(self->xFound-centerX, self->yFound-centerY);
    } completion:NULL];

}



@end
