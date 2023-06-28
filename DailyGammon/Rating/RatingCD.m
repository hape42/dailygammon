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
@end
