//
//  NSCharacterSet+URLQueryValueAllowed.h
//  DailyGammon
//
//  Created by Peter on 18.02.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCharacterSet (URLQueryValueAllowed)

@property (class, readonly, copy) NSCharacterSet *URLQueryValueAllowedCharacterSet;

@end
