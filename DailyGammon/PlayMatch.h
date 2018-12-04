//
//  PlayMatch.h
//  DailyGammon
//
//  Created by Peter on 29.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class Design;

@interface PlayMatch : UIViewController

@property (strong, readwrite, retain, atomic) Design *design;

@property (strong, readwrite, retain, atomic) NSString *matchLink;

@end

NS_ASSUME_NONNULL_END
