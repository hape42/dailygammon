//
//  ChatVC.m
//  DailyGammon
//
//  Created by Peter Schneider on 18.02.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import "ChatVC.h"

@interface ChatVC ()

@end

@implementation ChatVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
  //  self.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];

 //   [self layoutObjects];
}


#pragma mark - autoLayout

-(BOOL)prefersStatusBarHidden
{
    // maximize view
    return YES;
}

-(void)layoutObjects
{
    UIView *superview = self.view;
    UILayoutGuide *safe = superview.safeAreaLayoutGuide;
    
    float edge = 5.0;
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         // Code to be executed during the animation
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         // Code to be executed after the animation is completed
     }];

    XLog(@"Neue Breite: %.2f, Neue Höhe: %.2f", size.width, size.height);
    

}

@end
