//
//  Review.m
//  DailyGammon
//
//  Created by Peter Schneider on 18.02.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import "Review.h"

#import "Design.h"
#import "Tools.h"

#import "DGLabel.h"
#import "DGButton.h"
#import "DGRequest.h"

#import "AppDelegate.h"
#import "TFHpple.h"
#import "PlayMatch.h"
#import "Preferences.h"
#import "Rating.h"
#import "LoginVC.h"
#import "GameLounge.h"
#import "DbConnect.h"
#import "RatingVC.h"
#import "Player.h"
#import "iPhoneMenue.h"
#import "TopPageVC.h"
#import "About.h"
#import "PlayerLists.h"
#import "Constants.h"

#import "PlayMatch.h"
#import "iPhonePlayMatch.h"

@interface Review ()

@property (weak, nonatomic) IBOutlet DGLabel *header;
@property (weak, nonatomic) IBOutlet DGLabel *matchLengthLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;

@property (readwrite, retain, nonatomic) DGButton *topPageButton;


@end

@implementation Review

@synthesize reviewURL, matchLength;

@synthesize listArray;

@synthesize design,tools;
@synthesize player1wonGame;

@synthesize waitView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    design      = [[Design alloc] init];
    tools       = [[Tools alloc] init];

    UIImage *image = [[UIImage imageNamed:@"menue.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.moreButton setImage:image forState:UIControlStateNormal];
    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
    self.moreButton.tintColor = [schemaDict objectForKey:@"TintColor"];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    listArray = [[NSMutableArray alloc]init];

    if([design isX])
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        UIWindow *keyWindow = (UIWindow *) windows[0];
        UIEdgeInsets safeArea = keyWindow.safeAreaInsets;

        CGRect frame = self.tableView.frame;
        frame.origin.x = safeArea.left ;
        frame.size.width = self.tableView.frame.size.width - safeArea.left ;
        self.tableView.frame = frame;
    }
    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
    
    self.tableView.backgroundColor = [UIColor colorNamed:@"ColorTableView"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reDrawHeader) name:changeSchemaNotification object:nil];

    player1wonGame = FALSE;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reDrawHeader];

    [self startActivityIndicator:@"Getting moves from www.dailygammon.com"];
    
//    reviewURL = [NSURL URLWithString:@"http://dailygammon.com/bg/game/4796082/1/list"]; // This line is important. It can be used to quickly test certain matches that show strange behavior. Do not delete!
    
    DGRequest *request = [[DGRequest alloc] initWithURL:reviewURL completionHandler:^(BOOL success, NSError *error, NSString *result)
    {
        if (success)
        {
            [ self readReviewList:result];
        }
        else
        {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    request = nil;

    self.matchLengthLabel.text = [NSString stringWithFormat:@"%d point match",matchLength];
}

#pragma mark - WaitView

- (void)startActivityIndicator:(NSString *)text
{
    if(!waitView)
    {
        waitView = [[WaitView alloc]initWithText:text];
    }
    else
    {
        waitView.messageText = text;
    }
    [waitView showInView:self.view];
}

- (void)stopActivityIndicator
{
    [waitView dismiss];
}

-(void) reDrawHeader
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        UIView *header = [self makeHeader];
        if(header)
            [self.view addSubview:header];
    }
    
    self.navigationBar.leftBarButtonItems = nil;

    self.moreButton.tintColor = [UIColor colorNamed:@"ColorSwitch"];

}
-(void)readReviewList:(NSString *)htmlString
{

    listArray = [[NSMutableArray alloc]init];

    // Create parser
        
    NSData *htmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];

    NSArray *matchHeader  = [xpathParser searchWithXPathQuery:@"//h3"];
    NSMutableString *matchName = [[NSMutableString alloc]init];
    for(TFHppleElement *element in matchHeader)
    {
        for (TFHppleElement *child in element.children)
        {
            [matchName appendString:[child content]];
        }
    }
    self.header.text = matchName;

    int tableNo = 2;

    NSString *queryString = [NSString stringWithFormat:@"//table[%d]/tr",tableNo];
    NSArray *rows  = [xpathParser searchWithXPathQuery:queryString];
    for(int row = 1; row <= rows.count; row ++)
    {
        NSMutableArray *topPageZeile = [[NSMutableArray alloc]init];

        NSString * searchString = [NSString stringWithFormat:@"//table[%d]/tr[%d]/td",tableNo,row];
        NSArray *elementZeile  = [xpathParser searchWithXPathQuery:searchString];
        if(elementZeile.count < 1)
        {
            searchString = [NSString stringWithFormat:@"//table[%d]/tr[%d]/th",tableNo,row];
            elementZeile  = [xpathParser searchWithXPathQuery:searchString];
        }
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

        [listArray addObject:topPageZeile];
    }
    [self stopActivityIndicator];

    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}
