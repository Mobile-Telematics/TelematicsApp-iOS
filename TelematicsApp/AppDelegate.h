//
//  AppDelegate.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 09.06.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
@import UserNotifications;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIWindow *pushNotificationWindow;

+ (AppDelegate*)appDelegate;
- (void)updateRootController;
- (void)logoutOn401;
- (void)logoutOn419;

@end

