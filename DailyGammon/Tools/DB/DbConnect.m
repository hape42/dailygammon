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

-(void) saveDistance:(NSString *) timeStamp
            withClub:(int)clubKey
         vonLatitude:(CLLocationDegrees)latitudeVon vonLongitude:(CLLocationDegrees)LongitudeVon
         bisLatitude:(CLLocationDegrees)latitudeBis bisLongitude:(CLLocationDegrees)LongitudeBis
        withdistance:(float)distance
{
    char* errormsg;
    //create table if not exists
    sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS 'distance' ('ID' INTEGER PRIMARY KEY AUTOINCREMENT, 'ClubKey' INTEGER, 'LatitudeVon' REAL, 'LongitudeVon' REAL, 'LatitudeBis' REAL, 'LongitudeBis' REAL, 'DatumEnde' TEXT, 'Distance' REAL)", NULL, NULL, &errormsg);
    
    NSString *sqlQuery = [NSString stringWithFormat:@"INSERT INTO distance(ClubKey, LatitudeVon, LongitudeVon, LatitudeBis, LongitudeBis, DatumEnde, Distance ) VALUES (%d, %f, %f, %f, %f, %@,%f);", clubKey, latitudeVon, LongitudeVon, latitudeBis, LongitudeBis, timeStamp, distance];    
    const char *sql = [sqlQuery UTF8String];
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
    {
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
}

- (NSMutableArray *) readDistanceForKey:(int)key
{
    NSMutableArray *allDistanceArray = [NSMutableArray arrayWithCapacity:20];
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * FROM distance WHERE ClubKey = '%d' ORDER BY DatumEnde DESC;", key];
    const char *sql = [sqlQuery UTF8String];
    if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            int idDistance      = sqlite3_column_int(statement, 0);
            int clubKey         = sqlite3_column_int(statement, 1);
            float latitudeVon   = sqlite3_column_double(statement, 2);
            float longitudeVon  = sqlite3_column_double(statement, 3);
            float latitudeBis   = sqlite3_column_double(statement, 4);
            float longitudeBis  = sqlite3_column_double(statement, 5);
            NSString *datumEnde = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
            float distance      = sqlite3_column_double(statement, 7);
            
            NSDictionary *readDict = @{
                                       @"ClubKey"      : [NSNumber numberWithInt: clubKey],
                                       @"LatitudeVon"  : [NSNumber numberWithDouble: latitudeVon],
                                       @"LongitudeVon" : [NSNumber numberWithDouble: longitudeVon],
                                       @"LatitudeBis"  : [NSNumber numberWithDouble: latitudeBis],
                                       @"LongitudeBis" : [NSNumber numberWithDouble: longitudeBis],
                                       @"DatumEnde"    : datumEnde,
                                       @"Distance"     : [NSNumber numberWithDouble: distance],
                                       @"ID"           : [NSNumber numberWithInt: idDistance]
                                       
                                       };
            
            [allDistanceArray addObject:readDict];
            
        }
        sqlite3_finalize(statement);
    }
    return allDistanceArray;
}

- (void) deleteDistance:(int)ID
{
    
    NSString *sqlQuery = [NSString stringWithFormat:@"DELETE FROM Distance WHERE ID LIKE %d ", ID];
    const char *sql = [sqlQuery UTF8String];
    if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
    {
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
}

- (void) deleteAllDistance
{
    
    NSString *sqlQuery = [NSString stringWithFormat:@"DELETE FROM Distance "];
    const char *sql = [sqlQuery UTF8String];
    if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
    {
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
}

@end
