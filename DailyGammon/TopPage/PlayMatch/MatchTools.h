//
//  MatchTools.h
//  DailyGammon
//
//  Created by Peter Schneider on 13.12.22.
//  Copyright © 2022 Peter Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class Design;

@interface MatchTools : NSObject

@property (strong, readwrite, retain, atomic) Design *design;

-(NSMutableDictionary *)drawBoard:(int)schema boardInfo:(NSMutableDictionary *)boardDict;

@end

NS_ASSUME_NONNULL_END