#define CELL_HEIGHT 50
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //https://stackoverflow.com/questions/40203124/uitableviewcell-animation-only-once
    UIView *cellContentView = [cell contentView];
    CGFloat rotationAngleDegrees = -30;
    CGFloat rotationAngleRadians = rotationAngleDegrees * (M_PI/180);
    CGPoint offsetPositioning = CGPointMake(0, cell.contentView.frame.size.height*10);
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DRotate(transform, rotationAngleRadians, -50.0, 0.0, 1.0);
    transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y, -50.0);
    cellContentView.layer.transform = transform;
    cellContentView.layer.opacity = 0.8;
    
    [UIView animateWithDuration:0.95 delay:00 usingSpringWithDamping:0.85 initialSpringVelocity:0.8 options:0 animations:^{
        cellContentView.layer.transform = CATransform3DIdentity;
        cellContentView.layer.opacity = 1;
    } completion:^(BOOL finished) {}];
    cell.backgroundColor = [UIColor colorNamed:@"ColorTableViewCell"];

    return;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    for(UIView *subview in [cell.contentView subviews])
    {
        if([subview isKindOfClass:[DGLabel class]])
            [subview removeFromSuperview];
        if([subview isKindOfClass:[DGButton class]])
            [subview removeFromSuperview];
        if([subview isKindOfClass:[UIImageView class]])
            [subview removeFromSuperview];
        if([subview isKindOfClass:[UIView class]])
            [subview removeFromSuperview];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;

    NSArray *row = listArray[indexPath.row];
    
    int x = 0;
    int y = 5;
    int labelHeight = CELL_HEIGHT - 10;
    int cellWidth   = tableView.frame.size.width;
    
    int edge = 30;
    int gap = 10;
    float halfWidth = (cellWidth - edge - gap -edge) / 2;
    int diceSize = 30;
    
    switch (row.count)
    {
        case 0:

            return cell;

            break;
        case 1: // Game #
        {
#pragma mark Game #
            NSDictionary *dict = row[0];
            DGLabel *headerLabel = [[DGLabel alloc] initWithFrame:CGRectMake(0, y ,cellWidth,labelHeight)];
            headerLabel.textAlignment = NSTextAlignmentCenter;
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [dict objectForKey:@"Text"]]];
            [attr addAttribute:NSFontAttributeName
                         value:[UIFont systemFontOfSize:30.0]
                         range:NSMakeRange(0, [attr length])];
            [headerLabel setAttributedText:attr];

            [cell.contentView addSubview:headerLabel];
            return cell;
        }
            break;
        case 2: // Wins xx points
        {
            NSDictionary *dict = row[0];
            NSString *text = [dict objectForKey:@"Text"];
            if([text isEqualToString:@"&nbsp"])
            {
#pragma mark "Player 1 Wins xx points"
                dict = row[1];
                int x = edge + diceSize + gap + diceSize + gap;
                DGButton *won = [[DGButton alloc] initWithFrame:CGRectMake(x, y ,halfWidth - (diceSize + gap +diceSize + gap) ,labelHeight)];
                [won setTitle:[dict objectForKey:@"Text"] forState: UIControlStateNormal];
                [won addTarget:self action:@selector(moveAction:) forControlEvents:UIControlEventTouchUpInside];
                [won.layer setValue:[dict objectForKey:@"href"] forKey:@"href"];
                [cell.contentView addSubview:won];
                return cell;
            }
            dict = row[0];
            text = [dict objectForKey:@"Text"];
            unichar chr = [text characterAtIndex:0];
          //  NSLog(@"case 3: ascii value %d %@", chr, row);
            if(chr == 160)
            {
#pragma mark "Player 2 Wins xx points"
                dict = row[1];
                int x = edge + halfWidth + gap + diceSize + gap + diceSize + gap;
                DGButton *won = [[DGButton alloc] initWithFrame:CGRectMake(x, y ,halfWidth - (diceSize + gap +diceSize + gap) ,labelHeight)];
                [won setTitle:[dict objectForKey:@"Text"] forState: UIControlStateNormal];
                [won addTarget:self action:@selector(moveAction:) forControlEvents:UIControlEventTouchUpInside];
                [won.layer setValue:[dict objectForKey:@"href"] forKey:@"href"];
                [cell.contentView addSubview:won];
                return cell;
            }
            dict = row[1];

            NSRange player1Double = [[dict objectForKey:@"Text"] rangeOfString:@"Doubles"];
            if(player1Double.length > 0)
            {
#pragma mark "Doubles => 2 (4,8,16,32,64) Opponents move not done yet"
                DGLabel *number = [[DGLabel alloc] initWithFrame:CGRectMake(0, y ,edge,labelHeight)];
                number.textAlignment = NSTextAlignmentLeft;
                NSDictionary *dict = row[0];
                number.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"Text"]];
                [cell.contentView addSubview:number];

                UIView *doubleView = [[UIView alloc] initWithFrame:CGRectMake(edge, 0 ,halfWidth,CELL_HEIGHT)];
                doubleView = [self makeDoubleView:doubleView  cube:row[1]   gap:gap diceSize:diceSize];
                [cell.contentView addSubview:doubleView];

                return cell;
            }

            for(NSDictionary *dict in row)
            {
                text = [NSString stringWithFormat:@"%@ >%@<",text, [dict objectForKey:@"Text"]];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"The algorithm should never get here %ld %@",row.count, text];
            cell.contentView.backgroundColor = UIColor.greenColor;

            return cell;
        }
            break;
        case 3:
        {
            // "hape42:0  opponent:1"
            // or
            // "Doubles => 2    Takes"
            // or
            // Drops    Wins 1 point
            
            NSDictionary *dict = row[0];
            NSString *text = [dict objectForKey:@"Text"];
            unichar chr = [text characterAtIndex:0];
          //  NSLog(@"case 3: ascii value %d %@", chr, row);
            if(chr == 160)
            {
#pragma mark "hape42:0  opponent:1"

                int x = edge + diceSize + gap + diceSize + gap;
                DGLabel *player1 = [[DGLabel alloc] initWithFrame:CGRectMake(x, y, halfWidth - (diceSize + gap + diceSize + gap), labelHeight)];
                player1.textAlignment = NSTextAlignmentCenter;
                
                x += player1.frame.size.width + gap + diceSize + gap + diceSize + gap;
                DGLabel *player2 = [[DGLabel alloc] initWithFrame:CGRectMake(x, y, halfWidth - (diceSize + gap + diceSize + gap), labelHeight)];
                player2.textAlignment = NSTextAlignmentCenter;
                
                dict = row[1];
                player1.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"Text"]];
                dict = row[2];
                player2.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"Text"]];
                
                [cell.contentView addSubview:player1];
                [cell.contentView addSubview:player2];
                return cell;

            }
            dict = row[1];

            NSRange player1Double = [[dict objectForKey:@"Text"] rangeOfString:@"Doubles"];
            if(player1Double.length > 0)
            {
#pragma mark "Doubles => 2 (4,8,16,32,64)   Takes/Drops"
                DGLabel *number = [[DGLabel alloc] initWithFrame:CGRectMake(0, y ,edge,labelHeight)];
                number.textAlignment = NSTextAlignmentLeft;
                NSDictionary *dict = row[0];
                number.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"Text"]];
                [cell.contentView addSubview:number];

                UIView *doubleView = [[UIView alloc] initWithFrame:CGRectMake(edge, 0 ,halfWidth,CELL_HEIGHT)];
                doubleView = [self makeDoubleView:doubleView  cube:row[1]   gap:gap diceSize:diceSize];
                [cell.contentView addSubview:doubleView];

                x = edge + halfWidth + gap + diceSize + gap + diceSize + gap;
                dict = row[2];
                DGButton *take = [[DGButton alloc] initWithFrame:CGRectMake(x, y ,halfWidth - (diceSize + gap +diceSize + gap) ,doubleView.frame.size.height-10)];
                [take setTitle:[dict objectForKey:@"Text"] forState: UIControlStateNormal];
                [take addTarget:self action:@selector(moveAction:) forControlEvents:UIControlEventTouchUpInside];
                [take.layer setValue:[dict objectForKey:@"href"] forKey:@"href"];
                [cell.contentView addSubview:take];

                return cell;
            }

            dict = row[1];
            NSRange player1Drops = [[dict objectForKey:@"Text"] rangeOfString:@"Drops"];
            if(player1Drops.length > 0)
            {
#pragma mark "player 1 drops"
                DGLabel *number = [[DGLabel alloc] initWithFrame:CGRectMake(0, y ,edge,labelHeight)];
                number.textAlignment = NSTextAlignmentLeft;
                NSDictionary *dict = row[0];
                number.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"Text"]];
                [cell.contentView addSubview:number];
                
                dict = row[1];
                int x = edge + diceSize + gap + diceSize + gap;
                DGButton *drop = [[DGButton alloc] initWithFrame:CGRectMake(x, y ,halfWidth - (diceSize + gap +diceSize + gap) ,labelHeight)];
                [drop setTitle:[dict objectForKey:@"Text"] forState: UIControlStateNormal];
                [drop addTarget:self action:@selector(moveAction:) forControlEvents:UIControlEventTouchUpInside];
                [drop.layer setValue:[dict objectForKey:@"href"] forKey:@"href"];
                [cell.contentView addSubview:drop];

                x = edge + halfWidth + gap + diceSize + gap + diceSize + gap;
                dict = row[2];
                DGButton *won = [[DGButton alloc] initWithFrame:CGRectMake(x, y ,halfWidth - (diceSize + gap +diceSize + gap) ,labelHeight)];
                [won setTitle:[dict objectForKey:@"Text"] forState: UIControlStateNormal];
                [won addTarget:self action:@selector(moveAction:) forControlEvents:UIControlEventTouchUpInside];
                [won.layer setValue:[dict objectForKey:@"href"] forKey:@"href"];
                [cell.contentView addSubview:won];

                return cell;

            }
            dict = row[1];
