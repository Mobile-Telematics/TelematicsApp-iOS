//
//  ClaimReviewViewCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ClaimReviewViewCtrl.h"
#import "Color.h"
#import "Helpers.h"
#import "UIViewController+Preloader.h"
#import "NSDate+ISO8601.h"
#import "NSDate+UI.h"
#import "KSPhotoCell.h"
#import "UIImageView+WebCache.h"
#import "KSYYImageManager.h"
#import "KSSDImageManager.h"
#import <YYWebImage/YYWebImage.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface ClaimReviewViewCtrl () <UIScrollViewDelegate, KSPhotoBrowserDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) TelematicsAppModel               *appModel;
@property (weak, nonatomic) IBOutlet UIScrollView       *scrollView;
@property (weak, nonatomic) IBOutlet UILabel            *mainLbl;

@property (weak, nonatomic) IBOutlet UILabel            *claimAccidentTypeLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimDriverFirstNameLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimDriverLastNameLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimDriverLicenseNoLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimCarMakeLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimCarModelLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimCarYearLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimCarTypeLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimCarVinLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimCarPaintingLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimDateTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimLocationLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimDescriptionLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimCarDriveLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimCarTowingLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimInvolvedDriverFirstNameLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimInvolvedDriverLastNameLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimInvolvedLicenseNoLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimInvolvedCarPlateLbl;
@property (weak, nonatomic) IBOutlet UILabel            *claimPhotosCountLbl;

@property (nonatomic, strong) NSMutableArray            *urlsFull;
@property (weak, nonatomic) IBOutlet UICollectionView   *collectionView;
@property (nonatomic, strong) NSArray                   *photoItems;

@property (weak, nonatomic) IBOutlet UIButton           *backBtn;
@property (weak, nonatomic) IBOutlet UIButton           *confirmBtn;
@property (weak, nonatomic) IBOutlet UIView             *bottomView;
@end

