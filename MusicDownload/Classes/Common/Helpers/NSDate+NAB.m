//
//  NSDate+NAB.m
//  Manhattan
//
//  Created by Khoa Nguyen Thanh on 1/30/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import "NSDate+NAB.h"
#define NABIntervalLocalize(key, defaultValue) NSLocalizedStringWithDefaultValue(key, tableName, bundle, defaultValue, nil)

@implementation NSDate(NAB)


#pragma mark - String

- (NSString *)stringWithDateFormat:(NSString *)dateFormatString {
    
    // Date formats
    // yyyy     year
    // MM       month
    // dd       day
    // HH       hour
    // mm       minute
    // ss       second
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormatString;
    
    return [dateFormatter stringFromDate:self];
}

+ (NSString *)stringForTimeInterval:(NSTimeInterval)interval includeSeconds:(BOOL)includeSeconds {
    NSTimeInterval intervalInSeconds = fabs(interval);
    double intervalInMinutes = round(intervalInSeconds/60.0);
    
    NSString *tableName = nil;
    NSBundle *bundle = [NSBundle mainBundle];
    
    if (intervalInMinutes >= 0 && intervalInMinutes <= 1) {
        if (!includeSeconds) return intervalInMinutes <= 0 ? NABIntervalLocalize(@"LessThanAMinute", @"few sec ago") : NABIntervalLocalize(@"1Minute", @"a min ago");
        if (intervalInSeconds >= 0 && intervalInSeconds < 5) return [NSString stringWithFormat:NABIntervalLocalize(@"LessThanXSeconds", @"%d sec ago"), 5];
        else if (intervalInSeconds >= 5 && intervalInSeconds < 10) return [NSString stringWithFormat:NABIntervalLocalize(@"LessThanXSeconds", @"%d sec ago"), 10];
        else if (intervalInSeconds >= 10 && intervalInSeconds < 20) return [NSString stringWithFormat:NABIntervalLocalize(@"LessThanXSeconds", @"%d sec ago"), 20];
        else if (intervalInSeconds >= 20 && intervalInSeconds < 40) return NABIntervalLocalize(@"HalfMinute", @"a min ago");
        else if (intervalInSeconds >= 40 && intervalInSeconds < 60) return NABIntervalLocalize(@"LessThanAMinute", @"a min ago");
        else return NABIntervalLocalize(@"1Minute", @"a min ago");
    }
    else if (intervalInMinutes >= 2 && intervalInMinutes <= 44) return [NSString stringWithFormat:NABIntervalLocalize(@"XMinutes", @"%.0f mins ago"), intervalInMinutes];
    else if (intervalInMinutes >= 45 && intervalInMinutes <= 89) return NABIntervalLocalize(@"About1Hour", @"1 hr ago");
    else if (intervalInMinutes >= 90 && intervalInMinutes <= 1439) return [NSString stringWithFormat:NABIntervalLocalize(@"AboutXHours", @"%.0f hrs ago"), round(intervalInMinutes/60.0)];
    else if (intervalInMinutes >= 1440 && intervalInMinutes <= 2879) return NABIntervalLocalize(@"1Day", @"1 day ago");
    else if (intervalInMinutes >= 2880 && intervalInMinutes <= 43199) return [NSString stringWithFormat:NABIntervalLocalize(@"XDays", @"%.0f days ago"), round(intervalInMinutes/1440.0)];
    else if (intervalInMinutes >= 43200 && intervalInMinutes <= 86399) return NABIntervalLocalize(@"About1Month", @"1 mth ago");
    else if (intervalInMinutes >= 86400 && intervalInMinutes <= 525599) return [NSString stringWithFormat:NABIntervalLocalize(@"XMonths", @"%.0f mths ago"), round(intervalInMinutes/43200.0)];
    else if (intervalInMinutes >= 525600 && intervalInMinutes <= 1051199) return NABIntervalLocalize(@"About1Year", @"1 yr ago");
    else
        return [NSString stringWithFormat:NABIntervalLocalize(@"OverXYears", @"%.0f yrs ago"), floor(intervalInMinutes/525600.0)];    

}

@end
