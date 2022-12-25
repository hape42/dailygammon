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
- (UIImage *)getPointForSchema:(int)schema
                          name:(NSString *)img
                     withWidth:(float)width
                    withHeight:(float)height

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
        //pt_dk_down0
        // split name for parameters
        NSArray *paramters = [img componentsSeparatedByString: @"_"];

        int pointColor = 1;
        int pointDirection = 1;
        int checkerColor = 1;
        int checkerNumber = 0;
        NSString *checker = @"";
        if([paramters[1] isEqualToString:@"dk"])
            pointColor = POINT_DARK;
        else
            pointColor = POINT_LIGHT;
        if([paramters[2] isEqualToString:@"down"])
            pointDirection = POINT_DOWN;
        else
            pointDirection = POINT_UP;
        if(paramters.count == 3)
        {
            // no checker
            NSString *direction = [paramters[2] stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
            checkerNumber       = [[paramters[2] stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
            if([direction isEqualToString:@"down"])
                pointDirection = POINT_DOWN;
            else
                pointDirection = POINT_UP;

        }
        else
        {
            checker       = [paramters[3] stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
            checkerNumber = [[paramters[3] stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
        }
        if([checker isEqualToString:@"y"])
            checkerColor = CHECKER_LIGHT;
        else
            checkerColor = CHECKER_DARK;

        return [self drawPointForSchema:schema
                              withColor:pointColor
                          withDirection:pointDirection
                       withCheckerColor:checkerColor
                       withCheckerCount:checkerNumber
                              withWidth:(float)width
                             withHeight:(float)height];
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
    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
    image = [UIImage imageNamed:imgName];
    return image;
}

#pragma mark - methods to draw elements

- (UIImage *)drawPointForSchema:(int)schema
                      withColor:(int)pointColor
                  withDirection:(int)pointDirection
               withCheckerColor:(int)checkerColor
               withCheckerCount:(int)checkerCount
                      withWidth:(float)width
                     withHeight:(float)height
{
    UIImage *image = [UIImage imageNamed:@"DeadShot"];
    
    UIView *pointView = [[UIView alloc]initWithFrame:CGRectMake(0,0,width,height)];
    NSString *pointName = @"";

    if(pointDirection == POINT_UP)
    {
        if(pointColor == POINT_LIGHT)
            pointName = [NSString stringWithFormat:@"%d/%@",schema, @"point_light_up"];
        else
            pointName = [NSString stringWithFormat:@"%d/%@",schema, @"point_dark_up"];
    }
    else
    {
        if(pointColor == POINT_LIGHT)
            pointName = [NSString stringWithFormat:@"%d/%@",schema, @"point_light_down"];
        else
            pointName = [NSString stringWithFormat:@"%d/%@",schema, @"point_dark_down"];

    }
    //UIImageView *pointImageView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:pointName]] ;
    UIImageView *pointImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,width,height)];
    pointImageView.image = [UIImage imageNamed:pointName];
    [pointView addSubview:pointImageView];
    
    NSString *checkerName = [NSString stringWithFormat:@"%d/%@",schema, @"checker_dk"];
    if(checkerColor == CHECKER_LIGHT)
        checkerName = [NSString stringWithFormat:@"%d/%@",schema, @"checker_lt"];

    for(int i = 0;  i < MIN(5,checkerCount); i++)
    {
        //UIImageView *checkerImageView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:checkerName]] ;
        UIImageView *checkerImageView =  [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        checkerImageView.image = [UIImage imageNamed:checkerName];
        CGRect frame = checkerImageView.frame;
        frame.origin.y = i * width;
        if(pointDirection == POINT_UP)
            frame.origin.y = (4 * width)-(i * width);
        checkerImageView.frame = frame;
        [pointView addSubview:checkerImageView];
    }
    UILabel *numberLabel;
    if(checkerCount > 5)
    {
        int y = 0;
        if(pointDirection == POINT_DOWN)
            y = (4 * width);
        numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,y,width,width)];
        numberLabel.text = [NSString stringWithFormat:@"%d", checkerCount];
        numberLabel.textAlignment = NSTextAlignmentCenter;
        numberLabel.textColor = [UIColor whiteColor];
        [numberLabel setFont:[numberLabel.font fontWithSize: 25]];
        numberLabel.adjustsFontSizeToFitWidth = YES;
        numberLabel.numberOfLines = 0;
        numberLabel.minimumScaleFactor = 0.1;

        [pointView addSubview:numberLabel];

    }
    
    CGSize size = [pointView bounds].size;
    UIGraphicsBeginImageContext(size);
    [[pointView layer] renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (UIImage *)drawBarForSchema:(int)schema  withCheckerColor:(int)checkerColor withCheckerCount:(int)checkerCount
{
    UIImage *image = [UIImage imageNamed:@"DeadShot"];

    UIView *barView = [[UIView alloc]initWithFrame:CGRectMake(0,0,50, 50 * MIN(5,checkerCount))];

    NSString *checkerName = [NSString stringWithFormat:@"%d/%@",schema, @"checker_dk"];
    if(checkerColor == CHECKER_LIGHT)
        checkerName = [NSString stringWithFormat:@"%d/%@",schema, @"checker_lt"];

    for(int i = 0;  i < MIN(5,checkerCount); i++)
    {
        UIImageView *checkerImageView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:checkerName]] ;
        CGRect frame = checkerImageView.frame;
        frame.origin.y = i * 50;
        checkerImageView.frame = frame;
        
        [barView addSubview:checkerImageView];
    }
    if(checkerCount > 5)
    {
        UILabel *numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,100,50,50)];
        numberLabel.text = [NSString stringWithFormat:@"%d", checkerCount];
        numberLabel.textAlignment = NSTextAlignmentCenter;
        numberLabel.textColor = [UIColor whiteColor];
        [numberLabel setFont:[numberLabel.font fontWithSize: 25]];
        numberLabel.adjustsFontSizeToFitWidth = YES;
        numberLabel.numberOfLines = 0;
        numberLabel.minimumScaleFactor = 0.1;

        [barView addSubview:numberLabel];
    }

    CGSize size = [barView bounds].size;
    UIGraphicsBeginImageContext(size);
    [[barView layer] renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)drawOffForSchema:(int)schema  withDirection:(int)offDirection withCheckerColor:(int)checkerColor withCheckerCount:(int)checkerCount
{
    UIImage *image = [UIImage imageNamed:@"DeadShot"];
    UIView *offView = [[UIView alloc]initWithFrame:CGRectMake(0,0,230, 350)];
    NSString *checkerName = [NSString stringWithFormat:@"%d/%@",schema, @"off_black_shadow"];
    if(checkerColor == CHECKER_LIGHT)
        checkerName = [NSString stringWithFormat:@"%d/%@",schema, @"off_white_shadow"];

    for(int i = 0;  i < checkerCount; i++)
    {
        UIImageView *checkerImageView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:checkerName]];
        CGRect frame = checkerImageView.frame;
        switch (offDirection)
        {
            case OFF_BOTTOM:
                frame.origin.y = offView.frame.size.height - 100 - ( i * 50);
                break;
            case OFF_TOP:
                frame.origin.y = 50 + (i * 50);
                break;
            case OFF_ALL:
                frame.origin.y =  50 + ( i * 50);
            default:
                break;
        }
        frame.origin.x = 15;
        checkerImageView.frame = frame;
        [offView addSubview:checkerImageView];
    }

    CGSize size = [offView bounds].size;
    UIGraphicsBeginImageContext(size);
    [[offView layer] renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}


@end
