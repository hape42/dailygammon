//
//  NoInternet.m
//  DailyGammon
//
//  Created by Peter Schneider on 25.09.21.
//  Copyright © 2021 Peter Schneider. All rights reserved.
//

#import "NoInternet.h"
#import "Tools.h"
#import "TopPageCV.h"
#import "AppDelegate.h"
#import "About.h"
#import "GameLoungeCV.h"

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
     
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if(![tools hasConnectivity])
    {
        [self exitApp];
    }
    else
    {
        XLog(@"AboutCount %ld", [[NSUserDefaults standardUserDefaults] integerForKey:@"AboutCount"]);
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"AboutCount"] == 5)
        {
            About *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"About"];

            vc.showRemindMeLaterButton = YES;
            [self.navigationController pushViewController:vc animated:NO];
            return;

        }
        TopPageCV *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil]  instantiateViewControllerWithIdentifier:@"TopPageCV"];
        
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
