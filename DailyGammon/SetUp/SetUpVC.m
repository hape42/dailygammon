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
#import "DGLabel.h"
#import "PlayerLists.h"
#import "Constants.h"

@interface SetUpVC ()

@property (weak, nonatomic) IBOutlet DGButton *doneButton;

@property (weak, nonatomic) IBOutlet DGButton *boardSchemeButton;
@property (weak, nonatomic) IBOutlet DGButton *preferencesButton;

@property (weak, nonatomic) IBOutlet UISwitch *showRatingsOutlet;
@property (weak, nonatomic) IBOutlet DGLabel *showRatingsLabel;
@property (weak, nonatomic) IBOutlet UISwitch *showWinLossOutlet;
@property (weak, nonatomic) IBOutlet DGLabel *showWinLossLabel;

@property (weak, nonatomic) IBOutlet UISwitch *iCloudOutlet;
@property (weak, nonatomic) IBOutlet DGLabel *useIcloudLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iCloudConnected;
@property (weak, nonatomic) IBOutlet DGLabel *iCloudLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *buttonDesignOutlet;
@property (weak, nonatomic) IBOutlet DGLabel *buttonDesignLabel;

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

    [self layoutObjects];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.navigationItem.hidesBackButton = YES;

    
}

#pragma mark - autoLayout
-(void)layoutObjects
{
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    float edge = 10.0;
    float gap = 5;
    
#pragma mark doneButton autoLayout
    [self.doneButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.doneButton.topAnchor    constraintEqualToAnchor:safe.topAnchor  constant:edge].active = YES;
    [self.doneButton.leftAnchor   constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.doneButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.doneButton.widthAnchor  constraintEqualToConstant:60].active = YES;

#pragma mark boardScheme Button autoLayout
    [self.boardSchemeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.boardSchemeButton.topAnchor constraintEqualToAnchor:self.doneButton.bottomAnchor constant:gap].active = YES;
    [self.boardSchemeButton.leftAnchor    constraintEqualToAnchor:safe.leftAnchor              constant:gap].active = YES;
    [self.boardSchemeButton.heightAnchor  constraintEqualToConstant:40].active = YES;
    [self.boardSchemeButton.widthAnchor   constraintEqualToConstant:120].active = YES;

#pragma mark preferences Button autoLayout
    [self.preferencesButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.preferencesButton.centerYAnchor constraintEqualToAnchor:self.boardSchemeButton.centerYAnchor constant:0].active = YES;
    [self.preferencesButton.rightAnchor   constraintEqualToAnchor:safe.rightAnchor    constant:-gap].active = YES;
    [self.preferencesButton.heightAnchor  constraintEqualToConstant:40].active = YES;
    [self.preferencesButton.widthAnchor   constraintEqualToConstant:200].active = YES;

    
#pragma mark buttonDesign autoLayout
    [self.buttonDesignOutlet setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.buttonDesignOutlet.bottomAnchor  constraintEqualToAnchor:safe.bottomAnchor  constant:-(edge*2)].active = YES;
    [self.buttonDesignOutlet.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor constant:0].active = YES;
    [self.buttonDesignOutlet.widthAnchor   constraintEqualToConstant:300].active = YES;

    [self.buttonDesignLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.buttonDesignLabel.bottomAnchor  constraintEqualToAnchor:self.buttonDesignOutlet.topAnchor constant:-gap].active = YES;
    [self.buttonDesignLabel.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor                constant:0].active = YES;
    [self.buttonDesignLabel.heightAnchor  constraintEqualToConstant:35].active = YES;

#pragma mark showRatings autoLayout
    [self.showRatingsOutlet setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.showRatingsOutlet.topAnchor   constraintEqualToAnchor:self.boardSchemeButton.bottomAnchor constant:gap*4].active = YES;
    [self.showRatingsOutlet.leftAnchor  constraintEqualToAnchor:safe.leftAnchor                     constant:edge].active = YES;

    [self.showRatingsLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.showRatingsLabel.centerYAnchor constraintEqualToAnchor:self.showRatingsOutlet.centerYAnchor constant:0].active = YES;
    [self.showRatingsLabel.leftAnchor   constraintEqualToAnchor:self.showRatingsOutlet.rightAnchor    constant:gap*4].active = YES;
    [self.showRatingsLabel.heightAnchor   constraintEqualToConstant:35].active = YES;

#pragma mark winLoss autoLayout
    [self.showWinLossOutlet setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.showWinLossOutlet.topAnchor   constraintEqualToAnchor:self.showRatingsOutlet.bottomAnchor constant:gap].active = YES;
    [self.showWinLossOutlet.leftAnchor  constraintEqualToAnchor:safe.leftAnchor                     constant:edge].active = YES;

    [self.showWinLossLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.showWinLossLabel.centerYAnchor constraintEqualToAnchor:self.showWinLossOutlet.centerYAnchor constant:0].active = YES;
    [self.showWinLossLabel.leftAnchor   constraintEqualToAnchor:self.showWinLossOutlet.rightAnchor    constant:gap*4].active = YES;
    [self.showWinLossLabel.heightAnchor   constraintEqualToConstant:35].active = YES;

#pragma mark rating iCloud autoLayout
    [self.iCloudOutlet setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.iCloudOutlet.topAnchor   constraintEqualToAnchor:self.showWinLossOutlet.bottomAnchor constant:gap*8].active = YES;
    [self.iCloudOutlet.leftAnchor  constraintEqualToAnchor:safe.leftAnchor                     constant:edge].active = YES;

    [self.useIcloudLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.useIcloudLabel.centerYAnchor constraintEqualToAnchor:self.iCloudOutlet.centerYAnchor constant:0].active = YES;
    [self.useIcloudLabel.leftAnchor   constraintEqualToAnchor:self.iCloudOutlet.rightAnchor    constant:gap*4].active = YES;
    [self.useIcloudLabel.heightAnchor   constraintEqualToConstant:35].active = YES;

    [self.iCloudConnected setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.iCloudConnected.centerYAnchor   constraintEqualToAnchor:self.iCloudOutlet.centerYAnchor constant:0].active = YES;
    [self.iCloudConnected.leftAnchor  constraintEqualToAnchor:self.useIcloudLabel.rightAnchor                     constant:gap].active = YES;

    [self.iCloudLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.iCloudLabel.centerYAnchor constraintEqualToAnchor:self.iCloudOutlet.centerYAnchor constant:0].active = YES;
    [self.iCloudLabel.leftAnchor   constraintEqualToAnchor:self.iCloudConnected.rightAnchor    constant:gap].active = YES;
    [self.iCloudLabel.heightAnchor   constraintEqualToConstant:35].active = YES;

}


- (IBAction)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)boardSchemeAction:(id)sender
{

    UIViewController *controller = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"BoardSchemeVC"];
    
    // present the controller
    // on iPad, this will be a Popover
    // on iPhone, this will be an action sheet
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:NO completion:nil];
    
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
    UIViewController *controller = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"PreferencesVC"];
    
    // present the controller
    // on iPad, this will be a Popover
    // on iPhone, this will be an action sheet
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:NO completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionRight;
    popController.delegate = self;
    
    UIButton *button = (UIButton *)sender;
    popController.sourceView = button;
    popController.sourceRect = button.bounds;

}
- (IBAction)buttonDesignAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:((UISegmentedControl*)sender).selectedSegmentIndex  forKey:@"buttonDesign"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"buttonDesign" object:self];
    
}


@end
