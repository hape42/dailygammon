//
//  TextTools.h
//  DailyGammon
//
//  Created by Peter Schneider on 15.04.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextTools : NSObject

#pragma mark - methods for outgoing texts


#pragma mark - methods for incoming texts


#pragma mark - general methods

- (NSString *)cleanChatString:(NSString *)chatString;

#pragma mark - only for internal tests

-(void)testingTools;

- (NSString *)encodeStringToHTML:(NSString *)string;
- (NSString *)convertStringToHTML:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
