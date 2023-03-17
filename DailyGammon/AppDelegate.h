//
//  AppDelegate.h
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Design;
@class DbConnect;
@class Tools;
@class Preferences;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Tools *tools;
@property (strong, readwrite, retain, atomic) Preferences *preferences;

@property (nonatomic, strong) DbConnect *dbConnect;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIStoryboard *activeStoryBoard;

@end

