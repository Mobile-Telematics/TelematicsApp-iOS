//
//  GMGridViewCell.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
@import Photos;


@interface GMGridViewCell: UICollectionViewCell

@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIImageView *videoIcon;
@property (nonatomic, strong) UILabel *videoDuration;
@property (nonatomic, strong) UIView *gradientView;
@property (nonatomic, strong) CAGradientLayer *gradient;

@property (nonatomic) BOOL shouldShowSelection;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIButton *selectedButton;

@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

- (void)bind:(PHAsset *)asset;

@end
