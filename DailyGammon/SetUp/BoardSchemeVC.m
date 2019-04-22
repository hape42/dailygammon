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
    UIView *removeView;
    while((removeView = [self.view viewWithTag:42]) != nil)
    {
        for (UIView *subUIView in removeView.subviews)
        {
            [subUIView removeFromSuperview];
        }
        [removeView removeFromSuperview];
    }

    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1) boardSchema = 4;
    
    NSMutableDictionary *schemaDict = [design schema:boardSchema];

    int sameColor = [[[NSUserDefaults standardUserDefaults] valueForKey:@"sameColor"]intValue];
    if(!sameColor)
        return;
    UIView * rahmen =  [[UIView alloc] initWithFrame:CGRectMake(self.myColor.frame.origin.x,
                                                                self.myColor.frame.origin.y + self.myColor.frame.size.height,
                                                                self.myColor.frame.size.width,
                                                                70)];
    rahmen.layer.borderWidth = 1;
    rahmen.layer.borderColor = [[schemaDict objectForKey:@"TintColor"] CGColor];
    [self.view addSubview:rahmen];
    
    self.myColorView = [[UIView alloc]init];
    self.myColorView.tag = 42;
    self.myColorView.frame = CGRectMake(self.myColor.frame.origin.x + (self.myColor.frame.size.width / 2) + 10,
                                        self.myColor.frame.origin.y + self.myColor.frame.size.height + 10,
                                        (self.myColor.frame.size.width / 2) - 20,
                                        50);

    self.myColorView.backgroundColor = [schemaDict objectForKey:@"RandSchemaColor"];
    [self.view addSubview:self.myColorView];

    int x,y;
    float checkerBreite = 25.0;
    x = 5;
    y = 5;
    // Rahmen berechnen
    float rahmenBreite = 50 + 10 + checkerBreite;
    float rahmenLuecke = ((self.myColorView.frame.size.width ) - rahmenBreite - rahmenBreite) / 3;
    UIView *color1Rahmen = [[UIView alloc] initWithFrame:CGRectMake(rahmenLuecke,
                                                                    5,
                                                                    rahmenBreite,
                                                                    40)];
    color1Rahmen.layer.borderWidth = 1;
    [self.myColorView addSubview:color1Rahmen];
    
    UIView *color2Rahmen = [[UIView alloc] initWithFrame:CGRectMake(rahmenLuecke + rahmenBreite + rahmenLuecke,
                                                                    5,
                                                                    rahmenBreite,
                                                                    40)];
    color2Rahmen.layer.borderWidth = 1;
    [self.myColorView addSubview:color2Rahmen];


    self.switchColor1 = [[UISwitch alloc] initWithFrame:
                              CGRectMake(x,
                                         y,
                                         50,
                                         30)];
    self.switchColor1.transform = CGAffineTransformMakeScale(checkerBreite / 31.0, checkerBreite / 31.0);
    
    [self.switchColor1 addTarget: self action: @selector(actionColor1:) forControlEvents:UIControlEventValueChanged];
    [self.switchColor1 setTintColor:[schemaDict objectForKey:@"TintColor"]];
    [self.switchColor1 setOnTintColor:[schemaDict objectForKey:@"TintColor"]];
    [color1Rahmen addSubview: self.switchColor1];

    x += self.switchColor1.frame.size.width + 10;
    
    NSString *imgName = [NSString stringWithFormat:@"%d/bar_b1",boardSchema] ;
    self.color1 =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    self.color1.frame = CGRectMake(x,
                                   self.switchColor1.frame.origin.y + ( (self.switchColor1.frame.size.height - checkerBreite) / 2),
                                   checkerBreite,
                                   checkerBreite);
    [color1Rahmen addSubview:self.color1];
    
    imgName = [NSString stringWithFormat:@"%d/bar_y1",boardSchema] ;
    self.color2 =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    
    x = 5;

    self.switchColor2 = [[UISwitch alloc] initWithFrame:
                         CGRectMake(x,
                                    y,
                                    50,
                                    30)];
    self.switchColor2.transform = CGAffineTransformMakeScale(checkerBreite / 31.0, checkerBreite / 31.0);
    
    [self.switchColor2 addTarget: self action: @selector(actionColor2:) forControlEvents:UIControlEventValueChanged];
    [self.switchColor2 setTintColor:[schemaDict objectForKey:@"TintColor"]];
    [self.switchColor2 setOnTintColor:[schemaDict objectForKey:@"TintColor"]];
    [color2Rahmen addSubview: self.switchColor2];
    
    x += self.switchColor2.frame.size.width + 10;

    self.color2.frame = CGRectMake(x, self.switchColor2.frame.origin.y + ( (self.switchColor2.frame.size.height - checkerBreite) / 2), checkerBreite, checkerBreite);
    [color2Rahmen addSubview:self.color2];
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    infoButton = [design makeNiceFlatButton:infoButton];
    infoButton.layer.cornerRadius = 14.0f;
    [infoButton setTitle:@"Info" forState: UIControlStateNormal];
    infoButton.frame = CGRectMake(self.myColor.frame.origin.x + (self.myColor.frame.size.width / 4) - 25,
                                  self.myColor.frame.origin.y + self.myColor.frame.size.height + 10 + 10,
                                  50,
                                  30);
    [infoButton addTarget:self action:@selector(info:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:infoButton];

    if([[NSUserDefaults standardUserDefaults] boolForKey:@"myColorB"])
    {
        [self.switchColor1 setOn:YES animated:YES];
        [self.switchColor2 setOn:NO animated:YES];
    }
    else
    {
        [self.switchColor2 setOn:YES animated:YES];
        [self.switchColor1 setOn:NO animated:YES];
        [[NSUserDefaults standardUserDefaults] setBool:NO  forKey:@"myColorB"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    //XLog(@"%@",  [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);

}
- (IBAction)info:(id)sender
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Info"
                                 message:@"Hier kann ein ausführlicher Erklärungstext stehen damit auch Backgammon Spieler, die mit IT nicht so fit sind, eine Chance haben zu verstehen, was hier machen können \n \bI accept changing colors \n und \n I want to play my Color   \n sind niur eine erste Idee und sehr einfach durch \"bessere\" Texte ersetzbar "
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
