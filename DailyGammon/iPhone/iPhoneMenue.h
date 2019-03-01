//
//  iPhoneMenue.h
//  DailyGammon
//
//  Created by Peter on 01.03.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class Design;

@interface iPhoneMenue : UIViewController

@property (strong, readwrite, retain, atomic) Design *design;

@end

NS_ASSUME_NONNULL_END
