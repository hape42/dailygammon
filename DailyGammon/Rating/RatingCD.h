//
//  RatingCD.h
//  DailyGammon
//
//  Created by Peter Schneider on 28.06.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ratings+CoreDataProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface RatingCD : NSObject

- (void) convertDB;
- (void) saveRating:(float)rating forDate:(NSString *)date forUser:(NSString *)userID;

- (Ratings *)bestRating;

@end

NS_ASSUME_NONNULL_END
