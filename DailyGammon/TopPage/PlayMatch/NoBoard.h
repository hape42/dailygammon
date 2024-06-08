//
//  NoBoard.h
//  DailyGammon
//
//  Created by Peter Schneider on 31.03.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaitView.h"
#import <MessageUI/MessageUI.h>

NS_ASSUME_NONNULL_BEGIN

@class Design;
@class Preferences;
@class Rating;
@class Tools;
@class TextTools;
@class ChatHistory;

@interface NoBoard : UIViewController <MFMailComposeViewControllerDelegate, UITextViewDelegate, UIPopoverPresentationControllerDelegate>

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Preferences *preferences;
@property (strong, readwrite, retain, atomic) Rating *rating;
@property (strong, readwrite, retain, atomic) Tools *tools;
@property (strong, readwrite, retain, atomic) TextTools *textTools;
@property (strong, readwrite, retain, atomic) ChatHistory *chatHistory;

@property (strong, nonatomic, readwrite) WaitView *waitView;

@property (strong, readwrite, retain, atomic) NSMutableDictionary *boardDict;

@property (assign, atomic) CGRect finishedmatchChatViewFrame;
@property (readwrite, retain, nonatomic) UITextView *finishedMatchChat;
@property (readwrite, assign, atomic) BOOL isFinishedMatch;

@property (strong, readwrite, retain, atomic) UIViewController *presentingVC;

@end

NS_ASSUME_NONNULL_END
