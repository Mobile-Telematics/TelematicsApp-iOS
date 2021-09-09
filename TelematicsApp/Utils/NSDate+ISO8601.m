//
//  NSDate+ISO8601.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 07.03.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "NSDate+ISO8601.h"
#import "ISO8601Serialization.h"

@implementation NSDate (ISO8601)

#pragma mark - Reading

+ (NSString * __nullable)dateFromISO8601:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSDate *now = date;
    NSString *iso8601String = [dateFormatter stringFromDate:now];
    
    return iso8601String;
}

+ (NSDate * __nullable)dateWithISO8601String:(NSString *)string {
	return [self dateWithISO8601String:string timeZone:nil usingCalendar:nil];
}


+ (NSDate * __nullable)dateWithISO8601String:(NSString * __nonnull)string timeZone:(inout NSTimeZone * __nonnull * __nullable)timeZone usingCalendar:(NSCalendar * __nullable)calendar {
	NSDateComponents *components = [ISO8601Serialization dateComponentsForString:string];
	if (components == nil) {
		return nil;
	}

	if (!calendar) {
		calendar = [NSCalendar currentCalendar];
	}

	NSTimeZone *UTCTimeZone = [NSTimeZone timeZoneWithName:@"UTC"];

	if (timeZone) {
		*timeZone = components.timeZone ? components.timeZone : UTCTimeZone;
	}
    
	calendar.timeZone = UTCTimeZone;

	return [calendar dateFromComponents:components];
}


#pragma mark - Writing

- (NSString * __nullable)ISO8601String {
	return [self ISO8601StringWithTimeZone:[NSTimeZone localTimeZone] usingCalendar:nil];
}


- (NSString * __nullable)ISO8601StringWithTimeZone:(NSTimeZone * __nullable)timeZone usingCalendar:(NSCalendar * __nullable)calendar {
	if (!calendar) {
		calendar = [NSCalendar currentCalendar];
	}

	if (timeZone) {
		calendar.timeZone = (NSTimeZone * __nonnull)timeZone;
	} else {
		calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	}

	NSCalendarUnit units = (NSCalendarUnit)(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour |
		NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitTimeZone);

	NSDateComponents *dateComponents = [calendar components:units fromDate:self];
	return [ISO8601Serialization stringForDateComponents:dateComponents];
}

@end
