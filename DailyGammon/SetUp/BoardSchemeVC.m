//
//  BoardSchemeVC.m
//  DailyGammon
//
//  Created by Peter on 05.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "BoardSchemeVC.h"
#import "Design.h"
#import <SafariServices/SafariServices.h>
#import "DGButton.h"
#import "Constants.h"

@interface BoardSchemeVC ()

@property (weak, nonatomic) IBOutlet DGButton *doneButton;

@property (strong, nonatomic) IBOutlet UIView *viewBoard;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *selectBoard;

@property (weak, nonatomic) IBOutlet UISegmentedControl *myColor;
@property (weak, nonatomic) IBOutlet UILabel *titleCheckerColor;

@property (weak, nonatomic) IBOutlet DGButton *infoButton;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@end

@implementation BoardSchemeVC

@synthesize design;
@synthesize boardsArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    design = [[Design alloc] init];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    boardsArray = [[NSMutableArray alloc] initWithObjects:
                   @{ @"number" : [NSNumber numberWithInt:1],
                      @"name" : @"Classic Original",
                      @"design" : @"DailyGammon",
                      @"colorLight" : @"Yellow",
                      @"colorDark"  : @"Blue"},
                   @{ @"number" : [NSNumber numberWithInt:2],
                      @"name" : @"Classic HD",
                      @"design" : @"DailyGammon",
                      @"colorLight" : @"Yellow",
                      @"colorDark"  : @"Blue"},
                   @{ @"number" : [NSNumber numberWithInt:3],
                      @"name" : @"Blue / White Original",
                      @"design" : @"DailyGammon",
                      @"colorLight" : @"White",
                      @"colorDark"  : @"Blue"},
                   @{ @"number" : [NSNumber numberWithInt:4],
                      @"name" : @"Red / Grey HD",
                      @"design" : @"hape42",
                      @"colorLight" : @"Red",
                      @"colorDark"  : @"Grey"},
                   @{ @"number" : [NSNumber numberWithInt:5],
                      @"name" : @"Wood HD",
                      @"design" : @"darkhelmet",
                      @"colorLight" : @"Light",
                      @"colorDark"  : @"Dark"},
                   @{ @"number" : [NSNumber numberWithInt:6],
                      @"name" : @"Metal HD",
                      @"design" : @"darkhelmet",
                     @"colorLight" : @"Silver",
                      @"colorDark"  : @"Black"},
                   @{ @"number" : [NSNumber numberWithInt:7],
                      @"name" : @"Mono HD",
                      @"design" : @"darkhelmet",
                      @"colorLight" : @"Light",
                      @"colorDark"  : @"Dark"},
                   @{ @"number" : [NSNumber numberWithInt:8],
                      @"name" : @"Unicorn",
                      @"design" : @"Jutta Schneider",
                      @"colorLight" : @"Light",
                      @"colorDark"  : @"Dark"},
//                   @{ @"number" : [NSNumber numberWithInt:9],
//                      @"name" : @"Golf",
//                      @"design" : @"Jutta Schneider",
//                      @"colorLight" : @"Light",
//                      @"colorDark"  : @"Dark"},
//                   @{ @"number" : [NSNumber numberWithInt:10],
//                      @"name" : @"Snooker",
//                      @"design" : @"Jutta Schneider",
//                      @"colorLight" : @"Light",
//                      @"colorDark"  : @"Dark"},
//                   @{ @"number" : [NSNumber numberWithInt:11],
//                      @"name" : @"Billiard",
//                      @"design" : @"Jutta Schneider",
//                      @"colorLight" : @"Light",
//                      @"colorDark"  : @"Dark"},
                   @{ @"number" : [NSNumber numberWithInt:12],
                      @"name" : @"Steampunk",
                      @"design" : @"darkhelmet",
                      @"colorLight" : @"Light",
                      @"colorDark"  : @"Dark"},
                   @{ @"number" : [NSNumber numberWithInt:13],
                      @"name" : @"Sea",
                      @"design" : @"darkhelmet",
                      @"colorLight" : @"White",
                      @"colorDark"  : @"Blue"},
                   @{ @"number" : [NSNumber numberWithInt:14],
                      @"name" : @"Traditional",
                      @"design" : @"darkhelmet",
                      @"colorLight" : @"White",
                      @"colorDark"  : @"Black"},
                   @{ @"number" : [NSNumber numberWithInt:15],
                      @"name" : @"Spring",
                      @"design" : @"darkhelmet",
                      @"colorLight" : @"Yellow",
                      @"colorDark"  : @"Violet"},
              nil];
    
    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1) boardSchema = 4;
    
    NSMutableDictionary *schemaDict = [design schema:boardSchema];

    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.cornerRadius = 14.0f;
    self.tableView.layer.borderColor = [[schemaDict objectForKey:@"TintColor"] CGColor];

    return;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
      
    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1) boardSchema = 4;
    if(boardSchema > self.boardsArray.count) boardSchema = 4;
    NSDictionary *dict = self.boardsArray[boardSchema-1];

    [self.myColor setTitle:[dict objectForKey:@"colorDark"] forSegmentAtIndex:1];
    [self.myColor setTitle:[dict objectForKey:@"colorLight"] forSegmentAtIndex:2];

    int sameColor = [[[NSUserDefaults standardUserDefaults] valueForKey:@"sameColor"]intValue];
    self.myColor.selectedSegmentIndex = sameColor;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.navigationItem.hidesBackButton = YES;

    [self layoutObjects];
}
#pragma mark - autoLayout
-(void)layoutObjects
{
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    float edge = 10.0;
    float gap  = 10.0;
    
#pragma mark doneButton autoLayout
    [self.doneButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.doneButton.topAnchor    constraintEqualToAnchor:safe.topAnchor  constant:edge].active = YES;
    [self.doneButton.leftAnchor   constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.doneButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.doneButton.widthAnchor  constraintEqualToConstant:60].active = YES;

#pragma mark select checker color autoLayout
    [self.infoButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.infoButton.bottomAnchor    constraintEqualToAnchor:safe.bottomAnchor  constant:-edge].active = YES;
    [self.infoButton.leftAnchor   constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.infoButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.infoButton.widthAnchor  constraintEqualToConstant:60].active = YES;

    [self.myColor setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.myColor.centerYAnchor     constraintEqualToAnchor:self.infoButton.centerYAnchor                constant:0].active = YES;
    [self.myColor.leftAnchor constraintEqualToAnchor:self.infoButton.rightAnchor constant:edge].active = YES;
    [self.myColor.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;

    [self.titleCheckerColor setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.titleCheckerColor.bottomAnchor     constraintEqualToAnchor:self.myColor.topAnchor                constant:-gap].active = YES;
    [self.titleCheckerColor.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor constant:0].active = YES;
    [self.titleCheckerColor.heightAnchor  constraintEqualToConstant:35].active = YES;

#pragma mark selectBoard autoLayout
    [self.selectBoard setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.selectBoard.topAnchor     constraintEqualToAnchor:safe.topAnchor               constant:edge].active = YES;
    [self.selectBoard.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor constant:0].active = YES;
    [self.selectBoard.heightAnchor  constraintEqualToConstant:35].active = YES;


    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.tableView.topAnchor     constraintEqualToAnchor:self.selectBoard.bottomAnchor                constant:gap].active = YES;
    [self.tableView.bottomAnchor     constraintEqualToAnchor:self.titleCheckerColor.topAnchor                constant:-gap].active = YES;
    [self.tableView.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.tableView.rightAnchor  constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;

}

- (IBAction)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)myColorAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:((UISegmentedControl*)sender).selectedSegmentIndex  forKey:@"sameColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:changeSchemaNotification object:self];

}

