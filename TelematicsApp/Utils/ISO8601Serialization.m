//
//  ISO8601Serialization.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 07.03.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ISO8601Serialization.h"

@implementation ISO8601Serialization

+ (NSDateComponents * __nullable)dateComponentsForString:(NSString * __nonnull)string {
	NSScanner *scanner = [[NSScanner alloc] initWithString:string];
	scanner.charactersToBeSkipped = nil;

	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];

	NSInteger year;
	if (![scanner scanInteger:&year]) {
		return nil;
	}
	dateComponents.year = year;

	if (![scanner scanString:@"-" intoString:nil]) {
		return dateComponents;
	}

	NSInteger month;
	if (![scanner scanInteger:&month]) {
		return dateComponents;
	}
	dateComponents.month = month;

	if (![scanner scanString:@"-" intoString:nil]) {
		return dateComponents;
	}

	NSInteger day;
	if (![scanner scanInteger:&day]) {
		return dateComponents;
	}
	dateComponents.day = day;

	if (![scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"T "] intoString:nil]) {
		return dateComponents;
	}

	NSInteger hour;
	if (![scanner scanInteger:&hour]) {
		return dateComponents;
	}
	dateComponents.hour = hour;

	if (![scanner scanString:@":" intoString:nil]) {
		return dateComponents;
	}

	NSInteger minute;
	if (![scanner scanInteger:&minute]) {
		return dateComponents;
	}
	dateComponents.minute = minute;

	NSUInteger scannerLocation = scanner.scanLocation;
	if ([scanner scanString:@":" intoString:nil]) {
		NSInteger second;
		if (![scanner scanInteger:&second]) {
			return dateComponents;
		}
		dateComponents.second = second;
	} else {
		scanner.scanLocation = scannerLocation;
	}

	scannerLocation = scanner.scanLocation;
	[scanner scanUpToString:@"Z" intoString:nil];
	if ([scanner scanString:@"Z" intoString:nil]) {
		dateComponents.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
		return dateComponents;
	}

	scanner.scanLocation = scannerLocation;

	NSCharacterSet *signs = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
	[scanner scanUpToCharactersFromSet:signs intoString:nil];
	NSString *sign;
	if (![scanner scanCharactersFromSet:signs intoString:&sign]) {
		return dateComponents;
	}

	NSInteger timeZoneOffset = 0;
	NSInteger timeZoneOffsetHour = 0;
	NSInteger timeZoneOffsetMinute = 0;
	if (![scanner scanInteger:&timeZoneOffsetHour]) {
		return dateComponents;
	}

	BOOL colonExists = [scanner scanString:@":" intoString:nil];
	if (!colonExists && timeZoneOffsetHour > 14) {
		timeZoneOffsetMinute = timeZoneOffsetHour % 100;
		timeZoneOffsetHour = floor(timeZoneOffsetHour / 100);
	} else {
		[scanner scanInteger:&timeZoneOffsetMinute];
	}

	timeZoneOffset = (timeZoneOffsetHour * 60 * 60) + (timeZoneOffsetMinute * 60);
	dateComponents.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:timeZoneOffset * ([sign isEqualToString:@"-"] ? -1 : 1)];

	return dateComponents;
}


+ (NSString * __nullable)stringForDateComponents:(NSDateComponents * __nonnull)components {
	NSString *string = @"";
	BOOL hasDate = components.year != NSDateComponentUndefined || components.month != NSDateComponentUndefined || components.day != NSDateComponentUndefined;
	BOOL hasTime = components.hour != NSDateComponentUndefined || components.minute != NSDateComponentUndefined || components.second != NSDateComponentUndefined || components.timeZone;
	if (!hasDate && !hasTime) {
		return nil;
	}
	if (hasDate) {
		string = [string stringByAppendingFormat:@"%04li-%02i-%02i", (long)components.year,
		                                                              (int)components.month,
		                                                              (int)components.day];
	}
	if (hasTime) {
		string = [string stringByAppendingFormat:@"%@%02i:%02i:%02i", hasDate ? @"T" : @"",
		                                                              (int)components.hour,
		                                                              (int)components.minute,
		                                                              (int)components.second];
	}

	NSTimeZone *timeZone = components.timeZone;
	if (!timeZone) {
		return string;
	}

	if (timeZone.secondsFromGMT != 0) {
		NSInteger hoursOffset = timeZone.secondsFromGMT / 3600;

		NSUInteger secondsOffset = 0;

		NSString *sign = (hoursOffset >= 0) ? @"+" : @"-";
		return [string stringByAppendingFormat:@"%@%02i:%02i", sign, abs((int)hoursOffset), (int)secondsOffset];
	}

	return [string stringByAppendingString:@"Z"];
}

@end
