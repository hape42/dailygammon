//
//  MatchTools.m
//  DailyGammon
//
//  Created by Peter Schneider on 13.12.22.
//  Copyright © 2022 Peter Schneider. All rights reserved.
//

#import "MatchTools.h"
#import "Design.h"
#import "Constants.h"

@implementation MatchTools

@synthesize design;

-(NSMutableDictionary *)drawBoard:(int)schema boardInfo:(NSMutableDictionary *)boardDict
{
    
    //     13 14 15 16 17 18    19 20 21 22 23 24
    // !--!——————--------——-!—-!--------—————————!—-!
    // !C !                 !B !                 !O !
    // !U !                 !A !                 !F !
    // !B !     checker     !R !    checker      !F !
    // !E !                 !  !                 !  !
    // !  !                 !  !                 !  !
    // !  !                 !  !                 !  !
    // !--!——————--------——-!  !--------—————————!—-!
    // !  !   indicator     !  !   indicator     !  !
    // !--!——————--------——-!  !--------—————————!—-!
    // !  !     Dice        !  !                 !  !
    // !--!——————--------——-!  !--------—————————!—-!
    // !  !   indicator     !  !   indicator     !  !
    // !--!——————--------——-!  !--------—————————!—-!
    // !  !                 !  !                 !  !
    // !  !                 !  !                 !  !
    // !  !                 !  !                 !  !
    // !  !     checker     !  !    checker      !  !
    // !  !                 !  !                 !  !
    // !  !                 !  !                 !  !
    // !--!——————--------——-!—-!--------—————————!—-!
    //     12 11 10  9  8  7     6  5  4  3  2  1

    design = [[Design alloc] init];

    float zoomFactor = 1.0; // is important for iPhone
    
    // I have determined these numbers when planning on paper in order to optimally represent a game board.
    int checkerWidth = 40;
    int offWidth = 70;
    int barWidth = 40;
    int cubeWidth = offWidth;
    int pointsHeight = 200;
    int numberHeight = 15;
    int indicatorHeight = 22;

    float boardWidth  = cubeWidth + (6 * checkerWidth) + barWidth + (6 * checkerWidth) + offWidth; // 70 + (6 * 40) + 40 + (6 * 40) + 70 = 660
    float boardHeight = numberHeight + pointsHeight + indicatorHeight + checkerWidth + indicatorHeight + pointsHeight + numberHeight; // 15 + 200 + 22 + 40 + 22 + 200 + 15 = 504
    
    int maxWidth  = [UIScreen mainScreen].bounds.size.width;
    int maxHeight = [UIScreen mainScreen].bounds.size.height;

    int x = 0;
    int y = 0;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        x = 20;
        y = 200;
        zoomFactor = (maxHeight - y - 50) / boardHeight;
    }
    else
    {
        x = 5;
        int y = 40;
        if([design isX])
        {
            maxWidth = [UIScreen mainScreen].bounds.size.width - 30;
            x = 50;
            
            NSArray *windows = [[UIApplication sharedApplication] windows];
            UIWindow *keyWindow = (UIWindow *) windows[0];
            UIEdgeInsets safeArea = keyWindow.safeAreaInsets;
            maxHeight  = [UIScreen mainScreen].bounds.size.height - safeArea.bottom;
        }
        zoomFactor = (maxHeight - y - 5) / boardHeight;
    }
    zoomFactor *= .98; // to have more space for the activityView, otherwise it hangs on the edge.
    
    checkerWidth    *= zoomFactor;
    offWidth        *= zoomFactor;;
    barWidth        *= zoomFactor;;
    cubeWidth       *= zoomFactor;;
    pointsHeight    *= zoomFactor;;
    numberHeight    *= zoomFactor;;
    indicatorHeight *= zoomFactor;;

    boardWidth  = cubeWidth + (6 * checkerWidth) + barWidth + (6 * checkerWidth) + offWidth;
    boardHeight = numberHeight + pointsHeight + indicatorHeight + checkerWidth + indicatorHeight + pointsHeight + numberHeight;

    UIView *boardView = [[UIView alloc] initWithFrame:CGRectMake(x, y, boardWidth, boardHeight)];
    boardView.tag = BOARD_VIEW;

    NSMutableDictionary *schemaDict = [design schema:schema];
    UIColor *boardColor             = [schemaDict objectForKey:@"BoardSchemaColor"];
    UIColor *edgeColor              = [schemaDict objectForKey:@"RandSchemaColor"];
    UIColor *barCentralStripColor   = [schemaDict objectForKey:@"barMittelstreifenColor"];
    UIColor *numberColor            = [schemaDict objectForKey:@"numberColor"];
    
    boardView.backgroundColor = boardColor;
    NSMutableArray *moveArray = [[NSMutableArray alloc]init];

