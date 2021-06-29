//
//  GalleryCarViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.06.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "GalleryCarViewController.h"
#import "YYWebImage.h"
#import "KSPhotoCell.h"
#import "UIImageView+WebCache.h"
#import "KSYYImageManager.h"
#import "KSSDImageManager.h"
#import "VehicleResultResponse.h"
#import "Format.h"
#import "SpecialActionSheet.h"
#import "GalleryResponse.h"
#import "GMImagePickerController.h"
#import "IQMediaPickerController.h"
#import "UIImage+FixOrientation.h"
#import "KVNProgress.h"

@interface GalleryCarViewController () <KSPhotoBrowserDelegate, UICollectionViewDelegate, UICollectionViewDataSource, GMImagePickerControllerDelegate, UIImagePickerControllerDelegate, IQMediaPickerControllerDelegate>

@property (strong, nonatomic) ZenAppModel *appModel;
@property (nonatomic, strong) VehicleResultResponse *vehicle;
@property (nonatomic, strong) IBOutlet UILabel *titleDoc;

//@property (nonatomic, strong) NSMutableArray *urls;
@property (nonatomic, strong) NSMutableArray *urlsFull;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, assign) BOOL stopDismiss;
@property (nonatomic, strong) NSString *selectedSource;

@property (nonatomic) BOOL multiPickerSwitch;
@property (nonatomic) BOOL pickingSourceCamera;
@property (nonatomic) BOOL photoPickerSwitch;
@property (nonatomic) BOOL videoPickerSwitch;
@property (nonatomic) BOOL audioPickerSwitch;
@property (nonatomic) BOOL rearCaptureSwitch;
@property (nonatomic) BOOL flashOffSwitch;

@end

@implementation GalleryCarViewController {
    IQMediaPickerSelection *selectedMedias;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appModel = [ZenAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    [self setupCollection];
    
    if (_imageManagerType == KSImageManagerTypeSDWebImage) {
        [KSPhotoBrowser setImageManagerClass:KSSDImageManager.class];
    } else {
        [KSPhotoBrowser setImageManagerClass:KSYYImageManager.class];
    }
    
    _multiPickerSwitch = YES;
    _pickingSourceCamera = YES;
    _photoPickerSwitch = YES;
    _videoPickerSwitch = NO;
    _audioPickerSwitch = NO;
    _rearCaptureSwitch = YES;
    _flashOffSwitch = YES;
}

- (void)setupCollection {
    //_urls = [[NSMutableArray alloc] init];
    _urlsFull = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.galleryCollection.images.count; i++) {
        //NSString *min = [[self.galleryCollection.images objectAtIndex:i] valueForKey:@"Url"];
        NSString *max = [[self.galleryCollection.images objectAtIndex:i] valueForKey:@"Url"];
        //[_urls addObject:min];
        [_urlsFull addObject:max];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Upload more documents

- (IBAction)showUploadActionSheet:(UIButton *)sender {
    
    self.selectedSource = @"VehicleRegistrationCertificate";
    
    SpecialActionSheet *actionSheet = [[SpecialActionSheet alloc] init];
    actionSheet.titleColor = [Color officialWhiteColor];
    actionSheet.title = localizeString(@"Take photos of the front and back side of the document or select from the Gallery");
    actionSheet.headerBackgroundColor = [Color officialMainAppColor];
    actionSheet.contentstyle = ZenActionSheetContentStyleDefault;
    [actionSheet addButtonWithTitle:localizeString(@"Take Photo") icon:nil tappedBlock:^{
        [self openCamScanning];
    }];
    [actionSheet addButtonWithTitle:localizeString(@"Image Gallery") icon:nil tappedBlock:^{
        [self uploadPhotoDocumentsClick];
    }];
    
    UIButton *button = (UIButton *)sender;
    [actionSheet showFromView:button inView:self.view];
}


#pragma mark - Camera Helper

- (void)openCamScanning {
    
    IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
    controller.delegate = self;
    [controller setSourceType:self.pickingSourceCamera ? IQMediaPickerControllerSourceTypeCameraMicrophone : IQMediaPickerControllerSourceTypeLibrary];
    
    NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
    [mediaTypes addObject:@(PHAssetMediaTypeImage)];
    
    [controller setMediaTypes:mediaTypes];
    controller.captureDevice = self.rearCaptureSwitch ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    controller.allowsPickingMultipleItems = self.multiPickerSwitch;
    controller.maximumItemCount = 5;
    controller.view.tintColor = [Color officialMainAppColor];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)uploadPhotoDocumentsClick {
    GMImagePickerController *picker = [[GMImagePickerController alloc] init];
    picker.delegate = self;
    picker.title = localizeString(@"Camera Roll");
    
    picker.displaySelectionInfoToolbar = NO;
    picker.customDoneButtonTitle = localizeString(@"Done");
    picker.customCancelButtonTitle = localizeString(@"Cancel");
    
    picker.colsInPortrait = 3;
    picker.colsInLandscape = 5;
    picker.minimumInteritemSpacing = 2.0;
    
    picker.showCameraButton = NO;
    picker.modalPresentationStyle = UIModalPresentationPopover;
    picker.mediaTypes = @[@(PHAssetMediaTypeImage)];
    picker.navigationBarBackgroundColor = [Color officialWhiteColor];
    picker.navigationBarTextColor = [Color officialMainAppColor];
    picker.navigationBarTintColor = [Color darkGrayColor];
    
    UIPopoverPresentationController *popPC = picker.popoverPresentationController;
    popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popPC.sourceView = _gmImagePickerButton;
    popPC.sourceRect = _gmImagePickerButton.bounds;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"UIImagePickerController: User ended picking assets");
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"UIImagePickerController: User pressed cancel button");
}



#pragma mark - KSPhotoBrowserDelegate

- (void)ks_photoBrowser:(KSPhotoBrowser *)browser didSelectItem:(KSPhotoItem *)item atIndex:(NSUInteger)index {
    NSLog(@"selected index: %ld", index);
}


#pragma mark - CollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _urlsFull.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KSPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    if (_imageManagerType == KSImageManagerTypeSDWebImage) {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:_urlsFull[indexPath.row]]];
    } else {
        [cell.imageView yy_setImageWithURL:_urlsFull[indexPath.row] placeholder:[UIImage imageNamed:@"wizard_license_square"] options:kNilOptions progress:nil transform:nil completion:nil];
    }
    return cell;
}


#pragma mark - CollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *items = @[].mutableCopy;
    for (int i = 0; i < _urlsFull.count; i++) {
        KSPhotoCell *cell = (KSPhotoCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        NSString *url = _urlsFull[i];
        KSPhotoItem *item = [KSPhotoItem itemWithSourceView:cell.imageView imageUrl:[NSURL URLWithString:url]];
        [items addObject:item];
    }
    KSPhotoBrowser *browser = [KSPhotoBrowser browserWithPhotoItems:items selectedIndex:indexPath.row];
    browser.delegate = self;
    browser.dismissalStyle = _dismissalStyle;
    browser.backgroundStyle = _backgroundStyle;
    browser.loadingStyle = _loadingStyle;
    browser.pageindicatorStyle = _pageindicatorStyle;
    browser.bounces = _bounces;
    [browser showFromViewController:self];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize returnSize = CGSizeZero;
    returnSize = CGSizeMake(self.view.frame.size.width/3-1, self.view.frame.size.width/3-1);
    return returnSize;
}

- (IBAction)back:(UIButton *)sender {
    if (@available(iOS 13.0, *)) { 
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller {
    //
}

@end
