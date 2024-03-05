//
//  DGButton.m
//  DailyGammon
//
//  Created by Peter Schneider on 03.01.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import "DGButton.h"
#import "Design.h"
#import "Constants.h"

@implementation DGButton

@synthesize design;

- (id)initWithFrame:(CGRect)frame
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeButtonColor) name:changeSchemaNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDesign) name:@"buttonDesign" object:nil];

    self = [super initWithFrame:frame];
    if (self)
    {
        [self customizeButton];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeButtonColor) name:changeSchemaNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDesign) name:@"buttonDesign" object:nil];

    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self customizeButton];
    }
    return self;
}

- (void)customizeButton
{
    design = [[Design alloc] init];

    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1) boardSchema = 4;
        
    self.layer.cornerRadius = 14.0f;
    self.layer.masksToBounds = YES;

    UIButtonConfiguration *buttonConfig = [UIButtonConfiguration plainButtonConfiguration];
    buttonConfig.contentInsets = NSDirectionalEdgeInsetsMake(0, 5, 0, 5);
    buttonConfig.imagePadding = 20;

    self.configuration = buttonConfig;

     
    CAGradientLayer *gradient = [CAGradientLayer layer];

    gradient.frame = self.bounds;
    gradient.startPoint = CGPointMake(1, 0);;
    gradient.endPoint = CGPointMake(1, 1);

    gradient.colors = [NSArray arrayWithObjects:
                       (id)[UIColor colorNamed:@"ColorButtonGradientEdge"].CGColor,
                       (id)[UIColor colorNamed:@"ColorButtonGradientCenter"].CGColor,
                       (id)[UIColor colorNamed:@"ColorButtonGradientEdge"].CGColor, nil];

    gradient.name = @"gradientDG";
    
    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
    UIColor * tintColor = [schemaDict objectForKey:@"TintColor"];

    int buttonDesign = [[[NSUserDefaults standardUserDefaults] valueForKey:@"buttonDesign"]intValue];
    switch (buttonDesign)
    {
        case 0:
            self.layer.borderColor = tintColor.CGColor;
            self.layer.borderWidth = 1;
            self.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];

            break;
        case 1:
            [self.layer insertSublayer:gradient below:self.imageView.layer];
            break;
        case 2:
            self.layer.borderColor = tintColor.CGColor;
            self.layer.borderWidth = 1;
            [self.layer insertSublayer:gradient below:self.imageView.layer];
            break;
        case 3:
            self.backgroundColor = [UIColor colorNamed:@"ColorButtonGradientEdge"];
            break;

        default:
            break;
    }

    [self setTitleColor:[schemaDict objectForKey:@"TintColor"] forState:UIControlStateNormal];
    
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.lineBreakMode = NSLineBreakByClipping; 

    if(title)
        [self setTitle:title forState: UIControlStateNormal];
    

}
- (void)changeButtonColor
{
    design = [[Design alloc] init];

    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];

    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1) boardSchema = 4;
    [self setTitleColor:[schemaDict objectForKey:@"TintColor"] forState:UIControlStateNormal];
}

- (void)changeDesign
{
    design = [[Design alloc] init];

    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1) boardSchema = 4;
        
    self.layer.cornerRadius = 14.0f;
    self.layer.masksToBounds = YES;

    UIButtonConfiguration *buttonConfig = [UIButtonConfiguration plainButtonConfiguration];
    buttonConfig.contentInsets = NSDirectionalEdgeInsetsMake(0, 5, 0, 5);
    buttonConfig.imagePadding = 20;
    self.configuration = buttonConfig;

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.startPoint = CGPointMake(1, 0);;
    gradient.endPoint = CGPointMake(1, 1);

    gradient.colors = [NSArray arrayWithObjects:
                       (id)[UIColor colorNamed:@"ColorButtonGradientEdge"].CGColor,
                       (id)[UIColor colorNamed:@"ColorButtonGradientCenter"].CGColor,
                       (id)[UIColor colorNamed:@"ColorButtonGradientEdge"].CGColor, nil];
    gradient.name = @"gradientDG";

    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
    UIColor * tintColor = [schemaDict objectForKey:@"TintColor"];

    CAGradientLayer *sublayerDelete;
    for(CAGradientLayer *thesublayer in self.layer.sublayers)
    {
        if( [thesublayer.name isEqualToString: @"gradientDG"])
        {
            sublayerDelete = thesublayer;
        }
    }
    [sublayerDelete removeFromSuperlayer];

    int buttonDesign = [[[NSUserDefaults standardUserDefaults] valueForKey:@"buttonDesign"]intValue];
    switch (buttonDesign)
    {
        case 0:
            self.layer.borderColor = tintColor.CGColor;
            self.layer.borderWidth = 1;
            self.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
            break;
        case 1:
            self.layer.borderWidth = 0;
            [self.layer insertSublayer:gradient below:self.imageView.layer];

            break;
        case 2:
            self.layer.borderColor = tintColor.CGColor;
            self.layer.borderWidth = 1;
            [self.layer insertSublayer:gradient below:self.imageView.layer];

            break;
        case 3:
            self.backgroundColor = [UIColor colorNamed:@"ColorButtonGradientEdge"];
            self.layer.borderWidth = 0;

            break;

        default:
            break;
    }

    [self setTitleColor:[schemaDict objectForKey:@"TintColor"] forState:UIControlStateNormal];
    
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.lineBreakMode = NSLineBreakByClipping;

}

@end
