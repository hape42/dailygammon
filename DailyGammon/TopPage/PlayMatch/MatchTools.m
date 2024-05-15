//
//  MatchTools.m
//  DailyGammon
//
//  Created by Peter Schneider on 13.12.22.
//  Copyright © 2022 Peter Schneider. All rights reserved.
//

#import "MatchTools.h"
#import "Design.h"
#import "ConstantsMatch.h"
#import "Rating.h"
#import "BoardElements.h"
#import "DGButton.h"
#import "DGLabel.h"
#import "Tools.h"
#import "AppDelegate.h"

@implementation MatchTools

@synthesize design, rating,tools, boardElements;

#pragma mark - draw boardView
-(NSMutableDictionary *)drawBoard:(int)schema boardInfo:(NSMutableDictionary *)boardDict boardView:(UIView *)boardView zoom:(float)zoomFactor isReview:(BOOL) isReview
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

    design        = [[Design alloc] init];
    tools         = [[Tools alloc] init];
    boardElements = [[BoardElements alloc] init];
    
    NSMutableDictionary *returnDict = [[NSMutableDictionary alloc]init];

    // I have determined these numbers when planning on paper in order to optimally represent a game board.
    int checkerWidth = 40;
    int offWidth = 70;
    int barWidth = 40;
    int cubeWidth = offWidth;
    int pointsHeight = 200;
    int numberHeight = 15;
    int indicatorHeight = 22;

    int boardWidth  = cubeWidth + (6 * checkerWidth) + barWidth + (6 * checkerWidth) + offWidth; // 70 + (6 * 40) + 40 + (6 * 40) + 70 = 660
    int boardHeight = numberHeight + pointsHeight + indicatorHeight + checkerWidth + indicatorHeight + pointsHeight + numberHeight; // 15 + 200 + 22 + 40 + 22 + 200 + 15 = 514
    

    int x = 0;
    int y = 0;
    
    checkerWidth    *= zoomFactor;
    offWidth        *= zoomFactor;;
    barWidth        *= zoomFactor;;
    cubeWidth       *= zoomFactor;;
    pointsHeight    *= zoomFactor;;
    numberHeight    *= zoomFactor;;
    indicatorHeight *= zoomFactor;;

    boardWidth  = cubeWidth + (6 * checkerWidth) + barWidth + (6 * checkerWidth) + offWidth;
    boardHeight = numberHeight + pointsHeight + indicatorHeight + checkerWidth + indicatorHeight + pointsHeight + numberHeight;

    CGRect frame = boardView.frame;
    frame.size.height = boardHeight;
    frame.size.width = boardWidth;

    boardView.frame = frame;

    [tools removeAllSubviewsRecursively:boardView];

    NSMutableDictionary *schemaDict = [design schema:schema];
    UIColor *boardColor             = [schemaDict objectForKey:@"BoardSchemaColor"];
    UIColor *edgeColor              = [schemaDict objectForKey:@"RandSchemaColor"];
    UIColor *barCentralStripColor   = [schemaDict objectForKey:@"barMittelstreifenColor"];
    UIColor *numberColor            = [schemaDict objectForKey:@"nummerColor"];
    
    boardView.backgroundColor = boardColor;
    UIImage *boardImage = [UIImage imageNamed:[NSString stringWithFormat:@"%d/background",schema]] ;
    if(boardImage != nil)
    {
        float imageWidth  = (6 * checkerWidth) + barWidth + (6 * checkerWidth);
        float imageHeight = pointsHeight + indicatorHeight + checkerWidth + indicatorHeight + pointsHeight;
        UIImageView *bordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(cubeWidth,
                                                                          numberHeight,
                                                                          imageWidth,
                                                                          imageHeight)];
        bordImageView.image = boardImage;
        [boardView addSubview:bordImageView];
