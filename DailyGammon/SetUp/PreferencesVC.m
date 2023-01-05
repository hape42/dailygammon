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

@interface PreferencesVC ()<NSURLSessionDataDelegate>

@property (readwrite, retain, nonatomic) NSMutableArray *preferencesArray;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UISwitch *ConfirmationDouble;
@property (weak, nonatomic) IBOutlet UISwitch *ConfirmationTake;
@property (weak, nonatomic) IBOutlet UISwitch *ConfirmationPass;
@property (weak, nonatomic) IBOutlet UISwitch *NameLink;
@property (weak, nonatomic) IBOutlet UISwitch *SkipOpponentRollDice;
@property (weak, nonatomic) IBOutlet UISwitch *SkipAutomatic;
@property (weak, nonatomic) IBOutlet UISwitch *HidePipCount;
@property (weak, nonatomic) IBOutlet UISwitch *HomeBoardleftSide;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

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
        
    self.ConfirmationDouble = [design makeNiceSwitch:self.ConfirmationDouble];
    self.ConfirmationTake = [design makeNiceSwitch:self.ConfirmationTake];
    self.ConfirmationPass = [design makeNiceSwitch:self.ConfirmationPass];
    self.NameLink = [design makeNiceSwitch:self.NameLink];
    self.SkipOpponentRollDice = [design makeNiceSwitch:self.SkipOpponentRollDice];
    self.SkipAutomatic = [design makeNiceSwitch:self.SkipAutomatic];
    self.HidePipCount = [design makeNiceSwitch:self.HidePipCount];
    self.HomeBoardleftSide = [design makeNiceSwitch:self.HomeBoardleftSide];

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
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:TRUE];
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
