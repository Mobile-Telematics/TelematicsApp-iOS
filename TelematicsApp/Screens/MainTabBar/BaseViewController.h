//
//  BaseViewController.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 12.01.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
#import "APIErrorHandler.h"
#import <RMessage/RMessage.h>
#import <GKImagePicker_robseward/GKImagePicker.h>
#import <SafariServices/SafariServices.h>

//BASE DEFAULT VIEWCONTROLLER FOR MANU CONTROLLERS HELPER
@interface BaseViewController: UIViewController <GKImagePickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSafariViewControllerDelegate>

@property (nonatomic, strong, nullable) IBOutlet UIScrollView* keyboardAvoidingScrollView;
@property (nonatomic, strong, nullable) APIErrorHandler* errorHandler;
@property (nonatomic, strong, nullable) GKImagePicker* imagePicker;
@property (assign, nonatomic) BOOL needDisplayGPSAlert;
@property (readonly, nonatomic) BOOL hidesBackgroundImage;

+ (NSString* __nonnull)storyboardIdentifier;
- (void)showMessageWithTitle:(NSString* __nullable)title subTitle:(NSString* __nullable)subTitle type:(RMessageType)type;
- (void)showImagePicker;
- (void)setViewsHidden:(BOOL)hidden;

@end
