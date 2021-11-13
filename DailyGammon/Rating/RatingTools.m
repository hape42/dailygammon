//
//  RatingTools.m
//  DailyGammon
//
//  Created by Peter Schneider on 11.11.21.
//  Copyright © 2021 Peter Schneider. All rights reserved.
//

#import "RatingTools.h"

@implementation RatingTools

// Datenhaltung
// key = JJMM zB 2110
// für jeden Monat ein Array mit 31 Numbers (Floats)
// array[0] = 1.10.2021
// array[0] = 2054.17 Rating

// Rating schreiben:
// hole Array der zum Datum passt oder lege neuen Array an
// ist Rating zum Datum kleiner, dann überschreibe den Eintrag und speichere zurück

//- (void)storeDidChange:(id)sender {
//
//    // Retrieve the changes from iCloud
//    NSData *data = [[[NSUbiquitousKeyValueStore defaultStore] objectForKey:@"BACKGROUND"] mutableCopy];
//    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//    [self.view setBackgroundColor:color];
//
//    NSString *title = [[[NSUbiquitousKeyValueStore defaultStore] objectForKey:@"TITLE"] mutableCopy];
//    [self.centerButton setTitle:title forState:UIControlStateNormal];
//
//}
//
//- (void)backgroundColorChangedWithColor:(UIColor *)color Title:(NSString *)title {
//
//    [self.view setBackgroundColor:color];
//    [self.centerButton setTitle:title forState:UIControlStateNormal];
//
//    // Update data on the iCloud
//    [[NSUbiquitousKeyValueStore defaultStore] setObject:[NSKeyedArchiver archivedDataWithRootObject:color] forKey:@"BACKGROUND"];
//
//    NSArray *array = [mutableArray copy];
//
//https://stackoverflow.com/questions/1768937/how-do-i-convert-nsmutablearray-to-nsarray
//
//    [[NSUbiquitousKeyValueStore defaultStore] setString:title forKey:@"TITLE"];
//
//    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
//
//}

- (void)saveRating:(NSString *)datum
        withRating:(float)rating
{
    //hole gesamten Monat für das Jahr für Datum 2021-11-08
    NSString *key = [datum substringWithRange:NSMakeRange(0,7)];
    
    NSMutableArray *ratingArray = [[[NSUbiquitousKeyValueStore defaultStore] objectForKey:key] mutableCopy];
    if(ratingArray == nil)
    {
        ratingArray = [[NSMutableArray alloc]initWithCapacity:31];
        for(int i = 0; i < 31; i++)
            ratingArray[i]= [NSNumber numberWithFloat:0.0];
    }
    int tag = [[datum substringWithRange:NSMakeRange(8,2)]intValue] - 1;
    
    float ratingAlt = [ratingArray[tag] floatValue];
    if (rating > ratingAlt)
        ratingArray[tag] = [NSNumber numberWithFloat:rating];

    NSArray *array = [ratingArray copy];
    [[NSUbiquitousKeyValueStore defaultStore] setObject:array forKey:key];
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
}

@end
