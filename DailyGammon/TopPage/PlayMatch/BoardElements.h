//
//  BoardElements.h
//  DailyGammon
//
//  Created by Peter Schneider on 17.12.22.
//  Copyright © 2022 Peter Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BoardElements : NSObject

- (UIImage *)getPointForSchema:(int)schema name:(NSString *)img;

@end

NS_ASSUME_NONNULL_END
