//
//  EmailLoginViewCtrl.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.06.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "BaseViewController.h"

@interface EmailLoginViewCtrl: BaseViewController

@property (nonatomic, assign) BOOL          isUserExist;

@property (strong, nonatomic) NSString      *welcomeText;
@property (strong, nonatomic) NSString      *signInBtnText;

@property (strong, nonatomic) NSString      *enteredEmail;
@property (strong, nonatomic) NSString      *userName;
@property (strong, nonatomic) NSString      *userPhotoUrl;

@end
