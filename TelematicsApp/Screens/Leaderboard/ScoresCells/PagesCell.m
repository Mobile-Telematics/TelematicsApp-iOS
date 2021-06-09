//
//  PagesCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 09.04.19.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "PagesCell.h"
#import "UIImageView+WebCache.h"

@interface PagesCell ()

@end

@implementation PagesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _dotsImg.image = [UIImage imageNamed:@"lead_pages"];
}


@end
