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

@interface About : UIViewController <MFMailComposeViewControllerDelegate >

@property (weak, nonatomic) UIPopoverPresentationController *presentingPopoverController;

@property (strong, readwrite, retain, atomic) Design *design;

@property (weak, nonatomic) IBOutlet UILabel *MRAbout;
@property (weak, nonatomic) IBOutlet UILabel *MrAboutAppname;
@property (weak, nonatomic) IBOutlet UILabel *MRAboutAppVersion;
@property (weak, nonatomic) IBOutlet UILabel *MRAboutBuildInfo;
@property (weak, nonatomic) IBOutlet UILabel *MRAboutDevice;
@property (weak, nonatomic) IBOutlet UILabel *MRAboutOS;
@property (weak, nonatomic) IBOutlet UILabel *MRAboutCopyright;
@property (weak, nonatomic) IBOutlet UILabel *SMAboutChartCount;
@property (weak, nonatomic) IBOutlet UILabel *SMAboutChartSize;

- (IBAction)MRAboutButtonEmail:(id)sender;
- (IBAction)MRAboutButtonInfo:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *buttonWeb;
@property (weak, nonatomic) IBOutlet UIButton *buttonEmail;
@property (weak, nonatomic) IBOutlet UIButton *buttonPrivacy;


@end