#pragma mark "only player 1 has a move (last move of game)"
            int dice1 = [[[dict objectForKey:@"Text"]substringWithRange:NSMakeRange(0, 1)]intValue];
            if(dice1 > 0)
            {
                DGLabel *number = [[DGLabel alloc] initWithFrame:CGRectMake(0, y ,edge,labelHeight)];
                number.textAlignment = NSTextAlignmentLeft;
                NSDictionary *dict = row[0];
                number.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"Text"]];
                [cell.contentView addSubview:number];

                x = edge;
                UIView *moveView = [[UIView alloc] initWithFrame:CGRectMake(x, 0 ,halfWidth,CELL_HEIGHT)];
                moveView = [self makeMoveView:moveView playerColor:@"b" dices:row[1] move:row[2]  gap:gap diceSize:diceSize];
                [cell.contentView addSubview:moveView];
                                
                return cell;

            }
            // The algorythm should never get here
            for(NSDictionary *dict in row)
            {
                text = [NSString stringWithFormat:@"%@ >%@<",text, [dict objectForKey:@"Text"]];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"The algorithm should never get here %ld %@",row.count, text];
            cell.contentView.backgroundColor = UIColor.yellowColor;

            
            return cell;
        }

            break;
        case 4:
        {
            // "start with player 2"
            // or
            // "player 2 doubles"
            
            DGLabel *number = [[DGLabel alloc] initWithFrame:CGRectMake(0, y ,edge,labelHeight)];
            number.textAlignment = NSTextAlignmentLeft;
            NSDictionary *dict = row[0];
            number.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"Text"]];
            [cell.contentView addSubview:number];

            dict = row[1];
            NSString *text = [dict objectForKey:@"Text"];
            unichar chr = [text characterAtIndex:0];
           // NSLog(@"case 4: ascii value %d %@", chr, row);
            if(chr == 160)
            {
#pragma mark "start with player 2"
                x = edge + halfWidth  + gap ;

                UIView *moveView = [[UIView alloc] initWithFrame:CGRectMake(x, 0 ,halfWidth,CELL_HEIGHT)];
                moveView = [self makeMoveView:moveView playerColor:@"y" dices:row[2] move:row[3]  gap:gap diceSize:diceSize];
                [cell.contentView addSubview:moveView];
                return cell;
            }
            dict = row[3];
            NSRange player1Double = [[dict objectForKey:@"Text"] rangeOfString:@"Doubles"];
            if(player1Double.length > 0)
            {
#pragma mark "player 2 doubles"
                DGLabel *number = [[DGLabel alloc] initWithFrame:CGRectMake(0, y ,edge,labelHeight)];
                number.textAlignment = NSTextAlignmentLeft;
                NSDictionary *dict = row[0];
                number.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"Text"]];
                [cell.contentView addSubview:number];

                x = edge;
                UIView *moveView = [[UIView alloc] initWithFrame:CGRectMake(x, 0 ,halfWidth,CELL_HEIGHT)];
                moveView = [self makeMoveView:moveView playerColor:@"b" dices:row[1] move:row[2]  gap:gap diceSize:diceSize];
                [cell.contentView addSubview:moveView];

                x += halfWidth + gap;
                UIView *doubleView = [[UIView alloc] initWithFrame:CGRectMake(x, 0 ,halfWidth,CELL_HEIGHT)];
                doubleView = [self makeDoubleView:doubleView  cube:row[3]   gap:gap diceSize:diceSize];
                [cell.contentView addSubview:doubleView];

                return cell;
            }
            
            dict = row[1];
            NSRange player1Takes = [[dict objectForKey:@"Text"] rangeOfString:@"Takes"];
            if(player1Takes.length > 0)
            {
#pragma mark "player 1 takes"
                DGLabel *number = [[DGLabel alloc] initWithFrame:CGRectMake(0, y ,edge,labelHeight)];
                number.textAlignment = NSTextAlignmentLeft;
                NSDictionary *dict = row[0];
                number.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"Text"]];
                [cell.contentView addSubview:number];

                dict = row[1];
                x = edge + diceSize + gap + diceSize + gap;
                DGButton *take = [[DGButton alloc] initWithFrame:CGRectMake(x, y ,halfWidth - (diceSize + gap +diceSize + gap) ,labelHeight)];
                [take setTitle:[dict objectForKey:@"Text"] forState: UIControlStateNormal];
                [take addTarget:self action:@selector(moveAction:) forControlEvents:UIControlEventTouchUpInside];
                [take.layer setValue:[dict objectForKey:@"href"] forKey:@"href"];
                [cell.contentView addSubview:take];

                x = edge + halfWidth + gap;
                UIView *moveView = [[UIView alloc] initWithFrame:CGRectMake(x, 0 ,halfWidth,CELL_HEIGHT)];
                moveView = [self makeMoveView:moveView playerColor:@"y" dices:row[2] move:row[3]  gap:gap diceSize:diceSize];
                [cell.contentView addSubview:moveView];

                return cell;
            }
            dict = row[3];
            NSRange player2wins = [[dict objectForKey:@"Text"] rangeOfString:@"Wins"];
            if(player2wins.length > 0)
            {
#pragma mark "player 2 wins xx points"
                DGLabel *number = [[DGLabel alloc] initWithFrame:CGRectMake(0, y ,edge,labelHeight)];
                number.textAlignment = NSTextAlignmentLeft;
                NSDictionary *dict = row[0];
                number.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"Text"]];
                [cell.contentView addSubview:number];

                x = edge;
                UIView *moveView = [[UIView alloc] initWithFrame:CGRectMake(x, 0 ,halfWidth,CELL_HEIGHT)];
                moveView = [self makeMoveView:moveView playerColor:@"b" dices:row[1] move:row[2]  gap:gap diceSize:diceSize];
                [cell.contentView addSubview:moveView];

                x = edge + halfWidth + gap + diceSize + gap + diceSize + gap;
                dict = row[3];
                DGButton *won = [[DGButton alloc] initWithFrame:CGRectMake(x, y ,halfWidth - (diceSize + gap +diceSize + gap) ,labelHeight)];
                [won setTitle:[dict objectForKey:@"Text"] forState: UIControlStateNormal];
                [won addTarget:self action:@selector(moveAction:) forControlEvents:UIControlEventTouchUpInside];
                [won.layer setValue:[dict objectForKey:@"href"] forKey:@"href"];
                [cell.contentView addSubview:won];

                return cell;

            }
            for(NSDictionary *dict in row)
            {
                text = [NSString stringWithFormat:@"%@ >%@<",text, [dict objectForKey:@"Text"]];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"The algorithm should never get here  %ld %@",row.count, text];
            cell.contentView.backgroundColor = UIColor.brownColor;

           
           return cell;
        }

            break;
        case 5:
        {
#pragma mark standard move like: 3)    61:    24/23 23/17*    65:    25/20 13/7
            
            DGLabel *number = [[DGLabel alloc] initWithFrame:CGRectMake(0, y ,edge,labelHeight)];
            number.textAlignment = NSTextAlignmentLeft;
            NSDictionary *dict = row[0];
            number.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"Text"]];
            [cell.contentView addSubview:number];

            x = edge;
            UIView *moveView = [[UIView alloc] initWithFrame:CGRectMake(x, 0 ,halfWidth,CELL_HEIGHT)];
            moveView = [self makeMoveView:moveView playerColor:@"b" dices:row[1] move:row[2]  gap:gap diceSize:diceSize];
            [cell.contentView addSubview:moveView];
            
            x = edge + halfWidth  + gap ;
            moveView = [[UIView alloc] initWithFrame:CGRectMake(x, 0 ,halfWidth,CELL_HEIGHT)];
            moveView = [self makeMoveView:moveView playerColor:@"y" dices:row[3] move:row[4]  gap:gap diceSize:diceSize];
            [cell.contentView addSubview:moveView];
            
            return cell;
        }

            break;

        default:
            break;
    }

    return cell;
}