@implementation ClaimReviewViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    _claimPhotosCountLbl.hidden = YES;
    //[KSPhotoBrowser setImageManagerClass:SDWebImageManager.class]; // KSYYImageManager.class];
    
    self.dismissalStyle = KSPhotoBrowserInteractiveDismissalStyleSlide;
    self.backgroundStyle = KSPhotoBrowserBackgroundStyleBlur;
    self.pageindicatorStyle = KSPhotoBrowserPageIndicatorStyleDot;
    self.loadingStyle = KSPhotoBrowserImageLoadingStyleIndeterminate;
    self.bounces = YES;
    //self.imageManagerType = KSImageManagerTypeSDWebImage;
    
    [self updateClaimReviewLabels];
    
    [self.confirmBtn setTintColor:[Color officialWhiteColor]];
    [self.confirmBtn setBackgroundColor:[Color officialMainAppColor]];
    [self.confirmBtn.layer setMasksToBounds:YES];
    [self.confirmBtn.layer setCornerRadius:15.0f];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
    if (self.hideBottomButtons) {
        [self setupPhotosCollectionFromUrls];
    } else {
        [self setupPhotosCollectionFromCache];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)updateClaimReviewLabels {
    
    if (self.hideBottomButtons) {
        
        self.backBtn.hidden = YES;
        self.confirmBtn.hidden = YES;
        self.bottomView.hidden = YES;
        
        NSString *detectAccident = [self.selectedClaim valueForKey:@"AccidentType"];
        NSString *accName = @"Other";
        if (detectAccident != nil) {
            if ([detectAccident isEqualToString:@"road_accident"]) {
                accName = @"Road Accident";
            } else if ([detectAccident isEqualToString:@"fire_damage"]) {
                accName = @"Fire Damage";
            } else if ([detectAccident isEqualToString:@"cataclysm"]) {
                accName = @"Cataclysm";
            } else if ([detectAccident isEqualToString:@"hijacking"]) {
                accName = @"Hijacking";
            } else if ([detectAccident isEqualToString:@"vandalism"]) {
                accName = @"Vandalism";
            } else if ([detectAccident isEqualToString:@"vandalism"]) {
                accName = @"Vandalism";
            } else if ([detectAccident isEqualToString:@"glass_damage"]) {
                accName = @"Glass Damage";
            } else if ([detectAccident isEqualToString:@"animals"]) {
                accName = @"Animals";
            } else {
                accName = @"Other";
            }
        }
        
        NSString *dateClaimFormat = localizeString(@"Not specified");
        NSString *claimDateTime = [self.selectedClaim valueForKey:@"ClaimDateTime"] ? [self.selectedClaim valueForKey:@"ClaimDateTime"] : localizeString(@"Not specified");
        if (![claimDateTime isEqual:[NSNull null]]) {
            NSDate *date = [NSDate dateWithISO8601String:claimDateTime];
            dateClaimFormat = [date dateString];
        } else {
            dateClaimFormat = localizeString(@"Not specified");
        }
        
        _claimAccidentTypeLbl.text = accName;
        _claimDriverFirstNameLbl.text = [self.selectedClaim valueForKey:@"DriverFirstName"];
        _claimDriverLastNameLbl.text = [self.selectedClaim valueForKey:@"DriverLastName"];
        _claimDriverLicenseNoLbl.text = [self.selectedClaim valueForKey:@"VehicleLicenseplateno"] ? [self.selectedClaim valueForKey:@"VehicleLicenseplateno"] : localizeString(@"Not specified");
        if ([_claimDriverLicenseNoLbl.text isEqualToString:@""])
            _claimDriverLicenseNoLbl.text = localizeString(@"Not specified");
        
        _claimCarMakeLbl.text = [self.selectedClaim valueForKey:@"VehicleMake"];
        _claimCarModelLbl.text = [self.selectedClaim valueForKey:@"VehicleModel"];
        
        _claimCarYearLbl.text = localizeString(@"Not specified");
        _claimCarTypeLbl.text = localizeString(@"Not specified");
        _claimCarVinLbl.text = localizeString(@"Not specified");
        
        NSString *carToken = [self.selectedClaim valueForKey:@"CarToken"];
        for (int i=0; i < self.appModel.vehicleShortData.count; i++) {
            NSString *checkCarToken = [[self.appModel.vehicleShortData valueForKey:@"Token"] objectAtIndex:i];
            if ([checkCarToken isEqualToString:carToken]) {
                
                if (![[[self.appModel.vehicleShortData valueForKey:@"CarYear"] objectAtIndex:i] isEqual:[NSNull null]]) {
                    _claimCarYearLbl.text = [[self.appModel.vehicleShortData valueForKey:@"CarYear"] objectAtIndex:i];
                }
                if (![[[self.appModel.vehicleShortData valueForKey:@"BodyType"] objectAtIndex:i] isEqual:[NSNull null]]) {
                    _claimCarTypeLbl.text = [[self.appModel.vehicleShortData valueForKey:@"BodyType"] objectAtIndex:i];
                }
                if (![[[self.appModel.vehicleShortData valueForKey:@"Vin"] objectAtIndex:i] isEqual:[NSNull null]]) {
                    _claimCarVinLbl.text = [[self.appModel.vehicleShortData valueForKey:@"Vin"] objectAtIndex:i];
                }
            }
        }
        
        _claimCarPaintingLbl.text = [[self.selectedClaim valueForKey:@"Paint"] capitalizedString];
        _claimDateTimeLbl.text = dateClaimFormat;
        _claimLocationLbl.text = [self.selectedClaim valueForKey:@"Locations"] ? [self.selectedClaim valueForKey:@"Locations"] : localizeString(@"Not specified");
        if ([_claimLocationLbl.text isEqualToString:@""])
            _claimLocationLbl.text = localizeString(@"Not specified");
        
        _claimDescriptionLbl.text = [self.selectedClaim valueForKey:@"Description"] ? [self.selectedClaim valueForKey:@"Description"] : localizeString(@"Not specified");
        if ([_claimDescriptionLbl.text isEqualToString:@""])
            _claimDescriptionLbl.text = localizeString(@"Not specified");
        
        NSString *isDrivable = [[self.selectedClaim valueForKey:@"CarDrivable"] boolValue] ? @"YES" : @"NO";
        _claimCarDriveLbl.text = isDrivable;
        NSString *isTowing = [[self.selectedClaim valueForKey:@"CarTowing"] boolValue] ? @"YES" : @"NO";
        _claimCarTowingLbl.text = isTowing;
        
        if (![[self.selectedClaim valueForKey:@"InvolvedFirstName"] isEqual:[NSNull null]]) {
            _claimInvolvedDriverFirstNameLbl.text = [self.selectedClaim valueForKey:@"InvolvedFirstName"] ? [self.selectedClaim valueForKey:@"InvolvedFirstName"] : localizeString(@"Not specified");
            if ([_claimInvolvedDriverFirstNameLbl.text isEqualToString:@""] || [_claimInvolvedDriverFirstNameLbl.text isEqualToString:@"null"])
                _claimInvolvedDriverFirstNameLbl.text = localizeString(@"Not specified");
        } else {
            _claimInvolvedDriverFirstNameLbl.text = localizeString(@"Not specified");
        }
        
        if (![[self.selectedClaim valueForKey:@"InvolvedLastName"] isEqual:[NSNull null]]) {
            _claimInvolvedDriverLastNameLbl.text = [self.selectedClaim valueForKey:@"InvolvedLastName"] ? [self.selectedClaim valueForKey:@"InvolvedLastName"] : localizeString(@"Not specified");
            if ([_claimInvolvedDriverLastNameLbl.text isEqualToString:@""] || [_claimInvolvedDriverLastNameLbl.text isEqualToString:@"null"])
                _claimInvolvedDriverLastNameLbl.text = localizeString(@"Not specified");
        } else {
            _claimInvolvedDriverLastNameLbl.text = localizeString(@"Not specified");
        }
        
        if (![[self.selectedClaim valueForKey:@"InvolvedLicenseNo"] isEqual:[NSNull null]]) {
            _claimInvolvedLicenseNoLbl.text = [self.selectedClaim valueForKey:@"InvolvedLicenseNo"] ? [self.selectedClaim valueForKey:@"InvolvedLicenseNo"] : localizeString(@"Not specified");
            if ([_claimInvolvedLicenseNoLbl.text isEqualToString:@""] || [_claimInvolvedLicenseNoLbl.text isEqualToString:@"null"])
                _claimInvolvedLicenseNoLbl.text = localizeString(@"Not specified");
        } else {
            _claimInvolvedLicenseNoLbl.text = localizeString(@"Not specified");
        }
        
        if (![[self.selectedClaim valueForKey:@"InvolvedVehicleLicenseplateno"] isEqual:[NSNull null]]) {
            _claimInvolvedCarPlateLbl.text = [self.selectedClaim valueForKey:@"InvolvedVehicleLicenseplateno"] ? [self.selectedClaim valueForKey:@"InvolvedVehicleLicenseplateno"] : localizeString(@"Not specified");
            if ([_claimInvolvedCarPlateLbl.text isEqualToString:@""] || [_claimInvolvedCarPlateLbl.text isEqualToString:@"null"])
                _claimInvolvedCarPlateLbl.text = localizeString(@"Not specified");
        } else {
            _claimInvolvedCarPlateLbl.text = localizeString(@"Not specified");
        }
        
    } else {
        
        self.backBtn.hidden = NO;
        self.confirmBtn.hidden = NO;
        self.bottomView.hidden = NO;
        
        NSString *dateClaimFormat = localizeString(@"Not specified");
        NSString *claimDateTime = [ClaimsService sharedService].ClaimDateTime ? [ClaimsService sharedService].ClaimDateTime : localizeString(@"Not specified");
        if (![claimDateTime isEqual:[NSNull null]]) {
            NSDate *date = [NSDate dateWithISO8601String:claimDateTime];
            dateClaimFormat = [date dateString];
        } else {
            dateClaimFormat = localizeString(@"Not specified");
        }
        
        _claimAccidentTypeLbl.text = [ClaimsService sharedService].AccidentTypeLabel;
        _claimDriverFirstNameLbl.text = [ClaimsService sharedService].DriverFirstName;
        _claimDriverLastNameLbl.text = [ClaimsService sharedService].DriverLastName;
        _claimDriverLicenseNoLbl.text = [ClaimsService sharedService].DriverLicenseNo ? [ClaimsService sharedService].DriverLicenseNo : localizeString(@"Not specified");
        if ([_claimDriverLicenseNoLbl.text isEqualToString:@""])
            _claimDriverLicenseNoLbl.text = localizeString(@"Not specified");
        
        _claimCarMakeLbl.text = [ClaimsService sharedService].CarMake;
        _claimCarModelLbl.text = [ClaimsService sharedService].CarModel;
        _claimCarYearLbl.text = [ClaimsService sharedService].CarYear ? [ClaimsService sharedService].CarYear : localizeString(@"Not specified");
        _claimCarTypeLbl.text = [ClaimsService sharedService].CarType ? [ClaimsService sharedService].CarType : localizeString(@"Not specified");
        _claimCarVinLbl.text = [ClaimsService sharedService].CarVin ? [ClaimsService sharedService].CarVin : localizeString(@"Not specified");
        _claimCarPaintingLbl.text = [ClaimsService sharedService].CarPainting;
        _claimDateTimeLbl.text = dateClaimFormat;
        _claimLocationLbl.text = [ClaimsService sharedService].LocationStr ? [ClaimsService sharedService].LocationStr : localizeString(@"Not specified");
        if ([_claimLocationLbl.text isEqualToString:@""])
            _claimLocationLbl.text = localizeString(@"Not specified");
        
        _claimDescriptionLbl.text = [ClaimsService sharedService].DriverComments ? [ClaimsService sharedService].DriverComments : localizeString(@"Not specified");
        
        if ([[ClaimsService sharedService].CarDrivable isEqualToString:@"true"])
            _claimCarDriveLbl.text = @"YES";
        else {
            _claimCarDriveLbl.text = @"NO";
        }
        if ([[ClaimsService sharedService].CarTowing isEqualToString:@"true"])
            _claimCarTowingLbl.text = @"YES";
        else {
            _claimCarTowingLbl.text = @"NO";
        }
        
        _claimInvolvedDriverFirstNameLbl.text = [ClaimsService sharedService].InvolvedFirstName ? [ClaimsService sharedService].InvolvedFirstName : localizeString(@"Not specified");
        _claimInvolvedDriverLastNameLbl.text = [ClaimsService sharedService].InvolvedLastName ? [ClaimsService sharedService].InvolvedLastName : localizeString(@"Not specified");
        _claimInvolvedLicenseNoLbl.text = [ClaimsService sharedService].InvolvedLicenseNo ? [ClaimsService sharedService].InvolvedLicenseNo : localizeString(@"Not specified");
        _claimInvolvedCarPlateLbl.text = [ClaimsService sharedService].InvolvedVehicleLicenseplateno ? [ClaimsService sharedService].InvolvedVehicleLicenseplateno : localizeString(@"Not specified");
        _claimPhotosCountLbl.text = @"Photos Uploaded";
        
        if ([[ClaimsService sharedService].InvolvedFirstName isEqualToString:@""]) {
            _claimInvolvedDriverFirstNameLbl.text = localizeString(@"Not specified");
        }
        if ([[ClaimsService sharedService].InvolvedLastName isEqualToString:@""]) {
            _claimInvolvedDriverLastNameLbl.text = localizeString(@"Not specified");
        }
        if ([[ClaimsService sharedService].InvolvedLicenseNo isEqualToString:@""]) {
            _claimInvolvedLicenseNoLbl.text = localizeString(@"Not specified");
        }
        if ([[ClaimsService sharedService].InvolvedVehicleLicenseplateno isEqualToString:@""]) {
            _claimInvolvedCarPlateLbl.text = localizeString(@"Not specified");
        }
    }
}


