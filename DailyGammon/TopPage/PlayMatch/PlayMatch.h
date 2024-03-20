//
//  PlayMatch.h
//  DailyGammon
//
//  Created by Peter on 29.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ChatView.h"

NS_ASSUME_NONNULL_BEGIN
@class Design;
@class Match;
@class Rating;
@class Tools;
@class MatchTools;

@interface PlayMatch : UIViewController<MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate, MFMailComposeViewControllerDelegate >

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Match *match;
@property (strong, readwrite, retain, atomic) Rating *rating;
@property (strong, readwrite, retain, atomic) Tools *tools;
@property (strong, readwrite, retain, atomic) MatchTools *matchTools;

@property (strong, readwrite, retain, atomic) NSMutableDictionary *ratingDict;
@property (strong, readwrite, retain, atomic) NSMutableArray *topPageArray;

//@property (strong, readwrite, retain, atomic) NSString *matchLink;
@property (readwrite, assign, atomic) BOOL isReview;
@property (readwrite, assign, atomic) float zoomFactor;

@property (strong, nonatomic, readwrite) ChatView  *chatView;

@property (strong, nonatomic, readwrite) UIView *boardView;
@property (strong, nonatomic, readwrite) UIView *actionView;
@property (readwrite, assign, atomic) float actionViewWidth;

@property (readwrite, assign, atomic) BOOL isPortrait;

@end

NS_ASSUME_NONNULL_END
