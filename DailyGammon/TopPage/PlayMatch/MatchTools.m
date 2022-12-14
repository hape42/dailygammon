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

    float zoomFactor = 1.0;
    
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
    checkerWidth *= zoomFactor;
    offWidth *= zoomFactor;;
    barWidth  *= zoomFactor;;
    cubeWidth *= zoomFactor;;
    pointsHeight *= zoomFactor;;
    numberHeight *= zoomFactor;;
    indicatorHeight *= zoomFactor;;

    boardWidth  = cubeWidth + (6 * checkerWidth) + barWidth + (6 * checkerWidth) + offWidth;
    boardHeight = numberHeight + pointsHeight + indicatorHeight + checkerWidth + indicatorHeight + pointsHeight + numberHeight;

    UIView *boardView = [[UIView alloc] initWithFrame:CGRectMake(x, y, boardWidth, boardHeight)];
    boardView.tag = BOARD_VIEW;

    NSMutableDictionary *schemaDict = [design schema:schema];
    UIColor *boardColor             = [schemaDict objectForKey:@"BoardSchemaColor"];
    UIColor *edgeColor              = [schemaDict objectForKey:@"RandSchemaColor"];
    UIColor *barCentralStripColor   = [schemaDict objectForKey:@"barMittelstreifenColor"];
    UIColor *numberColor            = [schemaDict objectForKey:@"nummerColor"];
    UIColor *testColor = [UIColor redColor];
    
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
    
    UIView *removeView;
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
        // aus irgendwelchen Gründen wurde gar kein Board angezeigt
#warning        [self errorAction:2];
        return nil;
    }
    for(int i = 1; i <= 6; i++)
    {
        UILabel *nummer = [[UILabel alloc]initWithFrame:CGRectMake(x, y, checkerWidth, numberHeight)];
        nummer.textAlignment = NSTextAlignmentCenter;
        nummer.text = numberArray[i];
        nummer.textColor = numberColor;
        nummer.tag = i + 1000;
        while((removeView = [numberTopView viewWithTag:i + 1000]) != nil)
        {
            [removeView removeFromSuperview];
        }
        [numberTopView addSubview:nummer];

        x += checkerWidth;
    }
    x += barWidth; // bar

    for(int i = 8; i <= 13; i++)
    {
        UILabel *nummer = [[UILabel alloc]initWithFrame:CGRectMake(x, y, checkerWidth, numberHeight)];
        nummer.textAlignment = NSTextAlignmentCenter;
        nummer.text = numberArray[i];
        nummer.textColor = numberColor;
        nummer.tag = i + 1000;
        while((removeView = [numberTopView viewWithTag:i + 1000]) != nil)
        {
            [removeView removeFromSuperview];
        }
        
        [numberTopView addSubview:nummer];
        
        x += checkerWidth;
    }

    x = offWidth;
    y = 0;
    numberArray = [boardDict objectForKey:@"nummernUnten"];
    
    for(int i = 1; i <= 6; i++)
    {
        UILabel *nummer = [[UILabel alloc]initWithFrame:CGRectMake(x, y, checkerWidth, numberHeight)];
        nummer.textAlignment = NSTextAlignmentCenter;
        nummer.text = numberArray[i];
        nummer.textColor = numberColor;
        [numberBottomView addSubview:nummer];
        
        x += checkerWidth;
    }
    x += barWidth; // bar
    
    for(int i = 8; i <= 13; i++)
    {
        UILabel *nummer = [[UILabel alloc]initWithFrame:CGRectMake(x, y, checkerWidth, numberHeight)];
        nummer.textAlignment = NSTextAlignmentCenter;
        nummer.text = numberArray[i];
        nummer.textColor = numberColor;
        [numberBottomView addSubview:nummer];
        
        x += checkerWidth;
    }
