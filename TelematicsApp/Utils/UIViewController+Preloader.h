//
//  UIViewController+Preloader.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 09.01.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

static const float kShiftAnimationDuration = 0.25;

@interface UIViewController (Preloader)
@property(nonatomic, strong) UIView* preloader;
@property(nonatomic, strong) UIActivityIndicatorView* activity;

@property(nonatomic, assign) BOOL kbIsShown;
@property(nonatomic, assign) BOOL dontHideKb;

@property(nonatomic, assign) int shiftHeight;

- (void)showPreloader;
- (void)hidePreloader;

- (void)registerForKeyboardNotifications;

- (void)updatePosition;

@end
