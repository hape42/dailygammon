//
//  NSDictionary+PercentEncodeURLQueryValue.h
//  DailyGammon
//
//  Created by Peter on 18.02.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (PercentEncodeURLQueryValue)
- (NSString *)percentEncodedString;
- (NSData *)percentEncodedData;
@end