#pragma mark - edges
    UIView *offView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                               numberHeight,
                                                               offWidth,
                                                               boardView.frame.size.height - numberHeight)];
    offView.backgroundColor = edgeColor;

    UIView *offInnenObenView = [[UIView alloc] initWithFrame:CGRectMake((offWidth - checkerWidth) / 2,
                                                                        0,
                                                                        checkerWidth,
                                                                        pointsHeight)];
    offInnenObenView.backgroundColor = boardColor;
    offInnenObenView.layer.borderWidth = 1;
    offInnenObenView.layer.borderColor = [UIColor grayColor].CGColor;
    [offView addSubview:offInnenObenView];
    
    UIView *offInnenUntenView = [[UIView alloc] initWithFrame:CGRectMake((offWidth - checkerWidth) / 2,
                                                                         pointsHeight + indicatorHeight + checkerWidth + indicatorHeight,
                                                                         checkerWidth,
                                                                         pointsHeight)];
    offInnenUntenView.backgroundColor = boardColor;
    offInnenUntenView.layer.borderWidth = 1;
    offInnenUntenView.layer.borderColor = [UIColor grayColor].CGColor;
    [offView addSubview:offInnenUntenView];

    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(offWidth + (6 * checkerWidth),
                                                               0,
                                                               barWidth,
                                                               boardView.frame.size.height)];
    barView.backgroundColor = edgeColor;

    UIView *barMitteView = [[UIView alloc] initWithFrame:CGRectMake(((barWidth / 2) - 2),
                                                                    0,
                                                                    2,
                                                                    boardView.frame.size.height )];
    barMitteView.backgroundColor = barCentralStripColor;
    [barView addSubview:barMitteView];
    
    UIView *cubeView = [[UIView alloc] initWithFrame:CGRectMake(offWidth + (6 * checkerWidth) + barWidth + (6 * checkerWidth),
                                                                numberHeight,
                                                                cubeWidth,
                                                                boardView.frame.size.height - numberHeight)];
    cubeView.backgroundColor = edgeColor;

    UIView *cubeInnenObenView = [[UIView alloc] initWithFrame:CGRectMake((offWidth - checkerWidth) / 2,
                                                                         0,
                                                                         checkerWidth,
                                                                         pointsHeight)];
    cubeInnenObenView.backgroundColor = boardColor;
    cubeInnenObenView.layer.borderWidth = 1;
    cubeInnenObenView.layer.borderColor = [UIColor grayColor].CGColor;
    [cubeView addSubview:cubeInnenObenView];
    
    UIView *cubeInnenUntenView = [[UIView alloc] initWithFrame:CGRectMake((offWidth - checkerWidth) / 2,
                                                                          pointsHeight + indicatorHeight + checkerWidth + indicatorHeight,
                                                                          checkerWidth,
                                                                          pointsHeight)];
    cubeInnenUntenView.backgroundColor = boardColor;
    cubeInnenUntenView.layer.borderWidth = 1;
    cubeInnenUntenView.layer.borderColor = [UIColor grayColor].CGColor;
    [cubeView addSubview:cubeInnenUntenView];
    
    [boardView addSubview:offView];
    [boardView addSubview:barView];
    [boardView addSubview:cubeView];

    
