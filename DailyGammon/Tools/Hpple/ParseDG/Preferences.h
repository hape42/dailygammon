//
//  Preferences.h
//  DailyGammon
//
//  Created by Peter on 10.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Preferences : NSObject

- (NSMutableArray *)readPreferences;
- (void)readNextMatchOrdering;
- (bool)isMiniBoard;

@end

NS_ASSUME_NONNULL_END
