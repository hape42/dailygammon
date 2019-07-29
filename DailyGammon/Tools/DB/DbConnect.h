//
//  DbConnect.h
//
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import <MapKit/MapKit.h>

@interface DbConnect : NSObject

- (void) openDb;
- (void) closeDb;

-(void) saveRating:(NSString *) datum
          withRating:(float)rating  forUser:(NSString*)userID;

- (float)readRatingForDatum:(NSString *)datum andUser:(NSString*)userID;

- (int)countRating;
- (NSMutableArray *) readAlleRatingForUser:(NSString*)userID;

- (NSMutableArray *) readAlleRatingForUserAufgefuellt:(NSString*)userID;

@end
