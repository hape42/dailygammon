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

@property (strong, nonatomic) IBOutlet UIView *viewBoard;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *selectBoard;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (weak, nonatomic) IBOutlet UISegmentedControl *myColor;
@property (weak, nonatomic) IBOutlet UILabel *titleCheckerColor;
@property (readwrite, retain, nonatomic) UIView *buttonFrame;
@property (readwrite, retain, nonatomic) DGButton *infoButton;

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
              nil];
    
    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1) boardSchema = 4;
    
    NSMutableDictionary *schemaDict = [design schema:boardSchema];

    int maxWidth  = self.view.frame.size.width;
    int maxHeight = self.view.frame.size.height - 20;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        maxWidth = 800;
        maxHeight = 400;
    }
    self.buttonFrame =  [[UIView alloc] initWithFrame:CGRectMake(50,
                                                                maxHeight - 45,
                                                                maxWidth - 100,
                                                                45)];
    self.buttonFrame.layer.borderWidth = 1;
    self.buttonFrame.layer.borderColor = [[schemaDict objectForKey:@"TintColor"] CGColor];
    self.buttonFrame.layer.cornerRadius = 14.0f;

    [self.view addSubview:self.buttonFrame];
    
    
    self.infoButton = [[DGButton alloc] initWithFrame:CGRectMake((self.buttonFrame.frame.size.width / 2) - 25,
                                                                 (self.buttonFrame.frame.size.height / 2) - 15,
                                                            50,
                                                            30)];
    self.infoButton.layer.cornerRadius = 14.0f;
    [self.infoButton setTitle:@"Info" forState: UIControlStateNormal];
    //mittig in buttonFrame setzen
    [self.infoButton addTarget:self action:@selector(info:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonFrame addSubview:self.infoButton];
    int gap = 5;
    CGRect frame = self.myColor.frame;
    frame.origin.y = self.buttonFrame.frame.origin.y - self.myColor.frame.size.height - gap;
    frame.origin.x = self.buttonFrame.frame.origin.x;
    frame.size.width = self.buttonFrame.frame.size.width;
    self.myColor.frame = frame;
    
    frame = self.titleCheckerColor.frame;
    frame.origin.y = self.myColor.frame.origin.y - self.titleCheckerColor.frame.size.height - gap ;
    frame.origin.x = self.buttonFrame.frame.origin.x;
    self.titleCheckerColor.frame = frame;

    frame = self.selectBoard.frame;
    frame.origin.y = self.toolBar.frame.size.height + gap + gap;
    frame.origin.x = self.buttonFrame.frame.origin.x;
    self.selectBoard.frame = frame;

    frame = self.tableView.frame;
    frame.origin.y = self.selectBoard.frame.origin.y + self.selectBoard.frame.size.height + gap;
    frame.origin.x = self.buttonFrame.frame.origin.x;
    frame.size.width = self.buttonFrame.frame.size.width;
    frame.size.height = self.titleCheckerColor.frame.origin.y - self.selectBoard.frame.origin.y - self.selectBoard.frame.size.height - gap;
    self.tableView.frame = frame;
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

- (IBAction)doneAction:(id)sender
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:TRUE];
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
        if ([subview isKindOfClass:[UIImageView class]])
        {
            [subview removeFromSuperview];
        }
    }
    cell.backgroundColor = [UIColor colorNamed:@"ColorTableViewCell"];;

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    NSDictionary *dict = self.boardsArray[indexPath.row];

    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1)
        boardSchema = 4;
    NSMutableDictionary *schemaDict = [design schema:[[dict objectForKey:@"number"]intValue]];

    int x = 0;
    int labelHeight = cell.contentView.frame.size.height;
    labelHeight = 100;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,200,labelHeight/2)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"name"]];
    nameLabel.textColor = [schemaDict objectForKey:@"TintColor"] ;
    [cell.contentView addSubview:nameLabel];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, labelHeight/2 ,200,labelHeight/4)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = [NSString stringWithFormat:@"Designed by"];
    [cell.contentView addSubview:nameLabel];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, labelHeight/4*3 ,200,labelHeight/4)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = [NSString stringWithFormat:@"%@",  [dict objectForKey:@"design"] ];
    [cell.contentView addSubview:nameLabel];

    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d/board",[[dict objectForKey:@"number"]intValue ]]];
    if(!image)
        image = [UIImage imageNamed:@"DeadShot"];
    float factor = image.size.width / image.size.height;
    UIImageView *board =  [[UIImageView alloc] initWithFrame:CGRectMake(200, 5 ,labelHeight * factor,labelHeight-10)];
    board.image = image;
    [cell.contentView addSubview:board];

    UILabel *checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(400, 0 ,50,labelHeight)];
    checkLabel.textAlignment = NSTextAlignmentCenter;
    if([[dict objectForKey:@"number"]intValue] == boardSchema)
        checkLabel.text = @"✅";
    [cell.contentView addSubview:checkLabel];

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
    self.buttonFrame.layer.borderColor = [[schemaDict objectForKey:@"TintColor"] CGColor];
    self.tableView.layer.borderColor = [[schemaDict objectForKey:@"TintColor"] CGColor];
    [[NSNotificationCenter defaultCenter] postNotificationName:changeSchemaNotification object:self];

    [self.tableView reloadData];
}

@end
