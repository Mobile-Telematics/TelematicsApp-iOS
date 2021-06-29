//
//  GMAlbumsViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "GMImagePickerController.h"
#import "GMAlbumsViewController.h"
#import "GMGridViewCell.h"
#import "GMGridViewController.h"
#import "GMAlbumsViewCell.h"

@import Photos;

@interface GMAlbumsViewController() <PHPhotoLibraryChangeObserver>

@property (strong) NSArray *collectionsFetchResults;
@property (strong) NSArray *collectionsLocalizedTitles;
@property (strong) NSArray *collectionsFetchResultsAssets;
@property (strong) NSArray *collectionsFetchResultsTitles;
@property (nonatomic, weak) GMImagePickerController *picker;
@property (strong) PHCachingImageManager *imageManager;

@end


@implementation GMAlbumsViewController

- (id)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.preferredContentSize = kPopoverContentSize;
    }
    
    return self;
}

static NSString * const AllPhotosReuseIdentifier = @"AllPhotosCell";
static NSString * const CollectionCellReuseIdentifier = @"CollectionCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [self.picker pickerBackgroundColor];
    
    if (self.picker.customNavigationBarPrompt) {
        self.navigationItem.prompt = self.picker.customNavigationBarPrompt;
    }
    
    //self.imageManager = [[PHCachingImageManager alloc] init];
    
    self.tableView.rowHeight = kAlbumRowHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    NSDictionary* barButtonItemAttributes = @{NSFontAttributeName: [UIFont fontWithName:self.picker.pickerFontName size:self.picker.pickerFontHeaderSize]};

    NSString *cancelTitle = self.picker.customCancelButtonTitle ? self.picker.customCancelButtonTitle : NSLocalizedStringFromTableInBundle(@"picker.navigation.cancel-button",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class], @"Cancel");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:cancelTitle
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self.picker
                                                                            action:@selector(dismiss:)];
    if (self.picker.useCustomFontForNavigationBar) {
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateSelected];
    }
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status != PHAuthorizationStatusNotDetermined) {
        if (status == PHAuthorizationStatusAuthorized) {
            self.imageManager = [[PHCachingImageManager alloc] init];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:localizeString(@"Need access to Photo gallery")
                                                                           message:localizeString(@"To add photos to your trips, you must give access to the photo gallery. Turn on it?")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *yesAction = [UIAlertAction actionWithTitle:localizeString(@"Yes") style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction *action) {
                                                                  NSURL *settingsUrl = [[NSURL alloc] initWithString:UIApplicationOpenSettingsURLString];
                                                                  [[UIApplication sharedApplication] openURL:settingsUrl options:@{} completionHandler:nil];
                                                              }];
            UIAlertAction *noAction = [UIAlertAction actionWithTitle:localizeString(@"No") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action) {
                                                             }];
            [alert addAction:yesAction];
            [alert addAction:noAction];
            [self presentViewController:alert animated:NO completion:nil];
            return;
        }
    }

    if (self.picker.allowsMultipleSelection) {
        NSString *doneTitle = self.picker.customDoneButtonTitle ? self.picker.customDoneButtonTitle : NSLocalizedStringFromTableInBundle(@"picker.navigation.done-button",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class], @"Done");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:doneTitle
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self.picker
                                                                                 action:@selector(finishPickingAssets:)];
        if (self.picker.useCustomFontForNavigationBar) {
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateSelected];
        }
        
        self.navigationItem.rightBarButtonItem.enabled = (self.picker.autoDisableDoneButton ? self.picker.selectedAssets.count > 0 : TRUE);
    }
    
    self.toolbarItems = self.picker.toolbarItems;
    
    if (!self.picker.title) {
        self.title = NSLocalizedStringFromTableInBundle(@"picker.navigation.title",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class], @"Navigation bar default title");
    } else {
        self.title = self.picker.title;
    }
    
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    self.collectionsFetchResults = @[topLevelUserCollections, smartAlbums];
    self.collectionsLocalizedTitles = @[NSLocalizedStringFromTableInBundle(@"picker.table.user-albums-header",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class], @"Albums"), NSLocalizedStringFromTableInBundle(@"picker.table.smart-albums-header",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class], @"Smart Albums")];
    
    [self updateFetchResults];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.picker.pickerStatusBarStyle;
}

