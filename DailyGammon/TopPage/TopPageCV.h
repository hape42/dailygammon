//
//  TopPageCV.h
//  DailyGammon
//
//  Created by Peter Schneider on 31.01.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "WaitView.h"

@class Design;
@class Preferences;
@class Rating;
@class Tools;
@class RatingTools;

NS_ASSUME_NONNULL_BEGIN

@interface TopPageCV : UIViewController <NSURLSessionDataDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Preferences *preferences;
@property (strong, readwrite, retain, atomic) Rating *rating;
@property (strong, readwrite, retain, atomic) Tools *tools;
@property (strong, readwrite, retain, atomic) RatingTools *ratingTools;

@property (readwrite, retain, nonatomic) NSTimer *timer;
@property (readwrite, assign, atomic) int timeRefresh;
@property (readwrite, assign, atomic) bool refreshButtonPressed;

@property (strong, nonatomic, readwrite) WaitView *waitView;

@end

NS_ASSUME_NONNULL_END