#pragma mark - Setup Views

- (void)setupPhotosCollectionFromCache {
    
    _urlsFull = [[NSMutableArray alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *filePath_LEFT0 = @"";
    if (![[ClaimsService sharedService].Photo_Left_Wide isEqualToString:@""] && [ClaimsService sharedService].Photo_Left_Wide != nil && ![[ClaimsService sharedService].Photo_Left_Wide isEqualToString:@"(null)"]) {
        filePath_LEFT0 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoLEFT0.png"];
        [_urlsFull addObject:filePath_LEFT0];
    }
    NSString *filePath_LEFT1 = @"";
    if (![[ClaimsService sharedService].Photo_Left_Front_Wing isEqualToString:@""] && [ClaimsService sharedService].Photo_Left_Front_Wing != nil && ![[ClaimsService sharedService].Photo_Left_Front_Wing isEqualToString:@"(null)"]) {
        filePath_LEFT1 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoLEFT1.png"];
        [_urlsFull addObject:filePath_LEFT1];
    }
    NSString *filePath_LEFT2 = @"";
    if (![[ClaimsService sharedService].Photo_Left_Front_Door isEqualToString:@""] && [ClaimsService sharedService].Photo_Left_Front_Door != nil && ![[ClaimsService sharedService].Photo_Left_Front_Door isEqualToString:@"(null)"]) {
        filePath_LEFT2 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoLEFT2.png"];
        [_urlsFull addObject:filePath_LEFT2];
    }
    NSString *filePath_LEFT3 = @"";
    if (![[ClaimsService sharedService].Photo_Left_Rear_Door isEqualToString:@""] && [ClaimsService sharedService].Photo_Left_Rear_Door != nil && ![[ClaimsService sharedService].Photo_Left_Rear_Door isEqualToString:@"(null)"]) {
        filePath_LEFT3 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoLEFT3.png"];
        [_urlsFull addObject:filePath_LEFT3];
    }
    NSString *filePath_LEFT4 = @"";
    if (![[ClaimsService sharedService].Photo_Left_Rear_Wing isEqualToString:@""] && [ClaimsService sharedService].Photo_Left_Rear_Wing != nil && ![[ClaimsService sharedService].Photo_Left_Rear_Wing isEqualToString:@"(null)"]) {
        filePath_LEFT4 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoLEFT4.png"];
        [_urlsFull addObject:filePath_LEFT4];
    }
    
    //
    NSString *filePath_REAR0 = @"";
    if (![[ClaimsService sharedService].Photo_Rear_Left_Diagonal isEqualToString:@""] && [ClaimsService sharedService].Photo_Rear_Left_Diagonal != nil && ![[ClaimsService sharedService].Photo_Rear_Left_Diagonal isEqualToString:@"(null)"]) {
        filePath_REAR0 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoREAR0.png"];
        [_urlsFull addObject:filePath_REAR0];
    }
    NSString *filePath_REAR1 = @"";
    if (![[ClaimsService sharedService].Photo_Rear_Wide isEqualToString:@""] && [ClaimsService sharedService].Photo_Rear_Wide != nil && ![[ClaimsService sharedService].Photo_Rear_Wide isEqualToString:@"(null)"]) {
        filePath_REAR1 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoREAR1.png"];
        [_urlsFull addObject:filePath_REAR1];
    }
    NSString *filePath_REAR2 = @"";
    if (![[ClaimsService sharedService].Photo_Rear_Right_Diagonal isEqualToString:@""] && [ClaimsService sharedService].Photo_Rear_Right_Diagonal != nil && ![[ClaimsService sharedService].Photo_Rear_Right_Diagonal isEqualToString:@"(null)"]) {
        filePath_REAR2 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoREAR2.png"];
        [_urlsFull addObject:filePath_REAR2];
    }
    
    //
    NSString *filePath_RIGHT0 = @"";
    if (![[ClaimsService sharedService].Photo_Right_Wide isEqualToString:@""] && [ClaimsService sharedService].Photo_Right_Wide != nil && ![[ClaimsService sharedService].Photo_Right_Wide isEqualToString:@"(null)"]) {
        filePath_RIGHT0 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoRIGHT0.png"];
        [_urlsFull addObject:filePath_RIGHT0];
    }
    NSString *filePath_RIGHT1 = @"";
    if (![[ClaimsService sharedService].Photo_Right_Front_Wing isEqualToString:@""] && [ClaimsService sharedService].Photo_Right_Front_Wing != nil && ![[ClaimsService sharedService].Photo_Right_Front_Wing isEqualToString:@"(null)"]) {
        filePath_RIGHT1 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoRIGHT1.png"];
        [_urlsFull addObject:filePath_RIGHT1];
    }
    NSString *filePath_RIGHT2 = @"";
    if (![[ClaimsService sharedService].Photo_Right_Front_Door isEqualToString:@""] && [ClaimsService sharedService].Photo_Right_Front_Door != nil && ![[ClaimsService sharedService].Photo_Right_Front_Door isEqualToString:@"(null)"]) {
        filePath_RIGHT2 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoRIGHT2.png"];
        [_urlsFull addObject:filePath_RIGHT2];
    }
    NSString *filePath_RIGHT3 = @"";
    if (![[ClaimsService sharedService].Photo_Right_Rear_Door isEqualToString:@""] && [ClaimsService sharedService].Photo_Right_Rear_Door != nil && ![[ClaimsService sharedService].Photo_Right_Rear_Door isEqualToString:@"(null)"]) {
        filePath_RIGHT3 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoRIGHT3.png"];
        [_urlsFull addObject:filePath_RIGHT3];
    }
    NSString *filePath_RIGHT4 = @"";
    if (![[ClaimsService sharedService].Photo_Right_Rear_Wing isEqualToString:@""] && [ClaimsService sharedService].Photo_Right_Rear_Wing != nil && ![[ClaimsService sharedService].Photo_Right_Rear_Wing isEqualToString:@"(null)"]) {
        filePath_RIGHT4 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoRIGHT4.png"];
        [_urlsFull addObject:filePath_RIGHT4];
    }
    
    //
    NSString *filePath_FRONT0 = @"";
    if (![[ClaimsService sharedService].Photo_Front_Right_Diagonal isEqualToString:@""] && [ClaimsService sharedService].Photo_Front_Right_Diagonal != nil && ![[ClaimsService sharedService].Photo_Front_Right_Diagonal isEqualToString:@"(null)"]) {
        filePath_FRONT0 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoFRONT0.png"];
        [_urlsFull addObject:filePath_FRONT0];
    }
    NSString *filePath_FRONT1 = @"";
    if (![[ClaimsService sharedService].Photo_Front_Wide isEqualToString:@""] && [ClaimsService sharedService].Photo_Front_Wide != nil && ![[ClaimsService sharedService].Photo_Front_Wide isEqualToString:@"(null)"]) {
        filePath_FRONT1 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoFRONT1.png"];
        [_urlsFull addObject:filePath_FRONT1];
    }
    NSString *filePath_FRONT2 = @"";
    if (![[ClaimsService sharedService].Photo_Front_Left_Diagonal isEqualToString:@""] && [ClaimsService sharedService].Photo_Front_Left_Diagonal != nil && ![[ClaimsService sharedService].Photo_Front_Left_Diagonal isEqualToString:@"(null)"]) {
        filePath_FRONT2 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoFRONT2.png"];
        [_urlsFull addObject:filePath_FRONT2];
    }
    NSString *filePath_WIND0 = @"";
    if (![[ClaimsService sharedService].Photo_Windshield_Wide isEqualToString:@""] && [ClaimsService sharedService].Photo_Windshield_Wide != nil && ![[ClaimsService sharedService].Photo_Rear_Wide isEqualToString:@"(null)"]) {
        filePath_WIND0 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoWIND0.png"];
        [_urlsFull addObject:filePath_WIND0];
    }
    NSString *filePath_DASH0 = @"";
    if (![[ClaimsService sharedService].Photo_Dashboard_Wide isEqualToString:@""] && [ClaimsService sharedService].Photo_Dashboard_Wide != nil && ![[ClaimsService sharedService].Photo_Dashboard_Wide isEqualToString:@"(null)"]) {
        filePath_DASH0 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoDASH0.png"];
        [_urlsFull addObject:filePath_DASH0];
    }
    
    if (_urlsFull.count == 0) {
        _claimPhotosCountLbl.text = @"Photos Not Uploaded";
        _claimPhotosCountLbl.hidden = NO;
        [self exequeScrollViewHeigh];
    } else {
        [self.collectionView reloadData];
    }
}

- (void)setupPhotosCollectionFromUrls {
    _urlsFull = [[NSMutableArray alloc] init];
    
    if (self.selectedClaim.count != 0) {
        NSDictionary *screens = [[self.selectedClaim valueForKey:@"Screens"] objectAtIndex:0];
        
        if (screens != nil) {
            if (![[[screens valueForKey:@"Left"] valueForKey:@"url"] isEqual:[NSNull null]]) {
                [_urlsFull addObject:[[screens valueForKey:@"Left"] valueForKey:@"url"]];
            }
            if (![[[screens valueForKey:@"LeftFrontWing"] valueForKey:@"url"] isEqual:[NSNull null]]) {
                [_urlsFull addObject:[[screens valueForKey:@"LeftFrontWing"] valueForKey:@"url"]];
            }
            if (![[[screens valueForKey:@"LeftFrontDoor"] valueForKey:@"url"] isEqual:[NSNull null]]) {
                [_urlsFull addObject:[[screens valueForKey:@"LeftFrontDoor"] valueForKey:@"url"]];
            }
            if (![[[screens valueForKey:@"LeftRearDoor"] valueForKey:@"url"] isEqual:[NSNull null]]) {
                [_urlsFull addObject:[[screens valueForKey:@"LeftRearDoor"] valueForKey:@"url"]];
            }
            if (![[[screens valueForKey:@"LeftRearWing"] valueForKey:@"url"] isEqual:[NSNull null]]) {
                [_urlsFull addObject:[[screens valueForKey:@"LeftRearWing"] valueForKey:@"url"]];
            }
            
            if (![[[screens valueForKey:@"BackLeftDiagonal"] valueForKey:@"url"] isEqual:[NSNull null]]) {
                [_urlsFull addObject:[[screens valueForKey:@"BackLeftDiagonal"] valueForKey:@"url"]];
            }
            if (![[[screens valueForKey:@"Back"] valueForKey:@"url"] isEqual:[NSNull null]]) {
                [_urlsFull addObject:[[screens valueForKey:@"Back"] valueForKey:@"url"]];
            }
            if (![[[screens valueForKey:@"BackRightDiagonal"] valueForKey:@"url"] isEqual:[NSNull null]]) {
                [_urlsFull addObject:[[screens valueForKey:@"BackRightDiagonal"] valueForKey:@"url"]];
            }
            
            if (![[[screens valueForKey:@"Right"] valueForKey:@"url"] isEqual:[NSNull null]]) {
                [_urlsFull addObject:[[screens valueForKey:@"Right"] valueForKey:@"url"]];
            }
            if (![[[screens valueForKey:@"RightFrontWing"] valueForKey:@"url"] isEqual:[NSNull null]]) {
                [_urlsFull addObject:[[screens valueForKey:@"RightFrontWing"] valueForKey:@"url"]];
            }
            if (![[[screens valueForKey:@"RightFrontDoor"] valueForKey:@"url"] isEqual:[NSNull null]]) {
                [_urlsFull addObject:[[screens valueForKey:@"RightFrontDoor"] valueForKey:@"url"]];
            }
            if (![[[screens valueForKey:@"RightRearDoor"] valueForKey:@"url"] isEqual:[NSNull null]]) {
                [_urlsFull addObject:[[screens valueForKey:@"RightRearDoor"] valueForKey:@"url"]];
            }
            if (![[[screens valueForKey:@"RightRearWing"] valueForKey:@"url"] isEqual:[NSNull null]]) {
                [_urlsFull addObject:[[screens valueForKey:@"RightRearWing"] valueForKey:@"url"]];
            }
            
            if (![[[screens valueForKey:@"FrontRightDiagonal"] valueForKey:@"url"] isEqual:[NSNull null]]) {
                [_urlsFull addObject:[[screens valueForKey:@"FrontRightDiagonal"] valueForKey:@"url"]];
            }
            if (![[[screens valueForKey:@"FrontLeftDiagonal"] valueForKey:@"url"] isEqual:[NSNull null]]) {
                [_urlsFull addObject:[[screens valueForKey:@"FrontLeftDiagonal"] valueForKey:@"url"]];
            }
            if (![[[screens valueForKey:@"Front"] valueForKey:@"url"] isEqual:[NSNull null]]) {
                [_urlsFull addObject:[[screens valueForKey:@"Front"] valueForKey:@"url"]];
            }
            if (![[[screens valueForKey:@"Windshield"] valueForKey:@"url"] isEqual:[NSNull null]]) {
                [_urlsFull addObject:[[screens valueForKey:@"Windshield"] valueForKey:@"url"]];
            }
            if (![[[screens valueForKey:@"Dashboard"] valueForKey:@"url"] isEqual:[NSNull null]]) {
                [_urlsFull addObject:[[screens valueForKey:@"Dashboard"] valueForKey:@"url"]];
            }
        }
        
        if (_urlsFull.count == 0) {
            _claimPhotosCountLbl.hidden = NO;
            _claimPhotosCountLbl.text = @"Photos have not been attached";
        } else {
            _claimPhotosCountLbl.hidden = YES;
            [self.collectionView reloadData];
        }
    }
}

- (void)exequeScrollViewHeigh {
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/2, 0.0);
    if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/4.7, 0.0);
    } else if (IS_IPHONE_11 || IS_IPHONE_12_PRO) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/1.2, 0.0);
    } else if (IS_IPHONE_8P) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/2.6, 0.0);
    } else if (IS_IPHONE_8) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height + 140, 0.0);
    } else if (IS_IPHONE_5 || IS_IPHONE_4) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height + 170, 0.0);
    }
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


