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
@class Rating;
@class BoardElements;

@interface MatchTools : NSObject

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Rating *rating;
@property (strong, readwrite, retain, atomic) BoardElements *boardElements;

-(NSMutableDictionary *)drawBoard:(int)schema boardInfo:(NSMutableDictionary *)boardDict;
-(NSMutableDictionary *)drawActionView:(NSMutableDictionary *)boardDict bordView:(UIView *)boardView;

- (int) analyzeAction:(NSMutableDictionary *)actionDict isChat:(BOOL) isChat isReview:(BOOL) isReview;

@end

NS_ASSUME_NONNULL_END
