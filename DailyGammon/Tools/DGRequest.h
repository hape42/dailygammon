//
//  DGRequest.h
//  DailyGammon
//
//  Created by Peter Schneider on 18.02.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DGRequest : NSObject

typedef void (^DGRequestCompletionHandler)(BOOL success, NSError *error, NSString *result);

- (instancetype)initWithString:(NSString *)urlString completionHandler:(DGRequestCompletionHandler)completionHandler;
- (instancetype)initWithURL:(NSURL *)url completionHandler:(DGRequestCompletionHandler)completionHandler;

@end
