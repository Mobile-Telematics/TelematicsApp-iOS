//
//  TelematicsAppRegPopup.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.08.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

typedef void(^popUpHandler)(void);

@interface TelematicsAppRegPopup : UIView
{
    popUpHandler actionConfirm;
    popUpHandler actionCancel;
    
    UIView *baseView;
    UIImageView *imageView;
    UILabel *titleLabel;
    UILabel *messageLabel;
    UIButton *confirmBttn;
    UIButton *cancelBttn;
    NSInteger index;
    
    NSArray *images;
}
@property(nonatomic,strong) UIView *customView;
@property(nonatomic,assign) bool isDismissAble;
@property(nonatomic,strong) NSString *messageString;
@property(nonatomic,strong) NSString *titleString;


+ (instancetype)showMessage:(NSString*)message;
+ (instancetype)showMessage:(NSString*)message withTitle:(NSString*)title;
+ (instancetype)showProgress;
+ (void)stopProgress;

- (void)onConfirm:(popUpHandler)sender;
- (void)onConfirm:(popUpHandler)confirm onCancel:(popUpHandler)cancel;
- (void)withConfirm:(NSString*)titleConfirm onConfirm:(popUpHandler)sender;
- (void)withConfirm:(NSString*)titleConfirm onConfirm:(popUpHandler)confirm withCancel:(NSString*)titleCancel  onCancel:(popUpHandler)cancel;


@end
