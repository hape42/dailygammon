//
//  DGButton.m
//  DailyGammon
//
//  Created by Peter Schneider on 03.01.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import "DGButton.h"
#import "Design.h"

@implementation DGButton

@synthesize design;

- (id)initWithFrame:(CGRect)frame
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeButtonColor) name:@"changeSchemaNotification" object:nil];

    self = [super initWithFrame:frame];
    if (self)
    {
        [self customizeButton];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeButtonColor) name:@"changeSchemaNotification" object:nil];

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
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.startPoint = CGPointMake(1, 0);;
    gradient.endPoint = CGPointMake(1, 1);

    gradient.colors = [NSArray arrayWithObjects:
                       (id)[UIColor colorNamed:@"ColorButtonGradientEdge"].CGColor,
                       (id)[UIColor colorNamed:@"ColorButtonGradientCenter"].CGColor,
                       (id)[UIColor colorNamed:@"ColorButtonGradientEdge"].CGColor, nil];

    [self.layer addSublayer:gradient];
    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];

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
@end