//        UIGraphicsBeginImageContext(boardView.frame.size);
//        [boardImage drawInRect:boardView.bounds];
//        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        boardView.backgroundColor = [UIColor colorWithPatternImage:image];
    }
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
//TODO: better call topPage instead return nil;
        return nil;
    }
    for(int i = 1; i <= 6; i++)
    {
        UILabel *number = [[UILabel alloc]initWithFrame:CGRectMake(x, y, checkerWidth, numberHeight)];
        number.textAlignment = NSTextAlignmentCenter;
        number.text = numberArray[i];
        number.textColor = numberColor;
        number.adjustsFontSizeToFitWidth = YES;
        number.numberOfLines = 0;
        number.minimumScaleFactor = 0.1;

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
        number.adjustsFontSizeToFitWidth = YES;
        number.numberOfLines = 0;
        number.minimumScaleFactor = 0.1;
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
        number.adjustsFontSizeToFitWidth = YES;
        number.numberOfLines = 0;
        number.minimumScaleFactor = 0.1;
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
        number.adjustsFontSizeToFitWidth = YES;
        number.numberOfLines = 0;
        number.minimumScaleFactor = 0.1;
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

    NSString *imgName = [NSString stringWithFormat:@"%d/tray_light",schema] ;
    UIImage *trayImage = [UIImage imageNamed:imgName];

    if(trayImage != nil)
    {
        UIImageView *trayImageView =  [[UIImageView alloc] initWithImage:trayImage];
        trayImageView.frame = CGRectMake(0, 0, offInsideTopView.frame.size.width, offInsideTopView.frame.size.height) ;
        [offInsideTopView addSubview:trayImageView];
        
        trayImageView =  [[UIImageView alloc] initWithImage:trayImage];
        trayImageView.frame = CGRectMake(0, 0, offInsideBottomView.frame.size.width, offInsideBottomView.frame.size.height) ;
        [offInsideBottomView addSubview:trayImageView];

//        trayImage = [boardElements imageRotate:trayImage byDegrees:180];

        trayImageView =  [[UIImageView alloc] initWithImage:trayImage];
        trayImageView.frame = CGRectMake(0, 0, cubeInsideTopView.frame.size.width, cubeInsideTopView.frame.size.height) ;
        [cubeInsideTopView addSubview:trayImageView];

        trayImageView =  [[UIImageView alloc] initWithImage:trayImage];
        trayImageView.frame = CGRectMake(0, 0, cubeInsideBottomView.frame.size.width, cubeInsideBottomView.frame.size.height) ;
        [cubeInsideBottomView addSubview:trayImageView];

    }

    
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
                    UIImageView *pointView =  [[UIImageView alloc] init];
                    // is it a cube? then get width and height from the img for the view
                    if ([img containsString:@"cube"])
                    {
                        UIImage *cubeImg = [boardElements getCubeForSchema:schema name:img];
                        pointView =  [[UIImageView alloc] initWithImage:cubeImg];
                        float imgWidth = cubeImg.size.width;
                        float imgHeight = cubeImg.size.height;
                        float factor = checkerWidth / imgWidth;
                        imgHeight *= factor;
                        pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, imgHeight);
                    }
                    else
                    {
                        pointView =  [[UIImageView alloc] initWithImage:[boardElements getOffForSchema:schema name:img]];
                        pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2),
                                                     y, checkerWidth,
                                                     pointsHeight / 3);
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
                        UIImageView *pointView =  [[UIImageView alloc] initWithImage:[boardElements getBarForSchema:schema name:img]];
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
                // right side
                y = numberHeight;
                for(int indexOffBoard = 0; indexOffBoard < images.count; indexOffBoard++)
                {
                    NSString *img = [[images[indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                    img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
                    UIImageView *pointView =  [[UIImageView alloc] init];
                    // is it a cube? then get width and height from the img for the view
                    if ([img containsString:@"cube"])
                    {
                        UIImage *cubeImg = [boardElements getCubeForSchema:schema name:img];
                        pointView =  [[UIImageView alloc] initWithImage:cubeImg];
                        float imgWidth = cubeImg.size.width;
                        float imgHeight = cubeImg.size.height;
                        float factor = checkerWidth / imgWidth;
                        imgHeight *= factor;
                        pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, imgHeight);
                    }
                    else
                    {
                        pointView =  [[UIImageView alloc] initWithImage:[boardElements getOffForSchema:schema name:img]];
                        pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2),
                                                     y, checkerWidth,
                                                     pointsHeight / 3);
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
                    UIImageView *pointView =  [[UIImageView alloc] initWithImage:[boardElements getPointForSchema:schema name:img withWidth:checkerWidth withHeight:pointsHeight forPointRandom:i]]; // kha: forPointRandom doesn't need to be the actual point index, suffices if it is the same value for all checkers on the same point
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
    
    BOOL idButtonToDraw = YES;
    UIButton *idButton = [[UIButton alloc]initWithFrame:CGRectMake(0, y, checkerWidth, checkerWidth)];
    idButton = [design designSystemImageButton:@"square.and.arrow.up" button:idButton];
    [idButton.layer setValue:[self makePositionsID] forKey:@"posID"];
    [idButton.layer setValue:[self makeMatchID] forKey:@"matchID"];

    NSMutableArray *diceArray = [boardDict objectForKey:@"dice"];
    if(diceArray.count < 8)
    {        //sind wohl gar keine Würfel auf dem Board, trotzdem muss der Cube auf 1 gezeichnet werden
        NSString *img = [[diceArray[0] lastPathComponent] stringByDeletingPathExtension];
        img = [design changeCheckerColor:img forColor:[boardDict objectForKey:@"playerColor"]];
        NSString *imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
        UIImageView *pointView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, checkerWidth);
        
        [boardView addSubview:pointView];

        if(pointView.image != nil )
        {
            int idButtonX = offWidth  + (checkerWidth * 6) + barWidth + (checkerWidth * 6) + ((offWidth - checkerWidth) / 2);
            idButton.frame = CGRectMake(idButtonX, y, checkerWidth, checkerWidth);
            idButtonToDraw = NO;
        }

        x = offWidth + (6 * checkerWidth) + barWidth  + (6 * checkerWidth) ;

        img = [[diceArray[4] lastPathComponent] stringByDeletingPathExtension];
        imgName = [NSString stringWithFormat:@"%d/%@",schema, img] ;
        pointView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, checkerWidth);
        
        [boardView addSubview:pointView];
        
        if(pointView.image != nil)
        {
            // button für PosID auf die andere Seite
            idButton.frame = CGRectMake(0 + ((offWidth - checkerWidth) / 2), y, checkerWidth, checkerWidth);
            idButtonToDraw = NO;
        }

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
                    
                    // button für PosID auf die andere Seite
                    if(pointView.image != nil )
                    {
                        int idButtonX = offWidth  + (checkerWidth * 6) + barWidth + (checkerWidth * 6) + ((offWidth - checkerWidth) / 2);
                        idButton.frame = CGRectMake(idButtonX, y, checkerWidth, checkerWidth);
                        idButtonToDraw = NO;
                    }

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
                    
                    // button für PosID auf die andere Seite
                    if(pointView.image != nil )
                    {
                        idButton.frame = CGRectMake(0 + ((offWidth - checkerWidth) / 2), y, checkerWidth, checkerWidth);
                        idButtonToDraw = NO;
                    }
                }
                    break;
            }
        }
        if(idButtonToDraw )
        {
            idButton.frame = CGRectMake(0 + ((offWidth - checkerWidth) / 2), y, checkerWidth, checkerWidth);            
            idButtonToDraw = NO;
        }
    }
    if( (isReview || [[[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"] isEqualToString:@"13014"]))// only for testing
    {
        [boardView addSubview:idButton];
        [returnDict setObject:idButton forKey:@"posIdButton"];

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
                    UIImageView *pointView =  [[UIImageView alloc] init];
                    // is it a cube? then get width and height from the img for the view
                    if ([img containsString:@"cube"])
                    {
                        UIImage *cubeImg = [boardElements getCubeForSchema:schema name:img];
                        pointView =  [[UIImageView alloc] initWithImage:cubeImg];
                        float imgWidth = cubeImg.size.width;
                        float imgHeight = cubeImg.size.height;
                        float factor = checkerWidth / imgWidth;
                        imgHeight *= factor;
                        pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, imgHeight);
                    }
                    else
                    {
                        pointView =  [[UIImageView alloc] initWithImage:[boardElements getOffForSchema:schema name:img]];
                        pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2),
                                                     y, checkerWidth,
                                                     pointsHeight / 3);
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
                        UIImageView *pointView =  [[UIImageView alloc] initWithImage:[boardElements getBarForSchema:schema name:img]];
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
                        UIImageView *pointView =  [[UIImageView alloc] init];
                        // is it a cube? then get width and height from the img for the view
                        if ([img containsString:@"cube"])
                        {
                            UIImage *cubeImg = [boardElements getCubeForSchema:schema name:img];
                            pointView =  [[UIImageView alloc] initWithImage:cubeImg];
                            float imgWidth = cubeImg.size.width;
                            float imgHeight = cubeImg.size.height;
                            float factor = checkerWidth / imgWidth;
                            imgHeight *= factor;
                            pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2), y, checkerWidth, imgHeight);
                        }
                        else
                        {
                            pointView =  [[UIImageView alloc] initWithImage:[boardElements getOffForSchema:schema name:img]];
                            pointView.frame = CGRectMake(x + ((offWidth - checkerWidth) / 2),
                                                         y, checkerWidth,
                                                         pointsHeight / 3);
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
                    UIImageView *pointView =  [[UIImageView alloc] initWithImage:[boardElements getPointForSchema:schema name:img withWidth:checkerWidth withHeight:pointsHeight forPointRandom:i]]; // kha: again: okay to pass a number that is not the point id, as long as it stays the same for this point

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

#pragma mark - end drawBoard
    [returnDict setObject:boardView forKey:@"boardView"];
    [returnDict setObject:moveArray forKey:@"moveArray"];

    return returnDict;
}

#pragma mark - draw actionView
-(NSMutableDictionary *)drawActionView:(NSMutableDictionary *)boardDict bordView:(UIView *)boardView actionViewWidth:(float)actionViewWidth isPortrait:(BOOL) isPortrait maxHeight:(int)maxHeight
{
    int nameLabelHeight = 0;
    int detailLabelHeight = 0;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        nameLabelHeight   = 35;
        detailLabelHeight = 20;
    }
    else
    {
        nameLabelHeight   = 20;
        detailLabelHeight = 15;
    }

    rating = [[Rating alloc] init];
    design = [[Design alloc] init];

    float x = boardView.frame.origin.x + boardView.frame.size.width + 5;
    float y = boardView.frame.origin.y ;
    float labelWidth = actionViewWidth;
    float edge = 5;
    if(isPortrait)
    {
        labelWidth = boardView.frame.size.width / 2;
        x = boardView.frame.origin.x;
        y = boardView.frame.origin.y + boardView.frame.size.height + 5;
        nameLabelHeight *= 1.5;
        detailLabelHeight *= 1.5;
    }

    UIView  *opponentView = [[UIView alloc] initWithFrame:CGRectMake(x,
                                                                     y,
                                                                     labelWidth,
                                                                     nameLabelHeight + ( 3 * detailLabelHeight))];

    DGLabel *opponentName        = [[DGLabel alloc] initWithFrame:CGRectMake(0,
                                                                             0,
                                                                             opponentView.frame.size.width,
                                                                             nameLabelHeight)];
    DGLabel *opponentRating      = [[DGLabel alloc] initWithFrame:CGRectMake(edge,
                                                                             nameLabelHeight,
                                                                             opponentView.frame.size.width * .4,
                                                                             detailLabelHeight)];
    UITextField *opponentPips    = [[UITextField alloc] initWithFrame:CGRectMake(edge,
                                                                             nameLabelHeight + detailLabelHeight,
                                                                             opponentView.frame.size.width -edge - edge,
                                                                             detailLabelHeight + detailLabelHeight)];
    DGLabel *opponentActive      = [[DGLabel alloc] initWithFrame:CGRectMake(opponentRating.frame.size.width,
                                                                             nameLabelHeight,
                                                                             opponentView.frame.size.width * .6,
                                                                             detailLabelHeight)];
    DGLabel *opponentHistory         = [[DGLabel alloc] initWithFrame:CGRectMake(edge,
                                                                             nameLabelHeight + detailLabelHeight,
                                                                             opponentView.frame.size.width -edge - edge,
                                                                             detailLabelHeight)];
    
    [opponentView addSubview:opponentName];
    
    [opponentView addSubview:opponentRating];
    [opponentRating setFont:[UIFont systemFontOfSize: 15]];
    [opponentActive setFont:[UIFont systemFontOfSize: 15]];
    [opponentHistory setFont:[UIFont systemFontOfSize: 15]];

    [opponentView addSubview:opponentPips];
    opponentPips.textAlignment = NSTextAlignmentRight;
    [opponentPips setFont:[UIFont boldSystemFontOfSize: 20]];
    opponentPips.backgroundColor = [UIColor clearColor];
    opponentPips.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;

    [opponentView addSubview:opponentActive];
    [opponentView addSubview:opponentHistory];

    float playerX = x;
    float playerY = boardView.frame.origin.y + boardView.frame.size.height - (nameLabelHeight + ( 3 * detailLabelHeight));
    if(isPortrait)
    {
        playerX = x + labelWidth;
        playerY = opponentView.frame.origin.y;
    }
    UIView *playerView = [[UIView alloc] initWithFrame:CGRectMake(playerX,
                                                                  playerY,
                                                                  labelWidth,
                                                                  nameLabelHeight + ( 3 * detailLabelHeight))];
    
    DGLabel *playerName        = [[DGLabel alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           playerView.frame.size.width,
                                                                           nameLabelHeight)];
    DGLabel *playerRating      = [[DGLabel alloc] initWithFrame:CGRectMake(edge,
                                                                           nameLabelHeight,
                                                                           playerView.frame.size.width * .4,
                                                                           detailLabelHeight)];
    UITextField *playerPips    = [[UITextField alloc] initWithFrame:CGRectMake(edge,
                                                                             nameLabelHeight + detailLabelHeight,
                                                                           playerView.frame.size.width - edge -edge,
                                                                             detailLabelHeight + detailLabelHeight)];

    DGLabel *playerActive      = [[DGLabel alloc] initWithFrame:CGRectMake(playerRating.frame.size.width,
                                                                             nameLabelHeight,
                                                                           playerView.frame.size.width * .6,
                                                                             detailLabelHeight)];
    DGLabel *playerHistory         = [[DGLabel alloc] initWithFrame:CGRectMake(edge,
                                                                             nameLabelHeight + detailLabelHeight,
                                                                           playerView.frame.size.width - edge -edge,
                                                                             detailLabelHeight)];
 
    [playerView addSubview:playerName];
    
    [playerView addSubview:playerRating];
    [playerRating  setFont:[UIFont systemFontOfSize: 15]];
    [playerActive  setFont:[UIFont systemFontOfSize: 15]];
    [playerHistory setFont:[UIFont systemFontOfSize: 15]];

    [playerView addSubview:playerPips];
    playerPips.textAlignment = NSTextAlignmentRight;
    [playerPips setFont:[UIFont boldSystemFontOfSize: 20]];
    playerPips.backgroundColor = [UIColor clearColor];
    playerPips.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;

    [playerView addSubview:playerActive];
    [playerView addSubview:playerHistory];

    float actionViewHeight = boardView.frame.size.height - nameLabelHeight - ( 3 * detailLabelHeight) - nameLabelHeight - ( 3 * detailLabelHeight);
    y = opponentView.frame.origin.y + opponentView.frame.size.height;
    if(isPortrait)
    {
        actionViewHeight = 200;

        actionViewHeight = maxHeight - boardView.frame.size.height - nameLabelHeight - ( 3 * detailLabelHeight) - nameLabelHeight - ( 3 * detailLabelHeight);
    }

    UIView *actionView = [[UIView alloc] initWithFrame:CGRectMake(x,y,
                                                                  actionViewWidth,
                                                                  actionViewHeight)];

    bool showRatings = [[[NSUserDefaults standardUserDefaults] valueForKey:@"showRatings"]boolValue];
    bool showWinLoss = [[[NSUserDefaults standardUserDefaults] valueForKey:@"showWinLoss"]boolValue];
    
    static NSString *opponentRatingText = @"";
    static NSString *playerRatingText   = @"";
    
    if(showRatings)
    {
        playerRating.text  = playerRatingText;
        opponentRating.text = opponentRatingText;
    }
    
    static NSString *playerActiveText = @"";
    static NSString *playerWonText    = @"";
    static NSString *playerLostText   = @"";
    
    static NSString *opponentActiveText = @"";
    static NSString *opponentWonText    = @"";
    static NSString *opponentLostText   = @"";
    
    if(showWinLoss)
    {
        playerActive.text = playerActiveText;
        playerHistory.text = [NSString stringWithFormat:@"History: %@ %@", playerWonText, playerLostText];

        opponentActive.text = opponentActiveText;
        opponentHistory.text = [NSString stringWithFormat:@"History: %@ %@", opponentWonText, opponentLostText];
    }

#pragma mark - opponent / player

    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1) boardSchema = 4;
    
    if(showRatings || showWinLoss)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                    ^{
                        NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];
                        NSString *opponentID = [boardDict objectForKey:@"opponentID"];

                        NSMutableDictionary *ratingDict = [self->rating readRatingForPlayer:userID andOpponent:opponentID];

                        dispatch_async(dispatch_get_main_queue(),
                                       ^{
                                           if(showRatings)
                                           {
                                               if(![playerRatingText isEqualToString:[ratingDict objectForKey:@"ratingPlayer"]])
                                               {
                                                   playerRatingText       = [ratingDict objectForKey:@"ratingPlayer"];
                                                   playerRating.text = [ratingDict objectForKey:@"ratingPlayer"];
                                               }
                                               
                                               if(![opponentRatingText isEqualToString:[ratingDict objectForKey:@"ratingOpponent"]])
                                               {
                                                   opponentRatingText       = [ratingDict objectForKey:@"ratingOpponent"];
                                                   opponentRating.text = [ratingDict objectForKey:@"ratingOpponent"];
                                               }
                                           }
                                           if(showWinLoss)
                                           {
                                               if(![playerActiveText isEqualToString:[ratingDict objectForKey:@"activePlayer"]])
                                               {
                                                   playerActiveText       = [ratingDict objectForKey:@"activePlayer"];
                                                   playerActive.text = [ratingDict objectForKey:@"activePlayer"];
                                                   playerActive.numberOfLines = 1;
                                                   playerActive.adjustsFontSizeToFitWidth = YES;
                                                   playerActive.minimumScaleFactor = 0.1;
                                                   playerActive.lineBreakMode = NSLineBreakByClipping;
                                               }
                                               
                                               if(![playerWonText isEqualToString:[ratingDict objectForKey:@"wonPlayer"]])
                                               {
                                                   playerWonText       = [ratingDict objectForKey:@"wonPlayer"];
                                                   playerHistory.text = [NSString stringWithFormat:@"History: %@ ", playerWonText];

                                               }
                                               
                                               if(![playerLostText isEqualToString:[ratingDict objectForKey:@"lostPlayer"]])
                                               {
                                                   playerLostText       = [ratingDict objectForKey:@"lostPlayer"];
                                                   playerHistory.text = [NSString stringWithFormat:@"%@ %@",playerHistory.text, playerLostText];
                                               }
                                               
                                               if(![opponentActiveText isEqualToString:[ratingDict objectForKey:@"activeOpponent"]])
                                               {
                                                   opponentActiveText       = [ratingDict objectForKey:@"activeOpponent"];
                                                   opponentActive.text = [ratingDict objectForKey:@"activeOpponent"];
                                               }
                                               
                                               if(![opponentWonText isEqualToString:[ratingDict objectForKey:@"wonOpponent"]])
                                               {
                                                   opponentWonText       = [ratingDict objectForKey:@"wonOpponent"];
                                                   opponentHistory.text = [NSString stringWithFormat:@"History: %@ ", opponentWonText];
                                               }
                                               
                                               if(![opponentLostText isEqualToString:[ratingDict objectForKey:@"lostOpponent"]])
                                               {
                                                   opponentLostText       = [ratingDict objectForKey:@"lostOpponent"];
                                                   opponentHistory.text = [NSString stringWithFormat:@"%@ %@",opponentHistory.text, opponentLostText];
                                               }
                                           }
                                       });
            
                    });

    }

    opponentView.backgroundColor =  [UIColor colorNamed:@"ColorViewBackground"];
    playerView.backgroundColor   =  [UIColor colorNamed:@"ColorViewBackground"];
 
    NSMutableArray *opponentArray = [boardDict objectForKey:@"opponent"];
    
    opponentName.text = @"";
    opponentName = [design makeLabelColor:opponentName forColor:[boardDict objectForKey:@"opponentColor"]  forPlayer:NO];
    
    DGButton *buttonOpponent = [[DGButton alloc] initWithFrame:CGRectMake((opponentName.frame.size.width * .2) / 2,
                                                                          (opponentName.frame.size.height * .2) / 2,
                                                                          opponentName.frame.size.width * .8,
                                                                          opponentName.frame.size.height * .8)] ;
    NSString *opponentNameString = opponentArray[0];
    UIFont *font = buttonOpponent.titleLabel.font;
    CGSize textSize = [opponentNameString sizeWithAttributes:@{NSFontAttributeName: font}];

    if(textSize.width > buttonOpponent.frame.size.width)
    {
        float factor =  buttonOpponent.frame.size.width / textSize.width ;
        
        opponentNameString = [NSString stringWithFormat:@"%@ ...",[opponentNameString substringToIndex:(opponentNameString.length * factor) - 4]];
    }
    buttonOpponent.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    [buttonOpponent setTitle:opponentNameString forState: UIControlStateNormal];

    [buttonOpponent.layer setValue:[boardDict objectForKey:@"opponentID"] forKey:@"userID"];
    [opponentView addSubview:buttonOpponent];

    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = opponentView.bounds;
    gradient.startPoint = CGPointMake(1, 0);;
    gradient.endPoint = CGPointMake(1, 1);
    gradient.colors = @[(id)opponentName.backgroundColor.CGColor, (id)[UIColor colorNamed:@"ColorViewBackground"].CGColor];
    gradient.name = @"gradientOpponent";
    [opponentView.layer insertSublayer:gradient atIndex:0];

    opponentPips.text    = opponentArray[2];
    if([opponentArray[2] rangeOfString:@"pip"].location != NSNotFound)
    {
        opponentPips.text    = opponentArray[2];
    }
    else
    {
        opponentPips.text    = @"";
    }
    
    NSMutableArray *playerArray = [boardDict objectForKey:@"player"];
    
    playerName.text = @"";
    playerName = [design makeLabelColor:playerName forColor:[boardDict objectForKey:@"playerColor"]  forPlayer:YES];
    playerName = [design makeNiceLabel:playerName];
    
    DGButton *buttonPlayer = [[DGButton alloc] initWithFrame:CGRectMake((playerName.frame.size.width * .2) / 2,
                                                                        (playerName.frame.size.height * .2) / 2,
                                                                        playerName.frame.size.width * .8,
                                                                        playerName.frame.size.height * .8)] ;
    [buttonPlayer setTitle:playerArray[0] forState: UIControlStateNormal];
    [buttonPlayer.layer setValue:opponentArray[0] forKey:@"name"];
    [playerView addSubview:buttonPlayer];

    gradient = [CAGradientLayer layer];
    gradient.frame = playerView.bounds;
    gradient.startPoint = CGPointMake(1, 0);;
    gradient.endPoint = CGPointMake(1, 1);
    gradient.colors = @[(id)playerName.backgroundColor.CGColor, (id)[UIColor colorNamed:@"ColorViewBackground"].CGColor];
    gradient.name = @"gradientplayer";
    [playerView.layer insertSublayer:gradient atIndex:0];

    playerPips.text    = playerArray[2];
    if([playerArray[2] rangeOfString:@"pip"].location != NSNotFound)
    {
        playerPips.text    = playerArray[2];
    }
    else
    {
        playerPips.text    = @"";
    }
    
    actionView.tag = ACTION_VIEW;
    opponentView.tag = ACTION_VIEW;
    playerView.tag = ACTION_VIEW;

