//
//  GMImagePickerController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "GMImagePickerController.h"
#import "GMAlbumsViewController.h"
@import Photos;

@interface GMImagePickerController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

@end

@implementation GMImagePickerController

- (id)init
{
    if (self = [super init]) {
        _selectedAssets = [[NSMutableArray alloc] init];
        
        _displaySelectionInfoToolbar = YES;
        _displayAlbumsNumberOfAssets = YES;
        _autoDisableDoneButton = YES;
        _allowsMultipleSelection = YES;
        _confirmSingleSelection = NO;
        _showCameraButton = NO;
        
        _colsInPortrait = 3;
        _colsInLandscape = 5;
        _minimumInteritemSpacing = 2.0;
        
        _customSmartCollections = @[@(PHAssetCollectionSubtypeSmartAlbumFavorites),
                                    @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
                                    @(PHAssetCollectionSubtypeSmartAlbumVideos),
                                    @(PHAssetCollectionSubtypeSmartAlbumSlomoVideos),
                                    @(PHAssetCollectionSubtypeSmartAlbumTimelapses),
                                    @(PHAssetCollectionSubtypeSmartAlbumBursts),
                                    @(PHAssetCollectionSubtypeSmartAlbumPanoramas)];
        
        _mediaTypes = @[@(PHAssetMediaTypeAudio),
                        @(PHAssetMediaTypeVideo),
                        @(PHAssetMediaTypeImage)];
        
        self.preferredContentSize = kPopoverContentSize;
        
        _pickerBackgroundColor = [Color officialWhiteColor];
        _pickerTextColor = [UIColor darkTextColor];
        _pickerFontName = @"HelveticaNeue";
        _pickerBoldFontName = @"HelveticaNeue-Bold";
        _pickerFontNormalSize = 14.0f;
        _pickerFontHeaderSize = 17.0f;
        
        _navigationBarBackgroundColor = [Color officialWhiteColor];
        _navigationBarTextColor = [UIColor darkTextColor];
        _navigationBarTintColor = [UIColor darkTextColor];
        
        _toolbarBarTintColor = [Color officialWhiteColor];
        _toolbarTextColor = [UIColor darkTextColor];
        _toolbarTintColor = [UIColor darkTextColor];
        
        _pickerStatusBarStyle = UIStatusBarStyleDefault;
        
        [self setupNavigationController];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = _pickerBackgroundColor;

    _navigationController.toolbar.translucent = YES;
    _navigationController.toolbar.barTintColor = _toolbarBarTintColor;
    _navigationController.toolbar.tintColor = _toolbarTintColor;
    //[(UIView*)[_navigationController.toolbar.subviews objectAtIndex:0] setAlpha:0.75f];  //
    
    _navigationController.navigationBar.backgroundColor = _navigationBarBackgroundColor;
    _navigationController.navigationBar.tintColor = _navigationBarTintColor;
    NSDictionary *attributes;
    if (_useCustomFontForNavigationBar) {
        attributes = @{NSForegroundColorAttributeName : _navigationBarTextColor,
                       NSFontAttributeName : [UIFont fontWithName:_pickerBoldFontName size:_pickerFontHeaderSize]};
    } else {
        attributes = @{NSForegroundColorAttributeName : _navigationBarTextColor};
    }
    _navigationController.navigationBar.titleTextAttributes = attributes;
    
    [self updateToolbar];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _pickerStatusBarStyle;
}


#pragma mark - Setup Navigation Controller

- (void)setupNavigationController
{
    GMAlbumsViewController *albumsViewController = [[GMAlbumsViewController alloc] init];
    _navigationController = [[UINavigationController alloc] initWithRootViewController:albumsViewController];
    _navigationController.delegate = self;
    
    _navigationController.navigationBar.translucent = YES;
    [_navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    _navigationController.navigationBar.shadowImage = [UIImage new];
    
    [_navigationController willMoveToParentViewController:self];
    [_navigationController.view setFrame:self.view.frame];
    [self.view addSubview:_navigationController.view];
    [self addChildViewController:_navigationController];
    [_navigationController didMoveToParentViewController:self];
}


#pragma mark - Select / Deselect Asset

- (void)selectAsset:(PHAsset *)asset
{
    [self.selectedAssets insertObject:asset atIndex:self.selectedAssets.count];
    [self updateDoneButton];
    
    if (self.selectedAssets.count == 2) {
        
    }
    
    if (!self.allowsMultipleSelection) {
        if (self.confirmSingleSelection) {
            NSString *message = self.confirmSingleSelectionPrompt ? self.confirmSingleSelectionPrompt : [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"picker.confirm.message",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class], @"Do you want to select the image you tapped on?")];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"picker.confirm.title",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class], @"Are You Sure?")]
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *yesButton = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"picker.action.yes",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"Yes")]
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  [self finishPickingAssets:self];
                                                              }];
            UIAlertAction *noButton = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"picker.action.no",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"No")]
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction *action) {}];
            [alert addAction:yesButton];
            [alert addAction:noButton];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            [self finishPickingAssets:self];
        }
    } else if (self.displaySelectionInfoToolbar || self.showCameraButton) {
        [self updateToolbar];
    }
}

- (void)deselectAsset:(PHAsset *)asset
{
    [self.selectedAssets removeObjectAtIndex:[self.selectedAssets indexOfObject:asset]];
    if (self.selectedAssets.count == 0) {
        [self updateDoneButton];
    }
    
    if (self.displaySelectionInfoToolbar || self.showCameraButton) {
        [self updateToolbar];
    }
}

