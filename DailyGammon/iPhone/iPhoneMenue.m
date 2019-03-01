//
//  iPhoneMenue.m
//  DailyGammon
//
//  Created by Peter on 01.03.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import "iPhoneMenue.h"
#import "Design.h"
#import "DbConnect.h"
#import "AppDelegate.h"
#import "RatingVC.h"
#import "iPhoneTopPageVC.h"
#import "LoginVC.h"

#import "GameLounge.h"

@interface iPhoneMenue ()

@end

@implementation iPhoneMenue

@synthesize design;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:[self makeHeader] ];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
}
-(UIView *)makeHeader
{
    design = [[Design alloc] init];
    
    int maxBreite = [UIScreen mainScreen].bounds.size.width;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, maxBreite - 40, 50)];
    
    int x = 0, y = 0;
    int diceBreite = 40;
    int luecke = 10;
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    int countDB = [app.dbConnect countRating];
    int minDB = 3;
    int anzahlButtons = 3;
    if(countDB > minDB)
        anzahlButtons = 7;
    int headerBreite = headerView.frame.size.width;
    
    int buttonBreite = (headerBreite - diceBreite - (anzahlButtons * luecke) ) / anzahlButtons;
    
    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1)
        boardSchema = 4;
    NSString *imageName = @"dice_rot.png";
    switch(boardSchema)
    {
        case 1:
        case 2:
            imageName = @"dice_gruen.png";
            break;
        case 3:
            imageName = @"dice_blau.png";
            break;
        case 4:
            imageName = @"dice_rot.png";
            break;
            
    }
    UIImageView *diceView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    diceView.frame = CGRectMake(0, 5, diceBreite, diceBreite);
    
    x +=  diceBreite + luecke;
    y = 5;
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    button1 = [design makeNiceFlatButton:button1];
    [button1 setTitle:@"Top Page" forState: UIControlStateNormal];
    button1.frame = CGRectMake(x, y, buttonBreite - 10, 35);
    button1.tag = 1;
    [button1 addTarget:self action:@selector(topPageVC) forControlEvents:UIControlEventTouchUpInside];
    
    x += buttonBreite + luecke;
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    button2 = [design makeNiceFlatButton:button2];
    [button2 setTitle:@"Game Lounge" forState: UIControlStateNormal];
    button2.frame = CGRectMake(x, y, buttonBreite - 10, 35);
    button2.tag = 2;
    [button2 addTarget:self action:@selector(GameLoungeVC) forControlEvents:UIControlEventTouchUpInside];
    
    x += buttonBreite + luecke;
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeSystem];
    button3 = [design makeNiceFlatButton:button3];
    [button3 setTitle:@"Help" forState: UIControlStateNormal];
    button3.frame = CGRectMake(x, y, buttonBreite - 10, 35);
    button3.tag = 3;
    [button3 addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];
    
    x =  diceBreite + luecke;
    y = 100;
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeSystem];
    button4 = [design makeNiceFlatButton:button4];
    [button4 setTitle:@"Settings" forState: UIControlStateNormal];
    button4.frame = CGRectMake(x, y, buttonBreite - 10, 35);
    button4.tag = 4;
    [button4 addTarget:self action:@selector(popoverSetUp:) forControlEvents:UIControlEventTouchUpInside];
    
    x += buttonBreite + luecke;
    
    UIButton *button5 = [UIButton buttonWithType:UIButtonTypeSystem];
    button5 = [design makeNiceFlatButton:button5];
    [button5 setTitle:@"Log Out" forState: UIControlStateNormal];
    button5.frame = CGRectMake(x, y, buttonBreite - 10, 35);
    button5.tag = 5;
    [button5 addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    
    x += buttonBreite + luecke;
    
    UIButton *button6 = [UIButton buttonWithType:UIButtonTypeSystem];
    button6 = [design makeNiceFlatButton:button6];
    [button6 setTitle:@"About" forState: UIControlStateNormal];
    button6.frame = CGRectMake(x, y, buttonBreite - 10, 40);
    button6.tag = 6;
    [button6 addTarget:self action:@selector(showPopOverAbout:) forControlEvents:UIControlEventTouchUpInside];
    
    x =  diceBreite + luecke;
    y = 200;
    

    UIButton *button7 = [UIButton buttonWithType:UIButtonTypeSystem];
    button7 = [design makeNiceFlatButton:button7];
    [button7 setTitle:@"Rating" forState: UIControlStateNormal];
    button7.frame = CGRectMake(x, y, buttonBreite - 10, 40);
    button7.tag = 7;
    [button7 addTarget:self action:@selector(ratingVC) forControlEvents:UIControlEventTouchUpInside];
    
    x += buttonBreite + luecke;
    
    [headerView addSubview:diceView];
    
    [headerView addSubview:button1];
    [headerView addSubview:button2];
    [headerView addSubview:button3];
    [headerView addSubview:button4];
    [headerView addSubview:button5];
    [headerView addSubview:button6];
    if(countDB > minDB)
        [headerView addSubview:button7];
    
    return headerView;
}
-(void) ratingVC
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    RatingVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"RatingVC"];
    
    [self.navigationController pushViewController:vc animated:NO];
}

-(void) topPageVC
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    iPhoneTopPageVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneTopPageVC"];
    
    [self.navigationController pushViewController:vc animated:NO];
}

-(void) GameLoungeVC
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    GameLounge *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"GameLoungeVC"];
    
    [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)popoverSetUp:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIViewController *controller = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"SetUpVC"];
    
    // present the controller
    // on iPad, this will be a Popover
    // on iPhone, this will be an action sheet
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    popController.delegate = self;
    
    UIButton *button = (UIButton *)sender;
    popController.sourceView = button;
    popController.sourceRect = button.bounds;
}

- (void)logout
{
    NSURL *urlMatch = [NSURL URLWithString:@"http://dailygammon.com/bg/logout"];
    
    NSError *error = nil;
    NSStringEncoding encoding = 0;
    NSString *matchString = [[NSString alloc] initWithContentsOfURL:urlMatch
                                                       usedEncoding:&encoding
                                                              error:&error];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    LoginVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"LoginVC"];
    [self.navigationController pushViewController:vc animated:NO];
}
- (IBAction)showPopOverAbout:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIViewController *controller = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"About"];
    
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    popController.delegate = self;
    
    UIButton *button = (UIButton *)sender;
    popController.sourceView = button;
    popController.sourceRect = button.bounds;
    
}
-(void) help
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://dailygammon.com/help"] options:@{} completionHandler:nil];
}

@end
