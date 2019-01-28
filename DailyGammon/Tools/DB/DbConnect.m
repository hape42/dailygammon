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


-(void) saveRating:(NSString *) datum
            withRating:(float)rating
 {
     int count = 0;
     NSString *sqlQuery = [NSString stringWithFormat:@"SELECT COUNT (*) FROM Rating WHERE Datum LIKE '%@' ;", datum];
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
         NSString *sqlQuery = [NSString stringWithFormat:@"UPDATE Rating SET Rating = '%f' WHERE Datum LIKE \"%@\" ;",  rating, datum];
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
         sqlQuery = [NSString stringWithFormat:@"INSERT INTO Rating(Datum, Rating ) VALUES (\"%@\",%f);",datum, rating];
         sql = [sqlQuery UTF8String];
         if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
         {
             sqlite3_step(statement);
             sqlite3_finalize(statement);
         }
     }
}

- (float)readRatingForDatum:(NSString *)datum
{
    float rating = 0.0;
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * FROM Rating WHERE Datum = '%@';", datum];
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

@end
