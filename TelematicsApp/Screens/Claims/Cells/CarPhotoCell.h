//
//  CarPhotoCell.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 25.06.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

@interface CarPhotoCell: UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *sideLbl;
@property (weak, nonatomic) IBOutlet UIImageView *mainPhoto;
@property (weak, nonatomic) IBOutlet UIButton *cameraBtn;

@end
