//
//  MenueView.m
//  DailyGammon
//
//  Created by Peter Schneider on 29.12.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import "SortView.h"
#import "Design.h"
#import "DGButton.h"
#import "DbConnect.h"
#import "Tools.h"

#import "AppDelegate.h"
#import "Constants.h"


@implementation SortView

@synthesize design, tools;
@synthesize presentingView;

- (id)init
{
    design      = [[Design alloc] init];

    if (self = [super initWithFrame:CGRectZero])
    {
        self.opaque = FALSE;
        self.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
        self.layer.borderWidth = 1;
        NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
        self.layer.borderColor = [[schemaDict objectForKey:@"TintColor"] CGColor];
        self.layer.cornerRadius = 14.0f;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)showMenueInView:(UIView *)view
{
 
    presentingView = view;
    UITapGestureRecognizer *oneFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTouched:)];
    oneFingerTap.numberOfTapsRequired = 1;
    oneFingerTap.numberOfTouchesRequired = 1;
    [view addGestureRecognizer:oneFingerTap];

    // Place the view at the top right of the menu button

    CGRect superFrame = view.frame;

    float buttonCount = 1 + 8 + 1; // headerLabel + 8 Sort +  close
    float edge = 5.0;
    float gap = 10;
    float buttonWidth = 200.0;
    float checkWidth = 30.0;
    float buttonHight = MIN(((superFrame.size.height - 50 - edge) / buttonCount) ,  30.0 + gap) - gap;
    
    CGRect fr = self.frame;
    fr.size.width = edge + checkWidth + gap + buttonWidth + edge;
    fr.size.height = buttonCount * (buttonHight + gap);
    
    fr.origin.x = superFrame.origin.x + 50;
    fr.origin.y = 0 - fr.size.height;

    self.frame = fr;
    
    float x =  edge;
    float y = edge;

    DGLabel *header = [[DGLabel alloc] initWithFrame:CGRectMake(x,y, self.frame.size.width, buttonHight)];
    header.text = @"Sort Matches by";
    header.textAlignment = NSTextAlignmentCenter;
    [self addSubview:header];
    y += gap + buttonHight;

    int activeOrder = [[[NSUserDefaults standardUserDefaults] valueForKey:sortButton]intValue];
    if([[[NSUserDefaults standardUserDefaults] valueForKey:sortButton]intValue] > 0)
    {
        activeOrder = [[[NSUserDefaults standardUserDefaults] valueForKey:sortButton]intValue];
        UILabel *removeView;
        while((removeView = [self viewWithTag:42]) != nil)
        {
            [removeView removeFromSuperview];
        }
        y = edge + ( gap + buttonHight) * activeOrder;
        UILabel *checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+buttonWidth+gap,y, checkWidth, buttonHight)];
        checkLabel.tag = 42;
        checkLabel.text = @"✅";
        [self addSubview:checkLabel];
        XLog(@"sortButton %d", activeOrder);
    }
    y = edge + gap + buttonHight;
    DGButton *button1 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button1 setTitle:@"Grace then Pool" forState: UIControlStateNormal];
    button1.tag = 1;
    [button1 addTarget:self action:@selector(sortNotification:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button1];
    y += gap + buttonHight;
    
    DGButton *button2 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button2 setTitle:@"Pool" forState: UIControlStateNormal];
    button2.tag = 2;
    [button2 addTarget:self action:@selector(sortNotification:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button2];
    y += gap + buttonHight;

    DGButton *button3 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button3 setTitle:@"Grace + Pool" forState: UIControlStateNormal];
    button3.tag = 3;
    [self addSubview:button3];
    [button3 addTarget:self action:@selector(sortNotification:) forControlEvents:UIControlEventTouchUpInside];
    y += gap + buttonHight;
    
    DGButton *button4 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button4 setTitle:@"Recent Opponent Move" forState: UIControlStateNormal];
    button4.tag = 4;
    [self addSubview:button4];
    [button4 addTarget:self action:@selector(sortNotification:) forControlEvents:UIControlEventTouchUpInside];
    y += gap + buttonHight;

    DGButton *button5 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button5 setTitle:@"Event" forState: UIControlStateNormal];
    button5.tag = 5;
    [self addSubview:button5];
    [button5 addTarget:self action:@selector(sortNotification:) forControlEvents:UIControlEventTouchUpInside];
    y += gap + buttonHight;

    DGButton *button6 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button6 setTitle:@"Round" forState: UIControlStateNormal];
    button6.tag = 6;
    [button6 addTarget:self action:@selector(sortNotification:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button6];
    y += gap + buttonHight;

    DGButton *button7 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button7 setTitle:@"Length" forState: UIControlStateNormal];
    button7.tag = 7;
    [self addSubview:button7];
    [button7 addTarget:self action:@selector(sortNotification:) forControlEvents:UIControlEventTouchUpInside];
    y += gap + buttonHight;

    DGButton *button8 = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHight)];
    [button8 setTitle:@"Opponent Name" forState: UIControlStateNormal];
    button8.tag = 8;
    [self addSubview:button8];
    [button8 addTarget:self action:@selector(sortNotification:) forControlEvents:UIControlEventTouchUpInside];
    y += gap + buttonHight;

    x = (self.frame.size.width - (buttonWidth / 2)) /2;
    DGButton *buttonClose = [[DGButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth/2, buttonHight)];
    [buttonClose setTitle:@"Close" forState: UIControlStateNormal];
    buttonClose.tag = 99;
    [buttonClose setTitleColor:UIColor.blackColor forState:UIControlStateNormal];

    [buttonClose addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:buttonClose];
    
    // Add the view at the front of the app's windows

    [view addSubview:self];
    
    x = superFrame.origin.x + 50;
    y = superFrame.origin.y + 50;
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(x,y,self.frame.size.width,self.frame.size.height);

    } completion:^(BOOL finished) {
    }];

    return;
}

