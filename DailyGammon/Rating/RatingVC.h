//
//  RatingVC.h
//  DailyGammon
//
//  Created by Peter on 27.02.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import <MessageUI/MessageUI.h>

NS_ASSUME_NONNULL_BEGIN

@class Design;
@class Preferences;
@class Rating;
@class Tools;
@class RatingTools;
@class RatingCD;

@interface RatingVC : UIViewController< MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate>

@property (nonatomic, assign) BOOL shouldHideData;

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Preferences *preferences;
@property (strong, readwrite, retain, atomic) Rating *rating;
@property (strong, readwrite, retain, atomic) Tools *tools;
@property (strong, readwrite, retain, atomic) RatingTools *ratingTools;
@property (strong, readwrite, retain, atomic) RatingCD *ratingCD;

@property (strong, readwrite, retain, atomic) UIView *infoView;

@end

NS_ASSUME_NONNULL_END
