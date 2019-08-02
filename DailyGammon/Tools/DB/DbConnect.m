//
//  DbConnect.m
//
//

#import "DbConnect.h"
#import "AppDelegate.h"

@implementation DbConnect
{
    sqlite3 *database;
    NSString *dbPath;
    sqlite3_stmt *statement;
}

-(void) openDb
{
    // Den Pfad zur Documents-Directory in path speichern
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    dbPath = [documentsDirectory stringByAppendingPathComponent:@"rating.sqlite"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // Die Datenbank aus dem Bundle in die Documents-Directory kopieren
    NSString *pathInMainBundle = [[NSBundle mainBundle] pathForResource:@"rating" ofType:@"sqlite"];
    if (![fileManager fileExistsAtPath:dbPath])
    {
        NSLog(@"Datenbank noch nicht vorhanden");
        [fileManager copyItemAtPath:pathInMainBundle toPath:dbPath error:nil];
    }
    
    // Die Datenbank öffnen
    int result = sqlite3_open([dbPath UTF8String], &database);
    if (result != SQLITE_OK)
    {
        sqlite3_close(database);
        NSLog(@"Fehler beim Öffnen der Datenbank");
        return;
    }
   // NSLog(@"Datenbank erfolgreich geöffnet");
}

-(void) closeDb
{
    sqlite3_close(database);
    NSLog(@"Datenbank erfolgreich geschlossen");
}

-(BOOL)checkColumnExists
{
    BOOL columnExists = NO;
    
    sqlite3_stmt *selectStmt;
    
    const char *sqlStatement = "select userID from Rating";
    if(sqlite3_prepare_v2(database, sqlStatement, -1, &selectStmt, NULL) == SQLITE_OK)
        columnExists = YES;
    else
    {
        NSString *updateSQL = [NSString stringWithFormat: @"ALTER TABLE Rating ADD COLUMN userID VARCHAR"];
        const char *sql = [updateSQL UTF8String];
        sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
        sqlite3_step(statement);
        sqlite3_finalize(statement);

    }
    return columnExists;
}

-(void) saveRating:(NSString *) datum
        withRating:(float)rating forUser:(NSString*)userID
 {
     [self checkColumnExists];
     int count = 0;
     NSString *sqlQuery = [NSString stringWithFormat:@"SELECT COUNT (*) FROM Rating WHERE Datum LIKE '%@' AND userID LIKE '%@';", datum, userID];
     const char *sql = [sqlQuery UTF8String];
     if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
     {
         while (sqlite3_step(statement) == SQLITE_ROW)
         {
             count =  sqlite3_column_int(statement, 0);
             if(count >0)
             {
//                 sqlite3_finalize(statement);
                 continue;;
             }
         }
         sqlite3_finalize(statement);
     }
     if(count > 0)
     {
         NSString *sqlQuery = [NSString stringWithFormat:@"UPDATE Rating SET Rating = '%f' WHERE Datum LIKE \"%@\"  AND userID LIKE '%@';",  rating, datum, userID];
         const char *sql = [sqlQuery UTF8String];
         sql = [sqlQuery UTF8String];
         if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
         {
             sqlite3_step(statement);
             sqlite3_finalize(statement);
         }
     }
     else
     {
         sqlQuery = [NSString stringWithFormat:@"INSERT INTO Rating(Datum, Rating, userID ) VALUES (\"%@\",%f, \"%@\");",datum, rating, userID];
         sql = [sqlQuery UTF8String];
         if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
         {
             sqlite3_step(statement);
             sqlite3_finalize(statement);
         }
     }
}

- (float)readRatingForDatum:(NSString *)datum andUser:(NSString*)userID
{
    [self checkColumnExists];

    float rating = 0.0;
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * FROM Rating WHERE Datum = '%@' ", datum];
    const char *sql = [sqlQuery UTF8String];
    if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            rating   = sqlite3_column_double(statement, 2);
            
        }
        sqlite3_finalize(statement);
    }
    return rating;

}

- (int)countRating
{
    int count = 0;
    
    const char *sql = "select count(*) from Rating";
    if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            count =  sqlite3_column_int(statement, 0);
            if(count > 0)
            {
                return count;
            }
        }
        sqlite3_finalize(statement);
    }

    return count;
}

- (NSMutableArray *) readAlleRatingForUser:(NSString*)userID
{
    float min = 9999.0;
    float max = -1.0;
    
    NSMutableArray *alleRating = [NSMutableArray arrayWithCapacity:20];
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * FROM Rating ORDER BY Datum ASC ;"];
    const char *sql = [sqlQuery UTF8String];
    if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *datum = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            if(datum.length != 10)
                continue;
            float rating    = sqlite3_column_double(statement, 2);
            if(rating > max)
                max = rating;
            if(rating < min)
                min = rating;
            NSDictionary *ratingDict = @{
                                          @"datum"   : datum,
                                          @"min"     : [NSNumber numberWithDouble: min],
                                          @"max"     : [NSNumber numberWithDouble: max],
                                          @"rating"  : [NSNumber numberWithDouble: rating]
                                         };
                [alleRating addObject:ratingDict];
        }
        sqlite3_finalize(statement);
    }
    

    return alleRating;
}

- (NSMutableArray *) readAlleRatingForUserAufgefuellt:(NSString*)userID
{
    NSString *datum = @"2019-01-01";
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * FROM Rating ORDER BY Datum ASC LIMIT 1;"];
    const char *sql = [sqlQuery UTF8String];
    if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            datum = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
        }
        sqlite3_finalize(statement);
    }
    while(datum.length != 10)
    {
        NSString *sqlQuery = [NSString stringWithFormat:@"DELETE FROM Rating WHERE Datum LIKE %@ ", datum];
        const char *sql = [sqlQuery UTF8String];
        if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
        sqlQuery = [NSString stringWithFormat:@"SELECT * FROM Rating ORDER BY Datum ASC LIMIT 1;"];
        sql = [sqlQuery UTF8String];
        if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                datum = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            }
            sqlite3_finalize(statement);
        }

    }
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSDate *startDate = [df dateFromString:datum];
    
    NSDate *endDate = [NSDate date];
    NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
    
    float ratingVorher = 0.0;
    float min = 9999.0;
    float max = -1.0;

    for (NSDate *date = startDate;                    // initialisation
         [date compare:endDate] == NSOrderedAscending; // compare
         date = [date dateByAddingTimeInterval:60*60*24])    // increment
    {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyy-MM-dd"];
        NSString *dateDB = [format stringFromDate:date];

        NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERID"];

        float rating = [self readRatingForDatum:dateDB andUser:userID];
        if (rating < 1.0)
            rating = ratingVorher;
        else
            ratingVorher = rating;
        
//        XLog(@"%3.1f %3.1f", rating, ratingVorher);
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
