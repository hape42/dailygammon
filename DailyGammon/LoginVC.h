//
//  Login.h
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <WebKit/WebKit.h>
#import "DGButton.h"

@class Design;

@interface LoginVC : UIViewController<UIPopoverPresentationControllerDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate>

@property (strong, readwrite, retain, atomic) Design *design;

@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) DGButton *closeButton;

@end

