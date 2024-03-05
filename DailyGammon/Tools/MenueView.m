//
//  MenueView.m
//  DailyGammon
//
//  Created by Peter Schneider on 29.12.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import "MenueView.h"
#import "Design.h"
#import "DGButton.h"
#import "DbConnect.h"
#import "Tools.h"

#import "AppDelegate.h"
#import "RatingVC.h"
#import "LoginVC.h"
#import "SetupVC.h"
#import "About.h"
#import <SafariServices/SafariServices.h>
#import "Player.h"
#import "GameLoungeCV.h"
#import "PlayerLists.h"
#import "Constants.h"

#import "TopPageCV.h"

@implementation MenueView

@synthesize design, tools;
@synthesize presentingView;
@synthesize button1;

- (id)init
{
    design      = [[Design alloc] init];

    if (self = [super initWithFrame:CGRectZero])
    {
        self.opaque = FALSE;
        self.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
        self.layer.borderWidth = 1;
        NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
        self.layer.borderColor = [[schemaDict objectForKey:@"TintColor"] CGColor];
        self.layer.cornerRadius = 14.0f;
        self.layer.masksToBounds = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMatchCount) name:matchCountChangedNotification object:nil];

    }
    return self;
}

- (void)showMenueInView:(UIView *)view
{
    tools = [[Tools alloc] init];
    [tools matchCount];

    presentingView = view;
    UITapGestureRecognizer *oneFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTouched:)];
    oneFingerTap.numberOfTapsRequired = 1;
    oneFingerTap.numberOfTouchesRequired = 1;
    [view addGestureRecognizer:oneFingerTap];

    // Place the view at the top right of the menu button

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    int countDB = [app.dbConnect countRating];
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"iCloud"]boolValue])
        countDB = 99;
    int minDB = 5;

    CGRect superFrame = view.frame;

    float buttonCount = 10.0;
    float edge = 5.0;
    float gap = 10;
    float buttonWidth = 200.0;
    float buttonHight = MIN(((superFrame.size.height - 50 - edge) / buttonCount) ,  30.0 + gap) - gap;
    
    CGRect fr = self.frame;
    fr.size.width = edge + buttonWidth + edge;
    fr.size.height = buttonCount * (buttonHight + gap);
    
    fr.origin.x = superFrame.origin.x + superFrame.size.width  - fr.size.width - 50;
    fr.origin.y = 0 - fr.size.height;

    self.frame = fr;
    
    float x =  edge;
    float y = edge;

    button1 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button1 setTitle:[NSString stringWithFormat:@"%d Top Page", [[[NSUserDefaults standardUserDefaults] valueForKey:@"matchCount"]intValue]] forState: UIControlStateNormal];

    button1.tag = 1;
    [button1 addTarget:self action:@selector(topPage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button1];
    y += gap + buttonHight;
    
    DGButton *button2 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button2 setTitle:@"Game Lounge" forState: UIControlStateNormal];
    button2.tag = 2;
    [button2 addTarget:self action:@selector(GameLounge) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button2];
    y += gap + buttonHight;

    DGButton *button3 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button3 setTitle:@"Help" forState: UIControlStateNormal];
    [button3 setImage:[self designButtonImage:@"questionmark.circle"] forState:UIControlStateNormal];
    button3.tag = 3;
    [self addSubview:button3];
    [button3 addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];
    y += gap + buttonHight;
    
    DGButton *button4 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button4 setTitle:@"Settings" forState: UIControlStateNormal];
    [button4 setImage:[self designButtonImage:@"gear.badge.questionmark"] forState:UIControlStateNormal];
    button4.tag = 4;
    [self addSubview:button4];
    [button4 addTarget:self action:@selector(SetUpVC:) forControlEvents:UIControlEventTouchUpInside];
    y += gap + buttonHight;

    DGButton *button5 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button5 setTitle:@"Log Out" forState: UIControlStateNormal];
    [button5 setImage:[self designButtonImage:@"door.right.hand.open"] forState:UIControlStateNormal];
    button5.tag = 5;
    [self addSubview:button5];
    [button5 addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    y += gap + buttonHight;

    DGButton *button6 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button6 setTitle:@"About" forState: UIControlStateNormal];
    [button6 setImage:[self designButtonImage:@"info.circle"] forState:UIControlStateNormal];
    button6.tag = 6;
    [button6 addTarget:self action:@selector(AboutVC) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button6];
    y += gap + buttonHight;
    
    if(countDB > minDB)
    {
        DGButton *button7 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
        [button7 setTitle:@"Rating" forState: UIControlStateNormal];
        [button7 setImage:[self designButtonImage:@"chart.line.uptrend.xyaxis"] forState:UIControlStateNormal];
        button7.tag = 7;
        [button7 addTarget:self action:@selector(ratingVC) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button7];
    }
    y += gap + buttonHight;

    DGButton *button8 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button8 setTitle:@"Players" forState: UIControlStateNormal];
    [button8 setImage:[self designButtonImage:@"person.3"] forState:UIControlStateNormal];
    button8.tag = 8;
    [self addSubview:button8];
    [button8 addTarget:self action:@selector(playerVC) forControlEvents:UIControlEventTouchUpInside];
    y += gap + buttonHight;

    DGButton *button9 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button9 setTitle:@"Lists" forState: UIControlStateNormal];
    [button9 setImage:[self designButtonImage:@"list.number"] forState:UIControlStateNormal];
    [self addSubview:button9];
    button9.tag = 9;
    [button9 addTarget:self action:@selector(lists) forControlEvents:UIControlEventTouchUpInside];
    y += gap + buttonHight;

    DGButton *buttonClose = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [buttonClose setTitle:@"Close" forState: UIControlStateNormal];
    buttonClose.tag = 99;
    [buttonClose addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:buttonClose];
    
    // Add the view at the front of the app's windows

    [view addSubview:self];
        
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.topAnchor constraintEqualToAnchor:view.topAnchor constant:50].active = YES;
    [self.rightAnchor constraintEqualToAnchor:view.rightAnchor constant:-50].active = YES;
    [self.heightAnchor constraintEqualToConstant:self.frame.size.height].active = YES;
    [self.widthAnchor constraintEqualToConstant:self.frame.size.width].active = YES;

    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:1.0  animations:^{
            [self layoutIfNeeded];
        }];

    return;
}
-(UIImage *)designButtonImage:(NSString *)imageName
{
    UIImageSymbolConfiguration *configurationColor = [UIImageSymbolConfiguration configurationWithPaletteColors:@[[UIColor blackColor], [design getTintColorSchema]]];
    UIImageSymbolConfiguration *configurationSize = [UIImageSymbolConfiguration configurationWithPointSize:15];

    UIImageSymbolConfiguration *total = [configurationColor configurationByApplyingConfiguration:configurationSize];
    UIImage *image = [UIImage systemImageNamed:imageName withConfiguration:total];

    return image;
}
- (void)dismiss
{
    [self removeFromSuperview];
    return;
}

