//
//  GMAlbumsViewController.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

static int kAlbumRowHeight = 90;
static int kAlbumLeftToImageSpace = 10;
static int kAlbumImageToTextSpace = 21;
static float const kAlbumGradientHeight = 20.0f;
static CGSize const kAlbumThumbnailSize1 = {70.0f , 70.0f};
static CGSize const kAlbumThumbnailSize2 = {66.0f , 66.0f};
static CGSize const kAlbumThumbnailSize3 = {62.0f , 62.0f};


@interface GMAlbumsViewController: UITableViewController

- (void)selectAllAlbumsCell;

@end
