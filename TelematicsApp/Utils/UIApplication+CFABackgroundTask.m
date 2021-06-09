//
//  UIApplication+CFABackgroundTask.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 05.06.19.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "UIApplication+CFABackgroundTask.h"

@interface CFABackgroundTask ()

@property (nonatomic, readwrite) NSString *identifier;
@property (nonatomic, readwrite) UIBackgroundTaskIdentifier bgTask;

@end

@implementation CFABackgroundTask

- (instancetype)initWithExpiration:(void(^)(void))expiration
{
    self = [super init];
    if (self)
    {
        self.identifier = [[NSUUID UUID] UUIDString];
        
        __weak typeof(self) weakSelf = self;
        
        self.bgTask = [[UIApplication sharedApplication]
                  beginBackgroundTaskWithName:self.identifier
                  expirationHandler:^{
                      
#ifdef DEBUG
                      NSLog(@"Background task expired: %@", weakSelf);
#endif
                      
                      if (expiration != nil)
                      {
                          expiration();
                      }
                      
                      if (weakSelf.bgTask != UIBackgroundTaskInvalid)
                      {
                          [[UIApplication sharedApplication] endBackgroundTask:weakSelf.bgTask];
                          weakSelf.bgTask = UIBackgroundTaskInvalid;
                      }
                  }];
    }
    return self;
}

- (void)dealloc
{
    [self invalidate];
}

- (void)invalidate
{
    if (self.bgTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
}

- (BOOL)isActive
{
    return self.bgTask != UIBackgroundTaskInvalid;
}

@end


#pragma mark - Category

@implementation UIApplication (CFABackgroundTask)

+ (CFABackgroundTask *)cfa_backgroundTask
{
    return [self cfa_backgroundTaskWithExpiration:nil];
}

+ (CFABackgroundTask *)cfa_backgroundTaskWithExpiration:(void (^)(void))expiration
{
    return [[CFABackgroundTask alloc] initWithExpiration:expiration];
}

@end
