//
//  Rating.h
//  DailyGammon
//
//  Created by Peter on 12.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class RatingTools;

@interface Rating : NSObject

@property (strong, readwrite, retain, atomic) RatingTools *ratingTools;

- (NSMutableDictionary *)readRatingForPlayer:(NSString *)userID andOpponent: (NSString *)opponentID;
- (void)updateRating;

@end

NS_ASSUME_NONNULL_END
