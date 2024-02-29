//
//  About.h
//  DailyGammon
//
//  Created by Peter on 10.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "DGButton.h"
#import "MenueView.h"

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


- (IBAction)MRAboutButtonEmail:(id)sender;
- (IBAction)MRAboutButtonInfo:(id)sender;

@property (nonatomic, assign) BOOL showRemindMeLaterButton;

@property (strong, nonatomic, readwrite) MenueView *menueView;

@end
