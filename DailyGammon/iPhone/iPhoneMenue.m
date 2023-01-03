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
#import "TopPageVC.h"
#import "LoginVC.h"
#import "SetupVC.h"
#import "About.h"
#import <SafariServices/SafariServices.h>
#import "Player.h"
#import "GameLounge.h"
#import "DGButton.h"

@interface iPhoneMenue ()

@end

@implementation iPhoneMenue

@synthesize design;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;

    [self makeButtons] ;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self makeButtons] ;

}

- (void) makeButtons
{
    design = [[Design alloc] init];
    
    int maxBreite = [UIScreen mainScreen].bounds.size.width;
    if([design isX]) //Notch
        maxBreite -= 30;
    
    int x = 0, y = 50;
    int diceBreite = 40;
    int luecke = 10;
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    int countDB = [app.dbConnect countRating];
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"iCloud"]boolValue])
        countDB = 99;
    
    int minDB = 5;
    int anzahlButtons = 3;
//    if(countDB > minDB)
//        anzahlButtons = 7;
    
    int buttonBreite = (maxBreite - diceBreite - (anzahlButtons * luecke) ) / anzahlButtons;
    
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
    diceView.frame = CGRectMake(x, y, diceBreite, diceBreite);
    
    x +=  diceBreite + luecke;
    
    DGButton *button1 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonBreite - 10, 35)];
    [button1 setTitle:@"Top Page" forState: UIControlStateNormal];
    button1.tag = 1;
    [button1 addTarget:self action:@selector(topPageVC) forControlEvents:UIControlEventTouchUpInside];
    
    x += buttonBreite + luecke;
    
    DGButton *button2 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonBreite - 10, 35)];
    [button2 setTitle:@"Game Lounge" forState: UIControlStateNormal];
    button2.tag = 2;
    [button2 addTarget:self action:@selector(GameLoungeVC) forControlEvents:UIControlEventTouchUpInside];
    
    x += buttonBreite + luecke;
    
    DGButton *button3 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonBreite - 10, 35)];
    [button3 setTitle:@"Help" forState: UIControlStateNormal];
    button3.tag = 3;
    [button3 addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];
    
    x =  diceBreite + luecke;
    y += 100;
    
    DGButton *button4 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonBreite - 10, 35)];
    [button4 setTitle:@"Settings" forState: UIControlStateNormal];
    button4.tag = 4;
    [button4 addTarget:self action:@selector(SetUpVC) forControlEvents:UIControlEventTouchUpInside];
    
    x += buttonBreite + luecke;
    
    DGButton *button5 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonBreite - 10, 35)];
    [button5 setTitle:@"Log Out" forState: UIControlStateNormal];
    button5.tag = 5;
    [button5 addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    
    x += buttonBreite + luecke;
    
    DGButton *button6 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonBreite - 10, 35)];
    [button6 setTitle:@"About" forState: UIControlStateNormal];
    button6.tag = 6;
    [button6 addTarget:self action:@selector(AboutVC) forControlEvents:UIControlEventTouchUpInside];
    
    x =  diceBreite + luecke;
    y += 100;
    
    DGButton *button7 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonBreite - 10, 35)];
    [button7 setTitle:@"Rating" forState: UIControlStateNormal];
    button7.tag = 7;
    [button7 addTarget:self action:@selector(ratingVC) forControlEvents:UIControlEventTouchUpInside];
    
    x += buttonBreite + luecke;
    
    DGButton *button8 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonBreite - 10, 35)];
    [button8 setTitle:@"Players" forState: UIControlStateNormal];
    button8.tag = 8;
    [button8 addTarget:self action:@selector(playerVC) forControlEvents:UIControlEventTouchUpInside];
    
    x += buttonBreite + luecke;

    [self.view addSubview:diceView];
    
    [self.view addSubview:button1];
    [self.view addSubview:button2];
    [self.view addSubview:button3];
    [self.view addSubview:button4];
    [self.view addSubview:button5];
    [self.view addSubview:button6];
    if(countDB > minDB)
        [self.view addSubview:button7];
    [self.view addSubview:button8];

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
    
    TopPageVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneTopPageVC"];
    
    [self.navigationController pushViewController:vc animated:NO];
}

-(void) GameLoungeVC
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    GameLounge *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneGameLounge"];
    
    [self.navigationController pushViewController:vc animated:NO];
}

-(void) playerVC
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Player *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"PlayerVC"];
    
    [self.navigationController pushViewController:vc animated:NO];
}

-(void) SetUpVC
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    SetUpVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"SetUpVC"];
    
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)logout
{
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    LoginVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"LoginVC"];
    [self.navigationController pushViewController:vc animated:NO];
}
- (IBAction)AboutVC
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    About *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneAbout"];
    vc.showRemindMeLaterButton = NO;
    [self.navigationController pushViewController:vc animated:NO];
    
}
-(void) help
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com/help"]];
    if ([SFSafariViewController class] != nil) {
        SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:URL];
        [self presentViewController:sfvc animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
    }
}


@end
