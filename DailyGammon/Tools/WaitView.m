//
//  WaitView.m
//  DailyGammon
//
//  Created by Peter Schneider on 17.03.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import "WaitView.h"
#import "Design.h"

@implementation WaitView

@synthesize design;

- (id)initWithText:(NSString *)text
{
    if (self = [super initWithFrame:CGRectZero])
    {
        self.opaque = FALSE;
        self.backgroundColor = [UIColor lightGrayColor];
        self.messageText = text;
    }
    return self;
}

- (id)init
{
    return [self initWithText: @"Please wait… loading xxx from yyy"];
}

- (void)dealloc
{
    //[super dealloc];
}

- (void)showInView:(UIView *)view
{
    // Center the view in its superview

    CGRect fr = self.frame;
    fr.size.width = 200.0f;
    fr.size.height = 200.0f;
    CGRect superFrame = view.frame;
    fr.origin.x = superFrame.origin.x + superFrame.size.width / 2.0f - fr.size.width / 2.0f;
    fr.origin.y    = superFrame.origin.y + superFrame.size.height / 2.0f - fr.size.height / 2.0f;
    self.frame = fr;
    
    // Add the activity indicator
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    indicator.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f - 10.0f);
    indicator.tag = 99;
    indicator.color = UIColor.whiteColor;
    [self addSubview:indicator];
    [indicator startAnimating];

    // Add the view at the front of the app's windows
    self.backgroundColor = UIColor.clearColor;
    [view addSubview:self];
    return;
}

- (void)dismiss
{
    [self removeFromSuperview];
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
    CGContextSetFillColorWithColor(context, [[schemaDict objectForKey:@"TintColor"] CGColor]);

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
    
    // Write the message text

    UIFont *font = [UIFont systemFontOfSize:16.0f];
    CGFloat fontHeight = [font pointSize];
    UIColor *fontColor = [UIColor whiteColor];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, fontColor, NSForegroundColorAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil];

    [self.messageText drawInRect:CGRectMake(0.0f, fr.size.height - fontHeight - 60.0f, rect.size.width, 60) withAttributes:attributes];
    CGContextRestoreGState(context);
}

@end
