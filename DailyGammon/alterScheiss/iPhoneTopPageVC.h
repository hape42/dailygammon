//
//  iPhoneTopPageVC.h
//  DailyGammon
//
//  Created by Peter on 01.03.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class Design;
@class Preferences;
@class Rating;
@class Tools;

@interface iPhoneTopPageVC : UIViewController<UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate>

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Preferences *preferences;
@property (strong, readwrite, retain, atomic) Rating *rating;
@property (strong, readwrite, retain, atomic) Tools *tools;

@end

NS_ASSUME_NONNULL_END
