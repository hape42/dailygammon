//
//  PlayMatch.h
//  DailyGammon
//
//  Created by Peter on 29.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class Header;
@class Design;

@interface PlayMatch : UIViewController

@property (strong, readwrite, retain, atomic) Header *header;
@property (strong, readwrite, retain, atomic) Design *design;

@end

NS_ASSUME_NONNULL_END
