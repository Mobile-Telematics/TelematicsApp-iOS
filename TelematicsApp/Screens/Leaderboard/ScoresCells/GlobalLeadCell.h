//
//  GlobalLeadCell.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 05.10.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

@interface GlobalLeadCell: UITableViewCell

@property (nonatomic, assign, readwrite) IBOutlet UILabel           *positionLbl;
@property (nonatomic, assign, readwrite) IBOutlet UIImageView       *useravatar;
@property (nonatomic, assign, readwrite) IBOutlet UILabel           *usernameLbl;
@property (nonatomic, assign, readwrite) IBOutlet UILabel           *scoreLbl;


@end
