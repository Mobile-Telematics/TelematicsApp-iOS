//
//  ProfileLicensePopup.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 11.02.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

@interface ProfileLicensePopup : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *backColor;
@property (weak, nonatomic) IBOutlet UIButton *btnEditImg;
@property (weak, nonatomic) IBOutlet UILabel *licSeriesLbl;
@property (weak, nonatomic) IBOutlet UILabel *ownerLbl;
@property (weak, nonatomic) IBOutlet UILabel *regLbl;
@property (weak, nonatomic) IBOutlet UILabel *validLbl;
@property (weak, nonatomic) IBOutlet UILabel *issuedLbl;
@property (weak, nonatomic) IBOutlet UILabel *regLocLbl;
@property (weak, nonatomic) IBOutlet UILabel *categoriesLbl;
@end
