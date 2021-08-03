//
//  NewClaimViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "NewClaimViewController.h"
#import "DelegateCollectionViewFillLayout.h"
#import "NewClaimCell.h"
#import "TowingViewController.h"
#import "Color.h"
#import "Helpers.h"
#import "UIViewController+Preloader.h"
#import "IQDropDownTextField.h"

static NSString *const reuseIdentifier = @"claimCell";

@interface NewClaimViewController () <DelegateCollectionViewFillLayoutDelegate, IQDropDownTextFieldDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView               *claimsCollectionView;
@property (weak, nonatomic) IBOutlet IQDropDownTextField            *textFieldCarPicker;
@property (strong, nonatomic) DelegateCollectionViewFillLayout      *aLayout;
@property (strong, nonatomic) TelematicsAppModel                           *appModel;
@property (strong, nonatomic) NSMutableArray                        *carsNamesShort;

- (void)setupLayout;

@end

@implementation NewClaimViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAccidentButtons];
    
    UIView* left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
    self.textFieldCarPicker.leftView = left;
    self.textFieldCarPicker.leftViewMode = UITextFieldViewModeAlways;
    
    self.textFieldCarPicker.textColor = [UIColor darkGrayColor];
    [self.textFieldCarPicker setBackgroundColor:[Color lightSeparatorColor]];
    [self.textFieldCarPicker.layer setMasksToBounds:YES];
    [self.textFieldCarPicker.layer setCornerRadius:18.0f];
    [self.textFieldCarPicker.layer setBorderColor:[[Color grayColor] CGColor]];
    [self.textFieldCarPicker.layer setBorderWidth:1.5];
    self.textFieldCarPicker.showDismissToolbar = YES;
    self.textFieldCarPicker.pickerView.backgroundColor = [Color officialWhiteColor];
    
    [self.textFieldCarPicker setItemList:self.carsNamesShort];
    [self.textFieldCarPicker setItemListUI:self.carsNamesShort];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
}

- (void)setupAccidentButtons {
    [self setupLayout];
}

- (void)setupLayout {
    _aLayout = [[DelegateCollectionViewFillLayout alloc] init];
    _aLayout.delegate = self;
    _aLayout.direction = DelegateCollectionViewFillLayoutVertical;
    _claimsCollectionView.collectionViewLayout = _aLayout;
}


#pragma mark CarPicker

- (void)textField:(nonnull IQDropDownTextField*)textField didSelectItem:(nullable NSString*)item {
    NSUInteger selNum = [self.carsNamesShort indexOfObject:item];
    if (item != nil) {
        NSString *carTk = [[self.appModel.vehicleShortData objectAtIndex:selNum] valueForKey:@"Token"];
        NSString *carMake = [[self.appModel.vehicleShortData objectAtIndex:selNum] valueForKey:@"Manufacturer"];
        NSString *carModel = [[self.appModel.vehicleShortData objectAtIndex:selNum] valueForKey:@"Model"];
        NSString *carVin = [[self.appModel.vehicleShortData objectAtIndex:selNum] valueForKey:@"Vin"];
        NSString *carType = [[self.appModel.vehicleShortData objectAtIndex:selNum] valueForKey:@"Type"];
        NSString *carYear = [[self.appModel.vehicleShortData objectAtIndex:selNum] valueForKey:@"CarYear"];
        NSString *carPainting = @"solid"; //[[self.appModel.vehicleShortData objectAtIndex:selNum] valueForKey:@"ColorType"];
        NSString *carUserLicenseInCar = [[self.appModel.vehicleShortData objectAtIndex:selNum] valueForKey:@"PlateNumber"];
        
        [ClaimsService sharedService].CarToken = carTk;
        [ClaimsService sharedService].CarMake = carMake;
        [ClaimsService sharedService].CarModel = carModel;
        [ClaimsService sharedService].CarVin = carVin;
        [ClaimsService sharedService].CarType = carType;
        [ClaimsService sharedService].CarYear = carYear;
        [ClaimsService sharedService].CarPainting = carPainting;
        [ClaimsService sharedService].CarLicensePlate = carUserLicenseInCar;
    } else {
        [ClaimsService sharedService].CarToken = nil;
    }
}