#pragma mark - Numbers
    
    UIView *numberTopView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                      0,
                                                                      boardView.frame.size.width,
                                                                      numberHeight)];
    numberTopView.backgroundColor = edgeColor;
    numberTopView.tag = 5001;
    UIView *numberBottomView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                      boardView.frame.size.height - numberHeight,
                                                                      boardView.frame.size.width,
                                                                      numberHeight)];
    numberBottomView.backgroundColor = edgeColor;
    numberBottomView.tag = 5002;
    
    UIView *removeView; // delete views and redraw is important. otherwise the numbers often overlap by 1 pixel or so and it gets uglier and uglier
    while((removeView = [boardView viewWithTag:5001]) != nil)
    {
        [removeView removeFromSuperview];
    }
    while((removeView = [boardView viewWithTag:5002]) != nil)
    {
        [removeView removeFromSuperview];
    }

    [boardView addSubview:numberTopView];
    [boardView addSubview:numberBottomView];

    x = offWidth;
    y = 0;
    NSMutableArray *numberArray = [boardDict objectForKey:@"nummernOben"];
    if(numberArray.count < 17)
    {
        // for some reason no board was displayed at all
#warning        [self errorAction:2];
#warning better call topPage instead return nil;
        return nil;
    }
    for(int i = 1; i <= 6; i++)
    {
        UILabel *number = [[UILabel alloc]initWithFrame:CGRectMake(x, y, checkerWidth, numberHeight)];
        number.textAlignment = NSTextAlignmentCenter;
        number.text = numberArray[i];
        number.textColor = numberColor;
        number.tag = i + 1000;
        while((removeView = [numberTopView viewWithTag:i + 1000]) != nil)
        {
            [removeView removeFromSuperview];
        }
        [numberTopView addSubview:number];

        x += checkerWidth;
    }
    x += barWidth; // bar

    for(int i = 8; i <= 13; i++)
    {
        UILabel *number = [[UILabel alloc]initWithFrame:CGRectMake(x, y, checkerWidth, numberHeight)];
        number.textAlignment = NSTextAlignmentCenter;
        number.text = numberArray[i];
        number.textColor = numberColor;
        number.tag = i + 1000;
        while((removeView = [numberTopView viewWithTag:i + 1000]) != nil)
        {
            [removeView removeFromSuperview];
        }
        
        [numberTopView addSubview:number];
        
        x += checkerWidth;
    }

    x = offWidth;
    y = 0;
    numberArray = [boardDict objectForKey:@"nummernUnten"];
    
    for(int i = 1; i <= 6; i++)
    {
        UILabel *number = [[UILabel alloc]initWithFrame:CGRectMake(x, y, checkerWidth, numberHeight)];
        number.textAlignment = NSTextAlignmentCenter;
        number.text = numberArray[i];
        number.textColor = numberColor;
        [numberBottomView addSubview:number];
        
        x += checkerWidth;
    }
    x += barWidth; // bar
    
    for(int i = 8; i <= 13; i++)
    {
        UILabel *number = [[UILabel alloc]initWithFrame:CGRectMake(x, y, checkerWidth, numberHeight)];
        number.textAlignment = NSTextAlignmentCenter;
        number.text = numberArray[i];
        number.textColor = numberColor;
        [numberBottomView addSubview:number];
        
        x += checkerWidth;
    }
