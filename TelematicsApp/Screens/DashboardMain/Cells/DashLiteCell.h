//
//  DashLiteCell.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 23.05.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
#import "DashLiteGaugeView.h"
#import "UICountingLabel.h"

@interface DashLiteCell: UICollectionViewCell <DashLiteGaugeViewDelegate>

@property (strong, nonatomic) IBOutlet DashLiteGaugeView *gaugeView;

@property (weak, nonatomic) IBOutlet UICountingLabel *curveCountLbl;
@property (weak, nonatomic) IBOutlet UILabel *curveCountPlaceholder;
@property (weak, nonatomic) IBOutlet UIImageView *faceImg;
@property (weak, nonatomic) IBOutlet UILabel *curveNameLbl;

- (void)loadGauge:(NSNumber*)value curveName:(NSString*)curveName;
- (void)loadDemoGauge:(NSNumber*)value curveName:(NSString*)curveName;

@end
