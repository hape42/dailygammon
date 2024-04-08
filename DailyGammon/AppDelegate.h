//
//  AppDelegate.h
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Design;
@class DbConnect;
@class Tools;
@class Preferences;
@class RatingCD;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentCloudKitContainer *persistentContainer;
- (void)saveContext;

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Tools *tools;
@property (strong, readwrite, retain, atomic) Preferences *preferences;
@property (strong, readwrite, retain, atomic) RatingCD *ratingCD;

@property (nonatomic, strong) DbConnect *dbConnect;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIStoryboard *activeStoryBoard;

@property (strong, readwrite, retain, atomic) NSString *chatBuffer;

- (UIMenu *)mainMenu:(UINavigationController *)navigationController button:(UIButton *)menuButton;

@property (strong, readwrite, retain, atomic) NSString *matchLink;
@property (readwrite, assign, atomic) BOOL playMatchAktiv;;
@property (readwrite, retain, nonatomic) NSMutableDictionary *actionDict;
@property (readwrite, retain, nonatomic) NSMutableDictionary *boardDict;

@end

