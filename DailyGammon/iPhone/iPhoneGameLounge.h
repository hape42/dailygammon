//
//  iPhoneGameLounge.h
//  DailyGammon
//
//  Created by Peter on 07.03.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class Design;
@class Preferences;
@class Rating;
@class Tools;

@interface iPhoneGameLounge : UIViewController<MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate>

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Preferences *preferences;
@property (strong, readwrite, retain, atomic) Rating *rating;
@property (strong, readwrite, retain, atomic) Tools *tools;


@end

