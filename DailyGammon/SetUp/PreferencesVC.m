//
//  Preferences.m
//  DailyGammon
//
//  Created by Peter on 10.02.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import "PreferencesVC.h"
#import "Design.h"
#import "TFHpple.h"
#import "Preferences.h"
#import <SafariServices/SafariServices.h>
#import "DGButton.h"

@interface PreferencesVC ()<NSURLSessionDataDelegate>

@property (readwrite, retain, nonatomic) NSMutableArray *preferencesArray;

@property (weak, nonatomic) IBOutlet DGButton *doneButton;
@property (weak, nonatomic) IBOutlet DGLabel *header;

@property (weak, nonatomic) IBOutlet UISwitch *ConfirmationDouble;
@property (weak, nonatomic) IBOutlet UISwitch *ConfirmationTake;
@property (weak, nonatomic) IBOutlet UISwitch *ConfirmationPass;
@property (weak, nonatomic) IBOutlet UISwitch *NameLink;
@property (weak, nonatomic) IBOutlet UISwitch *SkipOpponentRollDice;
@property (weak, nonatomic) IBOutlet UISwitch *SkipAutomatic;
@property (weak, nonatomic) IBOutlet UISwitch *HidePipCount;
@property (weak, nonatomic) IBOutlet UISwitch *HomeBoardleftSide;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet DGLabel *ConfirmationDoubleLabel;
@property (weak, nonatomic) IBOutlet DGLabel *ConfirmationTakeLabel;
@property (weak, nonatomic) IBOutlet DGLabel *ConfirmationPassLabel;
@property (weak, nonatomic) IBOutlet DGLabel *NameLinkLabel;
@property (weak, nonatomic) IBOutlet DGLabel *SkipOpponentRollDiceLabel;
@property (weak, nonatomic) IBOutlet DGLabel *SkipAutomaticLabel;
@property (weak, nonatomic) IBOutlet DGLabel *HidePipCountLabel;
@property (weak, nonatomic) IBOutlet DGLabel *HomeBoardleftSideLabel;

@end

@implementation PreferencesVC

@synthesize design, preferences;

