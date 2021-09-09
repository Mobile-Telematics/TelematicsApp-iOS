//
//  GMImagePickerController.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
@import Photos;


static CGSize const kPopoverContentSize = {480, 720};


@protocol GMImagePickerControllerDelegate;

@interface GMImagePickerController: UIViewController

@property (nonatomic, weak) id <GMImagePickerControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *selectedAssets;


@property (nonatomic, strong) NSArray* customSmartCollections;

@property (nonatomic, strong) NSArray* mediaTypes;

@property (nonatomic) NSString* customDoneButtonTitle;

@property (nonatomic) NSString* customCancelButtonTitle;

@property (nonatomic) NSString* customNavigationBarPrompt;

@property (nonatomic) BOOL displaySelectionInfoToolbar;

@property (nonatomic, assign) BOOL displayAlbumsNumberOfAssets;

@property (nonatomic, assign) BOOL autoDisableDoneButton;

@property (nonatomic, assign) BOOL allowsMultipleSelection;

@property (nonatomic, assign) BOOL confirmSingleSelection;

@property (nonatomic) NSString *confirmSingleSelectionPrompt;

@property (nonatomic, assign) BOOL showCameraButton;

@property (nonatomic, assign) BOOL autoSelectCameraImages;

@property (nonatomic, assign) BOOL allowsEditingCameraImages;


@property (nonatomic) NSInteger colsInPortrait;
@property (nonatomic) NSInteger colsInLandscape;
@property (nonatomic) double minimumInteritemSpacing;


@property (nonatomic, strong) UIColor *pickerBackgroundColor;
@property (nonatomic, strong) UIColor *pickerTextColor;
@property (nonatomic, strong) UIColor *toolbarBarTintColor;
@property (nonatomic, strong) UIColor *toolbarTextColor;
@property (nonatomic, strong) UIColor *toolbarTintColor;
@property (nonatomic, strong) UIColor *navigationBarBackgroundColor;
@property (nonatomic, strong) UIColor *navigationBarTextColor;
@property (nonatomic, strong) UIColor *navigationBarTintColor;
@property (nonatomic, strong) NSString *pickerFontName;
@property (nonatomic, strong) NSString *pickerBoldFontName;
@property (nonatomic) CGFloat pickerFontNormalSize;
@property (nonatomic) CGFloat pickerFontHeaderSize;
@property (nonatomic) UIStatusBarStyle pickerStatusBarStyle;
@property (nonatomic) BOOL useCustomFontForNavigationBar;


@property (nonatomic, strong) UINavigationController *navigationController;

- (void)selectAsset:(PHAsset *)asset;
- (void)deselectAsset:(PHAsset *)asset;

- (void)dismiss:(id)sender;
- (void)finishPickingAssets:(id)sender;

@end



@protocol GMImagePickerControllerDelegate <NSObject>

- (void)assetsPickerController:(GMImagePickerController *)picker didFinishPickingAssets:(NSArray *)assets;

@optional

- (void)assetsPickerControllerDidCancel:(GMImagePickerController *)picker;

- (BOOL)assetsPickerController:(GMImagePickerController *)picker shouldShowAsset:(PHAsset *)asset;

- (BOOL)assetsPickerController:(GMImagePickerController *)picker shouldEnableAsset:(PHAsset *)asset;

- (BOOL)assetsPickerController:(GMImagePickerController *)picker shouldSelectAsset:(PHAsset *)asset;

- (void)assetsPickerController:(GMImagePickerController *)picker didSelectAsset:(PHAsset *)asset;

- (BOOL)assetsPickerController:(GMImagePickerController *)picker shouldDeselectAsset:(PHAsset *)asset;

- (void)assetsPickerController:(GMImagePickerController *)picker didDeselectAsset:(PHAsset *)asset;

- (BOOL)assetsPickerController:(GMImagePickerController *)picker shouldHighlightAsset:(PHAsset *)asset;

- (void)assetsPickerController:(GMImagePickerController *)picker didHighlightAsset:(PHAsset *)asset;

- (void)assetsPickerController:(GMImagePickerController *)picker didUnhighlightAsset:(PHAsset *)asset;




@end