- (void)updateDoneButton
{
    if (!self.allowsMultipleSelection) {
        return;
    }
    
    UINavigationController *nav = (UINavigationController *)self.childViewControllers[0];
    for (UIViewController *viewController in nav.viewControllers) {
        viewController.navigationItem.rightBarButtonItem.enabled = (self.autoDisableDoneButton ? self.selectedAssets.count > 0 : TRUE);
    }
}

- (void)updateToolbar
{
    if (!self.allowsMultipleSelection && !self.showCameraButton) {
        return;
    }

    UINavigationController *nav = (UINavigationController *)self.childViewControllers[0];
    for (UIViewController *viewController in nav.viewControllers) {
        NSUInteger index = 1;
        if (_showCameraButton) {
            index++;
        }
        [[viewController.toolbarItems objectAtIndex:index] setTitleTextAttributes:[self toolbarTitleTextAttributes] forState:UIControlStateNormal];
        [[viewController.toolbarItems objectAtIndex:index] setTitleTextAttributes:[self toolbarTitleTextAttributes] forState:UIControlStateDisabled];
        [[viewController.toolbarItems objectAtIndex:index] setTitle:[self toolbarTitle]];
        [viewController.navigationController setToolbarHidden:(self.selectedAssets.count == 0 && !self.showCameraButton) animated:YES];
    }
}


#pragma mark - User finish Actions

- (void)dismiss:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)]) {
        [self.delegate assetsPickerControllerDidCancel:self];
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)finishPickingAssets:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)]) {
        [self.delegate assetsPickerController:self didFinishPickingAssets:self.selectedAssets];
    }
}


#pragma mark - Toolbar Title

- (NSPredicate *)predicateOfAssetType:(PHAssetMediaType)type
{
    return [NSPredicate predicateWithBlock:^BOOL(PHAsset *asset, NSDictionary *bindings) {
        return (asset.mediaType == type);
    }];
}

- (NSString *)toolbarTitle
{
    if (self.selectedAssets.count == 0) {
        return nil;
    }
    
    NSPredicate *photoPredicate = [self predicateOfAssetType:PHAssetMediaTypeImage];
    NSPredicate *videoPredicate = [self predicateOfAssetType:PHAssetMediaTypeVideo];
    
    NSInteger nImages = [self.selectedAssets filteredArrayUsingPredicate:photoPredicate].count;
    NSInteger nVideos = [self.selectedAssets filteredArrayUsingPredicate:videoPredicate].count;
    
    if (nImages > 0 && nVideos > 0) {
        return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"picker.selection.multiple-items",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"%@ Items Selected" ), @(nImages + nVideos)];
    } else if (nImages > 1) {
        return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"picker.selection.multiple-photos",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"%@ Photos Selected"), @(nImages)];
    } else if (nImages == 1) {
        return NSLocalizedStringFromTableInBundle(@"picker.selection.single-photo",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"1 Photo Selected" );
    } else if (nVideos > 1) {
        return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"picker.selection.multiple-videos",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"%@ Videos Selected"), @(nVideos)];
    } else if (nVideos == 1) {
        return NSLocalizedStringFromTableInBundle(@"picker.selection.single-video",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"1 Video Selected");
    } else {
        return nil;
    }
}


#pragma mark - Toolbar Items

- (void)cameraButtonPressed:(UIBarButtonItem *)button
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Camera!"
                                                                       message:@"Sorry, this device does not have a camera."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:localizeString(@"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];

        return;
    }
    
    if (self.autoSelectCameraImages && [self.navigationController.topViewController isKindOfClass:[GMAlbumsViewController class]]) {
        [((GMAlbumsViewController *)self.navigationController.topViewController) selectAllAlbumsCell];
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    picker.allowsEditing = self.allowsEditingCameraImages;
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *popPC = picker.popoverPresentationController;
    popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popPC.barButtonItem = button;
    
    [self showViewController:picker sender:button];
}

- (NSDictionary *)toolbarTitleTextAttributes {
    return @{NSForegroundColorAttributeName : _toolbarTextColor,
             NSFontAttributeName : [UIFont fontWithName:_pickerFontName size:_pickerFontHeaderSize]};
}

- (UIBarButtonItem *)titleButtonItem
{
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithTitle:self.toolbarTitle
                                                              style:UIBarButtonItemStylePlain
                                                             target:nil
                                                             action:nil];
    
    NSDictionary *attributes = [self toolbarTitleTextAttributes];
    [title setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [title setTitleTextAttributes:attributes forState:UIControlStateDisabled];
    [title setEnabled:NO];
    
    return title;
}

- (UIBarButtonItem *)spaceButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (UIBarButtonItem *)cameraButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonPressed:)];
}

- (NSArray *)toolbarItems
{
    UIBarButtonItem *camera = [self cameraButtonItem];
    UIBarButtonItem *title = [self titleButtonItem];
    UIBarButtonItem *space = [self spaceButtonItem];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    if (_showCameraButton) {
        [items addObject:camera];
    }
    [items addObject:space];
    [items addObject:title];
    [items addObject:space];
    
    return [NSArray arrayWithArray:items];
}


#pragma mark - Camera Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];

    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerEditedImage] ? : info[UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       @selector(image:finishedSavingWithError:contextInfo:),
                                       nil);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Image Not Saved"
                                                                       message:@"Sorry, unable to save the new image!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:localizeString(@"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