#pragma mark - CollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _urlsFull.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KSPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    if (self.hideBottomButtons) {
//        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_urlsFull[indexPath.row]]];
//        UIImage* sourceImage = [UIImage imageWithData:imageData];
//        UIImage* flippedImage = [UIImage imageWithCGImage:sourceImage.CGImage scale:sourceImage.scale  orientation:UIImageOrientationUp];
//        cell.imageView.image = flippedImage;
        
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:_urlsFull[indexPath.row]] placeholderImage:[UIImage imageNamed:@"net_photo"]];
    } else {
        NSData *imageData = [NSData dataWithContentsOfFile:_urlsFull[indexPath.row]];
        UIImage* sourceImage = [UIImage imageWithData:imageData];
        UIImage* flippedImage = [UIImage imageWithCGImage:sourceImage.CGImage
                                                    scale:sourceImage.scale
                                              orientation:UIImageOrientationUp];
        
        cell.imageView.image = flippedImage;
        //cell.imageView.image = [UIImage imageWithData:imageData];
    }
    return cell;
}


#pragma mark - CollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray *items = @[].mutableCopy;
    if (self.hideBottomButtons) {
        for (int i = 0; i < _urlsFull.count; i++) {
            KSPhotoCell *cell = (KSPhotoCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            NSString *url = _urlsFull[i];
            KSPhotoItem *item = [KSPhotoItem itemWithSourceView:cell.imageView imageUrl:[NSURL URLWithString:url]];
            [items addObject:item];
        }
    } else {
        for (int i = 0; i < _urlsFull.count; i++) {
            KSPhotoCell *cell = (KSPhotoCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            NSData *imageData = [NSData dataWithContentsOfFile:_urlsFull[i]];
            KSPhotoItem *item = [KSPhotoItem itemWithSourceView:cell.imageView image:[UIImage imageWithData:imageData]];
            [items addObject:item];
        }
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (self.presentedViewController) {
        [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            int i = 0;
            for (KSPhotoItem *item in self.photoItems) {
                KSPhotoCell *cell = (KSPhotoCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i++ inSection:0]];
                item.sourceView = cell.imageView;
            }
        }];
    }
}

