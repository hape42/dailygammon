//
//  DateValueFormatter.m
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//


#import "DateValueFormatter.h"

@interface DateValueFormatter ()
{
    NSDateFormatter *_dateFormatter;
}
@end

@implementation DateValueFormatter

- (id)init
{
    self = [super init];
    if (self)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
  //      _dateFormatter.dateFormat = @"dd MMM HH:mm";
        _dateFormatter.dateFormat = @"MM yy";
    }
    return self;
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis
{
//    NSDateFormatter *format = [[NSDateFormatter alloc] init];
//    format.dateFormat = @"dd";
//
//    NSString *day = [format stringFromDate:[NSDate dateWithTimeIntervalSince1970:value]];
//    if([day intValue] != 1)
//        return @"";
    return [_dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:value]];
}

@end
