//
//  Login.h
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class Design;

@interface LoginVC : UIViewController<UIPopoverPresentationControllerDelegate, MFMailComposeViewControllerDelegate>

@property (strong, readwrite, retain, atomic) Design *design;

@end

