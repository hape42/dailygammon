//
//  BoardElements.m
//  DailyGammon
//
//  Created by Peter Schneider on 17.12.22.
//  Copyright © 2022 Peter Schneider. All rights reserved.
//

#import "BoardElements.h"
#import "Constants.h"

@implementation BoardElements

#pragma mark - methods to decide draw or catalog
- (UIImage *)getPointForSchema:(int)schema name:(NSString *)img
{
    UIImage *image = [UIImage imageNamed:@"DeadShot"];
    if(schema <= 4)
    {
        NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
        image = [UIImage imageNamed:imgName];
        return image;
    }
    else
    {
        // pt_dk_down_y3
        // pt_lt_up_b7
        // split name for parameters
        NSArray *paramters = [img componentsSeparatedByString: @"_"];
        if(paramters.count != 4)
            return image;
        int pointColor = 1;
        int pointDirection = 1;
        int checkerColor = 1;
        int checkerNumber = 0;
        if([paramters[1] isEqualToString:@"dk"])
            pointColor = POINT_DARK;
        else
            pointColor = POINT_LIGHT;
        if([paramters[2] isEqualToString:@"down"])
            pointDirection = POINT_DOWN;
        else
            pointDirection = POINT_UP;
        NSString *checker = [paramters[3] stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
        checkerNumber     = [[paramters[3] stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
        if([checker isEqualToString:@"y"])
            checkerColor = CHECKER_LIGHT;
        else
            checkerColor = CHECKER_DARK;

        return [self drawPointForSchema:schema
                              withColor:pointColor
                          withDirection:pointDirection
                       withCheckerColor:checkerColor
                       withCheckerCount:checkerNumber];
    }
    return image;
}

- (UIImage *)getBarForSchema:(int)schema name:(NSString *)img
{
    UIImage *image = [UIImage imageNamed:@"DeadShot"];
    if(schema <= 4)
    {
        NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
        image = [UIImage imageNamed:imgName];
        return image;
    }
    else
    {
        // bar_y9
        // split name for parameters
        NSArray *paramters = [img componentsSeparatedByString: @"_"];
        if(paramters.count != 2)
            return image;
        int checkerColor = 1;
        int checkerNumber = 0;
        NSString *checker = [paramters[1] stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
        checkerNumber     = [[paramters[1] stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
        if([checker isEqualToString:@"y"])
            checkerColor = CHECKER_LIGHT;
        else
            checkerColor = CHECKER_DARK;

        return [self drawBarForSchema:schema
                       withCheckerColor:checkerColor
                       withCheckerCount:checkerNumber];
    }
    return image;
}

- (UIImage *)getOffForSchema:(int)schema name:(NSString *)img
{
    UIImage *image = [UIImage imageNamed:@"DeadShot"];
    if(schema <= 4)
    {
        NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
        image = [UIImage imageNamed:imgName];
        return image;
    }
    else
    {
        // off_b2_top
        // off_b2_bot
        // off_y5
        // split name for parameters
        NSArray *paramters = [img componentsSeparatedByString: @"_"];
        int offDirection = 1;
        int checkerColor = 1;
        int checkerNumber = 0;
        NSString *checker = [paramters[1] stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
        checkerNumber     = [[paramters[1] stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
        if([checker isEqualToString:@"y"])
            checkerColor = CHECKER_LIGHT;
        else
            checkerColor = CHECKER_DARK;
        if(paramters.count == 3)
        {
            
            if([paramters[2] isEqualToString:@"bot"])
                offDirection = OFF_BOTTOM;
            else
                offDirection = OFF_TOP;
        }
        else
            offDirection = OFF_ALL;

        return [self drawOffForSchema:schema
                          withDirection:offDirection
                       withCheckerColor:checkerColor
                       withCheckerCount:checkerNumber];
    }
    return image;
}

- (UIImage *)getCubeForSchema:(int)schema name:(NSString *)img
{
    UIImage *image = [UIImage imageNamed:@"DeadShot"];
    if(schema <= 4)
    {
        NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
        image = [UIImage imageNamed:imgName];
        return image;
    }
    else
    {
        // cube4

        int cubeNumber     = [[img stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];

        return [self drawCubeForSchema:schema
                       withNumber:cubeNumber];
    }
    return image;
}

#pragma mark - methods to draw elements

- (UIImage *)drawPointForSchema:(int)schema withColor:(int)pointColor withDirection:(int)pointDirection withCheckerColor:(int)checkerColor withCheckerCount:(int)checkerCount
{
    UIImage *image = [UIImage imageNamed:@"DeadShot"];

//    uiview  erstellen
//    uiimageview mit zunge erstellen
//    uiview addsubview zunge
//    je checker uiimageview
//    uiview addsubview checkerview
//    mehr als 5? dann auf den letzten stein eine zahl schreiben
    
    // view in image transformieren
    
    return image;
}

- (UIImage *)drawBarForSchema:(int)schema  withCheckerColor:(int)checkerColor withCheckerCount:(int)checkerCount
{
    UIImage *image = [UIImage imageNamed:@"DeadShot"];

//    mehr als 5? dann auf den mittleren stein eine zahl schreiben
    
    return image;
}

- (UIImage *)drawOffForSchema:(int)schema  withDirection:(int)offDirection withCheckerColor:(int)checkerColor withCheckerCount:(int)checkerCount
{
    UIImage *image = [UIImage imageNamed:@"DeadShot"];

    return image;
}

- (UIImage *)drawCubeForSchema:(int)schema  withNumber:(int)cubeNumber 
{
    UIImage *image = [UIImage imageNamed:@"DeadShot"];

    return image;
}

@end
