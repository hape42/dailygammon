//
//  Match.h
//  DailyGammon
//
//  Created by Peter on 16.12.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Tools;
@class TextTools;

NS_ASSUME_NONNULL_BEGIN

@interface Match : UIViewController

@property (strong, readwrite, retain, atomic) Tools *tools;
@property (strong, readwrite, retain, atomic) TextTools *textTools;

- (void)readMatch:(NSString *)matchLink reviewMatch:(BOOL)isReview ;

@property (readwrite, assign, atomic) BOOL noBoard;

@end

NS_ASSUME_NONNULL_END
