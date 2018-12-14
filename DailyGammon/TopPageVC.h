//
//  TopPageVC.h
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Design;
@class Preferences;
@class Rating;

NS_ASSUME_NONNULL_BEGIN

@interface TopPageVC : UIViewController<UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate>

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Preferences *preferences;
@property (strong, readwrite, retain, atomic) Rating *rating;

@end

NS_ASSUME_NONNULL_END
