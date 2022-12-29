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
    NSString *pointName = [NSString stringWithFormat:@"%d/%@",schema, @"point_light"];

    if(pointColor == POINT_LIGHT)
            pointName = [NSString stringWithFormat:@"%d/%@",schema, @"point_light"];
        else
            pointName = [NSString stringWithFormat:@"%d/%@",schema, @"point_dark"];
    UIImage *pointImage = [UIImage imageNamed:pointName];
    if(pointDirection == POINT_UP)
        pointImage = [self imageRotate:pointImage byDegrees:180];

    UIImageView *pointImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,width,height)];
    pointImageView.image = pointImage;
    [pointView addSubview:pointImageView];
    
    NSString *checkerName = [NSString stringWithFormat:@"%d/%@",schema, @"checker_dk"];
    if(checkerColor == CHECKER_LIGHT)
        checkerName = [NSString stringWithFormat:@"%d/%@",schema, @"checker_lt"];

    for(int i = 0;  i < MIN(5,checkerCount); i++)
    {
        UIImageView *checkerImageView =  [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        UIImage *checker = [UIImage imageNamed:checkerName];
        
        checker = [self imageRotate:checker byDegrees:[self getRandomNumberBetween:0 and:360]];
        checkerImageView.image = checker;
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

- (UIImage*)rotateUIImage:(UIImage*)sourceImage imageOrientation:(UIImageOrientation) orientation
{
    CGSize size = sourceImage.size;
    UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
    [[UIImage imageWithCGImage:[sourceImage CGImage] scale:1.0 orientation:orientation] drawInRect:CGRectMake(0,0,size.height ,size.width)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}
-(int)getRandomNumberBetween:(int)from and:(int)to
{
    int number = (int)from + arc4random() % (to-from+1);
    if(number <= 90)
        return 90;
    if(number <= 180)
        return 180;
    if(number <= 270)
        return 270;
    if(number <= 360)
        return 360;
    return (int)from + arc4random() % (to-from+1);
}

-(UIImageOrientation)getRandomImageOrientation
{
    int random = (int)1 + arc4random() % (8-1+1);
    
    UIImageOrientation orientation = random;
    /*
     UIImageOrientationUp
     The original pixel data matches the image's intended display orientation.
    UIImageOrientationDown
    The image has been rotated 180° from the orientation of its original pixel data.
    UIImageOrientationLeft
    The image has been rotated 90° counterclockwise from the orientation of its original pixel data.
    UIImageOrientationRight
    The image has been rotated 90° clockwise from the orientation of its original pixel data.
    UIImageOrientationUpMirrored
    The image has been horizontally flipped from the orientation of its original pixel data.
    UIImageOrientationDownMirrored
    The image has been vertically flipped from the orientation of its original pixel data.
    UIImageOrientationLeftMirrored
    The image has been rotated 90° clockwise and flipped horizontally from the orientation of its original pixel data.
    UIImageOrientationRightMirrored
    The image has been rotated 90° counterclockwise and flipped horizontally from the orientation of its original pixel data.
    */

    return orientation;
}
- (UIImage *)imageRotate: (UIImage *)image byDegrees:(CGFloat)degrees
{
#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)
    CGFloat radians = DEGREES_TO_RADIANS(degrees);
    CGSize size = image.size;

    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0, size.width, size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(radians);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;

    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, [[UIScreen mainScreen] scale]);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();

    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);

    CGContextRotateCTM(bitmap, radians);

    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2 , size.width, size.height), image.CGImage );

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //XLog(@"%3.1f %@ %@",degrees,NSStringFromCGSize(size), NSStringFromCGSize(newImage.size));
    return newImage;
}
- (UIImage *)drawBarForSchema:(int)schema  withCheckerColor:(int)checkerColor withCheckerCount:(int)checkerCount
{
    UIImage *image = [UIImage imageNamed:@"DeadShot"];

    UIView *barView = [[UIView alloc]initWithFrame:CGRectMake(0,0,50, 50 * MIN(5,checkerCount))];

    NSString *checkerName = [NSString stringWithFormat:@"%d/%@",schema, @"checker_dk"];
    if(checkerColor == CHECKER_LIGHT)
        checkerName = [NSString stringWithFormat:@"%d/%@",schema, @"checker_lt"];
    UIImage *checker = [UIImage imageNamed:checkerName];

    for(int i = 0;  i < MIN(5,checkerCount); i++)
    {
      //  UIImageView *checkerImageView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:checkerName]] ;
        UIImageView *checkerImageView =  [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        checkerImageView.image = checker;
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
    NSString *checkerName = [NSString stringWithFormat:@"%d/%@",schema, @"off_dark"];
    if(checkerColor == CHECKER_LIGHT)
        checkerName = [NSString stringWithFormat:@"%d/%@",schema, @"off_light"];

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
