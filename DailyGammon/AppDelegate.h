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

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, readwrite, retain, atomic) Design *design;
@property (nonatomic, strong) DbConnect *dbConnect;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIStoryboard *activeStoryBoard;

@end

