//
//  Header.h
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Design;

NS_ASSUME_NONNULL_BEGIN

@interface HeaderX : UIViewController

@property (strong, readwrite, retain, atomic) Design *design;

-(UIView *)makeHeader;

@end

NS_ASSUME_NONNULL_END
