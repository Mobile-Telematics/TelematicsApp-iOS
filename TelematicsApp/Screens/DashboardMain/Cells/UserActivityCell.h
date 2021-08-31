//
//  UserActivityCell.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 19.08.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

@interface UserActivityCell: UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *averageSpeed;
@property (weak, nonatomic) IBOutlet UILabel *maxSpeed;
@property (weak, nonatomic) IBOutlet UILabel *averageTrip;

@end
