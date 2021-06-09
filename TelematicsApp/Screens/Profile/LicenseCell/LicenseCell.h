//
//  LicenseCell.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 12.12.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

@protocol LicenseCellDelegate <NSObject>

@end

@interface LicenseCell: UITableViewCell

@property (nonatomic, assign, readwrite) IBOutlet UILabel *licPlaceholder;
@property (nonatomic, assign, readwrite) IBOutlet UILabel *userNameLbl;
@property (nonatomic, assign, readwrite) IBOutlet UILabel *userLicNumLbl;
@property (nonatomic, assign, readwrite) IBOutlet UIImageView *arrow;
@property (nonatomic, assign, readwrite) IBOutlet UIImageView *addCellBackground;

@end