-(UIView *)makeMoveView:(UIView *)moveView
                 playerColor:(NSString *)playerColor // b=player1 y=player2
                  dices:(NSDictionary *)diceDict
                   move:(NSDictionary *)moveDict
                    gap:(int)gap
               diceSize:(int)diceSize
{
    
    int x = 0;
    int y = 5;
    int dice1 = [[[diceDict objectForKey:@"Text"]substringWithRange:NSMakeRange(0, 1)]intValue];
    int dice2 = [[[diceDict objectForKey:@"Text"]substringWithRange:NSMakeRange(1, 1)]intValue];

    NSString *imgName = [NSString stringWithFormat:@"%d/die_%@%d",[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue],playerColor, dice1] ;
    UIImageView *diceView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    diceView.frame = CGRectMake(x, (moveView.frame.size.height - diceSize)/2.0,  diceSize, diceSize);
    [moveView addSubview:diceView];

    x += diceSize + gap;
    imgName = [NSString stringWithFormat:@"%d/die_%@%d",[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue],playerColor, dice2] ;
    diceView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    diceView.frame = CGRectMake(x, (moveView.frame.size.height - diceSize)/2.0, diceSize, diceSize);
    [moveView addSubview:diceView];

    x += diceSize + gap;
    NSString* moveText = [moveDict objectForKey:@"Text"];
    DGButton *move = [[DGButton alloc] initWithFrame:CGRectMake(x, y ,moveView.frame.size.width - x ,moveView.frame.size.height-10)];
    [move setTitle:[moveDict objectForKey:@"Text"] forState: UIControlStateNormal];
    [move addTarget:self action:@selector(moveAction:) forControlEvents:UIControlEventTouchUpInside];
    [move.layer setValue:[moveDict objectForKey:@"href"] forKey:@"href"];
    if(moveText.length < 2)
    {
       // no move, dancing.
        DGLabel *dancing = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,moveView.frame.size.width - x ,moveView.frame.size.height-10)];
        dancing.textAlignment = NSTextAlignmentCenter;
        dancing.text = [NSString stringWithFormat:@"🎼\t🕺\t🎼"];
        [moveView addSubview:dancing];
    }
    else
        [moveView addSubview:move];

    return moveView;
}