#pragma mark - edges
    UIView *offView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                               numberHeight,
                                                               offWidth,
                                                               boardView.frame.size.height - numberHeight)];
    offView.backgroundColor = edgeColor;

    UIView *offInsideTopView = [[UIView alloc] initWithFrame:CGRectMake((offWidth - checkerWidth) / 2,
                                                                        0,
                                                                        checkerWidth,
                                                                        pointsHeight)];
    offInsideTopView.backgroundColor = boardColor;
    offInsideTopView.layer.borderWidth = 1;
    offInsideTopView.layer.borderColor = [UIColor grayColor].CGColor;
    [offView addSubview:offInsideTopView];
    
    UIView *offInsideBottomView = [[UIView alloc] initWithFrame:CGRectMake((offWidth - checkerWidth) / 2,
                                                                         pointsHeight + indicatorHeight + checkerWidth + indicatorHeight,
                                                                         checkerWidth,
                                                                         pointsHeight)];
    offInsideBottomView.backgroundColor = boardColor;
    offInsideBottomView.layer.borderWidth = 1;
    offInsideBottomView.layer.borderColor = [UIColor grayColor].CGColor;
    [offView addSubview:offInsideBottomView];

    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(offWidth + (6 * checkerWidth),
                                                               0,
                                                               barWidth,
                                                               boardView.frame.size.height)];
    barView.backgroundColor = edgeColor;

    UIView *barMidleView = [[UIView alloc] initWithFrame:CGRectMake(((barWidth / 2) - 2),
                                                                    0,
                                                                    2,
                                                                    boardView.frame.size.height )];
    barMidleView.backgroundColor = barCentralStripColor;
    [barView addSubview:barMidleView];
    
    UIView *cubeView = [[UIView alloc] initWithFrame:CGRectMake(offWidth + (6 * checkerWidth) + barWidth + (6 * checkerWidth),
                                                                numberHeight,
                                                                cubeWidth,
                                                                boardView.frame.size.height - numberHeight)];
    cubeView.backgroundColor = edgeColor;

    UIView *cubeInsideTopView = [[UIView alloc] initWithFrame:CGRectMake((offWidth - checkerWidth) / 2,
                                                                         0,
                                                                         checkerWidth,
                                                                         pointsHeight)];
    cubeInsideTopView.backgroundColor = boardColor;
    cubeInsideTopView.layer.borderWidth = 1;
    cubeInsideTopView.layer.borderColor = [UIColor grayColor].CGColor;
    [cubeView addSubview:cubeInsideTopView];
    
    UIView *cubeInsideBottomView = [[UIView alloc] initWithFrame:CGRectMake((offWidth - checkerWidth) / 2,
                                                                          pointsHeight + indicatorHeight + checkerWidth + indicatorHeight,
                                                                          checkerWidth,
                                                                          pointsHeight)];
    cubeInsideBottomView.backgroundColor = boardColor;
    cubeInsideBottomView.layer.borderWidth = 1;
    cubeInsideBottomView.layer.borderColor = [UIColor grayColor].CGColor;
    [cubeView addSubview:cubeInsideBottomView];
    
    [boardView addSubview:offView];
    [boardView addSubview:barView];
    [boardView addSubview:cubeView];

    
