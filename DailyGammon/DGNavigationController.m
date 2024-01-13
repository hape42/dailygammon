//
//  DGNavigationController.m
//  DailyGammon
//
//  Created by Peter Schneider on 26.12.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import "DGNavigationController.h"

@interface DGNavigationController ()

@end

@implementation DGNavigationController

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

@end
