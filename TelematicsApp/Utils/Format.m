//
//  Format.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 09.01.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "Format.h"


@interface Format () {
    
}

#pragma mark - Utils

+ (NSDateFormatter *)withFormat:(NSString *)format;

@end


@implementation Format

static NSDateFormatter *df = nil;


#pragma mark - Utils

+ (NSDateFormatter *)withFormat:(NSString *)format {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [NSDateFormatter new];
    });
    [df setDateFormat:format];
    
    return df;
}


#pragma mark - Dates

+ (NSDate *)endOfToday {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMonth | NSCalendarUnitSecond) fromDate:now];
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    NSDate *endDate = [calendar dateFromComponents:components];
    return endDate;
}

+ (NSCalendar *)calendar {
    return [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
}

+ (NSDateFormatter *)dateFormatterShort {
    return [self.class withFormat:@"YYYY-MM-dd"];
}

+ (NSDateFormatter *)dateFormatterFull {
    return [self.class withFormat:@"dd-MM-YYYY HH:mm"];
}


+ (NSDateFormatter *)dateFormatterISO8601 {
    return [self.class withFormat:@"YYYY-MM-dd'T'HH:mm:ssZ"];
}

+ (NSDateFormatter *)dateFormatterDayMonth {
    return [self.class withFormat:@"dd MMM"];
}

+ (NSDateFormatter *)dateFormatterMonthYear {
    return [self.class withFormat:@"LLL YYYY"];
}

+ (NSDateFormatter *)dateFormatterYear {
    return [self.class withFormat:@"YYYY"];
}

+ (NSDateFormatter *)dateFormatterDurationHoursMinutes {
    return [self.class withFormat:localizeString(@"format.durationHoursMinutes.long")];
}

+ (NSDateFormatter *)dateFormatterDurationHoursMinutesShort {
    return [self.class withFormat:localizeString(@"format.durationHoursMinutes.short")];
}

+ (NSDateFormatter *)dateFormatterTimeHoursMinutes {
    return [self.class withFormat:@"HH:mm"];
}

+ (NSDateFormatter *)dateFormatterTimeHoursMinutesSeconds {
    return [self.class withFormat:@"HH:mm:ss"];
}

+ (NSDateFormatter *)dateFormatterpostDateTime {
    return [self.class withFormat:@"d/MM/yyyy, HH:mm"];
}


#pragma mark - Units

+ (NSString *)formatKilometersWithFractionDigits:(NSUInteger)digitsCount value:(double)value {
    NSString *format = (digitsCount == 0) ? localizeString(@"format.km.integer") : localizeString(@"format.km.fractional");
    
    return [NSString stringWithFormat:format, value];
}

+ (NSString *)phoneNumberFromString:(NSString *)string {
    NSCharacterSet *chars = [NSCharacterSet characterSetWithCharactersInString:@"-() "];
    
    return [[string componentsSeparatedByCharactersInSet:chars] componentsJoinedByString:@""];
}

+ (NSString *)prettyPriceStringFromNumber:(NSNumber *)number {
    NSNumberFormatter *nf = [NSNumberFormatter new];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setCurrencySymbol:@""];
    [nf setMaximumFractionDigits:0];
    
    return [nf stringFromNumber:number];
}


#pragma mark - Language

+ (BOOL)isRussianLanguage {
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language hasPrefix:@"ru"]) {
        return YES;
    }
    return NO;
}

@end

// localization method
NSString *localizeString(NSString *tag) {
    return NSLocalizedString(tag, tag);
}
