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
@end
