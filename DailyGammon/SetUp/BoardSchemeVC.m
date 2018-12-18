//
//  BoardSchemeVC.m
//  DailyGammon
//
//  Created by Peter on 05.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "BoardSchemeVC.h"
#import "Design.h"

@interface BoardSchemeVC ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *schemaWaehlenOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *schema4;
@property (weak, nonatomic) IBOutlet UIImageView *schema3;
@property (weak, nonatomic) IBOutlet UIImageView *schema2;
@property (weak, nonatomic) IBOutlet UIImageView *schema1;

@end

@implementation BoardSchemeVC

@synthesize design;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    design = [[Design alloc] init];

    UITapGestureRecognizer *oneFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTouched:)];
    oneFingerTap.numberOfTapsRequired = 1;
    oneFingerTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:oneFingerTap];
}

- (void)cellTouched:(UIGestureRecognizer *)gesture
{
    CGPoint tapLocation = [gesture locationInView:self.view];
//    XLog(@"TapPoint = %@ ", NSStringFromCGPoint(tapLocation));
    if( CGRectContainsPoint(self.schema4.frame, tapLocation) )
    {
        [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"BoardSchema"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSchemaNotification" object:self];
        self.schemaWaehlenOutlet.selectedSegmentIndex = 3;
    }
    if( CGRectContainsPoint(self.schema3.frame, tapLocation) )
    {
        [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"BoardSchema"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSchemaNotification" object:self];
        self.schemaWaehlenOutlet.selectedSegmentIndex = 2;
    }
    if( CGRectContainsPoint(self.schema2.frame, tapLocation) )
    {
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"BoardSchema"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSchemaNotification" object:self];
        self.schemaWaehlenOutlet.selectedSegmentIndex = 1;
    }
    if( CGRectContainsPoint(self.schema1.frame, tapLocation) )
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"BoardSchema"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSchemaNotification" object:self];
        self.schemaWaehlenOutlet.selectedSegmentIndex = 0;
    }

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

    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];

    UIWindow* mWindow = [[UIApplication sharedApplication] keyWindow];
    mWindow.tintColor = [schemaDict objectForKey:@"TintColor"];
    
    [self viewDidLoad];
}

@end
