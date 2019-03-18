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

@property (weak, nonatomic) IBOutlet UIImageView *schema4;
@property (weak, nonatomic) IBOutlet UIImageView *schema3;
@property (weak, nonatomic) IBOutlet UIImageView *schema2;
@property (weak, nonatomic) IBOutlet UIImageView *schema1;
@property (weak, nonatomic) IBOutlet UISegmentedControl *waehleSchemaOutlet;

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
    
    if([design isX])
    {
        CGRect frame = self.waehleSchemaOutlet.frame;
        frame.size.width -= 30;
        self.waehleSchemaOutlet.frame = frame;
    }

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    int schema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    self.waehleSchemaOutlet.selectedSegmentIndex = schema - 1;
  
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad)
    {
        float x = self.waehleSchemaOutlet.frame.origin.x;
        float w = self.waehleSchemaOutlet.frame.size.width / 4;
        float faktor = self.schema4.frame.size.width / (w - 10 - 10);
        
        CGRect frame = self.schema1.frame;
        frame.size.width  /= faktor;
        frame.size.height /= faktor;
        frame.origin.x = x + 10;
        self.schema1.frame = frame;
        
        frame = self.schema2.frame;
        frame.size.width  /= faktor;
        frame.size.height /= faktor;
        frame.origin.x = x + 10 + w ;
        self.schema2.frame = frame;
        
        frame = self.schema3.frame;
        frame.size.width  /= faktor;
        frame.size.height /= faktor;
        frame.origin.x = x + 10 + w + w ;
        self.schema3.frame = frame;
        
        frame = self.schema4.frame;
        frame.size.width  /= faktor;
        frame.size.height /= faktor;
        frame.origin.x = x + 10 + w + w + w ;
        self.schema4.frame = frame;
    }
}

- (void)cellTouched:(UIGestureRecognizer *)gesture
{
    CGPoint tapLocation = [gesture locationInView:self.view];
//    XLog(@"TapPoint = %@ ", NSStringFromCGPoint(tapLocation));
    if( CGRectContainsPoint(self.schema4.frame, tapLocation) )
    {
        [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"BoardSchema"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.waehleSchemaOutlet.selectedSegmentIndex = 3;
    }
    if( CGRectContainsPoint(self.schema3.frame, tapLocation) )
    {
        [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"BoardSchema"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.waehleSchemaOutlet.selectedSegmentIndex = 2;
    }
    if( CGRectContainsPoint(self.schema2.frame, tapLocation) )
    {
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"BoardSchema"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.waehleSchemaOutlet.selectedSegmentIndex = 1;
    }
    if( CGRectContainsPoint(self.schema1.frame, tapLocation) )
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"BoardSchema"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.waehleSchemaOutlet.selectedSegmentIndex = 0;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSchemaNotification" object:self];

    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
    
    [UIApplication sharedApplication].delegate.window.tintColor = [schemaDict objectForKey:@"TintColor"];

}

- (IBAction)doneAction:(id)sender
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:TRUE];
}

- (IBAction)schemaWaehlen:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:((UISegmentedControl*)sender).selectedSegmentIndex + 1  forKey:@"BoardSchema"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSchemaNotification" object:self];
    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
    [UIApplication sharedApplication].delegate.window.tintColor = [schemaDict objectForKey:@"TintColor"];
}

@end
