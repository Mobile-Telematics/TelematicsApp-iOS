//
//  NSDate+ISO8601.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 07.03.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import Foundation;

@interface NSDate (ISO8601)


#pragma mark - Simple
+ (NSString * __nullable)dateFromISO8601:(NSDate *_Nonnull)date;
+ (NSDate * __nullable)dateWithISO8601String:(NSString * __nonnull)string;
- (NSString * __nullable)ISO8601String;


#pragma mark - Advanced
+ (NSDate * __nullable)dateWithISO8601String:(NSString * __nonnull)string timeZone:(inout NSTimeZone * __nonnull * __nullable)timeZone usingCalendar:(NSCalendar * __nullable)calendar;

- (NSString * __nullable)ISO8601StringWithTimeZone:(NSTimeZone * __nullable)timeZone usingCalendar:(NSCalendar * __nullable)calendar;

@end