#pragma mark - end drawAction
    
    NSMutableDictionary *returnDict = [[NSMutableDictionary alloc]init];
    [returnDict setObject:actionView forKey:@"actionView"];
    [returnDict setObject:playerView forKey:@"playerView"];
    [returnDict setObject:opponentView forKey:@"opponentView"];

    [returnDict setObject:buttonOpponent forKey:@"buttonOpponent"];
    [returnDict setObject:buttonPlayer forKey:@"buttonPlayer"];

    return returnDict;

}

#pragma mark - analyze
- (int) analyzeAction:(NSMutableDictionary *)actionDict isChat:(BOOL) isChat isReview:(BOOL) isReview
{
//    self.verifiedDouble = FALSE;
//    self.verifiedTake   = FALSE;
//    self.verifiedPass   = FALSE;
    
    if( isChat)
        return CHAT;
    
    if(isReview)
        return REVIEW;
    
    NSMutableArray *attributesArray = [actionDict objectForKey:@"attributes"];
    if(attributesArray.count == 1)
    {
        NSMutableDictionary *dict = attributesArray[0];
        if([[dict objectForKey:@"value"] isEqualToString:@"Next"])
            return NEXT;
        if([[dict objectForKey:@"value"] isEqualToString:@"1"])
            return NEXTGAME;
        if([[dict objectForKey:@"value"] isEqualToString:@"Roll Dice"])
            return ROLL;
        if([[dict objectForKey:@"value"] isEqualToString:@"Submit Forced Move"])
            return SUBMIT_FORCED_MOVE;
    }
    if(attributesArray.count > 1)
    {
        NSMutableDictionary *dict = attributesArray[1];
        if([[dict objectForKey:@"value"] isEqualToString:@"Beaver!"])
        {
            return ACCEPT_BEAVER_DECLINE;
        }
        dict = attributesArray[0];
        if([[dict objectForKey:@"value"] isEqualToString:@"Accept Beaver"])
            return BEAVER_ACCEPT;

        if([[dict objectForKey:@"value"] isEqualToString:@"Roll Dice"])
        {
            dict = attributesArray[1];
            if([[dict objectForKey:@"value"] isEqualToString:@"Double"])
                return ROLL_DOUBLE;
        }
        if([[dict objectForKey:@"value"] isEqualToString:@"Accept"])
        {
            dict = attributesArray[1];
            if([[dict objectForKey:@"value"] isEqualToString:@"Decline"])
                return ACCEPT_DECLINE;
        }
         
        dict = attributesArray[1];
        if([[dict objectForKey:@"value"] isEqualToString:@"Submit Move"])
            return SUBMIT_MOVE;
        if([[dict objectForKey:@"value"] isEqualToString:@"Submit Greedy Bearoff"])
            return GREEDY;
    }
    
    if([[actionDict objectForKey:@"SwapDice"] length] != 0)
        return SWAP_DICE;
    if([[actionDict objectForKey:@"UndoMove"] length] != 0)
        return UNDO_MOVE;
    if([[actionDict objectForKey:@"Next Game>>"] length] != 0)
        return NEXT__;
    
    if(attributesArray == nil)
    {
        if([[actionDict objectForKey:@"Message"] length] != 0)
            return ONLY_MESSAGE;
    }
    XLog(@"unknown action %@", actionDict);
    return 0;
}