- (void)selectAllAlbumsCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

- (void)updateFetchResults
{
    self.collectionsFetchResultsAssets=nil;
    self.collectionsFetchResultsTitles=nil;
    
    PHFetchResult *topLevelUserCollections = [self.collectionsFetchResults objectAtIndex:0];
    PHFetchResult *smartAlbums = [self.collectionsFetchResults objectAtIndex:1];
    
    NSMutableArray *allFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *allFetchResultLabel = [[NSMutableArray alloc] init];
    {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", self.picker.mediaTypes];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsWithOptions:options];
        [allFetchResultArray addObject:assetsFetchResult];
        [allFetchResultLabel addObject:NSLocalizedStringFromTableInBundle(@"picker.table.all-photos-label",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class], @"All photos")];
    }
    
    NSMutableArray *userFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *userFetchResultLabel = [[NSMutableArray alloc] init];
    for(PHCollection *collection in topLevelUserCollections)
    {
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", self.picker.mediaTypes];
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            [userFetchResultArray addObject:assetsFetchResult];
            [userFetchResultLabel addObject:collection.localizedTitle];
        }
    }
    
    
    NSMutableArray *smartFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *smartFetchResultLabel = [[NSMutableArray alloc] init];
    for(PHCollection *collection in smartAlbums)
    {
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            if (self.picker.customSmartCollections && [self.picker.customSmartCollections containsObject:@(assetCollection.assetCollectionSubtype)])
            {
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", self.picker.mediaTypes];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                if (assetsFetchResult.count > 0)
                {
                    [smartFetchResultArray addObject:assetsFetchResult];
                    [smartFetchResultLabel addObject:collection.localizedTitle];
                }
            }
        }
    }
    
    self.collectionsFetchResultsAssets= @[allFetchResultArray,userFetchResultArray,smartFetchResultArray];
    self.collectionsFetchResultsTitles= @[allFetchResultLabel,userFetchResultLabel,smartFetchResultLabel];
}


#pragma mark - Accessors

- (GMImagePickerController *)picker
{
    return (GMImagePickerController *)self.navigationController.parentViewController;
}


