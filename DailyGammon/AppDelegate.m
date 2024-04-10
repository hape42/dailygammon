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
#import "Preferences.h"
#import "Constants.h"
#import "DBConnect.h"
#import "RatingCD.h"
#import <StoreKit/StoreKit.h>
#import <BackgroundTasks/BackgroundTasks.h>
#import <UserNotifications/UserNotifications.h>

#import "GameLoungeCV.h"
#import "Review.h"
#import "Tournament.h"
#import "TopPageCV.h"
#import "PlayMatch.h"
#import "NoInternet.h"
#import "NoBoard.h"
#import "SetUp/SetUpVC.h"
#import "RatingVC.h"
#import "LoginVC.h"
#import "SetupVC.h"
#import "About.h"
#import <SafariServices/SafariServices.h>
#import "PlayerVC.h"
#import "GameLoungeCV.h"
#import "PlayerLists.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

@synthesize design,tools, preferences, ratingCD,activeStoryBoard;
@synthesize chatBuffer;

@synthesize matchLink;
@synthesize playMatchAktiv;
@synthesize actionDict, boardDict;

//- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskLandscape;
//
//    UIViewController *currentViewController = [self topViewControllerWithRootViewController:self.window.rootViewController];
// //   XLog(@"CurrentVC: %@", currentViewController);
//
//    if (currentViewController.class == GameLoungeCV.class) orientationMask = UIInterfaceOrientationMaskAll;
//    if (currentViewController.class == Review.class)       orientationMask = UIInterfaceOrientationMaskAll;
//    if (currentViewController.class == Tournament.class)   orientationMask = UIInterfaceOrientationMaskAll;
//    if (currentViewController.class == TopPageCV.class)    orientationMask = UIInterfaceOrientationMaskAll;
//    if (currentViewController.class == TopPageVC.class)    orientationMask = UIInterfaceOrientationMaskAll;
//    if (currentViewController.class == PlayMatch.class)    orientationMask = UIInterfaceOrientationMaskAll;
//    if (currentViewController.class == NoInternet.class)   orientationMask = UIInterfaceOrientationMaskAll;
//    if (currentViewController.class == NoBoard.class)      orientationMask = UIInterfaceOrientationMaskAll;
//    if (currentViewController.class == SetUpVC.class)      orientationMask = UIInterfaceOrientationMaskAll;
//
//    if (currentViewController.view.tag == ALERT_VIEW_TAG) orientationMask = UIInterfaceOrientationMaskAll; //
//    
//    return orientationMask;
//}

