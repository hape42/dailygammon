//
//  ExportPosition.m
//  DailyGammon
//
//  Created by Peter Schneider on 25.05.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import "ExportPosition.h"
#import "AppDelegate.h"
#import "ConstantsMatch.h"

@implementation ExportPosition

#pragma mark - ID
- (NSString *)makePositionsID
{
    // https://www.gnu.org/software/gnubg/manual/html_node/A-technical-description-of-the-Position-ID.html
    return @"";
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

    NSLog(@"bitstring meiner: %@", bitString);
    
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
    return @"";
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *bitString = @"";
    NSString *bitStringTemp = @"";

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
    bitStringTemp = [self getBitStringForInt:log2(cubeValue) stringLength:4];
    XLog(@"Bit 1-4 cube value %d %@", cubeValue, [self getBitStringForInt:log2(cubeValue) stringLength:4]);

    bitString = [NSString stringWithFormat:@"%@%@", bitString, [self reverseString:bitStringTemp]];

    XLog(@"Bit 5-6 cube owner %@", cubeOwner);
    bitString = [NSString stringWithFormat:@"%@%@", bitString, [self reverseString:cubeOwner]];

#pragma mark Bit 7 player on roll
    //    Bit 7 is the player on roll or the player who did roll (0 and 1 for player 0 and 1, respectively).
    // wenn roll dice steht, dann ist player 0 dran zu würfeln
    // wenn swap dice steht, dann ist player 0 dran zu würfeln
#warning immer player 0 am zug
    XLog(@"Bit 7 player on roll %@", @"0");

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
        bitStringTemp = @"1";
    else
        bitStringTemp = @"0";
    bitString = [NSString stringWithFormat:@"%@%@", bitString, bitStringTemp];
    XLog(@"Bit 8 Crawford flag %@", bitStringTemp);

#pragma mark Bit 9-11 game state
    //    Bit 9-11 is the game state: 000 for no game started, 001 for playing a game, 010 if the game is over, 011 if the game was resigned, or 100 if the game was ended by dropping a cube.
    bitString = [NSString stringWithFormat:@"%@%@", bitString, [self reverseString:@"001"]];
    XLog(@"Bit 9-11 game state %@", @"001");

#pragma mark Bit 12 whose turn
    //    Bit 12 indicates whose turn it is. For example, suppose player 0 is on roll then bit 7 above will be 0. Player 0 now decides to double, this will make bit 12 equal to 1, since it is now player 1's turn to decide whether she takes or passes the cube.
    bitString = [NSString stringWithFormat:@"%@%@", bitString, @"0"]; // für tests ist immer der gleiche
#warning immer player 0 am zug
    XLog(@"Bit 12 whose turn %@", @"0");

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
    XLog(@"Bit 13 double? %@", doubleBit);

#pragma mark Bit 14-15 resignation
    //    Bit 14-15 indicates whether an resignation was offered. 00 for no resignation, 01 for resign of a single game, 10 for resign of a gammon, or 11 for resign of a backgammon. The player offering the resignation is the inverse of bit 12, e.g., if player 0 resigns a gammon then bit 12 will be 1 (as it is now player 1 now has to decide whether to accept or reject the resignation) and bit 13-14 will be 10 for resign of a gammon.
    bitString = [NSString stringWithFormat:@"%@%@", bitString, [self reverseString:@"00"]];
    XLog(@"Bit 14-15 resignation %@", @"00");

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
                    if(img.length > 0)
                        dice1 = [[img substringFromIndex:[img length] - 1]intValue];

                }
                    break;
                case 3:     // 2. dice left half of the board
                {
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    if(img.length > 0)
                        dice2 = [[img substringFromIndex:[img length] - 1]intValue];

                }
                    break;
                case 4:     // 1. dice right half of the board
                {
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    if(img.length > 0)
                        dice1 = [[img substringFromIndex:[img length] - 1]intValue];

                }
                    break;
                case 5:     // 2. dice right half of the board
                {
                    NSString *img = [[diceArray[i] lastPathComponent] stringByDeletingPathExtension];
                    if(img.length > 0)
                        dice2 = [[img substringFromIndex:[img length] - 1]intValue];

                }
                    break;
                case 7:     //cube right
                {
                }
                    break;
            }
        }
    }
    bitString = [NSString stringWithFormat:@"%@%@%@",
                 bitString,
                 [self reverseString:[self getBitStringForInt:dice1 stringLength:3]],
                 [self reverseString:[self getBitStringForInt:dice2 stringLength:3]]];
    XLog(@"Bit 16-18 and bit 19-21 dice %d %@ %d %@", dice1,[self getBitStringForInt:dice1 stringLength:3], dice2, [self getBitStringForInt:dice2 stringLength:3]);

