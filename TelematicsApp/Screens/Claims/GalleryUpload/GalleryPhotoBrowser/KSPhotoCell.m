//
//  KSPhotoCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.06.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "KSPhotoCell.h"

@implementation KSPhotoCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.type == KSPhotoCellTypeRect) {
        self.imageView.layer.cornerRadius = 0;
    } else if (self.type == KSPhotoCellTypeCircular) {
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2;
    } else if (self.type == KSPhotoCellTypeRoundedRect) {
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 4;
    }
}

@end
