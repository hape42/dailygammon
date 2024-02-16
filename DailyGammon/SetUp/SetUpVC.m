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
#import <SafariServices/SafariServices.h>
#import "RatingTools.h"
#import "DGButton.h"
#import "PlayerLists.h"
#import "Constants.h"

@interface SetUpVC ()

@property (weak, nonatomic) IBOutlet DGButton *boardSchemeButton;
@property (weak, nonatomic) IBOutlet UISwitch *showRatingsOutlet;
@property (weak, nonatomic) IBOutlet UISwitch *showWinLossOutlet;
@property (weak, nonatomic) IBOutlet DGButton *preferencesButton;
@property (weak, nonatomic) IBOutlet UISwitch *iCloudOutlet;
@property (weak, nonatomic) IBOutlet UISegmentedControl *buttonDesignOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *iCloudConnected;

@end

@implementation SetUpVC

@synthesize design, ratingTools;
@synthesize fromRating;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    design      = [[Design alloc]      init];
    ratingTools = [[RatingTools alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillAppear:) name:changeSchemaNotification object:nil];
    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    else
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.navigationItem.hidesBackButton = YES;

    [self.showRatingsOutlet setOn:[[[NSUserDefaults standardUserDefaults] valueForKey:@"showRatings"]boolValue] animated:YES];
    [self.showWinLossOutlet setOn:[[[NSUserDefaults standardUserDefaults] valueForKey:@"showWinLoss"]boolValue] animated:YES];
    
    self.showRatingsOutlet = [design makeNiceSwitch:self.showRatingsOutlet];
    self.showWinLossOutlet = [design makeNiceSwitch:self.showWinLossOutlet];

    self.iCloudOutlet = [design makeNiceSwitch:self.iCloudOutlet];
    [self.iCloudOutlet setOn:[[[NSUserDefaults standardUserDefaults] valueForKey:@"iCloud"]boolValue] animated:YES];

    if ( [[NSFileManager defaultManager] ubiquityIdentityToken] != nil)
        [self.iCloudConnected setImage:[UIImage imageNamed:@"iCloudON.png"]];
    else
        [self.iCloudConnected setImage:[UIImage imageNamed:@"iCloudOFF.png"]];
    
    int buttonDesign = [[[NSUserDefaults standardUserDefaults] valueForKey:@"buttonDesign"]intValue];
    self.buttonDesignOutlet.selectedSegmentIndex = buttonDesign;

}
- (IBAction)doneAction:(id)sender
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:TRUE];
    if(fromRating)
        [self dismissViewControllerAnimated:YES completion:nil];

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
- (IBAction)iCloudAction:(id)sender
{
    if ([(UISwitch *)sender isOn])
    {
        if ( [[NSFileManager defaultManager] ubiquityIdentityToken] == nil)
        {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Problem"
                                         message:@"You are not connected to iCloud. Before you can use this feature in the app, you need to connect to iCloud in the settings of your device."
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"OK"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            [self.iCloudOutlet setOn:NO animated:YES];
                                        }];
            
            [alert addAction:yesButton];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES  forKey:@"iCloud"];
            
            //hol alle Ratingeinträge aus der Datenbank und stell die Daten in die iCloud
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];
            NSMutableArray *ratingArray = [app.dbConnect readAlleRatingForUser:userID];
            for(NSMutableDictionary *dict in ratingArray)
            {
                float rating = [[dict objectForKey:@"rating"]floatValue];
                NSString *datum = [dict objectForKey:@"datum"];
                [ratingTools saveRating:datum withRating:rating] ;
            }
        }
    }
    else
        [[NSUserDefaults standardUserDefaults] setBool:NO  forKey:@"iCloud"];
    
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
        popController.permittedArrowDirections = UIPopoverArrowDirectionRight;
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
- (IBAction)buttonDesignAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:((UISegmentedControl*)sender).selectedSegmentIndex  forKey:@"buttonDesign"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"buttonDesign" object:self];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         // Code to be executed during the animation
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         // Code to be executed after the animation is completed
     }];
    XLog(@"Neue Breite: %.2f, Neue Höhe: %.2f", size.width, size.height);
}

@end
