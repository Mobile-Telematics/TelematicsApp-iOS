//
//  GMGridViewController.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//


#import "GMImagePickerController.h"
@import UIKit;
@import Photos;


@interface GMGridViewController: UICollectionViewController

@property (strong) PHFetchResult *assetsFetchResults;

- (id)initWithPicker:(GMImagePickerController *)picker;
    
@end
