//
//  NSString+Date.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 19.01.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import Foundation;

static NSString* const kDateFormatWithTimezone = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
static NSString* const kDateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
static NSString* const kDateFormatWithMilliseconds = @"yyyy-MM-dd HH:mm:ss.SSS";

@interface NSString (Date)

- (NSDate*)date;
- (NSDate*)dateWithTimezone;
+ (NSString*)stringFromDateWithTimezone:(NSDate*)date;
+ (NSString*)stringFromDate:(NSDate*)date;
+ (NSString*)currentDateString;

@end
