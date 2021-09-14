//
//  PushNotificationViewController.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.01.20.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
#import "PushNotificationView.h"

@interface PushNotificationViewController: UIViewController

@property(nonatomic,strong) PushNotificationView *pushNotificationView;

- (void)presentPushNotificationView:(void(^)(void))completion;

@end
