//
//  PushNotificationViewController.m
//  DemoApp
//
//  Created by Pavel pavel.popov@raxeltelematics.com on 03.06.19.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "PushNotificationViewController.h"
#import "AppDelegate.h"
#import "Helpers.h"

@interface PushNotificationViewController ()

@end

@implementation PushNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.pushNotificationView = [[PushNotificationView alloc] initWithFrame:CGRectMake(8, -8-74, self.view.frame.size.width-8*2, 74)];
    [self.view addSubview:self.pushNotificationView];

    UITapGestureRecognizer *cTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showUpdatedContactsTabBar)];
    cTapGesture.numberOfTapsRequired = 1;
    [self.pushNotificationView addGestureRecognizer:cTapGesture];
}

- (void)presentPushNotificationView:(void(^)(void))completion
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options: 0
                         animations: ^{
                             if (IS_IPHONE_X || IS_IPHONE_12_PRO || IS_IPHONE_XS_MAX || IS_IPHONE_12_PROMAX) {
                                 weakSelf.pushNotificationView.frame = CGRectMake(8, 36, self.view.frame.size.width-8*2, 74);
                             } else {
                                 weakSelf.pushNotificationView.frame = CGRectMake(8, 8, self.view.frame.size.width-8*2, 74);
                             }
                         }
                         completion: ^(BOOL finished) {
                             
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                 
                                 [UIView animateWithDuration:0.5
                                                       delay:0
                                                     options: 0
                                                  animations: ^{
                                                      
                                                      weakSelf.pushNotificationView.frame = CGRectMake(8, -8-74, weakSelf.view.frame.size.width-8*2, 74);
                                                      
                                                  }
                                                  completion: ^(BOOL finished) {
                                                      completion();
                                                  }];
                             });
                         }];
    });
}

- (void)showUpdatedContactsTabBar {
    UITabBarController *tb = (UITabBarController *)[AppDelegate appDelegate].window.rootViewController;
    [tb setSelectedIndex:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
