//
//  Match.h
//  DailyGammon
//
//  Created by Peter on 16.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Match : UIViewController

- (void)readMatch:(NSString *)matchLink reviewMatch:(BOOL)isReview inBoardDict:(NSMutableDictionary *)boardDict inActionDict:(NSMutableDictionary *)actionDict;

@property (readwrite, assign, atomic) BOOL noBoard;

@end

NS_ASSUME_NONNULL_END