-(void) sortNotification:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:((DGButton*)sender).tag  forKey:sortButton];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:sortNotification object:self];

    [self dismiss];
}
- (void)drawRect:(CGRect)rect
{
    
    design      = [[Design alloc] init];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    // Draw a rectangle with rounded corners
    
    CGFloat radius = 10.0f;
    CGRect fr = rect;

    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    
    CGMutablePathRef selectionPath = CGPathCreateMutable();
    CGPathMoveToPoint(selectionPath, NULL, fr.origin.x, fr.origin.y + radius);
    CGPathAddLineToPoint(selectionPath, NULL, fr.origin.x, fr.origin.y + fr.size.height - radius);
    CGPathAddArc(selectionPath, NULL, fr.origin.x + radius, fr.origin.y + fr.size.height - radius, radius, M_PI, M_PI / 2, 1);
    CGPathAddLineToPoint(selectionPath, NULL, fr.origin.x + fr.size.width - radius, fr.origin.y + fr.size.height);
    CGPathAddArc(selectionPath, NULL, fr.origin.x + fr.size.width - radius, fr.origin.y + fr.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGPathAddLineToPoint(selectionPath, NULL, fr.origin.x + fr.size.width, fr.origin.y + radius);
    CGPathAddArc(selectionPath, NULL, fr.origin.x + fr.size.width - radius, fr.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
    CGPathAddLineToPoint(selectionPath, NULL, fr.origin.x + radius, fr.origin.y);
    CGPathAddArc(selectionPath, NULL, fr.origin.x + radius, fr.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
    CGPathCloseSubpath(selectionPath);

    CGContextAddPath(context, selectionPath);
    CGContextFillPath(context);
    CGPathRelease(selectionPath);
    
    CGContextRestoreGState(context);
}

- (void)dismiss
{
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(self.frame.origin.x,
                                1000,
                                self.frame.size.width,
                                self.frame.size.height);

    } completion:^(BOOL finished) {
        [self removeFromSuperview];

    }];
}

- (void)screenTouched:(UIGestureRecognizer *)gesture
{
    CGPoint tapLocation = [gesture locationInView:self];
    if( !CGRectContainsPoint(self.frame, tapLocation) )
    {
        for (UIGestureRecognizer *recognizer in presentingView.gestureRecognizers) 
        {
            [presentingView removeGestureRecognizer:recognizer];
        }
        [self dismiss];
        
    }
}

@end
