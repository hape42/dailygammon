//
//  iPhonePlayMatch.h
//  DailyGammon
//
//  Created by Peter on 02.03.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

NS_ASSUME_NONNULL_BEGIN
@class Design;
@class Match;
@class Rating;

@interface iPhonePlayMatch : UIViewController<UIPopoverPresentationControllerDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate >

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Match *match;
@property (strong, readwrite, retain, atomic) Rating *rating;

@property (strong, readwrite, retain, atomic) NSMutableDictionary *ratingDict;

@property (strong, readwrite, retain, atomic) NSString *matchLink;
@property (strong, readwrite, retain, atomic) NSMutableArray *topPageArray;

@end

NS_ASSUME_NONNULL_END