- (IBAction)info:(id)sender
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Info"
                                 message:@"On DailyGammon your checker color is determined at the start of each match. \n\nDepending on the draw, or whether you sent or accepted an invitation, you get one color or the other. \n\n\nThis option allows you to override this and choose the same color for all your matches instead. "
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return self.boardsArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    for (UIView *subview in [cell.contentView subviews])
    {
        if ([subview isKindOfClass:[UILabel class]])
        {
            [subview removeFromSuperview];
        }
        if ([subview isKindOfClass:[DGLabel class]])
        {
            [subview removeFromSuperview];
        }
       if ([subview isKindOfClass:[UIImageView class]])
        {
            [subview removeFromSuperview];
        }
    }
    cell.backgroundColor = [UIColor colorNamed:@"ColorTableViewCell"];;

    cell.accessoryType = UITableViewCellAccessoryNone;

    NSDictionary *dict = self.boardsArray[indexPath.row];

    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1)
        boardSchema = 4;
    NSMutableDictionary *schemaDict = [design schema:[[dict objectForKey:@"number"]intValue]];

    int x = 0;
    int labelHeight = cell.contentView.frame.size.height;
    labelHeight = 100;
    
    UILabel *checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,50,labelHeight)];
    checkLabel.textAlignment = NSTextAlignmentCenter;
    if([[dict objectForKey:@"number"]intValue] == boardSchema)
        checkLabel.text = @"✅";
    [cell.contentView addSubview:checkLabel];

    x += 50;
    
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d/board",[[dict objectForKey:@"number"]intValue ]]];
    if(!image)
        image = [UIImage imageNamed:@"DeadShot"];
    float factor = image.size.width / image.size.height;
    UIImageView *board =  [[UIImageView alloc] initWithFrame:CGRectMake(x, 5 ,labelHeight * factor,labelHeight-10)];
    board.image = image;
    [cell.contentView addSubview:board];

    x += board.frame.size.width + 5;
    int labelWidth = cell.contentView.frame.size.width - x;

    DGLabel *nameLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0 ,labelWidth,labelHeight/2)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"name"]];
    nameLabel.textColor = [schemaDict objectForKey:@"TintColor"] ;
    [cell.contentView addSubview:nameLabel];
    
    nameLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, labelHeight/2 ,labelWidth,labelHeight/4)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = [NSString stringWithFormat:@"Designed by"];
    [cell.contentView addSubview:nameLabel];
    
    nameLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, labelHeight/4*3 ,labelWidth,labelHeight/4)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = [NSString stringWithFormat:@"%@",  [dict objectForKey:@"design"] ];
    [cell.contentView addSubview:nameLabel];

    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.boardsArray[indexPath.row];

    [[NSUserDefaults standardUserDefaults] setInteger:[[dict objectForKey:@"number"]intValue] forKey:@"BoardSchema"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self.myColor setTitle:[dict objectForKey:@"colorDark"] forSegmentAtIndex:1];
    [self.myColor setTitle:[dict objectForKey:@"colorLight"] forSegmentAtIndex:2];

    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
    [UIApplication sharedApplication].delegate.window.tintColor = [schemaDict objectForKey:@"TintColor"];
    self.tableView.layer.borderColor = [[schemaDict objectForKey:@"TintColor"] CGColor];
    [[NSNotificationCenter defaultCenter] postNotificationName:changeSchemaNotification object:self];

    [self.tableView reloadData];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
        [self.tableView reloadData];

     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         // Code to be executed after the animation is completed
     }];

    //XLog(@"Neue Breite: %.2f, Neue Höhe: %.2f", size.width, size.height);

}

@end