#pragma mark - obere Grafiken
    x = 0;
    y = numberHeight;

    NSMutableArray *grafikObenArray = [boardDict objectForKey:@"grafikOben"];
    for(int i = 0; i < grafikObenArray.count; i++)
    {
        NSMutableDictionary *zunge = grafikObenArray[i];
        NSMutableArray *bilder = [zunge objectForKey:@"img"];
        switch(i)
        {
            case 0:
                // linke Seite
                y = numberHeight;
                for(int indexOffBoard = 0; indexOffBoard < bilder.count; indexOffBoard++)
                {
                    NSString *img = [[bilder[indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                    img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                    UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    zungeView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2),
                                                 y, checkerWidth,
                                                 pointsHeight / 3);
                    // ist es ein cube? dann besorge breite und höhe vom img für den view
                    if ([imgName containsString:@"cube"])
                    {
                        UIImage *cubeImg = [UIImage imageNamed:imgName];
                        float imgBreite = cubeImg.size.width;
                        float imgHoehe = cubeImg.size.height;
                        float faktor = checkerWidth / imgBreite;
                        imgHoehe *= faktor;
                        zungeView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, imgHoehe);
                    }

                    [boardView addSubview:zungeView];
                    y += pointsHeight / 3;
                }
                y = numberHeight;
                x += offWidth;
                
                break;
            case 7:
                // bar
                {
                    if(bilder.count > 0)
                    {
                        NSString *img = [[bilder[0] lastPathComponent] stringByDeletingPathExtension];
                        img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                        //  img = @"bar_b5";
                        NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                        UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                        int imgBreite = MAX(zungeView.frame.size.width,1);
                        int imgHoehe = zungeView.frame.size.height;
                        float faktor = imgHoehe / imgBreite;
                        zungeView.frame = CGRectMake(x + ((barWidth - checkerWidth) / 2) , y + pointsHeight - (checkerWidth * faktor), checkerWidth, checkerWidth * faktor);

                        [boardView addSubview:zungeView];
                        NSMutableDictionary *move = [[NSMutableDictionary alloc]init];
                        [move setValue:[NSNumber numberWithFloat:zungeView.frame.origin.x + boardView.frame.origin.x] forKey:@"x"];
                        [move setValue:[NSNumber numberWithFloat:zungeView.frame.origin.y + boardView.frame.origin.y] forKey:@"y"];
                        [move setValue:[NSNumber numberWithFloat:zungeView.frame.size.width] forKey:@"w"];
                        [move setValue:[NSNumber numberWithFloat:zungeView.frame.size.height] forKey:@"h"];
                        [move setValue:[zunge objectForKey:@"href"] forKey:@"href"];
                        [moveArray addObject:move];
                    }
                    x += barWidth;
                    
                }
                break;
            case 14:
                // rechte Seite
                y = numberHeight;
                for(int indexOffBoard = 0; indexOffBoard < bilder.count; indexOffBoard++)
                {
                    NSString *img = [[bilder[indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                    img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                    UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    zungeView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, pointsHeight/3);
                    // ist es ein cube? dann besorge breite und höhe vom img für den view
                    if ([imgName containsString:@"cube"])
                    {
                        UIImage *cubeImg = [UIImage imageNamed:imgName];
                        float imgBreite = cubeImg.size.width;
                        float imgHoehe = cubeImg.size.height;
                        float faktor = checkerWidth / imgBreite;
                        imgHoehe *= faktor;
                        zungeView.frame = CGRectMake(x + ((offWidth - checkerWidth)/2), y, checkerWidth, imgHoehe);
                        
                    }
                    
                    [boardView addSubview:zungeView];
                    y += pointsHeight / 3;
                }
                y = numberHeight;
                x += offWidth;
                
                break;
            default:
                // zungen
                if(bilder.count > 0)
                {
                    NSString *img = [[bilder[0] lastPathComponent] stringByDeletingPathExtension];
                    img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                    
                    UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    zungeView.frame = CGRectMake(x, y, checkerWidth, pointsHeight);
                    
                    [boardView addSubview:zungeView];
                    x += checkerWidth;
                    NSMutableDictionary *move = [[NSMutableDictionary alloc]init];
                    [move setValue:[NSNumber numberWithFloat:zungeView.frame.origin.x + boardView.frame.origin.x] forKey:@"x"];
                    [move setValue:[NSNumber numberWithFloat:zungeView.frame.origin.y + boardView.frame.origin.y] forKey:@"y"];
                    [move setValue:[NSNumber numberWithFloat:zungeView.frame.size.width] forKey:@"w"];
                    [move setValue:[NSNumber numberWithFloat:zungeView.frame.size.height] forKey:@"h"];
                    [move setValue:[zunge objectForKey:@"href"] forKey:@"href"];
                    [moveArray addObject:move];
                }
                break;
        }
    }

#pragma mark - obere moveIndicator
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
                    
                    UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    zungeView.frame = CGRectMake(x, y, checkerWidth, indicatorHeight);
                    
                    [boardView addSubview:zungeView];
                    x += checkerWidth;
                }
                break;
        }
    }
    x += checkerWidth;

    
#pragma mark - Würfel
    x = 0;
    y = numberHeight + pointsHeight + indicatorHeight ;
    
    NSMutableArray *diceArray = [boardDict objectForKey:@"dice"];
    if(diceArray.count < 8)
    {        //sind wohl gar keine Würfel auf dem Board, trotzdem muss der Cube auf 1 gezeichnet werden
        NSString *img = [[diceArray[0] lastPathComponent] stringByDeletingPathExtension];
        img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
        NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
        UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        zungeView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, checkerWidth);
        
        [boardView addSubview:zungeView];

        x = offWidth + (6 * checkerWidth) + barWidth  + (6 * checkerWidth) ;

        img = [[diceArray[4] lastPathComponent] stringByDeletingPathExtension];
        imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
        zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        zungeView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, checkerWidth);
        
        [boardView addSubview:zungeView];
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
                    UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    zungeView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, checkerWidth);
                    
                    [boardView addSubview:zungeView];
                }
                   break;
                case 2:     // 1. Würfel linke Boardhälfte
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
                case 3:     // 2. Würfel linke Boardhälfte
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
                case 4:     // 1. Würfel rechte Boardhälfte
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
                case 5:     // 2. Würfel rechte Boardhälfte
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
                case 7:     //cube rechts
                {
                    x += (checkerWidth * 2.5);
                    
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                    UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    zungeView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, checkerWidth);
                    
                    [boardView addSubview:zungeView];
                }
                    break;
            }
        }
    }

#pragma mark - untere moveIndicator
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
                
                UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                zungeView.frame = CGRectMake(x, y, checkerWidth, indicatorHeight);
                
                [boardView addSubview:zungeView];
                x += checkerWidth;
            }
                break;
        }
    }
