//
//  Rating.h
//  DailyGammon
//
//  Created by Peter on 12.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Rating : NSObject

- (NSMutableDictionary *)readRatingForPlayer:(NSString *)userID andOpponent: (NSString *)opponentID;
- (float)readRatingForUser:(NSString *)userID;
- (void)writeRating;

@end

NS_ASSUME_NONNULL_END
