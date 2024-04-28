//
//  PlayerDetail.h
//  DailyGammon
//
//  Created by Peter Schneider on 23.03.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "WaitView.h"

NS_ASSUME_NONNULL_BEGIN
@class Design;
@class Rating;

@interface PlayerDetail : UIViewController<MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate>

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Rating *rating;

@property (strong, readwrite, retain, atomic) NSString *userID;
@property (strong, readwrite, retain, atomic) NSMutableArray *playerProfileArray;

@property (strong, nonatomic, readwrite) WaitView *waitView;

@end

NS_ASSUME_NONNULL_END
