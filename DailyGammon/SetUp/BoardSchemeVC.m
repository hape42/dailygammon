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

@property (weak, nonatomic) IBOutlet UISegmentedControl *myColor;
@property (readwrite, retain, nonatomic) UIView *myColorView;
@property (readwrite, retain, nonatomic) UISwitch *switchColor1;
@property (readwrite, retain, nonatomic) UISwitch *switchColor2;
@property (readwrite, retain, nonatomic) UIImageView *color1;
@property (readwrite, retain, nonatomic) UIImageView *color2;

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
        
        frame = self.myColor.frame;
        frame.size.width -= 30;
        self.myColor.frame = frame;
   }

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    int schema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    self.waehleSchemaOutlet.selectedSegmentIndex = schema - 1;
  
    int sameColor = [[[NSUserDefaults standardUserDefaults] valueForKey:@"sameColor"]intValue];
    self.myColor.selectedSegmentIndex = sameColor;

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
        
        frame = self.myColor.frame;
        frame.origin.y = self.schema4.frame.origin.y + self.schema4.frame.size.height + 10;
        self.myColor.frame = frame;
    }
    [self makeColorAuswahl];

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

    [self makeColorAuswahl];

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
    
    [self makeColorAuswahl];
}
- (IBAction)myColorAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:((UISegmentedControl*)sender).selectedSegmentIndex  forKey:@"sameColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self makeColorAuswahl];

}

- (void) makeColorAuswahl
{
    
    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1) boardSchema = 4;
    
    NSMutableDictionary *schemaDict = [design schema:boardSchema];

    switch (boardSchema) {
        case 1:
            [self.myColor setTitle:@"Always Blue" forSegmentAtIndex:1];
            [self.myColor setTitle:@"Always Yellow" forSegmentAtIndex:2];
            break;
        case 2:
            [self.myColor setTitle:@"Always Blue" forSegmentAtIndex:1];
            [self.myColor setTitle:@"Always Yellow" forSegmentAtIndex:2];
            break;
        case 3:
            [self.myColor setTitle:@"Always Blue" forSegmentAtIndex:1];
            [self.myColor setTitle:@"Always White" forSegmentAtIndex:2];
            break;
        case 4:
            [self.myColor setTitle:@"Always Black" forSegmentAtIndex:1];
            [self.myColor setTitle:@"Always Red" forSegmentAtIndex:2];
            break;
        default:
            break;
    }
    UIView * rahmen =  [[UIView alloc] initWithFrame:CGRectMake(self.myColor.frame.origin.x,
                                                                self.myColor.frame.origin.y + self.myColor.frame.size.height,
                                                                self.myColor.frame.size.width,
                                                                50)];
    rahmen.layer.borderWidth = 1;
    rahmen.layer.borderColor = [[schemaDict objectForKey:@"TintColor"] CGColor];
    [self.view addSubview:rahmen];
    
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    infoButton = [design makeNiceFlatButton:infoButton];
    infoButton.layer.cornerRadius = 14.0f;
    [infoButton setTitle:@"Info" forState: UIControlStateNormal];
    infoButton.frame = CGRectMake(self.myColor.frame.origin.x + (self.myColor.frame.size.width / 2) - 25,
                                  self.myColor.frame.origin.y + self.myColor.frame.size.height + 10,
                                  50,
                                  30);
    [infoButton addTarget:self action:@selector(info:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:infoButton];

}
- (IBAction)info:(id)sender
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Info"
                                 message:@"On DailyGammon your checker color is determined at the start of each match. \n\nDepending on the draw, or whether you sent or accepted an invitation, you get one color or the other. \n\n\nThis option allows you to override this and choose the same color for all your matches instead. "
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    
                                }];
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)actionColor1:(id)sender
{   
    if([(UISwitch *)sender isOn])
    {
        [self.switchColor2 setOn:NO animated:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES  forKey:@"myColorB"];
    }
    else
    {
        [self.switchColor2 setOn:YES animated:YES];
        [[NSUserDefaults standardUserDefaults] setBool:NO  forKey:@"myColorB"];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)actionColor2:(id)sender
{
    
    if([(UISwitch *)sender isOn])
    {
        [self.switchColor1 setOn:NO animated:YES];
        [[NSUserDefaults standardUserDefaults] setBool:NO  forKey:@"myColorB"];
    }
    else
    {
        [self.switchColor1 setOn:YES animated:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES  forKey:@"myColorB"];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