#pragma mark - untere Grafiken
    x = 0;
    y = numberHeight + pointsHeight + indicatorHeight + checkerWidth + indicatorHeight;
    
    NSMutableArray *grafikUntenArray = [boardDict objectForKey:@"grafikUnten"];
    for(int i = 0; i < grafikUntenArray.count; i++)
    {
        NSMutableDictionary *zunge = grafikUntenArray[i];
        NSMutableArray *bilder = [zunge objectForKey:@"img"];
        switch(i)
        {
            case 0:
                // off board
                y += (2 * (pointsHeight / 3));
                for(int indexOffBoard = 0; indexOffBoard < bilder.count; indexOffBoard++)
                {
                    NSString *img = [[bilder[(bilder.count-1) - indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                    img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                    UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    zungeView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, pointsHeight/3);
                    // ist es ein cube? dann besorge breite und höhe vom img für den view
                    if ([imgName containsString:@"cube"])
                    {
                        UIImage *cubeImg = [UIImage imageNamed:imgName];
                        float imgBreite = cubeImg.size.width;
                        float imgHoehe = cubeImg.size.height;
                        float faktor = checkerWidth / imgBreite;
                        imgHoehe *= faktor;
                        zungeView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, imgHoehe);

                    }
                    [boardView addSubview:zungeView];
                    y -= pointsHeight / 3;
                }
                y = numberHeight + pointsHeight + indicatorHeight + checkerWidth + indicatorHeight;
                x += offWidth;

                break;
            case 7:
                // bar
                {
                    if(bilder.count > 0)
                    {
                        NSString *img = [[bilder[0] lastPathComponent] stringByDeletingPathExtension];
                        img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                      //  img = @"bar_b5";
                        NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                        UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                        int imgBreite = MAX(zungeView.frame.size.width,1);
                        int imgHoehe = zungeView.frame.size.height;
                        float faktor = imgHoehe / imgBreite;
                        zungeView.frame = CGRectMake(x + ((barWidth - checkerWidth) / 2) , y, checkerWidth, checkerWidth * faktor);

                        [boardView addSubview:zungeView];
                        NSMutableDictionary *move = [[NSMutableDictionary alloc]init];
                        [move setValue:[NSNumber numberWithFloat:zungeView.frame.origin.x + boardView.frame.origin.x] forKey:@"x"];
                        [move setValue:[NSNumber numberWithFloat:zungeView.frame.origin.y + boardView.frame.origin.y] forKey:@"y"];
                        [move setValue:[NSNumber numberWithFloat:zungeView.frame.size.width] forKey:@"w"];
                        [move setValue:[NSNumber numberWithFloat:zungeView.frame.size.height] forKey:@"h"];
                        [move setValue:[zunge objectForKey:@"href"] forKey:@"href"];
                        [moveArray addObject:move];

                    }
                    x += barWidth;

                }
                break;
            case 14:
                // rechte Seite
                {

                    y += (2 * (pointsHeight / 3));
                    for(int indexOffBoard = 0; indexOffBoard < bilder.count; indexOffBoard++)
                    {
                        NSString *img = [[bilder[(bilder.count-1) - indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                        img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                        NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
                        UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                        zungeView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, pointsHeight / 3);
                        // ist es ein cube? dann besorge breite und höhe vom img für den view
                        if ([imgName containsString:@"cube"])
                        {
                            UIImage *cubeImg = [UIImage imageNamed:imgName];
                            float imgBreite = cubeImg.size.width;
                            float imgHoehe = cubeImg.size.height;
                            float faktor = checkerWidth / imgBreite;
                            imgHoehe *= faktor;
                            zungeView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, imgHoehe);
                        }

                        [boardView addSubview:zungeView];
                        y -= pointsHeight / 3;
                    }

                    y = numberHeight + pointsHeight + indicatorHeight + checkerWidth + indicatorHeight;
                    x += cubeWidth;

                }
                break;
            default:
                // zungen
                if(bilder.count > 0)
                {
                    NSString *img = [[bilder[0] lastPathComponent] stringByDeletingPathExtension];
                    img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                    NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;

                    UIImageView *zungeView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
                    zungeView.frame = CGRectMake(x, y, checkerWidth, pointsHeight);
                    
                    [boardView addSubview:zungeView];
                    x += checkerWidth;
                    NSMutableDictionary *move = [[NSMutableDictionary alloc]init];
                    [move setValue:[NSNumber numberWithFloat:zungeView.frame.origin.x + boardView.frame.origin.x] forKey:@"x"];
                    [move setValue:[NSNumber numberWithFloat:zungeView.frame.origin.y + boardView.frame.origin.y] forKey:@"y"];
                    [move setValue:[NSNumber numberWithFloat:zungeView.frame.size.width] forKey:@"w"];
                    [move setValue:[NSNumber numberWithFloat:zungeView.frame.size.height] forKey:@"h"];
                    [move setValue:[zunge objectForKey:@"href"] forKey:@"href"];
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