#pragma mark  Bit 22 to 36  match length
    //    Bit 22 to 36 is the match length. The maximum value for the match length is 32767. A match score of zero indicates that the game is a money game.
    int matchLength = [[[app.boardDict objectForKey:@"matchLaengeText"] stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
    bitString = [NSString stringWithFormat:@"%@%@",
                 bitString,
                 [self reverseString:[self getBitStringForInt:matchLength stringLength:15]]];

#pragma mark Bit 37-51 and bit 52-66 Score
    //    Bit 37-51 and bit 52-66 is the score for player 0 and player 1 respectively. The maximum value of the match score is 32767.
    int scorePlayer = [[playerScore stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
    bitString = [NSString stringWithFormat:@"%@%@",
                 bitString,
                 [self reverseString:[self getBitStringForInt:scorePlayer stringLength:15]]];

    int scoreOpponent = [[opponentScore stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]]intValue];
    bitString = [NSString stringWithFormat:@"%@%@",
                 bitString,
                 [self reverseString:[self getBitStringForInt:scoreOpponent stringLength:15]]];

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
   // bitString = @"100000101001000101010100100000000000010000000000000001000000000000";//score is 2-4 in a 9 point match with player 0 holding a 2-cube, and player 1 has just rolled 52.
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

    [self testPosition];
    return base64String;
}

- (NSString *)reverseString:(NSString *)string
{
    NSUInteger length = [string length];
    if (length == 0) {
        return @""; // Rückgabe eines leeren Strings, wenn der String leer ist
    }
    
    NSMutableString *reversedString = [NSMutableString stringWithCapacity:length];
    
    // Durchlaufe den String von hinten nach vorne
    for (NSInteger i = length - 1; i >= 0; i--) {
        unichar character = [string characterAtIndex:i];
        [reversedString appendFormat:@"%C", character];
    }
    
    return reversedString;
}

- (NSString *)testPosition
{
    // Base64 in NSData dekodieren
    
    NSString *Base64ToBitString = @"4HPwATDg2+ABMA==";
    NSData *data = [[NSData alloc] initWithBase64EncodedString:Base64ToBitString options:0];
    
    if (!data) {
        NSLog(@"Fehler beim Dekodieren des Base64-Strings.");
        return nil;
    }
    
    NSMutableString *bitString = [NSMutableString string];
    
    // Bytes in einen Bit-String umwandeln
    const uint8_t *bytes = [data bytes];
    NSUInteger length = [data length];
    for (NSUInteger i = 0; i < length; i++) {
        uint8_t byte = bytes[i];
        for (NSInteger j = 7; j >= 0; j--) {
            [bitString appendString:((byte & (1 << j)) ? @"1" : @"0")];
        }
    }
    NSString *littleEndianString = @"";
    for (int i = 0; i < bitString.length; i += 8)
    {
        NSString *byteString = [bitString substringWithRange:NSMakeRange(i, 8)];
        for(int j=7; j >= 0; j --)
            littleEndianString = [NSString stringWithFormat:@"%@%@", littleEndianString, [byteString substringWithRange:NSMakeRange(j, 1)]];
    }

    NSLog(@"littleEndianString BGBlitz: %@", littleEndianString);

    return bitString;
}

@end
