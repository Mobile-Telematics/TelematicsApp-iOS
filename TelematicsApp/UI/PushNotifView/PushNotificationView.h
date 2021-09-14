//
//  PushNotificationView.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.01.20.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PushNotificationView: UIView

- (void)setAppName:(NSString*)appName iconURLString:(NSString*)iconURLString message:(NSString*)message time:(NSString*)time;

@end
