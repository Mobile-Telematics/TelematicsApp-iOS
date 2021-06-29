//
//  NewClaimCell.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 21.064.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

@protocol NewClaimCellDelegate <NSObject>

- (void)selectedButtonNow:(int)button rowNumber:(int)row;

@end

@interface NewClaimCell: UICollectionViewCell

@property (nonatomic, assign, readwrite) IBOutlet UILabel *accLabel;
@property (nonatomic, assign, readwrite) IBOutlet UIImageView *accImg;
@property (nonatomic, assign, readwrite) IBOutlet UIButton *accBtn;

@property (nonatomic, weak) id <NewClaimCellDelegate> delegate;

@end
