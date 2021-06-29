//
//  ISO8601Serialization.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 07.03.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#if __has_feature(modules)
	@import Foundation;
#else
	#import <Foundation/Foundation.h>
#endif

@interface ISO8601Serialization : NSObject

#pragma mark - Reading
+ (NSDateComponents * __nullable)dateComponentsForString:(NSString * __nonnull)string;


#pragma mark - Writing
+ (NSString * __nullable)stringForDateComponents:(NSDateComponents * __nonnull)components;

@end