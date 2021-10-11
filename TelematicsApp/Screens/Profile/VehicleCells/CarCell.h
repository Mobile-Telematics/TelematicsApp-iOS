//
//  CarCell.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 07.02.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

@protocol CarCellDelegate <NSObject>

- (void)selectedButtonNow:(int)button rowNumber:(int)row;

@end

@interface CarCell: UITableViewCell

@property (nonatomic, assign, readwrite) IBOutlet UILabel       *vehiclePlaceholder;
@property (nonatomic, assign, readwrite) IBOutlet UILabel       *vehicleNameLbl;
@property (nonatomic, assign, readwrite) IBOutlet UILabel       *vehicleLicNumLbl;
@property (nonatomic, assign, readwrite) IBOutlet UIImageView   *arrow;
@property (nonatomic, assign, readwrite) IBOutlet UIButton      *okBtn;
@property (nonatomic, assign, readwrite) IBOutlet UIButton      *delBtn;

@property (nonatomic, weak) id <CarCellDelegate>                delegate;

@end
