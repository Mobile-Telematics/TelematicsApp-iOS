//
//  PushNotificationViewController.h
//  DemoApp
//
//  Created by Pavel pavel.popov@raxeltelematics.com on 03.06.19.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
#import "PushNotificationView.h"

@interface PushNotificationViewController: UIViewController

@property(nonatomic,strong) PushNotificationView *pushNotificationView;

- (void)presentPushNotificationView:(void(^)(void))completion;

@end
