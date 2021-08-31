//
//  ClaimQouteCell.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 25.06.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

@interface ClaimQouteCell: UITableViewCell

@property (nonatomic, assign, readwrite) IBOutlet UILabel *claimName;
@property (nonatomic, assign, readwrite) IBOutlet UILabel *claimDate;
@property (nonatomic, assign, readwrite) IBOutlet UILabel *claimId;
@property (nonatomic, assign, readwrite) IBOutlet UILabel *claimStatus;

@end