- (void)viewDidLoad
{
    [super viewDidLoad];

    design = [[Design alloc] init];
    preferences = [[Preferences alloc] init];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.scrollView.delegate = self;
    self.scrollView.scrollEnabled = YES;

    [self initSwitches];
        
    self.ConfirmationDouble   = [design makeNiceSwitch:self.ConfirmationDouble];
    self.ConfirmationTake     = [design makeNiceSwitch:self.ConfirmationTake];
    self.ConfirmationPass     = [design makeNiceSwitch:self.ConfirmationPass];
    self.NameLink             = [design makeNiceSwitch:self.NameLink];
    self.SkipOpponentRollDice = [design makeNiceSwitch:self.SkipOpponentRollDice];
    self.SkipAutomatic        = [design makeNiceSwitch:self.SkipAutomatic];
    self.HidePipCount         = [design makeNiceSwitch:self.HidePipCount];
    self.HomeBoardleftSide    = [design makeNiceSwitch:self.HomeBoardleftSide];

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

#pragma mark header autoLayout
    [self.header setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.header.topAnchor     constraintEqualToAnchor:safe.topAnchor                 constant:edge].active = YES;
    [self.header.leadingAnchor constraintEqualToAnchor:self.doneButton.trailingAnchor constant:edge].active = YES;
    [self.header.rightAnchor   constraintEqualToAnchor:safe.rightAnchor               constant:-edge].active = YES;
    [self.header.heightAnchor  constraintEqualToConstant:35].active = YES;

#pragma mark ConfirmationDouble autoLayout
    [self.ConfirmationDouble setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.ConfirmationDouble.topAnchor  constraintEqualToAnchor:self.doneButton.bottomAnchor constant:gap*2].active = YES;
    [self.ConfirmationDouble.leftAnchor constraintEqualToAnchor:safe.leftAnchor              constant:edge].active = YES;

#pragma mark ConfirmationDoubleLabel autoLayout
    [self.ConfirmationDoubleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.ConfirmationDoubleLabel.topAnchor    constraintEqualToAnchor:self.ConfirmationDouble.topAnchor    constant:0].active = YES;
    [self.ConfirmationDoubleLabel.leftAnchor   constraintEqualToAnchor:self.ConfirmationDouble.rightAnchor  constant:gap].active = YES;
    [self.ConfirmationDoubleLabel.heightAnchor constraintEqualToAnchor:self.ConfirmationDouble.heightAnchor constant:0].active = YES;

#pragma mark ConfirmationTake autoLayout
    [self.ConfirmationTake setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.ConfirmationTake.topAnchor  constraintEqualToAnchor:self.ConfirmationDouble.bottomAnchor constant:gap].active = YES;
    [self.ConfirmationTake.leftAnchor constraintEqualToAnchor:safe.leftAnchor                      constant:edge].active = YES;

#pragma mark ConfirmationTakeLabel autoLayout
    [self.ConfirmationTakeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.ConfirmationTakeLabel.topAnchor    constraintEqualToAnchor:self.ConfirmationTake.topAnchor    constant:0].active = YES;
    [self.ConfirmationTakeLabel.leftAnchor   constraintEqualToAnchor:self.ConfirmationTake.rightAnchor  constant:gap].active = YES;
    [self.ConfirmationTakeLabel.heightAnchor constraintEqualToAnchor:self.ConfirmationTake.heightAnchor constant:0].active = YES;

#pragma mark ConfirmationPass autoLayout
    [self.ConfirmationPass setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.ConfirmationPass.topAnchor  constraintEqualToAnchor:self.ConfirmationTake.bottomAnchor constant:gap].active = YES;
    [self.ConfirmationPass.leftAnchor constraintEqualToAnchor:safe.leftAnchor                    constant:edge].active = YES;

#pragma mark ConfirmationPassLabel autoLayout
    [self.ConfirmationPassLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.ConfirmationPassLabel.topAnchor    constraintEqualToAnchor:self.ConfirmationPass.topAnchor    constant:0].active = YES;
    [self.ConfirmationPassLabel.leftAnchor   constraintEqualToAnchor:self.ConfirmationPass.rightAnchor  constant:gap].active = YES;
    [self.ConfirmationPassLabel.heightAnchor constraintEqualToAnchor:self.ConfirmationPass.heightAnchor constant:0].active = YES;

#pragma mark NameLink autoLayout
    [self.NameLink setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.NameLink.topAnchor  constraintEqualToAnchor:self.ConfirmationPass.bottomAnchor constant:gap].active = YES;
    [self.NameLink.leftAnchor constraintEqualToAnchor:safe.leftAnchor                    constant:edge].active = YES;

#pragma mark NameLinkLabel autoLayout
    [self.NameLinkLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.NameLinkLabel.topAnchor    constraintEqualToAnchor:self.NameLink.topAnchor    constant:0].active = YES;
    [self.NameLinkLabel.leftAnchor   constraintEqualToAnchor:self.NameLink.rightAnchor  constant:gap].active = YES;
    [self.NameLinkLabel.heightAnchor constraintEqualToAnchor:self.NameLink.heightAnchor constant:0].active = YES;

#pragma mark SkipOpponentRollDice autoLayout
    [self.SkipOpponentRollDice setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.SkipOpponentRollDice.topAnchor  constraintEqualToAnchor:self.NameLink.bottomAnchor constant:gap].active  = YES;
    [self.SkipOpponentRollDice.leftAnchor constraintEqualToAnchor:safe.leftAnchor            constant:edge].active = YES;

#pragma mark SkipOpponentRollDiceLabel autoLayout
    [self.SkipOpponentRollDiceLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.SkipOpponentRollDiceLabel.topAnchor    constraintEqualToAnchor:self.SkipOpponentRollDice.topAnchor    constant:0].active   = YES;
    [self.SkipOpponentRollDiceLabel.leftAnchor   constraintEqualToAnchor:self.SkipOpponentRollDice.rightAnchor  constant:gap].active = YES;
    [self.SkipOpponentRollDiceLabel.heightAnchor constraintEqualToAnchor:self.SkipOpponentRollDice.heightAnchor constant:0].active   = YES;

#pragma mark SkipAutomatic autoLayout
    [self.SkipAutomatic setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.SkipAutomatic.topAnchor  constraintEqualToAnchor:self.SkipOpponentRollDice.bottomAnchor constant:gap].active  = YES;
    [self.SkipAutomatic.leftAnchor constraintEqualToAnchor:safe.leftAnchor                        constant:edge].active = YES;

#pragma mark SkipAutomaticLabel autoLayout
    [self.SkipAutomaticLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.SkipAutomaticLabel.topAnchor    constraintEqualToAnchor:self.SkipAutomatic.topAnchor    constant:0].active   = YES;
    [self.SkipAutomaticLabel.leftAnchor   constraintEqualToAnchor:self.SkipAutomatic.rightAnchor  constant:gap].active = YES;
    [self.SkipAutomaticLabel.heightAnchor constraintEqualToAnchor:self.SkipAutomatic.heightAnchor constant:0].active   = YES;

#pragma mark HidePipCount autoLayout
    [self.HidePipCount setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.HidePipCount.topAnchor  constraintEqualToAnchor:self.SkipAutomatic.bottomAnchor constant:gap].active  = YES;
    [self.HidePipCount.leftAnchor constraintEqualToAnchor:safe.leftAnchor                 constant:edge].active = YES;

#pragma mark HidePipCountLabel autoLayout
    [self.HidePipCountLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.HidePipCountLabel.topAnchor    constraintEqualToAnchor:self.HidePipCount.topAnchor    constant:0].active   = YES;
    [self.HidePipCountLabel.leftAnchor   constraintEqualToAnchor:self.HidePipCount.rightAnchor  constant:gap].active = YES;
    [self.HidePipCountLabel.heightAnchor constraintEqualToAnchor:self.HidePipCount.heightAnchor constant:0].active   = YES;

#pragma mark HomeBoardleftSide autoLayout
    [self.HomeBoardleftSide setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.HomeBoardleftSide.topAnchor  constraintEqualToAnchor:self.HidePipCount.bottomAnchor constant:gap].active  = YES;
    [self.HomeBoardleftSide.leftAnchor constraintEqualToAnchor:safe.leftAnchor                 constant:edge].active = YES;

#pragma mark HomeBoardleftSideLabel autoLayout
    [self.HomeBoardleftSideLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.HomeBoardleftSideLabel.topAnchor    constraintEqualToAnchor:self.HomeBoardleftSide.topAnchor    constant:0].active   = YES;
    [self.HomeBoardleftSideLabel.leftAnchor   constraintEqualToAnchor:self.HomeBoardleftSide.rightAnchor  constant:gap].active = YES;
    [self.HomeBoardleftSideLabel.heightAnchor constraintEqualToAnchor:self.HomeBoardleftSide.heightAnchor constant:0].active   = YES;



}

