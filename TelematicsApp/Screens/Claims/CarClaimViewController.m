//
//  CarClaimViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "CarClaimViewController.h"
#import "NewClaimViewController.h"
#import "AddCarCtrl.h"
#import "RetypeVehicleCtrl.h"
#import "ClaimCarCell.h"
#import "Color.h"
#import "Helpers.h"
#import "UIViewController+Preloader.h"


@interface CarClaimViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView            *tableView;
@property (weak, nonatomic) IBOutlet UILabel                *tablePlaceholderLbl;
@property (weak, nonatomic) IBOutlet UIButton               *plusBtn;
@property (strong, nonatomic) TelematicsAppModel                   *appModel;
@property (nonatomic) NSInteger                             loadSelectedByUserCar;

@end


@implementation CarClaimViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ClaimsService sharedService].CarToken = nil;
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    if (self.appModel.vehicleShortData.count == 0) {
        self.tablePlaceholderLbl.hidden = NO;
    } else {
        self.tablePlaceholderLbl.hidden = YES;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:@"reloadUserVehiclesForClaims" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
}

- (void)reloadTableData {
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.appModel.vehicleShortData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClaimCarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClaimCarCell"];
    if (!cell) {
        cell = [[ClaimCarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ClaimCarCell"];
    }
    
    cell.carName.text = [[self.appModel.vehicleShortData objectAtIndex:indexPath.row] valueForKey:@"Manufacturer"];
    cell.carDescription.text = [[self.appModel.vehicleShortData objectAtIndex:indexPath.row] valueForKey:@"PlateNumber"] ? [[self.appModel.vehicleShortData objectAtIndex:indexPath.row] valueForKey:@"PlateNumber"] : @"Plate Number not specified";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGFloat height = cell.frame.size.height;
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *carTk = [[self.appModel.vehicleShortData objectAtIndex:indexPath.row] valueForKey:@"Token"];
    NSString *carMake = [[self.appModel.vehicleShortData objectAtIndex:indexPath.row] valueForKey:@"Manufacturer"];
    NSString *carModel = [[self.appModel.vehicleShortData objectAtIndex:indexPath.row] valueForKey:@"Model"];
    NSString *carVin = [[self.appModel.vehicleShortData objectAtIndex:indexPath.row] valueForKey:@"Vin"];
    NSString *carType = [[self.appModel.vehicleShortData objectAtIndex:indexPath.row] valueForKey:@"Type"];
    NSString *carYear = [[self.appModel.vehicleShortData objectAtIndex:indexPath.row] valueForKey:@"CarYear"];
    NSString *carPainting = [[self.appModel.vehicleShortData objectAtIndex:indexPath.row] valueForKey:@"ColorType"];
    NSString *carLicensePlateNumber = [[self.appModel.vehicleShortData objectAtIndex:indexPath.row] valueForKey:@"PlateNumber"];
    NSString *carNickname = [[self.appModel.vehicleShortData objectAtIndex:indexPath.row] valueForKey:@"Name"];
    NSString *carMileage = [[self.appModel.vehicleShortData objectAtIndex:indexPath.row] valueForKey:@"InitialMilage"];
    self.loadSelectedByUserCar = indexPath.row;
    
    if (carTk == nil || carMake == nil || carModel == nil || carVin == nil || carYear == nil || carPainting == nil || carLicensePlateNumber == nil || carNickname == nil || carMileage == nil) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userUpdatedVehicleManually) name:@"userUpdatedVehicleManually" object:nil];
        
        RetypeVehicleCtrl* retypeCar = [self.storyboard instantiateViewControllerWithIdentifier:@"RetypeVehicleCtrl"];
        retypeCar.vehicleTokenString = carTk;
        retypeCar.vinCodeStr = carVin;
        retypeCar.plateString = carLicensePlateNumber;
        retypeCar.manufacturerString = carMake;
        retypeCar.modelString = carModel;
        retypeCar.typeString = carType;
        retypeCar.nicknameString = carNickname;
        retypeCar.yearString = carYear;
        retypeCar.mileageString = carMileage;
        retypeCar.paintingString = carPainting;

        retypeCar.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:retypeCar animated:YES completion:nil];
        return;
    }
    
    [ClaimsService sharedService].CarToken = carTk;
    [ClaimsService sharedService].CarMake = carMake;
    [ClaimsService sharedService].CarModel = carModel;
    [ClaimsService sharedService].CarVin = carVin;
    [ClaimsService sharedService].CarType = carType;
    [ClaimsService sharedService].CarYear = carYear;
    [ClaimsService sharedService].CarPainting = carPainting;
    [ClaimsService sharedService].CarLicensePlate = carLicensePlateNumber;
    
    NewClaimViewController* detailClaim = [self.storyboard instantiateViewControllerWithIdentifier:@"NewClaimViewController"];
    detailClaim.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:detailClaim animated:YES completion:nil];
}

- (void)userUpdatedVehicleManually {
    NSString *carTk = [[self.appModel.vehicleShortData objectAtIndex:self.loadSelectedByUserCar] valueForKey:@"Token"];
    NSString *carMake = [[self.appModel.vehicleShortData objectAtIndex:self.loadSelectedByUserCar] valueForKey:@"Manufacturer"];
    NSString *carModel = [[self.appModel.vehicleShortData objectAtIndex:self.loadSelectedByUserCar] valueForKey:@"Model"];
    NSString *carVin = [[self.appModel.vehicleShortData objectAtIndex:self.loadSelectedByUserCar] valueForKey:@"Vin"];
    NSString *carType = [[self.appModel.vehicleShortData objectAtIndex:self.loadSelectedByUserCar] valueForKey:@"Type"];
    NSString *carYear = [[self.appModel.vehicleShortData objectAtIndex:self.loadSelectedByUserCar] valueForKey:@"CarYear"];
    NSString *carPainting = [[self.appModel.vehicleShortData objectAtIndex:self.loadSelectedByUserCar] valueForKey:@"ColorType"];
    NSString *carLicensePlateNumber = [[self.appModel.vehicleShortData objectAtIndex:self.loadSelectedByUserCar] valueForKey:@"PlateNumber"];
    
    [ClaimsService sharedService].CarToken = carTk;
    [ClaimsService sharedService].CarMake = carMake;
    [ClaimsService sharedService].CarModel = carModel;
    [ClaimsService sharedService].CarVin = carVin;
    [ClaimsService sharedService].CarType = carType;
    [ClaimsService sharedService].CarYear = carYear;
    [ClaimsService sharedService].CarPainting = carPainting;
    [ClaimsService sharedService].CarLicensePlate = carLicensePlateNumber;
    
    NewClaimViewController* detailClaim = [self.storyboard instantiateViewControllerWithIdentifier:@"NewClaimViewController"];
    detailClaim.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:detailClaim animated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"userUpdatedVehicleManually" object:nil];
}

- (IBAction)addCarAction:(id)sender {
    AddCarCtrl* addCar = [self.storyboard instantiateViewControllerWithIdentifier:@"AddCarCtrl"];
    addCar.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:addCar animated:YES completion:nil];
}


#pragma mark - Navigation

- (IBAction)dismissAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
