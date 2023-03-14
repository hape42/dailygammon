//
//  AppDelegate.m
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "AppDelegate.h"
#import "Design.h"
#import "Tools.h"
#import "DBConnect.h"
#import <StoreKit/StoreKit.h>
#import <BackgroundTasks/BackgroundTasks.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

@synthesize design,tools ,activeStoryBoard;

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
    tools = [[Tools alloc] init];

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

    long aboutCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"AboutCount"];
    if(aboutCount < 0) aboutCount = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:aboutCount+1 forKey:@"AboutCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    UNAuthorizationOptions authOptions =
    UNAuthorizationOptionAlert
    | UNAuthorizationOptionSound
    | UNAuthorizationOptionBadge;
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
    }];

    [self configureProcessingTask];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self scheduleProcessingTask];

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    long count = [[NSUserDefaults standardUserDefaults] integerForKey:@"LaunchCount"];
    if(count < 0) count = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:count+1 forKey:@"LaunchCount"];

    long aboutCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"AboutCount"];
    if(aboutCount < 0) aboutCount = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:aboutCount+1 forKey:@"AboutCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if([[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies].count > 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidBecomeActive" object:self];
    }

}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"LaunchCount"] == 5)
    {
        [SKStoreReviewController requestReview] ;
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

static NSString* backgroundTask = @"com.dailygammon.TopPage";

-(void)configureProcessingTask
{
    [[BGTaskScheduler sharedScheduler] registerForTaskWithIdentifier:backgroundTask
                                                          usingQueue:nil
                                                       launchHandler:^(BGTask *task) {
        [self handleProcessingTask:task];
    }];
}

-(void)handleProcessingTask:(BGTask *)task
{
    [tools matchCount];
    int count = [[[NSUserDefaults standardUserDefaults] valueForKey:@"matchCount"]intValue];
    //do things with task
    XLog(@"%d Matches to play", count);
 //   [self scheduleProcessingTask];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].applicationIconBadgeNumber = count;
    });

    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"Dailygammon" arguments:nil];
    content.body = [NSString stringWithFormat:@"There are Matches where you can move"];
    content.sound = [UNNotificationSound defaultSound];
     
    // Deliver the notification in five seconds.
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                triggerWithTimeInterval:5 repeats:NO];
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
                content:content trigger:trigger];
     
    if(count > 0)
    {
        // Schedule the notification.
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:nil];
    }
    [task setTaskCompletedWithSuccess:YES];
    return;
}

-(void)scheduleProcessingTask
{
    NSError *error = NULL;
    // cancel existing task (if any)
    [BGTaskScheduler.sharedScheduler cancelTaskRequestWithIdentifier:backgroundTask];
    // new task
    BGProcessingTaskRequest *request = [[BGProcessingTaskRequest alloc] initWithIdentifier:backgroundTask];
    request.requiresNetworkConnectivity = YES;
    request.earliestBeginDate = [NSDate dateWithTimeIntervalSinceNow:5];
    BOOL success = [[BGTaskScheduler sharedScheduler] submitTaskRequest:request error:&error];
    if (!success)
    {
        // Errorcodes https://stackoverflow.com/a/58224050/872051
        XLog(@"Failed to submit request: %@", error);
    } else
    {
       [tools matchCount];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = [[[NSUserDefaults standardUserDefaults] valueForKey:@"matchCount"]intValue];
        });

        XLog(@"Badge=%d, Success submit request %@",[[[NSUserDefaults standardUserDefaults] valueForKey:@"matchCount"]intValue], request);
    }
}
@end
