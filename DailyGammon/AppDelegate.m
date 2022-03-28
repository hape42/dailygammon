//
//  AppDelegate.m
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "AppDelegate.h"
#import "Design.h"
#import "DBConnect.h"
#import <StoreKit/StoreKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize design, activeStoryBoard;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    activeStoryBoard = [UIStoryboard storyboardWithName:@"iPad" bundle:nil];

    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad)
        activeStoryBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];

    UIViewController *rootController = [activeStoryBoard instantiateInitialViewController];
    self.window.rootViewController = rootController;
    [self.window makeKeyAndVisible];

    design = [[Design alloc] init];

    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
    if(schemaDict.count == 0)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"BoardSchema"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        schemaDict = [design schema:4];
    }
 //   [self.window setTintColor:[schemaDict objectForKey:@"TintColor"]];
    [self.window setTintColor:[UIColor colorNamed:@"ColorSwitch"]];

    long count = [[NSUserDefaults standardUserDefaults] integerForKey:@"LaunchCount"];
    if(count < 0) count = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:count+1 forKey:@"LaunchCount"];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    long count = [[NSUserDefaults standardUserDefaults] integerForKey:@"LaunchCount"];
    if(count < 0) count = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:count+1 forKey:@"LaunchCount"];

}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"LaunchCount"] == 5)
    {
        [SKStoreReviewController requestReview] ;
    }
    if([[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies].count > 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidBecomeActive" object:self];
    }

}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (DbConnect *)dbConnect
{
    if (!_dbConnect)
    {
        _dbConnect = [[DbConnect alloc] init];
        [_dbConnect openDb];
        
    }
    // [_dbConnect openDb];
    return _dbConnect;
}

@end
