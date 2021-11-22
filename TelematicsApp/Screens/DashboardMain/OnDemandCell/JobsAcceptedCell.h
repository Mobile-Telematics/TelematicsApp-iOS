//
//  JobsAcceptedCell.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 22.11.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

@interface JobsAcceptedCell: UITableViewCell

@property (nonatomic, assign, readwrite) IBOutlet UILabel *jobNameLbl;
@property (nonatomic, assign, readwrite) IBOutlet UIButton *jobDeclineBtn;
@property (nonatomic, assign, readwrite) IBOutlet UIButton *jobStartBtn;
@property (nonatomic, assign, readwrite) IBOutlet UIButton *jobPauseBtn;
@property (nonatomic, assign) BOOL isPause;

@end
