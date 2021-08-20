//
//  NSDate+UI.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 19.01.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import Foundation;

@interface NSDate (UI)

- (NSString*)dateString;
- (NSString*)timeString;
- (NSString*)yearString;
- (NSString*)dateTimeStringShort;
- (NSString*)dateStringShortYear;
- (NSString*)dateStringShortYearInverse;
- (NSString*)dateTimeStringSpecial;
- (NSString*)dateTimeStringShortDdMm24;
- (NSString*)dateTimeStringShortMmDd24;
- (NSString*)dateTimeStringShortDdMmAmPm;
- (NSString*)dateTimeStringShortMmDdAmPm;
- (NSString*)dateTimeStringShortSimple;
- (NSString*)dateStringFullMonth;
- (NSString*)tripDateTimeString;
- (NSString*)postDateTimeString;
- (NSString*)dateTimePosix;
- (NSString*)dateTimePosixFull;
- (NSString*)dayDate;
- (NSString*)dayDateShort;
+ (NSString*)remainingTimeStringForTimeInterval:(NSTimeInterval)seconds;

@end
