//
//  NewClaimCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 11.06.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "NewClaimCell.h"
#import "UIImageView+WebCache.h"

@interface NewClaimCell ()

@end

@implementation NewClaimCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.accBtn addTarget:self action:@selector(okBtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)okBtn:(UIButton *)sender {
    
    if (sender == self.accBtn){
        [self.delegate selectedButtonNow:1 rowNumber:(int)self.tag];
    }
}

@end
