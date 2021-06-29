//
//  KSPhotoCell.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.06.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KSPhotoCellType) {
    KSPhotoCellTypeRect,
    KSPhotoCellTypeRoundedRect,
    KSPhotoCellTypeCircular
};
@interface KSPhotoCell: UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) KSPhotoCellType type;

@end
