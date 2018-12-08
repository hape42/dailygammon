//
//  BoardSchemeVC.m
//  DailyGammon
//
//  Created by Peter on 05.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "BoardSchemeVC.h"

@interface BoardSchemeVC ()

@property (weak, nonatomic) IBOutlet UISwitch *schema1Outlet;
@property (weak, nonatomic) IBOutlet UISwitch *schema2Outlet;

@end

@implementation BoardSchemeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    int schema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    
    switch (schema)
    {
        case 1:
            [self.schema1Outlet setOn:YES animated:YES];
            [self.schema2Outlet setOn:NO animated:YES];
          break;
        case 2:
            [self.schema2Outlet setOn:YES animated:YES];
            [self.schema1Outlet setOn:NO animated:YES];
            break;

        default:
            break;
    }
}

- (IBAction)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)schema1:(id)sender
{
    UISwitch *schemaSwitch = (UISwitch *)sender;
    if ([schemaSwitch isOn])
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1  forKey:@"BoardSchema"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //alle anderen auf off setzen
        [self.schema2Outlet setOn:NO animated:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSchemaNotification" object:self];
    }
}

- (IBAction)schema2:(id)sender
{
    UISwitch *schemaSwitch = (UISwitch *)sender;
    
    if ([schemaSwitch isOn])
    {
        [[NSUserDefaults standardUserDefaults] setInteger:2  forKey:@"BoardSchema"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        //alle anderen auf off setzen
        [self.schema1Outlet setOn:NO animated:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSchemaNotification" object:self];
    }
}


@end
