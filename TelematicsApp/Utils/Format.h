//
//  Format.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 09.01.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#define USE_RUSSIAN_PHONE_FORMAT 0


@interface Format : NSObject {
    
}

#pragma mark - Dates

+ (NSDate *)endOfToday;
+ (NSCalendar *)calendar;
+ (NSDateFormatter *)dateFormatterShort;
+ (NSDateFormatter *)dateFormatterFull;
+ (NSDateFormatter *)dateFormatterISO8601;
+ (NSDateFormatter *)dateFormatterMonthYear;
+ (NSDateFormatter *)dateFormatterDayMonth;
+ (NSDateFormatter *)dateFormatterYear;
+ (NSDateFormatter *)dateFormatterDurationHoursMinutes;
+ (NSDateFormatter *)dateFormatterTimeHoursMinutes;
+ (NSDateFormatter *)dateFormatterDurationHoursMinutesShort;
+ (NSDateFormatter *)dateFormatterTimeHoursMinutesSeconds;
+ (NSDateFormatter *)dateFormatterpostDateTime;


#pragma mark - Units

+ (NSString *)formatKilometersWithFractionDigits:(NSUInteger)digitsCount value:(double)value;
+ (NSString *)phoneNumberFromString:(NSString *)string;
+ (NSString *)prettyPriceStringFromNumber:(NSNumber *)number;

#pragma mark - Language

+ (BOOL)isRussianLanguage;

@end

// localization method
NSString *localizeString(NSString *tag);
