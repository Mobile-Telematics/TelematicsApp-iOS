//
//  PhoneLoginViewCtrl.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.06.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "BaseViewController.h"

@interface PhoneLoginViewCtrl: BaseViewController

@property(strong, nonatomic) FIRDatabaseReference *realtimeDatabase;

@property (strong, nonatomic) NSString *enteredPhone;
@property (strong, nonatomic) NSString *savedVerificationId;
@property (strong, nonatomic) NSString *userPhotoUrl;

@end