-(UIView *)makeDoubleView:(UIView *)doubleView
                  cube:(NSDictionary *)cubeDict
                    gap:(int)gap
               diceSize:(int)diceSize
{
    
    int x = 0;
    int y = 5;
    
    NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    int cube =  [[[[cubeDict objectForKey:@"Text"] componentsSeparatedByCharactersInSet:nonDigitCharacterSet] componentsJoinedByString:@""]intValue];

    NSString *imgName = [NSString stringWithFormat:@"%d/cube%d",[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue],cube] ;
    UIImageView *cubeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    cubeView.frame = CGRectMake(x + (diceSize / 2), y,  diceSize + gap , doubleView.frame.size.height - y - y);
    [doubleView addSubview:cubeView];


    x += diceSize + gap + diceSize + gap;
    DGButton *move = [[DGButton alloc] initWithFrame:CGRectMake(x, y ,doubleView.frame.size.width - x ,doubleView.frame.size.height-10)];
    [move setTitle:@"Doubles" forState: UIControlStateNormal];
    [move addTarget:self action:@selector(moveAction:) forControlEvents:UIControlEventTouchUpInside];
    [move.layer setValue:[cubeDict objectForKey:@"href"] forKey:@"href"];
    [doubleView addSubview:move];
    return doubleView;
}
- (IBAction)moreAction:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    iPhoneMenue *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneMenue"];
    [self.navigationController pushViewController:vc animated:NO];
    
}

- (IBAction)moveAction:(UIButton*)button
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        PlayMatch *vc = [app.activeStoryBoard  instantiateViewControllerWithIdentifier:@"PlayMatch"];
        vc.matchLink = (NSString *)[button.layer valueForKey:@"href"];
        vc.isReview = TRUE;
        vc.topPageArray = [[NSMutableArray alloc]init];
        [self.navigationController pushViewController:vc animated:NO];
    }
    else
    {
        iPhonePlayMatch *vc = [app.activeStoryBoard  instantiateViewControllerWithIdentifier:@"iPhonePlayMatch"];
        vc.matchLink = (NSString *)[button.layer valueForKey:@"href"];
        vc.topPageArray = [[NSMutableArray alloc]init];
        vc.isReview = TRUE;
        [self.navigationController pushViewController:vc animated:NO];
    }
    return;


}
#pragma mark - Header
#include "HeaderInclude.h"

@end
