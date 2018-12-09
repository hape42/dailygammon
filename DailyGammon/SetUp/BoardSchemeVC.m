//
//  BoardSchemeVC.m
//  DailyGammon
//
//  Created by Peter on 05.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "BoardSchemeVC.h"

@interface BoardSchemeVC ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *schemaWaehlenOutlet;

@end

@implementation BoardSchemeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    int schema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    
    self.schemaWaehlenOutlet.selectedSegmentIndex = schema - 1;

}

- (IBAction)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)schemaWaehlen:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:((UISegmentedControl*)sender).selectedSegmentIndex + 1  forKey:@"BoardSchema"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSchemaNotification" object:self];

}

@end
