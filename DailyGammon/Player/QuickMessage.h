//
//  QuickMessage.h
//  DailyGammon
//
//  Created by Peter Schneider on 25.03.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

NS_ASSUME_NONNULL_BEGIN
@class Design;
@class Tools;

@interface QuickMessage : UIViewController <UITextViewDelegate, UIPopoverPresentationControllerDelegate>

@property (strong, readwrite, retain, atomic)    NSString *playerName;
@property (strong, readwrite, retain, atomic)    NSString *playerNummer;

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Tools *tools;

@end

NS_ASSUME_NONNULL_END
