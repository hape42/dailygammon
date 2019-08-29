//
//  PlayMatch.h
//  DailyGammon
//
//  Created by Peter on 29.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

NS_ASSUME_NONNULL_BEGIN
@class Design;
@class Match;
@class Rating;
@class Tools;

@interface PlayMatch : UIViewController<UIPopoverPresentationControllerDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate >

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Match *match;
@property (strong, readwrite, retain, atomic) Rating *rating;
@property (strong, readwrite, retain, atomic) Tools *tools;

@property (strong, readwrite, retain, atomic) NSMutableDictionary *ratingDict;
@property (strong, readwrite, retain, atomic) NSMutableArray *topPageArray;

@property (strong, readwrite, retain, atomic) NSString *matchLink;

@end

NS_ASSUME_NONNULL_END