#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.collectionsFetchResultsAssets.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PHFetchResult *fetchResult = self.collectionsFetchResultsAssets[section];
    return fetchResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    GMAlbumsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GMAlbumsViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;

    cell.textLabel.font = [UIFont fontWithName:self.picker.pickerFontName size:self.picker.pickerFontHeaderSize];
    cell.textLabel.text = (self.collectionsFetchResultsTitles[indexPath.section])[indexPath.row];
    cell.textLabel.textColor = self.picker.pickerTextColor;
    
    PHFetchResult *assetsFetchResult = (self.collectionsFetchResultsAssets[indexPath.section])[indexPath.row];
    
    if (self.picker.displayAlbumsNumberOfAssets) {
        cell.detailTextLabel.font = [UIFont fontWithName:self.picker.pickerFontName size:self.picker.pickerFontNormalSize];
        cell.detailTextLabel.text = [self tableCellSubtitle:assetsFetchResult];
        cell.detailTextLabel.textColor = self.picker.pickerTextColor;
    }
    
    if ([assetsFetchResult count] > 0) {
        CGFloat scale = [UIScreen mainScreen].scale;
        
        CGSize tableCellThumbnailSize1 = CGSizeMake(kAlbumThumbnailSize1.width*scale, kAlbumThumbnailSize1.height*scale);
        PHAsset *asset = assetsFetchResult[0];
        [cell setVideoLayout:(asset.mediaType==PHAssetMediaTypeVideo)];
        [self.imageManager requestImageForAsset:asset
                                     targetSize:tableCellThumbnailSize1
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
             if (cell.tag == currentTag) {
                 cell.imageView1.image = result;
             }
         }];
        
        
        if ([assetsFetchResult count] > 1) {
            CGSize tableCellThumbnailSize2 = CGSizeMake(kAlbumThumbnailSize2.width*scale, kAlbumThumbnailSize2.height*scale);
            PHAsset *asset = assetsFetchResult[1];
            [self.imageManager requestImageForAsset:asset
                                         targetSize:tableCellThumbnailSize2
                                        contentMode:PHImageContentModeAspectFill
                                            options:nil
                                      resultHandler:^(UIImage *result, NSDictionary *info) {
                 if (cell.tag == currentTag) {
                     cell.imageView2.image = result;
                 }
             }];
        } else {
            cell.imageView2.image = nil;
        }
        
        if ([assetsFetchResult count] > 2) {
            CGSize tableCellThumbnailSize3 = CGSizeMake(kAlbumThumbnailSize3.width*scale, kAlbumThumbnailSize3.height*scale);
            PHAsset *asset = assetsFetchResult[2];
            [self.imageManager requestImageForAsset:asset
                                         targetSize:tableCellThumbnailSize3
                                        contentMode:PHImageContentModeAspectFill
                                            options:nil
                                      resultHandler:^(UIImage *result, NSDictionary *info) {
                 if (cell.tag == currentTag) {
                     cell.imageView3.image = result;
                 }
             }];
        } else {
            cell.imageView3.image = nil;
        }
    } else {
        [cell setVideoLayout:NO];
        cell.imageView3.image = [UIImage imageNamed:@"GMEmptyFolder"];
        cell.imageView2.image = [UIImage imageNamed:@"GMEmptyFolder"];
        cell.imageView1.image = [UIImage imageNamed:@"GMEmptyFolder"];
        //cell.userInteractionEnabled = NO;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    GMGridViewController *gridViewController = [[GMGridViewController alloc] initWithPicker:[self picker]];

    gridViewController.title = cell.textLabel.text;
    
    gridViewController.assetsFetchResults = [[_collectionsFetchResultsAssets objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];

    [self.navigationController pushViewController:gridViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor = [UIColor clearColor];
    header.backgroundView.backgroundColor = [UIColor clearColor];
    
    header.textLabel.font = [UIFont fontWithName:self.picker.pickerFontName size:self.picker.pickerFontNormalSize];
    header.textLabel.textColor = self.picker.pickerTextColor;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (section > 0) {
        PHFetchResult *fetchResult = self.collectionsFetchResultsAssets[section];
        if (fetchResult.count > 0) {
            title = self.collectionsLocalizedTitles[section - 1];
        }
    }
    return title;
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableArray *updatedCollectionsFetchResults = nil;
        
        for (PHFetchResult *collectionsFetchResult in self.collectionsFetchResults) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            if (changeDetails) {
                if (!updatedCollectionsFetchResults) {
                    updatedCollectionsFetchResults = [self.collectionsFetchResults mutableCopy];
                }
                [updatedCollectionsFetchResults replaceObjectAtIndex:[self.collectionsFetchResults indexOfObject:collectionsFetchResult] withObject:[changeDetails fetchResultAfterChanges]];
            }
        }
        
        if (updatedCollectionsFetchResults) {
            self.collectionsFetchResults = updatedCollectionsFetchResults;
        }
        
        [self updateFetchResults];
        [self.tableView reloadData];
        
    });
}



#pragma mark - Cell Subtitle

- (NSString *)tableCellSubtitle:(PHFetchResult*)assetsFetchResult
{
    return [NSString stringWithFormat:@"%ld", (long)[assetsFetchResult count]];
}


@end
