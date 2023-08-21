//
//  RatingCD.m
//  DailyGammon
//
//  Created by Peter Schneider on 28.06.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import "RatingCD.h"
#import "DbConnect.h"
#import "AppDelegate.h"
#import "Ratings+CoreDataProperties.h"

@implementation RatingCD

- (void)convertDB
{
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSMutableArray *ratingArray = [app.dbConnect readAll];

    for(NSMutableDictionary *ratingDict in ratingArray)
    {
        [self saveRating:[[ratingDict objectForKey:@"rating"] floatValue] forDate:[ratingDict objectForKey:@"date"] forUser:[ratingDict objectForKey:@"userID"]];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"convertDB_done"];
    return;
}

-(void)saveRating:(float)rating forDate:(NSString *)date forUser:(NSString *)userID
{
    
    NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;

    if([self dateUserExist:date user:userID inManagedObjectContext:context])
    {
        // change existing data
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ratings" inManagedObjectContext:context];
        NSError *error;

        Ratings *ratingEntity = (Ratings *)[NSEntityDescription entityForName:@"Ratings" inManagedObjectContext:context];
        NSMutableArray *predicates = [NSMutableArray array];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateRating like %@",date];
        [predicates addObject:predicate];
        predicate = [NSPredicate predicateWithFormat:@"user = [c] %@",userID];
        [predicates addObject:predicate];
        NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];

        [fetchRequest setPredicate:compoundPredicate];

        [fetchRequest setFetchLimit:1];
        [fetchRequest setEntity:entity];
        NSArray *arrResult = [context executeFetchRequest:fetchRequest error:&error];
        ratingEntity = arrResult[0];
        if(rating > ratingEntity.rating)
        {
            ratingEntity.rating = rating;
            
            if (![context save:&error])
            {
                // Something's gone seriously wrong
                XLog(@"Error update Rating %@", [error localizedDescription]);
            }
        }
    }
    else
    {
        Ratings *ratingEntity = (Ratings *)[NSEntityDescription insertNewObjectForEntityForName:@"Ratings" inManagedObjectContext:context];

        ratingEntity.dateRating = date;
        ratingEntity.rating     = rating;
        ratingEntity.user       = userID;

        NSError *error;
        if (![context save:&error])
        {
            // Something's gone seriously wrong
            XLog(@"Error saving Rating %@", [error localizedDescription]);
        }
    }
}

- (bool)dateUserExist:(NSString *)date user:(NSString*)userID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSMutableArray *predicates = [NSMutableArray array];

    request.entity = [NSEntityDescription entityForName:@"Ratings" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateRating = [c] %@", date];
    
    [predicates addObject:predicate];
    predicate = [NSPredicate predicateWithFormat:@"user = [c] %@",userID];
    [predicates addObject:predicate];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    request.predicate =  compoundPredicate;

    [request setPredicate:compoundPredicate];

    NSError *executeFetchError = nil;
    if ([context countForFetchRequest:request error:&executeFetchError])
    {
        XLog(@"Existiert: %@ %@", date, userID);
        return TRUE;
    }
    else
    {
        XLog(@"Fehlt: %@ %@", date, userID);
        return FALSE;
    }
}

- (float)readRatingForDate:(NSString *)date user:(NSString*)userID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSMutableArray *predicates = [NSMutableArray array];

    request.entity = [NSEntityDescription entityForName:@"Ratings" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateRating = [c] %@", date];
    
    [predicates addObject:predicate];
    predicate = [NSPredicate predicateWithFormat:@"user = [c] %@",userID];
    [predicates addObject:predicate];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    request.predicate =  compoundPredicate;

    [request setPredicate:compoundPredicate];
    [request setFetchLimit:1];

    NSError *error;

    NSArray *arrResult = [context executeFetchRequest:request error:&error];
    Ratings *ratingEntity = (Ratings *)[NSEntityDescription entityForName:@"Ratings" inManagedObjectContext:context];

    if(arrResult.count < 1)
        return 0.0;
    ratingEntity = arrResult[0];
    return ratingEntity.rating;
}

- (Ratings *)bestRating
{
    NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;

    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ratings" inManagedObjectContext:context];
    NSError *error;

    Ratings *ratingEntity = (Ratings *)[NSEntityDescription entityForName:@"Ratings" inManagedObjectContext:context];
    NSMutableArray *predicates = [NSMutableArray array];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user = [c] %@",userID];
    [predicates addObject:predicate];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];

    [fetchRequest setPredicate:compoundPredicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rating" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];

    [fetchRequest setFetchLimit:1];
    [fetchRequest setEntity:entity];
    NSArray *arrResult = [context executeFetchRequest:fetchRequest error:&error];
    ratingEntity = arrResult[0];

    return ratingEntity;
}
- (Ratings *)worstRating
{
    NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;

    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ratings" inManagedObjectContext:context];
    NSError *error;

    Ratings *ratingEntity = (Ratings *)[NSEntityDescription entityForName:@"Ratings" inManagedObjectContext:context];
    NSMutableArray *predicates = [NSMutableArray array];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user = [c] %@",userID];
    [predicates addObject:predicate];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];

    [fetchRequest setPredicate:compoundPredicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rating" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];

    [fetchRequest setFetchLimit:1];
    [fetchRequest setEntity:entity];
    NSArray *arrResult = [context executeFetchRequest:fetchRequest error:&error];
    ratingEntity = arrResult[0];

    return ratingEntity;
}

- (NSMutableArray *) readAlleRatingForUser:(NSString*)userID
{
    NSString *startDateDB = @"2000-01-01";

    NSMutableArray *tmpArray = [[NSMutableArray alloc]init];

    NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ratings" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user = [c] %@",userID];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateRating" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    [request setFetchLimit:1];

    // Fetch the records and handle an error
    NSError *error;
    
    NSMutableArray *arrayDB = [[context executeFetchRequest:request error:&error] mutableCopy];
    Ratings *rating = arrayDB[0];
    startDateDB = rating.dateRating;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSDate *startDate = [df dateFromString:startDateDB];
    
    NSDate *endDate = [NSDate date];
    
    float lastRating = 0.0;
    float min = 9999.0;
    float max = -1.0;

    for (NSDate *date = startDate;                    // initialisation
         [date compare:endDate] == NSOrderedAscending; // compare
         date = [date dateByAddingTimeInterval:60*60*24])    // increment
    {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        NSString *dateDB = [format stringFromDate:date];


        float rating = [self readRatingForDate:dateDB user:userID inManagedObjectContext:context];
        if (rating < 1.0)
            rating = lastRating;
        else
            lastRating = rating;
        
//        XLog(@"%3.1f %3.1f", rating, lastRating);
        if(rating > max)
            max = rating;
        if(rating < min)
            min = rating;

        NSDictionary *ratingDict = @{
                                     @"datum"   : dateDB,
                                     @"min"     : [NSNumber numberWithDouble: min],
                                     @"max"     : [NSNumber numberWithDouble: max],
                                     @"rating"  : [NSNumber numberWithDouble: rating]
                                     };

        [tmpArray addObject:ratingDict];
    }
    
    return tmpArray;
}

@end
