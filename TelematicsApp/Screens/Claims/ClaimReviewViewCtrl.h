//
//  ClaimReviewViewCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSPhotoBrowser.h"

typedef NS_ENUM(NSInteger, KSImageManagerType) {
    KSImageManagerTypeYYWebImage,
    KSImageManagerTypeSDWebImage
};

@interface ClaimReviewViewCtrl : UIViewController

@property (assign, nonatomic) BOOL                                          hideBottomButtons;
@property (strong, nonatomic) NSArray                                       *selectedClaim;

@property (nonatomic, assign) KSPhotoBrowserInteractiveDismissalStyle       dismissalStyle;
@property (nonatomic, assign) KSPhotoBrowserBackgroundStyle                 backgroundStyle;
@property (nonatomic, assign) KSPhotoBrowserPageIndicatorStyle              pageindicatorStyle;
@property (nonatomic, assign) KSPhotoBrowserImageLoadingStyle               loadingStyle;
@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, assign) KSImageManagerType                            imageManagerType;

@end

