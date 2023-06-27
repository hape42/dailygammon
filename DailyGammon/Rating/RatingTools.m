//
//  RatingTools.m
//  DailyGammon
//
//  Created by Peter Schneider on 11.11.21.
//  Copyright © 2021 Peter Schneider. All rights reserved.
//

#import "RatingTools.h"
#import "Ratings+CoreDataProperties.h"



@implementation RatingTools

// Datenhaltung
// key = JJMM zB 2110
// für jeden Monat ein Array mit 31 Numbers (Floats)
// array[0] = 1.10.2021
// array[0] = 2054.17 Rating

// Rating schreiben:
// hole Array der zum Datum passt oder lege neuen Array an
// ist Rating zum Datum kleiner, dann überschreibe den Eintrag und speichere zurück


- (void)saveRating:(NSString *)date
        withRating:(float)rating
{
    //hole gesamten Monat für das Jahr für Datum 2021-11-08
    NSString *key = [date substringWithRange:NSMakeRange(0,7)];
    
    NSMutableArray *ratingArray = [[[NSUbiquitousKeyValueStore defaultStore] objectForKey:key] mutableCopy];
    if(ratingArray == nil)
    {
        ratingArray = [[NSMutableArray alloc]initWithCapacity:31];
        for(int i = 0; i < 31; i++)
            ratingArray[i]= [NSNumber numberWithFloat:0.0];
    }
    int day = [[date substringWithRange:NSMakeRange(8,2)]intValue] - 1;
    
    float ratingOld = [ratingArray[day] floatValue];
    if (rating > ratingOld)
        ratingArray[day] = [NSNumber numberWithFloat:rating];

    NSArray *array = [ratingArray copy];
    [[NSUbiquitousKeyValueStore defaultStore] setObject:array forKey:key];
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
}


-(NSMutableArray *)readAll
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];

    NSMutableArray *ratingArrayAll = [[NSMutableArray alloc]init];
    NSString *oldestDate = @"2019-01-01";
    int thisYear = [[ [format stringFromDate:[NSDate date]] substringWithRange:NSMakeRange(0,4)]intValue];
    BOOL found = FALSE;
    // find the oldest date for which there is an entry in defaultStore and store formatted
    // as yyyy-mm-dd in oldestDate
    for(int year = 2019; year < thisYear; year++)
    {
        if(found)
            break;
        for(int month = 1; month < 12; month++)
        {
            if(found)
                break;
            NSString * key = [NSString stringWithFormat:@"%d-%02d",year, month];
            NSMutableArray *ratingArray = [[[NSUbiquitousKeyValueStore defaultStore] objectForKey:key] mutableCopy];
            if(ratingArray != nil)
            {
                for(int day = 0; day < 31; day++)
                {
                    if([ratingArray[day]floatValue] > 0.0)
                    {
                        oldestDate = [NSString stringWithFormat:@"%d-%02d-%02d",year, month, day+1];
                        XLog(@"%@",oldestDate);
                        found = TRUE;
                        break;
                    }
                }
            }
        }
    }
    NSDate *startDate = [format dateFromString:oldestDate];
    
    NSDate *endDate = [NSDate date];
    
    float ratingBefore = 0.0;
    float min = 9999.0;
    float max = -1.0;
    
    for (NSDate *date = startDate;                    // initialisation
         [date compare:endDate] == NSOrderedAscending; // compare
         date = [date dateByAddingTimeInterval:60*60*24])    // increment
    {
        
        NSString *iCloudDate = [format stringFromDate:date];
        NSString *key = [iCloudDate substringWithRange:NSMakeRange(0,7)];

        NSMutableArray *ratingArray = [[[NSUbiquitousKeyValueStore defaultStore] objectForKey:key] mutableCopy];
        int day = [[iCloudDate substringWithRange:NSMakeRange(8,2)]intValue] - 1;
        
        float rating = [ratingArray[day] floatValue];

        if (rating < 1.0)
            rating = ratingBefore;
        else
            ratingBefore = rating;
        
//        XLog(@"%3.1f %3.1f", rating, ratingVorher);
        if(rating > max)
            max = rating;
        if(rating < min)
            min = rating;

        NSDictionary *ratingDict = @{
                                     @"datum"   : iCloudDate,
                                     @"min"     : [NSNumber numberWithDouble: min],
                                     @"max"     : [NSNumber numberWithDouble: max],
                                     @"rating"  : [NSNumber numberWithDouble: rating]
                                     };

        [ratingArrayAll addObject:ratingDict];
    }

    
    return ratingArrayAll;
}

- (void)clearStore
{
    NSUbiquitousKeyValueStore *ubiquitousStore;
    // Clear everything regardless of actual key:
    for (NSString *key in ubiquitousStore.dictionaryRepresentation.allKeys)
    {
            [ubiquitousStore removeObjectForKey:key];
    }

    // Sync back to iCloud
    [ubiquitousStore synchronize];

}
@end
