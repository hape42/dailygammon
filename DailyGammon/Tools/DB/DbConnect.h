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

-(void) saveDistance:(NSString *) timeStamp
            withClub:(int)clubKey
         vonLatitude:(CLLocationDegrees)latitudeVon vonLongitude:(CLLocationDegrees)LongitudeVon
         bisLatitude:(CLLocationDegrees)latitudeBis bisLongitude:(CLLocationDegrees)LongitudeBis
        withdistance:(float)distance;

- (NSMutableArray *) readDistanceForKey:(int)key;
- (void) deleteDistance:(int)ID;
- (void) deleteAllDistance;

@end
