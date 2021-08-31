//
//  GMAlbumsViewCell.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
@import Photos;

@interface GMAlbumsViewCell: UITableViewCell

@property (strong) PHFetchResult *assetsFetchResults;
@property (strong) PHAssetCollection *assetCollection;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UIImageView *imageView2;
@property (nonatomic, strong) UIImageView *imageView3;

@property (nonatomic, strong) UIImageView *videoIcon;
@property (nonatomic, strong) UIImageView *slowMoIcon;
@property (nonatomic, strong) UIView* gradientView;
@property (nonatomic, strong) CAGradientLayer *gradient;

- (void)setVideoLayout:(BOOL)isVideo;

@end