#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([ClaimsService sharedService].AccidentTypes.count == 0) {
        return 8;
    } else {
        return [ClaimsService sharedService].AccidentTypes.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NewClaimCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    if ([ClaimsService sharedService].AccidentTypes.count == 0) {
        if (indexPath.row == 0) {
            cell.accImg.image = [UIImage imageNamed:@"acc_ins"];
            cell.accLabel.text = @"Inspection";
        } else if (indexPath.row == 1) {
            cell.accImg.image = [UIImage imageNamed:@"acc_road"];
            cell.accLabel.text = @"Road Accident";
        } else if (indexPath.row == 2) {
            cell.accImg.image = [UIImage imageNamed:@"acc_vandalism"];
            cell.accLabel.text = @"Vandalism";
        } else if (indexPath.row == 3) {
            cell.accImg.image = [UIImage imageNamed:@"acc_fire"];
            cell.accLabel.text = @"Fire Damage";
        } else if (indexPath.row == 4) {
            cell.accImg.image = [UIImage imageNamed:@"acc_wind"];
            cell.accLabel.text = @"Glass Damage";
        } else if (indexPath.row == 5) {
            cell.accImg.image = [UIImage imageNamed:@"acc_cataclysm"];
            cell.accLabel.text = @"Cataclysm";
        } else if (indexPath.row == 6) {
            cell.accImg.image = [UIImage imageNamed:@"acc_animals"];
            cell.accLabel.text = @"Animals";
        } else if (indexPath.row == 7) {
            cell.accImg.image = [UIImage imageNamed:@"acc_hijack"];
            cell.accLabel.text = @"Hijacking";
        }
    } else {
        NSString *accKey = [[[ClaimsService sharedService].AccidentTypes objectAtIndex:indexPath.row] valueForKey:@"Key"];
        cell.hidden = NO;
        
        if ([accKey isEqualToString:@"road_accident"]) {
            cell.accImg.image = [UIImage imageNamed:@"acc_road"];
            cell.accLabel.text = @"Road Accident";
        } else if ([accKey isEqualToString:@"fire_damage"]) {
            cell.accImg.image = [UIImage imageNamed:@"acc_fire"];
            cell.accLabel.text = @"Fire Damage";
        } else if ([accKey isEqualToString:@"cataclysm"]) {
            cell.accImg.image = [UIImage imageNamed:@"acc_cataclysm"];
            cell.accLabel.text = @"Cataclysm";
        } else if ([accKey isEqualToString:@"hijacking"]) {
            cell.accImg.image = [UIImage imageNamed:@"acc_hijack"];
            cell.accLabel.text = @"Hijacking";
        } else if ([accKey isEqualToString:@"vandalism"]) {
            cell.accImg.image = [UIImage imageNamed:@"acc_vandalism"];
            cell.accLabel.text = @"Vandalism";
        } else if ([accKey isEqualToString:@"glass_damage"]) {
            cell.accImg.image = [UIImage imageNamed:@"acc_wind"];
            cell.accLabel.text = @"Glass Damage";
        } else if ([accKey isEqualToString:@"animals"]) {
            cell.accImg.image = [UIImage imageNamed:@"acc_animals"];
            cell.accLabel.text = @"Animals";
        } else if ([accKey isEqualToString:@"other"]) {
            cell.accImg.image = nil;
            cell.accLabel.text = nil;
            cell.hidden = YES;
        }
    }
    return cell;
}


#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    [ClaimsService sharedService].AccidentTypeKey = [[[ClaimsService sharedService].AccidentTypes objectAtIndex:indexPath.row] valueForKey:@"Key"];
    [ClaimsService sharedService].AccidentTypeLabel = [[[ClaimsService sharedService].AccidentTypes objectAtIndex:indexPath.row] valueForKey:@"Label"];
    
    TowingViewController* towing = [self.storyboard instantiateViewControllerWithIdentifier:@"TowingViewController"];
    towing.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:towing animated:YES completion:nil];
}

- (IBAction)otherAccidentBtnClick:(id)sender {
    
    [ClaimsService sharedService].AccidentTypeKey = @"other";
    [ClaimsService sharedService].AccidentTypeLabel = @"Other";
    
    TowingViewController* towing = [self.storyboard instantiateViewControllerWithIdentifier:@"TowingViewController"];
    towing.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:towing animated:YES completion:nil];
}


#pragma mark - DelegateCollectionViewFillLayoutDelegate

- (NSInteger)numberOfItemsInSide {
    return 2;
}

- (CGFloat)itemLength {
    return 100.0f;
}

- (CGFloat)itemSpacing {
    return 10.0f;
}


#pragma mark - Navigation

- (IBAction)dismissAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
