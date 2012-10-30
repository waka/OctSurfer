//
//  CCDateTime.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "CCDateTime.h"


@implementation CCDateTime

#ifndef DateTimeLocalizedStrings
#define DateTimeLocalizedStrings(key) \
    NSLocalizedStringFromTable(key, @"NSDateTimeAgo", nil)
#endif

/**
 * Create datetime expression like twitter
 */
+ (NSString *) prettyPrint: (NSDate *)dt
{
    NSDate *now = [NSDate date];
    double deltaSeconds = fabs([dt timeIntervalSinceDate: now]);
    double deltaMinutes = deltaSeconds / 60.0f;
    
    NSString *result;
    if (deltaSeconds < 5) {
        result = DateTimeLocalizedStrings(@"Just now");
    } else if (deltaSeconds < 60) {
        result = [NSString stringWithFormat: DateTimeLocalizedStrings(@"%d seconds ago"), (int)deltaSeconds];
    } else if (deltaSeconds < 120) {
        result = DateTimeLocalizedStrings(@"A minute ago");
    } else if (deltaMinutes < 60) {
        result = [NSString stringWithFormat: DateTimeLocalizedStrings(@"%d minutes ago"), (int)deltaMinutes];
    } else if (deltaMinutes < 120) {
        result = DateTimeLocalizedStrings(@"An hour ago");
    } else if (deltaMinutes < (24 * 60)) {
        result = [NSString stringWithFormat: DateTimeLocalizedStrings(@"%d hours ago"),
                  (int)floor(deltaMinutes / 60)];
    } else if (deltaMinutes < (24 * 60 * 2)) {
        result = DateTimeLocalizedStrings(@"Yesterday");
    } else if (deltaMinutes < (24 * 60 * 7)) {
        result = [NSString stringWithFormat: DateTimeLocalizedStrings(@"%d days ago"),
                  (int)floor(deltaMinutes / (60 * 24))];
    } else if (deltaMinutes < (24 * 60 * 14)) {
        result = DateTimeLocalizedStrings(@"Last week");
    } else if (deltaMinutes < (24 * 60 * 31)) {
        result = [NSString stringWithFormat: DateTimeLocalizedStrings(@"%d weeks ago"),
                  (int)floor(deltaMinutes / (60 * 24 * 7))];
    } else if (deltaMinutes < (24 * 60 * 61)) {
        result = DateTimeLocalizedStrings(@"Last month");
    } else if (deltaMinutes < (24 * 60 * 365.25)) {
        result = [NSString stringWithFormat: DateTimeLocalizedStrings(@"%d months ago"),
                  (int)floor(deltaMinutes / (60 * 24 * 30))];
    } else if (deltaMinutes < (24 * 60 * 731)) {
        result = DateTimeLocalizedStrings(@"Last year");
    } else {
        result = [NSString stringWithFormat: DateTimeLocalizedStrings(@"%d years ago"),
                  (int)floor(deltaMinutes / (60 * 24 * 365))];
    }
    return result;
}

+ (NSDate *) dateFromString: (NSString *)dateStr
{
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    }
    return [formatter dateFromString: dateStr];
}

@end
