//
//  StreakCell.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 17.08.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

@interface StreakCell: UITableViewCell

@property (nonatomic, assign, readwrite) IBOutlet UILabel           *mainTitleLbl;
@property (nonatomic, assign, readwrite) IBOutlet UIImageView       *mainStreakImg;

@property (nonatomic, assign, readwrite) IBOutlet UILabel           *currentNameLbl;
@property (nonatomic, assign, readwrite) IBOutlet UILabel           *bestNameLbl;

@property (nonatomic, assign, readwrite) IBOutlet UILabel           *currentValueLbl;
@property (nonatomic, assign, readwrite) IBOutlet UILabel           *bestValueLbl;

@property (nonatomic, assign, readwrite) IBOutlet UILabel           *section1ValueLbl;
@property (nonatomic, assign, readwrite) IBOutlet UILabel           *section2ValueLbl;

@property (nonatomic, assign, readwrite) IBOutlet UILabel           *dateTimeSection1Lbl;
@property (nonatomic, assign, readwrite) IBOutlet UILabel           *dateTimeSection2Lbl;


@end
