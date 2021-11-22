//
//  JobsCompletedCell.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 22.11.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

@interface JobsCompletedCell: UITableViewCell

@property (nonatomic, assign, readwrite) IBOutlet UILabel       *jobCompletedNameLbl;
@property (nonatomic, assign, readwrite) IBOutlet UIButton      *jobHideBtn;

@property (nonatomic, assign, readwrite) IBOutlet UILabel       *job_riskScoreLbl;
@property (nonatomic, assign, readwrite) IBOutlet UILabel       *job_tripsCountLbl;
@property (nonatomic, assign, readwrite) IBOutlet UILabel       *job_mileageLbl;
@property (nonatomic, assign, readwrite) IBOutlet UILabel       *job_timeLbl;

@property (weak, nonatomic) IBOutlet UIImageView                *job_riskScoreImg;
@property (weak, nonatomic) IBOutlet UIImageView                *job_tripsCountImg;
@property (weak, nonatomic) IBOutlet UIImageView                *job_mileageImg;
@property (weak, nonatomic) IBOutlet UIImageView                *job_timeImg;

@end
