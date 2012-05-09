//
//  NSDate+NAB.h
//  Manhattan
//
//  Created by Khoa Nguyen Thanh on 1/30/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

@interface NSDate(NAB)

// String
- (NSString *)stringWithDateFormat:(NSString *)dateFormatString;
+ (NSString *)stringForTimeInterval:(NSTimeInterval)interval includeSeconds:(BOOL)includeSeconds;

@end
