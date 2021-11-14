//
//  RatingTools.h
//  DailyGammon
//
//  Created by Peter Schneider on 11.11.21.
//  Copyright © 2021 Peter Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RatingTools : NSObject

- (void)saveRating:(NSString *)datum
        withRating:(float)rating;


-(NSMutableArray *)readAll;
- (void)clearStore;

@end

NS_ASSUME_NONNULL_END
