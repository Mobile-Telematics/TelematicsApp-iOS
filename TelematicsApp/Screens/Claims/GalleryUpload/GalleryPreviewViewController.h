//
//  GalleryPreviewViewController.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.06.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSPhotoBrowser.h"
#import "GalleryResultResponse.h"

typedef NS_ENUM(NSInteger, KSImageManagerType) {
    KSImageManagerTypeYYWebImage,
    KSImageManagerTypeSDWebImage
};

@interface GalleryPreviewViewController: BaseViewController

@property (nonatomic, strong) GalleryResultResponse *galleryCollection;
@property (nonatomic, assign) KSPhotoBrowserInteractiveDismissalStyle dismissalStyle;
@property (nonatomic, assign) KSPhotoBrowserBackgroundStyle backgroundStyle;
@property (nonatomic, assign) KSPhotoBrowserPageIndicatorStyle pageindicatorStyle;
@property (nonatomic, assign) KSPhotoBrowserImageLoadingStyle loadingStyle;
@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, assign) KSImageManagerType imageManagerType;
@property (weak, nonatomic) IBOutlet UIButton *gmImagePickerButton;
@property (weak, nonatomic) IBOutlet UIButton *uiImagePickerButton;
@property (nonatomic, strong) NSString *selectedSourceForBackEnd;

@end

