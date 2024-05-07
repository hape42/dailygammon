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
@class Tools;

@interface MatchTools : NSObject

@property (strong, readwrite, retain, atomic) Design *design;
@property (strong, readwrite, retain, atomic) Rating *rating;
@property (strong, readwrite, retain, atomic) Tools *tools;
@property (strong, readwrite, retain, atomic) BoardElements *boardElements;

-(NSMutableDictionary *)drawBoard:(int)schema boardInfo:(NSMutableDictionary *)boardDict boardView:(UIView *)boardView zoom:(float)zoomFactor isReview:(BOOL) isReview;
-(NSMutableDictionary *)drawActionView:(NSMutableDictionary *)boardDict bordView:(UIView *)boardView actionViewWidth:(float)actionViewWidth isPortrait:(BOOL)isPortrait maxHeight:(int)maxHeight;

- (int) analyzeAction:(NSMutableDictionary *)actionDict isChat:(BOOL) isChat isReview:(BOOL) isReview;

@end

NS_ASSUME_NONNULL_END
