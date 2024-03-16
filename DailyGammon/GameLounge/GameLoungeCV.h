//
//  GameLounge.h
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "WaitView.h"

@class Design;
@class Preferences;
@class Rating;
@class Tools;

NS_ASSUME_NONNULL_BEGIN

@interface GameLoungeCV : UIViewController<NSURLSessionDataDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIPopoverPresentationControllerDelegate>

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Preferences *preferences;
@property (strong, readwrite, retain, atomic) Rating *rating;
@property (strong, readwrite, retain, atomic) Tools *tools;

@property (strong, nonatomic, readwrite) WaitView *waitView;

@end

NS_ASSUME_NONNULL_END
