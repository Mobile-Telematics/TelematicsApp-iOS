//
//  APIErrorHandler.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.01.19.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import Foundation;

@class UIViewController;
@class RootResponse;

@interface APIErrorHandler : NSObject

@property (nonatomic, weak) UIViewController* viewController;

- (void)handleError:(NSError*)error response:(id)response;
- (void)showErrorMessages:(NSArray<NSString *>*)errors;
- (void)handleSuccess:(RootResponse*)response;
- (void)showErrorNow:(NSString*)message;
- (void)showSuccessNow:(NSString*)message;
- (void)dismissActiveNotifNow;

@end
