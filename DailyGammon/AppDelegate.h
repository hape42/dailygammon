//
//  AppDelegate.h
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Design;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, readwrite, retain, atomic) Design *design;

@property (strong, nonatomic) UIWindow *window;


@end

