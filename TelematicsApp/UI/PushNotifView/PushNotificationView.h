//
//  PushNotificationView.h
//  DemoApp
//
//  Created by Pavel pavel.popov@raxeltelematics.com on 03.06.19.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PushNotificationView: UIView

- (void)setAppName:(NSString*)appName iconURLString:(NSString*)iconURLString message:(NSString*)message time:(NSString*)time;

@end