- (void)showBrowserWithPhotoItems:(NSArray *)items selectedIndex:(NSUInteger)selectedIndex {
    self.photoItems = items;
    KSPhotoBrowser *browser = [KSPhotoBrowser browserWithPhotoItems:items selectedIndex:selectedIndex];
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
    returnSize = CGSizeMake(self.view.frame.size.width/4-1, self.view.frame.size.width/4-1);
    return returnSize;
}

- (void)ks_photoBrowser:(KSPhotoBrowser *)browser didSelectItem:(KSPhotoItem *)item atIndex:(NSUInteger)index {
    NSLog(@"Photo selected index: %ld", index);
}


#pragma mark - Navigation

- (IBAction)confirmBtnAction:(id)sender {
    
    if (self.hideBottomButtons) {
        CATransition *transition = [[CATransition alloc] init];
        transition.duration = 0.3;
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromLeft;
        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        [self.view.window.layer addAnimation:transition forKey:kCATransition];
        [self dismissViewControllerAnimated:NO completion:nil];
        
    } else {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(claimSuccessUpdate) name:@"claimSuccessUpdate" object:nil];
        [self showPreloader];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
            [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
                if (!error && [response isSuccesful]) {
                    NSLog(@"Success Claim Upload");
                } else {
                    //Error
                }
            }] createClaim:nil];
        });
    }
}

- (IBAction)claimSuccessUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hidePreloader];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:localizeString(@"Successful") message:[NSString stringWithFormat:@"%@", localizeString(@"Your request was successfully sent! Please, wait for consideration.")] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:localizeString(@"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[[[[[[[[self presentingViewController] presentingViewController] presentingViewController] presentingViewController] presentingViewController] presentingViewController] presentingViewController] presentingViewController] dismissViewControllerAnimated:NO completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"claimsNeedUpdateNow" object:self];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"claimsNeedUpdateNow" object:self];
            });
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (IBAction)dismissAction:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backAction:(id)sender {
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.3;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
