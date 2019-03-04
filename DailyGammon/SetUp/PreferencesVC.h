//
//  Preferences.h
//  DailyGammon
//
//  Created by Peter on 10.02.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class Design;
@class Preferences;

@interface PreferencesVC : UIViewController<UIScrollViewDelegate>

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Preferences *preferences;

@end

NS_ASSUME_NONNULL_END
