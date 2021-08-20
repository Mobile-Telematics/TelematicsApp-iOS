//
//  UIApplication+CFABackgroundTask.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 05.06.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CFABackgroundTask : NSObject

@property (nonatomic, readonly) NSString *identifier;

@property (nonatomic, readonly) BOOL isActive;

- (instancetype)init __attribute__((unavailable("Use the UIApplication category methods")));

- (void)invalidate;

@end


@interface UIApplication (CFABackgroundTask)

+ (CFABackgroundTask *)cfa_backgroundTask;

+ (CFABackgroundTask *)cfa_backgroundTaskWithExpiration:(void(^)(void))expiration;

@end
