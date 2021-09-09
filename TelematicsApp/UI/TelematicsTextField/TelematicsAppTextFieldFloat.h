//
//  TelematicsAppTextFieldFloat.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 25.01.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

@interface TelematicsAppTextFieldFloat : UITextField
{
    UIView *bottomLineView;
    BOOL showingError;
}

@property (nonatomic,strong) IBInspectable UIColor *lineColor;
@property (nonatomic,strong) IBInspectable UIColor *placeHolderColor;
@property (nonatomic,strong) IBInspectable UIColor *selectedPlaceHolderColor;
@property (nonatomic,strong) IBInspectable UIColor *selectedLineColor;
@property (nonatomic,strong) IBInspectable UIColor *errorTextColor;
@property (nonatomic,strong) IBInspectable UIColor *errorLineColor;
@property (nonatomic,strong) IBInspectable NSString  *errorText;

@property (assign) IBInspectable  BOOL disableShakeWithError;

@property (nonatomic,strong) UILabel *labelPlaceholder;
@property (nonatomic,strong) UILabel *labelErrorPlaceholder;

@property (assign) IBInspectable  BOOL disableFloatingLabel;

@property (nonatomic,strong) IBInspectable UIImage *leftimage;


- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;

- (void)showError;
- (void)showErrorWithText:(NSString *)errorText;
- (void)updateTextField:(CGRect)frame;

@end