#pragma mark - upper graphics
    x = 0;
    y = numberHeight;

    NSMutableArray *graphicsTopArray = [boardDict objectForKey:@"grafikOben"];
    for(int i = 0; i < graphicsTopArray.count; i++)
    {
        NSMutableDictionary *pointDict = graphicsTopArray[i];
        NSMutableArray *images = [pointDict objectForKey:@"img"];
        switch(i)
        {
            case 0:
                // left side
                y = numberHeight;
                for(int indexOffBoard = 0; indexOffBoard < images.count; indexOffBoard++)
                {
                    NSString *img = [[images[indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                    img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                    UIImageView *pointView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2),
                                                 y, checkerWidth,
                                                 pointsHeight / 3);
                    // is it a cube? then get width and height from the img for the view
                    if ([imgName containsString:@"cube"])
                    {
                        UIImage *cubeImg = [UIImage imageNamed:imgName];
                        float imgWidth = cubeImg.size.width;
                        float imgHeight = cubeImg.size.height;
                        float factor = checkerWidth / imgWidth;
                        imgHeight *= factor;
                        pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, imgHeight);
                    }
                    [boardView addSubview:pointView];
                    y += pointsHeight / 3;
                }
                y = numberHeight;
                x += offWidth;
                
                break;
            case 7:
                // bar
                {
                    if(images.count > 0)
                    {
                        NSString *img = [[images[0] lastPathComponent] stringByDeletingPathExtension];
                        img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                        //  img = @"bar_b5";
                        NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                        UIImageView *pointView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                        int imgWidth = MAX(pointView.frame.size.width,1);
                        int imgHeight = pointView.frame.size.height;
                        float factor = imgHeight / imgWidth;
                        pointView.frame = CGRectMake(x + ((barWidth - checkerWidth) / 2) , y + pointsHeight - (checkerWidth * factor), checkerWidth, checkerWidth * factor);

                        [boardView addSubview:pointView];
                        NSMutableDictionary *move = [[NSMutableDictionary alloc]init];
                        [move setValue:[NSNumber numberWithFloat:pointView.frame.origin.x + boardView.frame.origin.x] forKey:@"x"];
                        [move setValue:[NSNumber numberWithFloat:pointView.frame.origin.y + boardView.frame.origin.y] forKey:@"y"];
                        [move setValue:[NSNumber numberWithFloat:pointView.frame.size.width] forKey:@"w"];
                        [move setValue:[NSNumber numberWithFloat:pointView.frame.size.height] forKey:@"h"];
                        [move setValue:[pointDict objectForKey:@"href"] forKey:@"href"];
                        [moveArray addObject:move];
                    }
                    x += barWidth;
                    
                }
                break;
            case 14:
                // right sidee
                y = numberHeight;
                for(int indexOffBoard = 0; indexOffBoard < images.count; indexOffBoard++)
                {
                    NSString *img = [[images[indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                    img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                    UIImageView *pointView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, pointsHeight/3);
                    // ist es ein cube? dann besorge breite und höhe vom img für den view
                    if ([imgName containsString:@"cube"])
                    {
                        UIImage *cubeImg = [UIImage imageNamed:imgName];
                        float imgWidth = cubeImg.size.width;
                        float imgHeight = cubeImg.size.height;
                        float factor = checkerWidth / imgWidth;
                        imgHeight *= factor;
                        pointView.frame = CGRectMake(x + ((offWidth - checkerWidth)/2), y, checkerWidth, imgHeight);
                        
                    }
                    
                    [boardView addSubview:pointView];
                    y += pointsHeight / 3;
                }
                y = numberHeight;
                x += offWidth;
                
                break;
            default:
                // zungen
                if(images.count > 0)
                {
                    NSString *img = [[images[0] lastPathComponent] stringByDeletingPathExtension];
                    img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                    
                    UIImageView *pointView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    pointView.frame = CGRectMake(x, y, checkerWidth, pointsHeight);
                    
                    [boardView addSubview:pointView];
                    x += checkerWidth;
                    NSMutableDictionary *move = [[NSMutableDictionary alloc]init];
                    [move setValue:[NSNumber numberWithFloat:pointView.frame.origin.x + boardView.frame.origin.x] forKey:@"x"];
                    [move setValue:[NSNumber numberWithFloat:pointView.frame.origin.y + boardView.frame.origin.y] forKey:@"y"];
                    [move setValue:[NSNumber numberWithFloat:pointView.frame.size.width] forKey:@"w"];
                    [move setValue:[NSNumber numberWithFloat:pointView.frame.size.height] forKey:@"h"];
                    [move setValue:[pointDict objectForKey:@"href"] forKey:@"href"];
                    [moveArray addObject:move];
                }
                break;
        }
    }

#pragma mark - upper moveIndicator
    x = 0;
    y = numberHeight + pointsHeight ;
    
    NSMutableArray *moveIndicatorObenArray = [boardDict objectForKey:@"moveIndicatorOben"];
    for(int i = 0; i < moveIndicatorObenArray.count; i++)
    {
        switch(i)
        {
            case 0:
                // off board
                x += offWidth;
                break;
            case 7:
                // bar
                x += barWidth;
                break;
            case 14:
                //cube
                x += cubeWidth;
                break;
            default:
                // zungen
                {
                    NSString *img = [[moveIndicatorObenArray[i] lastPathComponent] stringByDeletingPathExtension];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                    
                    UIImageView *pointView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    pointView.frame = CGRectMake(x, y, checkerWidth, indicatorHeight);
                    
                    [boardView addSubview:pointView];
                    x += checkerWidth;
                }
                break;
        }
    }
    
#pragma mark - Dices
    x = 0;
    y = numberHeight + pointsHeight + indicatorHeight ;
    
    NSMutableArray *diceArray = [boardDict objectForKey:@"dice"];
    if(diceArray.count < 8)
    {        //sind wohl gar keine Würfel auf dem Board, trotzdem muss der Cube auf 1 gezeichnet werden
        NSString *img = [[diceArray[0] lastPathComponent] stringByDeletingPathExtension];
        img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
        NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
        UIImageView *pointView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, checkerWidth);
        
        [boardView addSubview:pointView];

        x = offWidth + (6 * checkerWidth) + barWidth  + (6 * checkerWidth) ;

        img = [[diceArray[4] lastPathComponent] stringByDeletingPathExtension];
        imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
        pointView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, checkerWidth);
        
        [boardView addSubview:pointView];
    }
    else
    {
        for(int i = 0; i < diceArray.count; i++)
        {
            switch(i)
            {
                case 0:
                {// off board
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                    UIImageView *pointView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, checkerWidth);
                    
                    [boardView addSubview:pointView];
                }
                   break;
                case 2:     // 1. dice left half of the board
                {
                    x += offWidth + (checkerWidth / 2) + checkerWidth;
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                    
                    UIImageView *diceView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    diceView.frame = CGRectMake(x, y, checkerWidth, checkerWidth);
                    
                    [boardView addSubview:diceView];
                }
                    break;
                case 3:     // 2. dice left half of the board
                {
                    x += checkerWidth + checkerWidth;
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                    
                    UIImageView *diceView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    diceView.frame = CGRectMake(x, y, checkerWidth, checkerWidth);
                    
                    [boardView addSubview:diceView];
                }
                    break;
                case 4:     // 1. dice right half of the board
                {
                    x += checkerWidth + checkerWidth + barWidth + checkerWidth + checkerWidth;
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                    
                    UIImageView *diceView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    diceView.frame = CGRectMake(x, y, checkerWidth, checkerWidth);
                    
                    [boardView addSubview:diceView];
                }
                    break;
                case 5:     // 2. dice right half of the board
                {
                    x += checkerWidth + checkerWidth ;
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                    
                    UIImageView *diceView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    diceView.frame = CGRectMake(x, y, checkerWidth, checkerWidth);
                    
                    [boardView addSubview:diceView];
                }
                   break;
                case 7:     //cube right
                {
                    x += (checkerWidth * 2.5);
                    
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                    UIImageView *pointView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, checkerWidth);
                    
                    [boardView addSubview:pointView];
                }
                    break;
            }
        }
    }

