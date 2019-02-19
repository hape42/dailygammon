//
//  NSDictionary+PercentEncodeURLQueryValue.m
//  DailyGammon
//
//  Created by Peter on 18.02.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import "NSDictionary+PercentEncodeURLQueryValue.h"
#import "NSCharacterSet+URLQueryValueAllowed.h"

@implementation NSDictionary (PercentEncodeURLQueryValue)

- (NSString *)percentEncodedString
{
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSCharacterSet *allowed = [NSCharacterSet URLQueryValueAllowedCharacterSet];
    
    for (NSString *key in self.allKeys) {
        NSString *encodedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:allowed];
        NSString *value = [[self objectForKey:key] description];
        NSString *encodedValue = [value stringByAddingPercentEncodingWithAllowedCharacters:allowed];
        [results addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue]];
    }
    return [results componentsJoinedByString:@"&"];
}

- (NSData *)percentEncodedData
{
    return [[self percentEncodedString] dataUsingEncoding:NSUTF8StringEncoding];
}
@end