#pragma mark - ID
- (NSString *)makePositionsID
{
    // https://www.gnu.org/software/gnubg/manual/html_node/A-technical-description-of-the-Position-ID.html
   
    NSString *posId = @"positionsID";

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableArray *boardArray = [[NSMutableArray alloc]init];
    NSMutableArray *numberArray = [app.boardDict objectForKey:@"nummernOben"];
    
    NSMutableArray *barArray = [[NSMutableArray alloc]init];
    
    if(numberArray.count < 17)
    {
        // for some reason no board was displayed at all
        return @"no Board";
    }
    
    for(int i = 1; i <= 6; i++)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:numberArray[i] forKey:@"number"];
        [boardArray addObject:dict];
    }
    
    for(int i = 8; i <= 13; i++)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:numberArray[i] forKey:@"number"];
        [boardArray addObject:dict];
    }
    
    numberArray = [app.boardDict objectForKey:@"nummernUnten"];
    
    for(int i = 1; i <= 6; i++)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:numberArray[i] forKey:@"number"];
        [boardArray addObject:dict];
    }
    
    for(int i = 8; i <= 13; i++)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:numberArray[i] forKey:@"number"];
        [boardArray addObject:dict];
    }
    
    NSMutableArray *graphicsArray = [app.boardDict objectForKey:@"grafikOben"];
    int boardArrayIndex = 0;
    for(int i = 0; i < graphicsArray.count; i++)
    {
        NSMutableDictionary *pointDict = graphicsArray[i];
        NSMutableArray *images = [pointDict objectForKey:@"img"];
        switch(i)
        {
            case 0:
                // left side
                for(int indexOffBoard = 0; indexOffBoard < images.count; indexOffBoard++)
                {
                    NSString *img = [[images[indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                    // is it a cube? then get width and height from the img for the view
                    if ([img containsString:@"cube"])
                    {
                        // cube irgendwie irgendwo speichern
                    }
                    else
                    {
                    }
                }
                
                break;
            case 7:
                // bar
            {
                if(images.count > 0)
                {
                    NSString *img = [[images[0] lastPathComponent] stringByDeletingPathExtension];
                    // steine auf der bar speichern
                    NSArray *paramters = [img componentsSeparatedByString: @"_"];
                    int checkerCount = 0;
                    NSString *checker = @"";
                    int checkerColor = 1;
                    
                    if(paramters.count == 2)
                    {
                        checker       = [paramters[1] stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
                        checkerCount = [[paramters[1] stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
                    }
                    if([checker isEqualToString:@"y"])
                        checkerColor = CHECKER_LIGHT;
                    else
                        checkerColor = CHECKER_DARK;
                    
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[NSNumber numberWithInt: checkerCount] forKey:@"checkerCount"];
                    [dict setValue:[NSNumber numberWithInt: checkerColor] forKey:@"checkerColor"];
                    [barArray addObject:dict];
                }
            }
                break;
            case 14:
                // right side
                for(int indexOffBoard = 0; indexOffBoard < images.count; indexOffBoard++)
                {
                    NSString *img = [[images[indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                    // is it a cube? then get width and height from the img for the view
                    if ([img containsString:@"cube"])
                    {
                        // cube irgendwie irgendwo speichern
                    }
                    else
                    {
                    }
                }
                
                break;
            default:
                // zungen
                if(images.count > 0)
                {
                    NSString *img = [[images[0] lastPathComponent] stringByDeletingPathExtension];
                    // split name for parameters
                    NSArray *paramters = [img componentsSeparatedByString: @"_"];
                    int checkerCount = 0;
                    NSString *checker = @"";
                    int checkerColor = 1;
                    
                    if(paramters.count == 3)
                    {
                        // no checker
                    }
                    else
                    {
                        checker       = [paramters[3] stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
                        checkerCount = [[paramters[3] stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
                    }
                    if([checker isEqualToString:@"y"])
                        checkerColor = CHECKER_LIGHT;
                    else
                        checkerColor = CHECKER_DARK;
                    
                    NSMutableDictionary *dict = boardArray[boardArrayIndex++];
                    [dict setValue:[NSNumber numberWithInt: checkerCount] forKey:@"checkerCount"];
                    [dict setValue:[NSNumber numberWithInt: checkerColor] forKey:@"checkerColor"];
                    
                }
                break;
        }
    }
    
    graphicsArray = [app.boardDict objectForKey:@"grafikUnten"];
    boardArrayIndex = 12;
    for(int i = 0; i < graphicsArray.count; i++)
    {
        NSMutableDictionary *pointDict = graphicsArray[i];
        NSMutableArray *images = [pointDict objectForKey:@"img"];
        switch(i)
        {
            case 0:
                // left side
                for(int indexOffBoard = 0; indexOffBoard < images.count; indexOffBoard++)
                {
                    NSString *img = [[images[indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                    // is it a cube? then get width and height from the img for the view
                    if ([img containsString:@"cube"])
                    {
                        // cube irgendwie irgendwo speichern
                    }
                    else
                    {
                    }
                }
                
                break;
            case 7:
                // bar
            {
                if(images.count > 0)
                {
                    NSString *img = [[images[0] lastPathComponent] stringByDeletingPathExtension];
                    NSArray *paramters = [img componentsSeparatedByString: @"_"];
                    int checkerCount = 0;
                    NSString *checker = @"";
                    int checkerColor = 1;
                    
                    if(paramters.count == 2)
                    {
                        checker       = [paramters[1] stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
                        checkerCount = [[paramters[1] stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
                    }
                    if([checker isEqualToString:@"y"])
                        checkerColor = CHECKER_LIGHT;
                    else
                        checkerColor = CHECKER_DARK;
                    
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[NSNumber numberWithInt: checkerCount] forKey:@"checkerCount"];
                    [dict setValue:[NSNumber numberWithInt: checkerColor] forKey:@"checkerColor"];
                    [barArray addObject:dict];

                }
            }
                break;
            case 14:
                // right side
                for(int indexOffBoard = 0; indexOffBoard < images.count; indexOffBoard++)
                {
                    NSString *img = [[images[indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                    // is it a cube? then get width and height from the img for the view
                    if ([img containsString:@"cube"])
                    {
                        // cube irgendwie irgendwo speichern
                    }
                    else
                    {
                    }
                }
                
                break;
            default:
                // zungen
                if(images.count > 0)
                {
                    NSString *img = [[images[0] lastPathComponent] stringByDeletingPathExtension];
                    // split name for parameters
                    NSArray *paramters = [img componentsSeparatedByString: @"_"];
                    int checkerCount = 0;
                    NSString *checker = @"";
                    int checkerColor = 1;
                    
                    if(paramters.count == 3)
                    {
                        // no checker
                    }
                    else
                    {
                        checker       = [paramters[3] stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
                        checkerCount = [[paramters[3] stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
                    }
                    if([checker isEqualToString:@"y"])
                        checkerColor = CHECKER_LIGHT;
                    else
                        checkerColor = CHECKER_DARK;
                    
                    NSMutableDictionary *dict = boardArray[boardArrayIndex++];
                    [dict setValue:[NSNumber numberWithInt: checkerCount] forKey:@"checkerCount"];
                    [dict setValue:[NSNumber numberWithInt: checkerColor] forKey:@"checkerColor"];
                    
                }
                break;
        }
    }
    
    // die hintergrundfarbe rechts unten beim namen legt fest ob ich CHECKER_LIGHT oder CHECKER_DARK bin
    // mögliche farben
    // #9999FF & #3399CC = b
    // #FFFF66 & #FFFFFF = y
    
    // boardArray nach Number sortieren
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES comparator:^(id obj1, id obj2)
                                        {
        int number1 = [(NSNumber *)obj1 intValue];
        int number2 = [(NSNumber *)obj2 intValue];
        
        if(number1 < number2)
            return NSOrderedAscending;
        if(number1 > number2)
            return NSOrderedDescending;
        if(number1 == number2)
            return NSOrderedSame;
        
        //  return [(NSNumber *)obj1 compare:(NSNumber *)obj2];
        return NSOrderedSame;
        
    }];
    NSArray *boardArraySorted = [boardArray sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    int checkerColorPlayer = CHECKER_LIGHT;
    int checkerColorOpponent = CHECKER_DARK;

    if([[app.boardDict objectForKey:@"playerColor"] isEqualToString:@"#9999FF"] || [[app.boardDict objectForKey:@"playerColor"] isEqualToString:@"#3399CC"] )
    {
        checkerColorPlayer = CHECKER_DARK;
        checkerColorOpponent = CHECKER_LIGHT;
    }
    NSString *bitString = @"";
    for(NSMutableDictionary *dict in boardArraySorted)
    {
        if([[dict objectForKey:@"checkerColor"]intValue] == checkerColorPlayer)
        {
            for(int i = 0; i < [[dict objectForKey:@"checkerCount"]intValue]; i++)
                bitString = [NSString stringWithFormat:@"%@%@", bitString, @"1"];
        }
        bitString = [NSString stringWithFormat:@"%@%@", bitString, @"0"];
    }
    // checker bar
    BOOL barFound = NO;
    for(NSMutableDictionary *dict in barArray)
    {
        if([[dict objectForKey:@"checkerColor"]intValue] != checkerColorOpponent)
        {
            for(int i = 0; i < [[dict objectForKey:@"checkerCount"]intValue]; i++)
                bitString = [NSString stringWithFormat:@"%@%@", bitString, @"1"];
            bitString = [NSString stringWithFormat:@"%@%@", bitString, @"0"];
            barFound = YES;
      }
    }
    if(!barFound)
        bitString = [NSString stringWithFormat:@"%@%@", bitString, @"0"];

    for(NSMutableDictionary *dict in [boardArraySorted reverseObjectEnumerator])
    {
        if([[dict objectForKey:@"checkerColor"]intValue] == checkerColorOpponent)
        {
            for(int i = 0; i < [[dict objectForKey:@"checkerCount"]intValue]; i++)
                bitString = [NSString stringWithFormat:@"%@%@", bitString, @"1"];
        }
        bitString = [NSString stringWithFormat:@"%@%@", bitString, @"0"];
    }
    // checker bar
    barFound = NO;
    for(NSMutableDictionary *dict in barArray)
    {
        if([[dict objectForKey:@"checkerColor"]intValue] != checkerColorPlayer)
        {
            for(int i = 0; i < [[dict objectForKey:@"checkerCount"]intValue]; i++)
                bitString = [NSString stringWithFormat:@"%@%@", bitString, @"1"];
            bitString = [NSString stringWithFormat:@"%@%@", bitString, @"0"];
            barFound = YES;
       }
    }
    if(!barFound)
        bitString = [NSString stringWithFormat:@"%@%@", bitString, @"0"];

    
    // bitString muss auf 80 Zeichen aufgefüllt werden
    for(int i = (int)bitString.length; i < 80; i++)
    {
        bitString = [NSString stringWithFormat:@"%@%@", bitString, @"0"];
    }
 //   bitString = @"00000111110011100000111110000000000011000000011111001110000011111000000000001100"; Start stellung zum testen

    NSString *littleEndianString = @"";
    
    for (int i = 0; i < bitString.length; i += 8)
    {
        NSString *byteString = [bitString substringWithRange:NSMakeRange(i, 8)];
        for(int j=7; j >= 0; j --)
            littleEndianString = [NSString stringWithFormat:@"%@%@", littleEndianString, [byteString substringWithRange:NSMakeRange(j, 1)]];
    }

//    NSLog(@"littleEndianString Key: %@", littleEndianString);
    
    // Konvertieren des Bit-Strings in Bytes
    NSMutableData *data = [[NSMutableData alloc] init];
    for (int i = 0; i < littleEndianString.length; i += 8) {
        NSString *byteString = [littleEndianString substringWithRange:NSMakeRange(i, 8)];
        unsigned char byte = strtol([byteString UTF8String], NULL, 2);
        [data appendBytes:&byte length:1];
    }
    
    // Base64-Kodierung der Bytes
    NSString *base64String = [data base64EncodedStringWithOptions:0];

//    NSLog(@"Base64 Encoded String: %@", base64String);
    
    // eleminiere die letzten beiden Stellen wie ZB in NvsKABgz27MAAA==
    posId = [base64String substringToIndex:base64String.length - 2];

    return posId;
}

- (NSString *)makeMatchID
{
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *bitString = @"";
    
    // https://www.gnu.org/software/gnubg/manual/html_node/A-technical-description-of-the-Match-ID.html#A-technical-description-of-the-Match-ID
    
//    The match key is a bit string of length 66:

#pragma mark Bit 1-4 cube value
    //    Bit 1-4 contains the 2-logarithm of the cube value. For example, a 8-cube is encoded as 0011 binary (or 3), since 2 to the power of 3 is 8. The maximum value of the cube in with this encoding is 2 to the power of 15, i.e., a 32768-cube.
#pragma mark Bit 5-6 cube owner

    //    Bit 5-6 contains the cube owner. 00 if player 0 owns the cube, 01 if player 1 owns the cube, or 11 for a centered cube.
    NSString *cubeOwner = @"11";
    int cubeValue = 1;
    
    NSMutableArray *graphicsArray = [app.boardDict objectForKey:@"grafikOben"];
    for(int i = 0; i < graphicsArray.count; i++)
    {
        NSMutableDictionary *pointDict = graphicsArray[i];
        NSMutableArray *images = [pointDict objectForKey:@"img"];
        switch(i)
        {
            case 0:
                // left side
                for(int indexOffBoard = 0; indexOffBoard < images.count; indexOffBoard++)
                {
                    NSString *img = [[images[indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                    if ([img containsString:@"cube"])
                    {
                        cubeValue = [[img stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
                        cubeOwner = @"01";
                    }
                }
                
                break;
            case 14:
                // right side
                for(int indexOffBoard = 0; indexOffBoard < images.count; indexOffBoard++)
                {
                    NSString *img = [[images[indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                    if ([img containsString:@"cube"])
                    {
                        cubeValue = [[img stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
                        cubeOwner = @"01";
                    }
                }
                
                break;
        }
    }
    graphicsArray = [app.boardDict objectForKey:@"grafikUnten"];
    for(int i = 0; i < graphicsArray.count; i++)
    {
        NSMutableDictionary *pointDict = graphicsArray[i];
        NSMutableArray *images = [pointDict objectForKey:@"img"];
        switch(i)
        {
            case 0:
                // left side
                for(int indexOffBoard = 0; indexOffBoard < images.count; indexOffBoard++)
                {
                    NSString *img = [[images[indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                    if ([img containsString:@"cube"])
                    {
                        cubeValue = [[img stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
                        cubeOwner = @"00";
                    }
                }
                
                break;
            case 14:
                // right side
                for(int indexOffBoard = 0; indexOffBoard < images.count; indexOffBoard++)
                {
                    NSString *img = [[images[indexOffBoard] lastPathComponent] stringByDeletingPathExtension];
                    if ([img containsString:@"cube"])
                    {
                        cubeValue = [[img stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
                        cubeOwner = @"00";
                    }
                }
                
                break;
        }
    }
    bitString = [NSString stringWithFormat:@"%@%@%@", bitString, cubeOwner, [self getBitStringForInt:log2(cubeValue) stringLength:4]];

    XLog(@"Owner %@, Value %d %@", cubeOwner,cubeValue, [self getBitStringForInt:log2(cubeValue) stringLength:4]);
    
#pragma mark Bit 7 player on roll
    //    Bit 7 is the player on roll or the player who did roll (0 and 1 for player 0 and 1, respectively).
    // wenn roll dice steht, dann ist player 0 dran zu würfeln
    // wenn swap dice steht, dann ist player 0 dran zu würfeln
#warning immer player 0 am zug
    bitString = [NSString stringWithFormat:@"%@%@", bitString, @"0"];

#pragma mark Bit 8 Crawford flag
    //    Bit 8 is the Crawford flag: 1 if this game is the Crawford game, 0 otherwise.
    NSMutableArray *playerArray = [app.boardDict objectForKey:@"player"];
    NSMutableArray *opponentArray = [app.boardDict objectForKey:@"opponent"];
    NSString *opponentScore = @"";
    if([opponentArray[2] rangeOfString:@"pip"].location != NSNotFound)
        opponentScore  = opponentArray[5];
    else
        opponentScore  = opponentArray[3];
    
    NSString *playerScore = @"";
    if([playerArray[2] rangeOfString:@"pip"].location != NSNotFound)
        playerScore  = playerArray[5];
    else
        playerScore  = playerArray[3];
    NSRange opponentCrawford = [opponentScore rangeOfString:@"*"];
    NSRange playerCrawford = [playerScore rangeOfString:@"*"];

    if ((opponentCrawford.location != NSNotFound) || (playerCrawford.location != NSNotFound))
        bitString = [NSString stringWithFormat:@"%@%@", bitString, @"1"];
    else
        bitString = [NSString stringWithFormat:@"%@%@", bitString, @"0"];

#pragma mark Bit 9-11 game state
    //    Bit 9-11 is the game state: 000 for no game started, 001 for playing a game, 010 if the game is over, 011 if the game was resigned, or 100 if the game was ended by dropping a cube.
    bitString = [NSString stringWithFormat:@"%@%@", bitString, @"001"];

#pragma mark Bit 12 whose turn
    //    Bit 12 indicates whose turn it is. For example, suppose player 0 is on roll then bit 7 above will be 0. Player 0 now decides to double, this will make bit 12 equal to 1, since it is now player 1's turn to decide whether she takes or passes the cube.
    bitString = [NSString stringWithFormat:@"%@%@", bitString, @"0"]; // für tests ist immer der gleiche
#warning immer player 0 am zug
    
#pragma mark Bit 13 double?
    //    Bit 13 indicates whether an doubled is being offered. 0 if no double is being offered and 1 if a double is being offered.
    // wenn roll dice und double erscheint, gehen wir von der frage aus ob es ein double ist
    NSString *doubleBit = @"0";
    NSRange rollDiceRange = [[app.boardDict objectForKey:@"htmlString"] rangeOfString:@"Roll Dice"];
    NSRange doubleRange = [[app.boardDict objectForKey:@"htmlString"] rangeOfString:@"Double"];
    if ((rollDiceRange.location != NSNotFound) && (doubleRange.location != NSNotFound))
        doubleBit = @"1";
    NSRange acceptRange = [[app.boardDict objectForKey:@"htmlString"] rangeOfString:@"Accept"];
    NSRange declineRange = [[app.boardDict objectForKey:@"htmlString"] rangeOfString:@"Decline"];
    if ((declineRange.location != NSNotFound) || (acceptRange.location != NSNotFound))
        doubleBit = @"1";
    bitString = [NSString stringWithFormat:@"%@%@", bitString, doubleBit];

#pragma mark Bit 14-15 resignation
    //    Bit 14-15 indicates whether an resignation was offered. 00 for no resignation, 01 for resign of a single game, 10 for resign of a gammon, or 11 for resign of a backgammon. The player offering the resignation is the inverse of bit 12, e.g., if player 0 resigns a gammon then bit 12 will be 1 (as it is now player 1 now has to decide whether to accept or reject the resignation) and bit 13-14 will be 10 for resign of a gammon.
    bitString = [NSString stringWithFormat:@"%@%@", bitString, @"00"];

#pragma mark Bit 16-18 and bit 19-21 dice
    //    Bit 16-18 and bit 19-21 is the first and second die, respectively. 0 if the dice has not yet be rolled, otherwise the binary encoding of the dice, e.g., if 5-2 was rolled bit 16-21 will be 101-010.

    NSMutableArray *diceArray = [app.boardDict objectForKey:@"dice"];
    int dice1 = 0;
    int dice2 = 0;
    if(diceArray.count < 8)
    {        //sind wohl gar keine Würfel auf dem Board
        
    }
    else
    {
        for(int i = 0; i < diceArray.count; i++)
        {
            switch(i)
            {
                case 0:
                {// off board
                    
                }
                    break;
                case 2:     // 1. dice left half of the board
                {
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    dice1 = [[img stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
                }
                    break;
                case 3:     // 2. dice left half of the board
                {
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    dice2 = [[img stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
                }
                    break;
                case 4:     // 1. dice right half of the board
                {
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    dice1 = [[img stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
                }
                    break;
                case 5:     // 2. dice right half of the board
                {
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    dice2 = [[img stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
                }
                    break;
                case 7:     //cube right
                {
                }
                    break;
            }
        }
    }
    bitString = [NSString stringWithFormat:@"%@%@%@", bitString, [self getBitStringForInt:dice1 stringLength:3], [self getBitStringForInt:dice2 stringLength:3]];

#pragma mark  Bit 22 to 36  match length
    //    Bit 22 to 36 is the match length. The maximum value for the match length is 32767. A match score of zero indicates that the game is a money game.
    int matchLength = [[[app.boardDict objectForKey:@"matchLaengeText"] stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
    bitString = [NSString stringWithFormat:@"%@%@", bitString, [self getBitStringForInt:matchLength stringLength:15]];

#pragma mark Bit 37-51 and bit 52-66 Score
    //    Bit 37-51 and bit 52-66 is the score for player 0 and player 1 respectively. The maximum value of the match score is 32767.
    int scorePlayer = [[playerScore stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
    bitString = [NSString stringWithFormat:@"%@%@", bitString, [self getBitStringForInt:scorePlayer stringLength:15]];

    int scoreOpponent = [[opponentScore stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
    bitString = [NSString stringWithFormat:@"%@%@", bitString, [self getBitStringForInt:scoreOpponent stringLength:15]];

    return [self makeBase64String:bitString];
    return @"MAHzAAAAAAAE";
             // c I n q A A A A A A A E
             // A w Q A A A 4 A A A A
}


- (NSString *)getBitStringForInt:(int)value stringLength:(int)length
{

    NSMutableString *bits = [NSMutableString stringWithString:@""];

    for(int i = 0; i < length; i ++)
    {
        bits = [NSMutableString stringWithFormat:@"%i%@", value & (1 << i) ? 1 : 0, bits];
    }
    while (bits.length < length)
    {
         [bits insertString:@"0" atIndex:0];
    }

    return bits;
}

- (NSString *)makeBase64String:(NSString *)bitString
{
    
    NSString *littleEndianString = @"";
//    bitString = @"100000101001000101010100100000000000010000000000000001000000000000";//score is 2-4 in a 9 point match with player 0 holding a 2-cube, and player 1 has just rolled 52.
    for (int i = 0; i < 64; i += 8)
    {
        NSString *byteString = [bitString substringWithRange:NSMakeRange(i, 8)];
        for(int j=7; j >= 0; j --)
            littleEndianString = [NSString stringWithFormat:@"%@%@", littleEndianString, [byteString substringWithRange:NSMakeRange(j, 1)]];
    }
 //   littleEndianString = [NSString stringWithFormat:@"%@%@", littleEndianString, @"00000000"];

    //    NSLog(@"littleEndianString Key: %@", littleEndianString);

//    littleEndianString = @"100000101001000101010100100000000000010000000000000001000000000000";
 //   littleEndianString = @"010000011000100100101010000000010010000000000000001000000000000000";

    // Konvertieren des Bit-Strings in Bytes
    NSMutableData *data = [[NSMutableData alloc] init];
    for (int i = 0; i < 64; i += 8) {
        NSString *byteString = [littleEndianString substringWithRange:NSMakeRange(i, 8)];
        unsigned char byte = strtol([byteString UTF8String], NULL, 2);
        [data appendBytes:&byte length:1];
    }
    //Bit 65 & 66
    unsigned char byte = strtol([@"00" UTF8String], NULL, 2);
    [data appendBytes:&byte length:1];

    // Base64-Kodierung der Bytes
    NSString *base64String = [data base64EncodedStringWithOptions:0];

    //    NSLog(@"Base64 Encoded String: %@", base64String);


    return base64String;
}
@end
