//
//  NoInternet.m
//  DailyGammon
//
//  Created by Peter Schneider on 25.09.21.
//  Copyright © 2021 Peter Schneider. All rights reserved.
//

#import "NoInternet.h"
#import "Tools.h"
#import "TopPageVC.h"
#import "AppDelegate.h"
#import "About.h"

@interface NoInternet ()

@end

@implementation NoInternet
@synthesize tools;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    tools       = [[Tools alloc] init];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(![tools hasConnectivity])
    {
        [self exitApp];
    }
    else
    {
        XLog(@"AboutCount %ld", [[NSUserDefaults standardUserDefaults] integerForKey:@"AboutCount"]);
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"AboutCount"] == 5)
        {
            About *vc = [[About alloc]init];
            
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
                vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"About"];
            else
                vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneAbout"];
            vc.showRemindMeLaterButton = YES;
            [self.navigationController pushViewController:vc animated:NO];
            return;

        }
        TopPageVC *vc = [[TopPageVC alloc]init];
        
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
            vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"TopPageVC"];
        else
            vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneTopPageVC"];

        [self.navigationController pushViewController:vc animated:NO];

    }
}
- (void)exitApp
{
    UIAlertController * alert = [UIAlertController
                                  alertControllerWithTitle:@"Problem"
                                  message:@"This app is a client for the backgammon server from www.dailygammon.com\n\nThe app can only be used with a working internet connection.\n\nPlease make sure you have an internet connection and restart the app.\n\nThe app will exit now "
                                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    exit(0);
                                }];

    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];

}

@end
