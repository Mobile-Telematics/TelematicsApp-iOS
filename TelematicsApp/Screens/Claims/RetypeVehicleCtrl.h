//
//  RetypeVehicleCtrl.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
@import Foundation;

@interface RetypeVehicleCtrl: BaseViewController

@property (weak, nonatomic) IBOutlet UIButton       *gmImagePickerButton;
@property (weak, nonatomic) IBOutlet UIButton       *uiImagePickerButton;

@property (weak, nonatomic) NSString                *vehicleTokenString;
@property (weak, nonatomic) NSString                *plateString;
@property (weak, nonatomic) NSString                *vinCodeStr;
@property (weak, nonatomic) NSString                *manufacturerString;
@property (weak, nonatomic) NSString                *modelString;
@property (weak, nonatomic) NSString                *typeString;
@property (weak, nonatomic) NSString                *nicknameString;
@property (weak, nonatomic) NSString                *yearString;
@property (weak, nonatomic) NSString                *mileageString;
@property (weak, nonatomic) NSString                *paintingString;

@end
