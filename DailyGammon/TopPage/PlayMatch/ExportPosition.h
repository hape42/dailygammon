//
//  ExportPosition.h
//  DailyGammon
//
//  Created by Peter Schneider on 25.05.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExportPosition : NSObject

- (NSString *)makePositionsID;
- (NSString *)makeMatchID;

@end

NS_ASSUME_NONNULL_END
