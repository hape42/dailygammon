//
//  Tools.h
//  DailyGammon
//
//  Created by Peter on 25.04.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//


#import <Foundation/Foundation.h>

@class Preferences;

@interface Tools: NSObject <NSURLSessionDelegate>

@property (strong, readwrite, retain, atomic) Preferences *preferences;

-(BOOL)hasConnectivity;
- (void)noInternet: (UIViewController *)vc;

-(void)matchCount;
- (void)readPlayers:(NSString *)event inDict:(NSMutableDictionary *)eventDict;
- (void)readNote:(NSString *)event inDict:(NSMutableDictionary *)note;

- (NSString *)cleanChatString:(NSString *)chatString;

- (void)removeAllSubviewsRecursively:(UIView *)view;

@end

