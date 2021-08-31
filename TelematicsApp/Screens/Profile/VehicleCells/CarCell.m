//
//  CarCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 07.02.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "CarCell.h"
#import "UIImageView+WebCache.h"

@interface CarCell ()

@end

@implementation CarCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.okBtn addTarget:self action:@selector(okBtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)okBtn:(UIButton *)sender {
    
    if (sender == self.okBtn) {
        [self.delegate selectedButtonNow:1 rowNumber:(int)self.tag];
    }
}

@end