- (void)initSwitches
{
    self.preferencesArray = [preferences readPreferences];
    
    NSMutableDictionary *preferencesDict = self.preferencesArray[0];
    if([preferencesDict objectForKey:@"checked"] != nil)
        [self.ConfirmationDouble setOn:YES animated:YES];
    preferencesDict = self.preferencesArray[1];
    if([preferencesDict objectForKey:@"checked"] != nil)
        [self.ConfirmationTake setOn:YES animated:YES];
    preferencesDict = self.preferencesArray[2];
    if([preferencesDict objectForKey:@"checked"] != nil)
        [self.ConfirmationPass setOn:YES animated:YES];
    preferencesDict = self.preferencesArray[3];
    if([preferencesDict objectForKey:@"checked"] != nil)
        [self.NameLink setOn:YES animated:YES];
    preferencesDict = self.preferencesArray[4];
    if([preferencesDict objectForKey:@"checked"] != nil)
        [self.SkipOpponentRollDice setOn:YES animated:YES];
    preferencesDict = self.preferencesArray[5];
    if([preferencesDict objectForKey:@"checked"] != nil)
        [self.SkipAutomatic setOn:YES animated:YES];
    preferencesDict = self.preferencesArray[6];
    if([preferencesDict objectForKey:@"checked"] != nil)
        [self.HidePipCount setOn:YES animated:YES];
    preferencesDict = self.preferencesArray[7];
    if([preferencesDict objectForKey:@"checked"] != nil)
        [self.HomeBoardleftSide setOn:YES animated:YES];

}
- (IBAction)ConfirmationDoubleAction:(id)sender
{
    [self savePreferences:0];
}
- (IBAction)ConfirmationTakeAction:(id)sender
{
    [self savePreferences:1];
}
- (IBAction)ConfirmationPassAction:(id)sender
{
    [self savePreferences:2];
}
- (IBAction)NameLinkAction:(id)sender
{
    [self savePreferences:3];
}
- (IBAction)SkipOpponentRollDiceAction:(id)sender
{
    [self savePreferences:4];
}
- (IBAction)SkipAutomaticAction:(id)sender
{
    [self savePreferences:5];
}
- (IBAction)HidePipCountAction:(id)sender
{
    [self savePreferences:6];
}
- (IBAction)HomeBoardleftSideAction:(id)sender
{
    [self savePreferences:7];
}

- (IBAction)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)savePreferences:(int)typ
{
    NSString *postString = @"";
    if ([self.ConfirmationDouble isOn])
        postString = @"0=on";
    else
        postString = @"0=off";
    if ([self.ConfirmationTake isOn])
        postString = [NSString stringWithFormat:@"%@&1=on",postString];
    else
        postString = [NSString stringWithFormat:@"%@&1=off",postString];
    if ([self.ConfirmationPass isOn])
        postString = [NSString stringWithFormat:@"%@&2=on",postString];
    else
        postString = [NSString stringWithFormat:@"%@&2=off",postString];
    if ([self.NameLink isOn])
        postString = [NSString stringWithFormat:@"%@&3=on",postString];
    else
        postString = [NSString stringWithFormat:@"%@&3=off",postString];
    if ([self.SkipOpponentRollDice isOn])
        postString = [NSString stringWithFormat:@"%@&4=on",postString];
    else
        postString = [NSString stringWithFormat:@"%@&4=off",postString];
    if ([self.SkipAutomatic isOn])
        postString = [NSString stringWithFormat:@"%@&5=on",postString];
    else
        postString = [NSString stringWithFormat:@"%@&5=off",postString];
    if ([self.HidePipCount isOn])
        postString = [NSString stringWithFormat:@"%@&6=on",postString];
    else
        postString = [NSString stringWithFormat:@"%@&6=off",postString];
    if ([self.HomeBoardleftSide isOn])
        postString = [NSString stringWithFormat:@"%@&7=on",postString];
    else
        postString = [NSString stringWithFormat:@"%@&7=off",postString];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://dailygammon.com/bg/profile/pref"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task resume];

}

@end
