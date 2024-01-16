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
#import "TopPageVC.h"
#import "LoginVC.h"
#import "SetupVC.h"
#import "About.h"
#import <SafariServices/SafariServices.h>
#import "Player.h"
#import "GameLounge.h"
#import "PlayerLists.h"

@implementation MenueView

@synthesize design, tools;

- (id)init
{
    if (self = [super initWithFrame:CGRectZero])
    {
        self.opaque = FALSE;
        self.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
    }
    return self;
}

- (void)showMenueInView:(UIView *)view
{
    tools = [[Tools alloc] init];
    [tools matchCount];

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

    DGButton *button1 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button1 setTitle:[NSString stringWithFormat:@"%d Top Page", [[[NSUserDefaults standardUserDefaults] valueForKey:@"matchCount"]intValue]] forState: UIControlStateNormal];

    button1.tag = 1;
    [button1 addTarget:self action:@selector(topPageVC) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button1];
    y += gap + buttonHight;
    
    DGButton *button2 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button2 setTitle:@"Game Lounge" forState: UIControlStateNormal];
    button2.tag = 2;
    [button2 addTarget:self action:@selector(GameLoungeVC) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button2];
    y += gap + buttonHight;

    DGButton *button3 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button3 setTitle:@"Help" forState: UIControlStateNormal];
    button3.tag = 3;
    [self addSubview:button3];
    [button3 addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];
    y += gap + buttonHight;
    
    DGButton *button4 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button4 setTitle:@"Settings" forState: UIControlStateNormal];
    button4.tag = 4;
    [self addSubview:button4];
    [button4 addTarget:self action:@selector(SetUpVC:) forControlEvents:UIControlEventTouchUpInside];
    y += gap + buttonHight;

    DGButton *button5 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button5 setTitle:@"Log Out" forState: UIControlStateNormal];
    button5.tag = 5;
    [self addSubview:button5];
    [button5 addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    y += gap + buttonHight;

    DGButton *button6 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button6 setTitle:@"About" forState: UIControlStateNormal];
    button6.tag = 6;
    [button6 addTarget:self action:@selector(AboutVC) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button6];
    y += gap + buttonHight;
    
    if(countDB > minDB)
    {
        DGButton *button7 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
        [button7 setTitle:@"Rating" forState: UIControlStateNormal];
        button7.tag = 7;
        [button7 addTarget:self action:@selector(ratingVC) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button7];
    }
    y += gap + buttonHight;

    DGButton *button8 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button8 setTitle:@"Players" forState: UIControlStateNormal];
    button8.tag = 8;
    [self addSubview:button8];
    [button8 addTarget:self action:@selector(playerVC) forControlEvents:UIControlEventTouchUpInside];
    y += gap + buttonHight;

    DGButton *button9 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button9 setTitle:@"Lists" forState: UIControlStateNormal];
    button9.tag = 9;
    [self addSubview:button9];
    [button9 addTarget:self action:@selector(lists) forControlEvents:UIControlEventTouchUpInside];
    y += gap + buttonHight;

    DGButton *buttonClose = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [buttonClose setTitle:@"Close" forState: UIControlStateNormal];
    buttonClose.tag = 99;
    [buttonClose addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:buttonClose];
    
    // Add the view at the front of the app's windows
    self.backgroundColor = UIColor.clearColor;
    [view addSubview:self];
    
    x = superFrame.origin.x + superFrame.size.width  - fr.size.width - 50;
    y = superFrame.origin.y + 50;
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(x,y,self.frame.size.width,self.frame.size.height);

    } completion:^(BOOL finished) {
    }];

    return;
}


- (void)drawRect:(CGRect)rect
{
    
    design      = [[Design alloc] init];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    // Draw a rectangle with rounded corners
    
    CGFloat radius = 10.0f;
    CGRect fr = rect;

    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
    CGContextSetFillColorWithColor(context, [[UIColor colorNamed:@"ColorViewBackground"] CGColor]);
    CGContextSetFillColorWithColor(context, [[schemaDict objectForKey:@"TintColor"] CGColor]);

    CGMutablePathRef selectionPath = CGPathCreateMutable();
    CGPathMoveToPoint(selectionPath, NULL, fr.origin.x, fr.origin.y + radius);
    CGPathAddLineToPoint(selectionPath, NULL, fr.origin.x, fr.origin.y + fr.size.height - radius);
    CGPathAddArc(selectionPath, NULL, fr.origin.x + radius, fr.origin.y + fr.size.height - radius, radius, M_PI, M_PI / 2, 1);
    CGPathAddLineToPoint(selectionPath, NULL, fr.origin.x + fr.size.width - radius, fr.origin.y + fr.size.height);
    CGPathAddArc(selectionPath, NULL, fr.origin.x + fr.size.width - radius, fr.origin.y + fr.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGPathAddLineToPoint(selectionPath, NULL, fr.origin.x + fr.size.width, fr.origin.y + radius);
    CGPathAddArc(selectionPath, NULL, fr.origin.x + fr.size.width - radius, fr.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
    CGPathAddLineToPoint(selectionPath, NULL, fr.origin.x + radius, fr.origin.y);
    CGPathAddArc(selectionPath, NULL, fr.origin.x + radius, fr.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
    CGPathCloseSubpath(selectionPath);

    CGContextAddPath(context, selectionPath);
    CGContextFillPath(context);
    CGPathRelease(selectionPath);
    
    CGContextRestoreGState(context);
}

- (void)dismiss
{
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(self.frame.origin.x,
                                1000,
                                self.frame.size.width,
                                self.frame.size.height);

    } completion:^(BOOL finished) {
        [self removeFromSuperview];

    }];
}

- (void)screenTouched:(UIGestureRecognizer *)gesture
{
    CGPoint tapLocation = [gesture locationInView:self];
    if( !CGRectContainsPoint(self.frame, tapLocation) )
    {
        [self dismiss];
    }
}

-(void) topPageVC
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    TopPageVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"TopPageVC"];
    
    [self.navigationController pushViewController:vc animated:NO];
}
-(void) ratingVC
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    RatingVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"RatingVC"];
    
    [self.navigationController pushViewController:vc animated:NO];
}

-(void) GameLoungeVC
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    GameLounge *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"GameLounge"];
    
    [self.navigationController pushViewController:vc animated:NO];
}

-(void) playerVC
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Player *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"PlayerVC"];
    
    [self.navigationController pushViewController:vc animated:NO];
}

-(void) SetUpVC:(id)sender
{
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
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    LoginVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"LoginVC"];
    [self.navigationController pushViewController:vc animated:NO];
}
- (IBAction)AboutVC
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    About *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"About"];
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
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PlayerLists *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"PlayerLists"];

    [self.navigationController pushViewController:vc animated:NO];
}

@end