#pragma mark - lower moveIndicator
    x = 0;
    y = numberHeight + pointsHeight + indicatorHeight + checkerWidth;

    NSMutableArray *moveIndicatorUntenArray = [boardDict objectForKey:@"moveIndicatorUnten"];
    for(int i = 0; i < moveIndicatorUntenArray.count; i++)
    {
        switch(i)
        {
            case 0:
                // off board
                x += offWidth;
                break;
            case 7:
                // bar
                x += barWidth;
                break;
            case 14:
                //cube
                x += cubeWidth;
                break;
            default:
                // zungen
            {
                NSString *img = [[moveIndicatorUntenArray[i] lastPathComponent] stringByDeletingPathExtension];
                NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                
                UIImageView *pointView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                pointView.frame = CGRectMake(x, y, checkerWidth, indicatorHeight);
                
                [boardView addSubview:pointView];
                x += checkerWidth;
            }
                break;
        }
    }
#pragma mark - lower graphics
    x = 0;
    y = numberHeight + pointsHeight + indicatorHeight + checkerWidth + indicatorHeight;
    
    NSMutableArray *grafikUntenArray = [boardDict objectForKey:@"grafikUnten"];
    for(int i = 0; i < grafikUntenArray.count; i++)
    {
        NSMutableDictionary *pointDict = grafikUntenArray[i];
        NSMutableArray *images = [pointDict objectForKey:@"img"];
        switch(i)
        {
            case 0:
                // off board
                y += (2 * (pointsHeight / 3));
                for(int indexOffBoard = 0; indexOffBoard < images.count; indexOffBoard++)
                {
                    NSString *img = [[images[(images.count-1) - indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                    img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                    UIImageView *pointView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, pointsHeight/3);
                    // ist es ein cube? dann besorge breite und höhe vom img für den view
                    if ([imgName containsString:@"cube"])
                    {
                        UIImage *cubeImg = [UIImage imageNamed:imgName];
                        float imgWidth = cubeImg.size.width;
                        float imgHeight = cubeImg.size.height;
                        float factor = checkerWidth / imgWidth;
                        imgHeight *= factor;
                        pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, imgHeight);
                    }
                    [boardView addSubview:pointView];
                    y -= pointsHeight / 3;
                }
                y = numberHeight + pointsHeight + indicatorHeight + checkerWidth + indicatorHeight;
                x += offWidth;

                break;
            case 7:
                // bar
                {
                    if(images.count > 0)
                    {
                        NSString *img = [[images[0] lastPathComponent] stringByDeletingPathExtension];
                        img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                      //  img = @"bar_b5";
                        NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                        UIImageView *pointView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                        int imgWidth = MAX(pointView.frame.size.width,1);
                        int imgHeight = pointView.frame.size.height;
                        float factor = imgHeight / imgWidth;
                        pointView.frame = CGRectMake(x + ((barWidth - checkerWidth) / 2) , y, checkerWidth, checkerWidth * factor);

                        [boardView addSubview:pointView];
                        NSMutableDictionary *move = [[NSMutableDictionary alloc]init];
                        [move setValue:[NSNumber numberWithFloat:pointView.frame.origin.x + boardView.frame.origin.x] forKey:@"x"];
                        [move setValue:[NSNumber numberWithFloat:pointView.frame.origin.y + boardView.frame.origin.y] forKey:@"y"];
                        [move setValue:[NSNumber numberWithFloat:pointView.frame.size.width] forKey:@"w"];
                        [move setValue:[NSNumber numberWithFloat:pointView.frame.size.height] forKey:@"h"];
                        [move setValue:[pointDict objectForKey:@"href"] forKey:@"href"];
                        [moveArray addObject:move];

                    }
                    x += barWidth;

                }
                break;
            case 14:
                // right side
                {

                    y += (2 * (pointsHeight / 3));
                    for(int indexOffBoard = 0; indexOffBoard < images.count; indexOffBoard++)
                    {
                        NSString *img = [[images[(images.count-1) - indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                        img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                        NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                        UIImageView *pointView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                        pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, pointsHeight / 3);
                        // ist es ein cube? dann besorge breite und höhe vom img für den view
                        if ([imgName containsString:@"cube"])
                        {
                            UIImage *cubeImg = [UIImage imageNamed:imgName];
                            float imgWidth = cubeImg.size.width;
                            float imgHeight = cubeImg.size.height;
                            float factor = checkerWidth / imgWidth;
                            imgHeight *= factor;
                            pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, imgHeight);
                        }

                        [boardView addSubview:pointView];
                        y -= pointsHeight / 3;
                    }

                    y = numberHeight + pointsHeight + indicatorHeight + checkerWidth + indicatorHeight;
                    x += cubeWidth;

                }
                break;
            default:
                // points
                if(images.count > 0)
                {
                    NSString *img = [[images[0] lastPathComponent] stringByDeletingPathExtension];
                    img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;

                    UIImageView *pointView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    pointView.frame = CGRectMake(x, y, checkerWidth, pointsHeight);
                    
                    [boardView addSubview:pointView];
                    x += checkerWidth;
                    NSMutableDictionary *move = [[NSMutableDictionary alloc]init];
                    [move setValue:[NSNumber numberWithFloat:pointView.frame.origin.x + boardView.frame.origin.x] forKey:@"x"];
                    [move setValue:[NSNumber numberWithFloat:pointView.frame.origin.y + boardView.frame.origin.y] forKey:@"y"];
                    [move setValue:[NSNumber numberWithFloat:pointView.frame.size.width] forKey:@"w"];
                    [move setValue:[NSNumber numberWithFloat:pointView.frame.size.height] forKey:@"h"];
                    [move setValue:[pointDict objectForKey:@"href"] forKey:@"href"];
                    [moveArray addObject:move];
                }
               break;
        }
    }

#pragma mark - end
    NSMutableDictionary *returnDict = [[NSMutableDictionary alloc]init];
    [returnDict setObject:boardView forKey:@"boardView"];
    [returnDict setObject:moveArray forKey:@"moveArray"];

    return returnDict;
}
@end
