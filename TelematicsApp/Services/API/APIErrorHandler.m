//
//  APIErrorHandler.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.01.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "APIErrorHandler.h"
#import <RMessage/RMessage.h>
#import "BaseViewController.h"
#import "RootResponse.h"

@implementation APIErrorHandler

//ERROR VIEW FROM TOP
- (void)handleError:(NSError *)error response:(id)response {
    if ([response isKindOfClass:[RootResponse class]]) {
        
        [RMessage showNotificationInViewController:self.viewController.navigationController
                                             title:localizeString(@"error_title")
                                          subtitle:[NSString stringWithFormat:@"%@", ((RootResponse*)response).Errors.Message]
                                         iconImage:nil
                                              type:RMessageTypeError
                                    customTypeName:nil
                                          duration:RMessageDurationAutomatic
                                          callback:nil
                                       buttonTitle:nil
                                    buttonCallback:nil
                                        atPosition:RMessagePositionNavBarOverlay
                              canBeDismissedByUser:YES];
    
    } else {
        
        [RMessage showNotificationInViewController:self.viewController.navigationController
                                             title:localizeString(@"error_title")
                                          subtitle:[NSString stringWithFormat:@"%@ %@", error.localizedDescription, (response ? response : @"")]
                                         iconImage:nil
                                              type:RMessageTypeError
                                    customTypeName:nil
                                          duration:RMessageDurationAutomatic
                                          callback:nil
                                       buttonTitle:nil
                                    buttonCallback:nil
                                        atPosition:RMessagePositionNavBarOverlay
                              canBeDismissedByUser:YES];
    }
}

- (void)showErrorMessages:(NSArray<NSString *>*)errors {
    
    [RMessage showNotificationInViewController:self.viewController.navigationController
                                         title:localizeString(@"error_title")
                                      subtitle:[errors componentsJoinedByString:@"\n"]
                                     iconImage:nil
                                          type:RMessageTypeError
                                customTypeName:nil
                                      duration:RMessageDurationAutomatic
                                      callback:nil
                                   buttonTitle:nil
                                buttonCallback:nil
                                    atPosition:RMessagePositionNavBarOverlay
                          canBeDismissedByUser:YES];
}

- (void)handleSuccess:(RootResponse*)response {
    if ([response isKindOfClass:[ResponseObject class]]) {
        
        [RMessage showNotificationInViewController:(UIViewController*)self.viewController
                                             title:response.Title
                                          subtitle:nil
                                         iconImage:nil
                                              type:RMessageTypeSuccess
                                    customTypeName:nil
                                          duration:RMessageDurationAutomatic
                                          callback:nil
                                       buttonTitle:nil
                                    buttonCallback:nil
                                        atPosition:RMessagePositionNavBarOverlay
                              canBeDismissedByUser:YES];
        
    } else {
        
        [RMessage showNotificationInViewController:(UIViewController*)self.viewController
                                             title:[NSString stringWithFormat:@"%@", response]
                                          subtitle:nil
                                         iconImage:nil
                                              type:RMessageTypeSuccess
                                    customTypeName:nil
                                          duration:RMessageDurationAutomatic
                                          callback:nil
                                       buttonTitle:nil
                                    buttonCallback:nil
                                        atPosition:RMessagePositionNavBarOverlay
                              canBeDismissedByUser:YES];
    }
}

- (void)showErrorNow:(NSString*)message {
    
    [RMessage showNotificationInViewController:(UIViewController*)self.viewController
                                         title:localizeString(@"error_title")
                                      subtitle:[NSString stringWithFormat:@"%@", message]
                                     iconImage:nil
                                          type:RMessageTypeError
                                customTypeName:nil
                                      duration:RMessageDurationAutomatic
                                      callback:nil
                                   buttonTitle:nil
                                buttonCallback:nil
                                    atPosition:RMessagePositionNavBarOverlay
                          canBeDismissedByUser:YES];
}

- (void)showSuccessNow:(NSString*)message {
    
    UIWindow *main = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [RMessage showNotificationInViewController:main.rootViewController
                                         title:localizeString(@"Success")
                                      subtitle:[NSString stringWithFormat:@"%@", message]
                                     iconImage:nil
                                          type:RMessageTypeSuccess
                                customTypeName:nil
                                      duration:RMessageDurationAutomatic
                                      callback:nil
                                   buttonTitle:nil
                                buttonCallback:nil
                                    atPosition:RMessagePositionNavBarOverlay
                          canBeDismissedByUser:YES];
}

- (void)dismissActiveNotifNow {
    [RMessage dismissActiveNotification];
}

@end