- (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController
{
    // Walking recursively through view hierarchie to identify top-most view controller
    
    if (rootViewController == nil) return nil;
    if ([rootViewController isKindOfClass:UITabBarController.class])
    {
        return [self topViewControllerWithRootViewController:((UITabBarController *)rootViewController).selectedViewController];
    }
    else if ([rootViewController isKindOfClass:UINavigationController.class])
    {
        return [self topViewControllerWithRootViewController:((UINavigationController *)rootViewController).topViewController];
    }
    else if ((rootViewController.presentedViewController != nil) && rootViewController.presentedViewController.isBeingDismissed == FALSE)
    {
        return [self topViewControllerWithRootViewController:rootViewController.presentedViewController];
    }

    return rootViewController;
}
- (UIMenu *)mainMenu:(UINavigationController *)navigationController button:(UIButton *)menuButton
{
    
    int countDB = [self.dbConnect countRating];
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"iCloud"]boolValue])
        countDB = 99;
    int minDB = 5;

    NSMutableArray  *menuArray = [[NSMutableArray alloc] initWithCapacity:9];

 
    [menuArray addObject:[UIAction actionWithTitle:@"Top Page"
                                             image:[design designSystemImage:[NSString stringWithFormat:@"%d.square", [[[NSUserDefaults standardUserDefaults] valueForKey:@"matchCount"]intValue]]]
                                        identifier:@"1"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [navigationController popToRootViewControllerAnimated:NO];
        
        TopPageCV *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"TopPageCV"];
        [navigationController pushViewController:vc animated:NO];

    }]];
    
    [menuArray addObject:[UIAction actionWithTitle:@"Game Lounge"
                                             image:[design designSystemImage:@"person.badge.plus"]
                                        identifier:@"2"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [navigationController popToRootViewControllerAnimated:NO];
        
        GameLoungeCV *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"GameLoungeCV"];
        [navigationController pushViewController:vc animated:NO];

    }]];

    [menuArray addObject:[UIAction actionWithTitle:@"Help"
                                             image:[design designSystemImage:@"questionmark.circle"]
                                        identifier:@"3"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [navigationController popToRootViewControllerAnimated:NO];
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com/help"]];
        
        [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];

    }]];

    [menuArray addObject:[UIAction actionWithTitle:@"Settings"
                                             image:[design designSystemImage:@"gear.badge.questionmark"]
                                        identifier:@"4"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        SetUpVC *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"SetUpVC"];
        vc.modalPresentationStyle = UIModalPresentationPopover;
        [navigationController presentViewController:vc animated:NO completion:nil];
        
        UIPopoverPresentationController *popController = [vc popoverPresentationController];
        popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
       // popController.delegate = self;
        
        popController.sourceView = menuButton;
        popController.sourceRect = menuButton.bounds;

    }]];

    [menuArray addObject:[UIAction actionWithTitle:@"Logout"
                                             image:[design designSystemImage:@"door.right.hand.open"]
                                        identifier:@"5"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"user"];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"password"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [navigationController popToRootViewControllerAnimated:NO];

        LoginVC *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
        [navigationController pushViewController:vc animated:NO];
    }]];

    [menuArray addObject:[UIAction actionWithTitle:@"About"
                                             image:[design designSystemImage:@"info.circle"]
                                        identifier:@"6"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [navigationController popToRootViewControllerAnimated:NO];

        About *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"About"];
        vc.showRemindMeLaterButton = NO;
        [navigationController pushViewController:vc animated:NO];
    }]];

    if(countDB > minDB)
    {
        [menuArray addObject:[UIAction actionWithTitle:@"Rating"
                                                 image:[design designSystemImage:@"chart.line.uptrend.xyaxis"]
                                            identifier:@"7"
                                               handler:^(__kindof UIAction* _Nonnull action) {
            [navigationController popToRootViewControllerAnimated:NO];

            RatingVC *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"RatingVC"];
            [navigationController pushViewController:vc animated:NO];
        }]];
   }
    
    [menuArray addObject:[UIAction actionWithTitle:@"Players"
                                             image:[design designSystemImage:@"person.3"]
                                        identifier:@"8"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [navigationController popToRootViewControllerAnimated:NO];

        PlayerVC *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"PlayerVC"];
        
        [navigationController pushViewController:vc animated:NO];
    }]];

    [menuArray addObject:[UIAction actionWithTitle:@"Lists"
                                             image:[design designSystemImage:@"list.number"]
                                        identifier:@"9"
                                           handler:^(__kindof UIAction* _Nonnull action) {
        [navigationController popToRootViewControllerAnimated:NO];
        
        PlayerLists *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"PlayerLists"];
        [navigationController pushViewController:vc animated:NO];
    }]];

    return [UIMenu menuWithChildren:menuArray];

}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    chatBuffer = @"";
    playMatchAktiv = NO;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    activeStoryBoard = [UIStoryboard storyboardWithName:@"iPad" bundle:nil];

    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad)
        activeStoryBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];

    UIViewController *rootController = [activeStoryBoard instantiateInitialViewController];
    self.window.rootViewController = rootController;
    [self.window makeKeyAndVisible];

    design      = [[Design alloc] init];
    tools       = [[Tools alloc] init];
    preferences = [[Preferences alloc] init];
    ratingCD    = [[RatingCD alloc] init];

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

#pragma mark - Convert DB from sqlLite to CoreDate/iCloud
    if([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"convertDB_done"])
    {
        XLog(@"convertDB_done found %d", [[NSUserDefaults standardUserDefaults] boolForKey:@"convertDB_done"]);
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"convertDB_done"];
        XLog(@"convertDB_done not found %d", [[NSUserDefaults standardUserDefaults] boolForKey:@"convertDB_done"]);
    }
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"convertDB_done"] == FALSE)
    {
        [ratingCD convertDB];
    }
    XLog(@"convertDB_done  %d", [[NSUserDefaults standardUserDefaults] boolForKey:@"convertDB_done"]);

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

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentCloudKitContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentCloudKitContainer alloc] initWithName:@"DailyGammon"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}
- (NSManagedObjectContext *)managedObjectContext
{
    NSThread *currentThread = [NSThread currentThread];
    if (currentThread == [NSThread mainThread])
    {
        return self.persistentContainer.viewContext;
    }
    else
    {
        // Return separate MOC for each new thread

        NSManagedObjectContext *backgroundContext = [currentThread.threadDictionary objectForKey:@"MOC_KEY"];
        if (backgroundContext == nil)
        {
            backgroundContext = self.persistentContainer.newBackgroundContext;
            [currentThread.threadDictionary setObject:backgroundContext forKey:@"MOC_KEY"];
        }

        return backgroundContext;
    }
}
@end