- (void)screenTouched:(UIGestureRecognizer *)gesture
{
    CGPoint tapLocation = [gesture locationInView:self];
    if( !CGRectContainsPoint(self.frame, tapLocation) )
    {
        for (UIGestureRecognizer *recognizer in presentingView.gestureRecognizers) 
        {
            [presentingView removeGestureRecognizer:recognizer];
        }
        [self dismiss];
        
    }
}
-(void)updateMatchCount
{
    [button1 setTitle:[NSString stringWithFormat:@"%d Top Page", [[[NSUserDefaults standardUserDefaults] valueForKey:@"matchCount"]intValue]] forState: UIControlStateNormal];
}
-(void) topPage
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    TopPageCV *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"TopPageCV"];
    [self.navigationController pushViewController:vc animated:NO];

}
-(void) ratingVC
{
    RatingVC *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"RatingVC"];
    [self.navigationController pushViewController:vc animated:NO];
}

-(void) GameLounge
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    GameLoungeCV *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"GameLoungeCV"];
    [self.navigationController pushViewController:vc animated:NO];
}

-(void) playerVC
{
    [self.navigationController popToRootViewControllerAnimated:NO];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Player *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"PlayerVC"];
    
    [self.navigationController pushViewController:vc animated:NO];
}

-(void) SetUpVC:(id)sender
{
 //   [self.navigationController popToRootViewControllerAnimated:NO];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    SetUpVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"SetUpVC"];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        vc.modalPresentationStyle = UIModalPresentationPopover;
        [self.navigationController presentViewController:vc animated:YES completion:nil];
        
        UIPopoverPresentationController *popController = [vc popoverPresentationController];
        popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        popController.delegate = self;
        
        UIButton *button = (UIButton *)sender;
        popController.sourceView = button;
        popController.sourceRect = button.bounds;
    }
    else
    {
        [self dismiss];
        [self.navigationController pushViewController:vc animated:NO];
    }
}

- (void)logout
{
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popToRootViewControllerAnimated:NO];

    LoginVC *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
    [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)AboutVC
{
    [self.navigationController popToRootViewControllerAnimated:NO];

    About *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"About"];
    vc.showRemindMeLaterButton = NO;
    [self.navigationController pushViewController:vc animated:NO];

}

-(void) help
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com/help"]];
    
    [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];

}

- (void)lists
{
    [self.navigationController popToRootViewControllerAnimated:NO];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PlayerLists *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"PlayerLists"];

    [self.navigationController pushViewController:vc animated:NO];
}

@end
