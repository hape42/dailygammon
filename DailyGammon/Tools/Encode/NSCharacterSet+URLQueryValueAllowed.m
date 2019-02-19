//
//  NSCharacterSet+URLQueryValueAllowed.m
//  DailyGammon
//
//  Created by Peter on 18.02.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import "NSCharacterSet+URLQueryValueAllowed.h"

@implementation NSCharacterSet (URLQueryValueAllowed)

+ (NSCharacterSet *)URLQueryValueAllowedCharacterSet {
    static dispatch_once_t onceToken;
    static NSCharacterSet *queryValueAllowed;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *allowed = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        NSString *generalDelimitersToEncode = @":#[]@";   // does not include "?" or "/" due to RFC 3986 - Section 3.4
        NSString *subDelimitersToEncode = @"!$&'()*+,;=";
        
        [allowed removeCharactersInString:generalDelimitersToEncode];
        [allowed removeCharactersInString:subDelimitersToEncode];
        
        queryValueAllowed = [allowed copy];
    });
    return queryValueAllowed;
}

@end
