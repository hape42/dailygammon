//
//  About.h
//  DailyGammon
//
//  Created by Peter on 10.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class Design;
@class Preferences;
@class Rating;
@class Tools;

@interface About : UIViewController <MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate >

@property (weak, nonatomic) UIPopoverPresentationController *presentingPopoverController;

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Preferences *preferences;
@property (strong, readwrite, retain, atomic) Rating *rating;
@property (strong, readwrite, retain, atomic) Tools *tools;

@property (weak, nonatomic) IBOutlet UILabel *MRAboutAppVersion;

- (IBAction)MRAboutButtonEmail:(id)sender;
- (IBAction)MRAboutButtonInfo:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *buttonWeb;
@property (weak, nonatomic) IBOutlet UIButton *buttonReminder;

@property (weak, nonatomic) IBOutlet UIButton *buttonEmail;
@property (weak, nonatomic) IBOutlet UIButton *buttonPrivacy;

@property (nonatomic, assign) BOOL showRemindMeLaterButton;

@end
