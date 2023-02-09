//
//  CellConnector.m
//  DailyGammon
//
//  Created by Peter Schneider on 09.02.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import "CellConnector.h"
#import "DGLabel.h"

@implementation CellConnector

- (id)initWithFrame:(CGRect)frame
{

    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initFromLabels:(DGLabel *)topLabel rootLabel1:(DGLabel *)rootLabel1 rootLabel2:(DGLabel *)rootLabel2
{
    float x = rootLabel1.frame.origin.x + rootLabel1.frame.size.width;
    float y = rootLabel1.frame.origin.y;

    float width = topLabel.frame.origin.x - ( rootLabel1.frame.origin.x + rootLabel1.frame.size.width);
    float height = (rootLabel2.frame.origin.y + rootLabel2.frame.size.height) - rootLabel1.frame.origin.y;
    
    return [self initWithFrame:CGRectMake(x, y,width, height )];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    /*   3
    1 ---!
         !--- 4
    2 ---!
     */
    
    int labelHeight = 30;
    labelHeight = [[[NSUserDefaults standardUserDefaults] valueForKey:@"labelHeight"]intValue];

    // first stroke
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    [path1 moveToPoint:CGPointMake(0, labelHeight/2)];
    [path1 addLineToPoint:CGPointMake(rect.size.width/2, labelHeight/2)];
    path1.lineWidth = 1;
    [[UIColor blackColor] setStroke];
    [path1 stroke];
    
    // second stroke
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    [path2 moveToPoint:CGPointMake(0, (rect.origin.x + rect.size.height) - labelHeight/2)];
    [path2 addLineToPoint:CGPointMake(rect.size.width/2, (rect.origin.x + rect.size.height) - labelHeight/2)];
    path2.lineWidth = 1;
    [[UIColor blackColor] setStroke];
    [path2 stroke];

    // third stroke
    UIBezierPath *path3 = [UIBezierPath bezierPath];
    [path3 moveToPoint:CGPointMake(rect.size.width/2, labelHeight/2)];
    [path3 addLineToPoint:CGPointMake(rect.size.width/2, (rect.origin.x + rect.size.height) - labelHeight/2)];
    path3.lineWidth = 1;
    [[UIColor blackColor] setStroke];
    [path3 stroke];

    // fourth stroke
    UIBezierPath *path4 = [UIBezierPath bezierPath];
    [path4 moveToPoint:CGPointMake(rect.size.width/2, rect.size.height/2)];
    [path4 addLineToPoint:CGPointMake(rect.size.width, rect.size.height/2)];
    path4.lineWidth = 1;
    [[UIColor blackColor] setStroke];
    [path4 stroke];

}


@end
