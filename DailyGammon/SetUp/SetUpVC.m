//
//  SetUpVC.m
//  DailyGammon
//
//  Created by Peter on 04.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "SetUpVC.h"
#import "Design.h"
#import "BoardSchemeVC.h"
#import "PreferencesVC.h"
#import "AppDelegate.h"
#import "DbConnect.h"

@interface SetUpVC ()

@property (weak, nonatomic) IBOutlet UIButton *boardSchemeButton;
@property (weak, nonatomic) IBOutlet UISwitch *showRatingsOutlet;
@property (weak, nonatomic) IBOutlet UISwitch *showWinLossOutlet;
@property (weak, nonatomic) IBOutlet UIButton *preferencesButton;

@end

@implementation SetUpVC

@synthesize design;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    design = [[Design alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillAppear:) name:@"changeSchemaNotification" object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
    
    [self.showRatingsOutlet setOn:[[[NSUserDefaults standardUserDefaults] valueForKey:@"showRatings"]boolValue] animated:YES];
    [self.showWinLossOutlet setOn:[[[NSUserDefaults standardUserDefaults] valueForKey:@"showWinLoss"]boolValue] animated:YES];
    [self.showRatingsOutlet setTintColor:[schemaDict objectForKey:@"TintColor"]];
    [self.showRatingsOutlet setOnTintColor:[schemaDict objectForKey:@"TintColor"]];
    [self.showWinLossOutlet setTintColor:[schemaDict objectForKey:@"TintColor"]];
    [self.showWinLossOutlet setOnTintColor:[schemaDict objectForKey:@"TintColor"]];
    self.boardSchemeButton = [design makeNiceButton:self.boardSchemeButton];
    self.preferencesButton = [design makeNiceButton:self.preferencesButton];

}
- (IBAction)doneAction:(id)sender
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:TRUE];
}

- (IBAction)boardSchemeAction:(id)sender
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        UIViewController *controller = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"BoardSchemeVC"];
        
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
    else
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        BoardSchemeVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"BoardSchemeVC"];
        [self.navigationController pushViewController:vc animated:NO];
    }
}
- (IBAction)showRatingsAction:(id)sender
{
    if ([(UISwitch *)sender isOn])
        [[NSUserDefaults standardUserDefaults] setBool:YES  forKey:@"showRatings"];
    else
        [[NSUserDefaults standardUserDefaults] setBool:NO  forKey:@"showRatings"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (IBAction)showWinLossAction:(id)sender
{
    if ([(UISwitch *)sender isOn])
        [[NSUserDefaults standardUserDefaults] setBool:YES  forKey:@"showWinLoss"];
    else
        [[NSUserDefaults standardUserDefaults] setBool:NO  forKey:@"showWinLoss"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (IBAction)preferencesAction:(id)sender
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {

        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        UIViewController *controller = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"PreferencesVC"];
        
        // present the controller
        // on iPad, this will be a Popover
        // on iPhone, this will be an action sheet
        controller.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:controller animated:YES completion:nil];
        
        UIPopoverPresentationController *popController = [controller popoverPresentationController];
        popController.permittedArrowDirections = UIPopoverArrowDirectionDown;
        popController.delegate = self;
        
        UIButton *button = (UIButton *)sender;
        popController.sourceView = button;
        popController.sourceRect = button.bounds;
    }
    else
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        PreferencesVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"PreferencesVC"];
        [self.navigationController pushViewController:vc animated:NO];
    }

}

@end
