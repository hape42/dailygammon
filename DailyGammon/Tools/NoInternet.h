//
//  NoInternet.h
//  DailyGammon
//
//  Created by Peter Schneider on 25.09.21.
//  Copyright © 2021 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class Tools;

@interface NoInternet : UIViewController
@property (strong, readwrite, retain, atomic) Tools *tools;

@end

NS_ASSUME_NONNULL_END
