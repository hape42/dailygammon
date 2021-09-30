//
//  SetUpVC.h
//  DailyGammon
//
//  Created by Peter on 04.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class Design;

@interface SetUpVC : UIViewController<MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate>

@property (strong, readwrite, retain, atomic) Design *design;

@end

