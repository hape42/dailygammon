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
    self.boardSchemeButton = [design makeNiceButton:self.boardSchemeButton];
    self.preferencesButton = [design makeNiceButton:self.preferencesButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.showRatingsOutlet setOn:[[[NSUserDefaults standardUserDefaults] valueForKey:@"showRatings"]boolValue] animated:YES];
    [self.showWinLossOutlet setOn:[[[NSUserDefaults standardUserDefaults] valueForKey:@"showWinLoss"]boolValue] animated:YES];

}
- (IBAction)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)boardSchemeAction:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"BoardSchemeVC"];
    
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
}

@end
