//
//  RetypeVehicleCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RetypeVehicleCtrl.h"
#import "TelematicsAppTextField.h"
#import "CarPickerCtrl.h"
#import "UIViewController+Preloader.h"
#import "GMImagePickerController.h"
#import "IQMediaPickerController.h"
#import "VehiclesDictionaryResponse.h"
#import "VehicleRequestData.h"
#import "VehicleResponse.h"
#import "GalleryResponse.h"
#import "GalleryResultResponse.h"
#import "GalleryCarViewController.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"
#import "UIImage+FixOrientation.h"

@interface RetypeVehicleCtrl () <UIScrollViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CarPickerDelegate> {
    NSArray *arrayCarYears;
    NSArray *arrayPaintingTypes;
}

@property (strong, nonatomic) TelematicsAppModel                           *appModel;
@property (nonatomic, strong) VehicleResultResponse                 *vehicle;
@property (nonatomic, strong) NSDictionary                          *allCarsManufacturers;
@property (nonatomic, strong) NSDictionary                          *allCarsModels;
@property (nonatomic) CarPickerCtrl                                 *carPicker;

@property (weak, nonatomic) IBOutlet UIScrollView                   *scrollView;
@property (weak, nonatomic) IBOutlet UILabel                        *userNameLbl;
@property (weak, nonatomic) IBOutlet UIImageView                    *avatarImg;
@property (weak, nonatomic) IBOutlet UIView                         *bottomView;
@property (weak, nonatomic) IBOutlet UIButton                       *saveBtn;
@property (nonatomic) UISearchController                            *searchController;

@property (nonatomic, assign) UITextField                           *activeTextField;
@property (strong, nonatomic) IBOutlet TelematicsAppTextField       *licensePlateField;
@property (strong, nonatomic) IBOutlet TelematicsAppTextField       *vinField;
@property (strong, nonatomic) IBOutlet TelematicsAppTextField       *manufacturerField;
@property (strong, nonatomic) IBOutlet TelematicsAppTextField       *modelField;
@property (strong, nonatomic) IBOutlet TelematicsAppTextField       *carTypeField;
@property (strong, nonatomic) IBOutlet TelematicsAppTextField       *carNicknameField;
@property (strong, nonatomic) IBOutlet TelematicsAppTextField       *carYearIssueField;
@property (strong, nonatomic) IBOutlet TelematicsAppTextField       *mileageField;
@property (strong, nonatomic) IBOutlet TelematicsAppTextField       *paintingTypeField;

@property (weak, nonatomic) IBOutlet UILabel                        *uploadVehicleLbl;
@property (weak, nonatomic) IBOutlet UIButton                       *uploadVehicleBtn;

@property (strong, nonatomic) UIPickerView                          *pickerViewCarYear;
@property (strong, nonatomic) UIPickerView                          *pickerViewPaintingType;
@property (nonatomic, strong) NSString                              *paintingSelectByUser;
@property (nonatomic) NSInteger                                     pickerCarYearSelected;
@property (nonatomic) NSInteger                                     pickerPaintingTypeSelected;

@property (nonatomic, strong) GalleryResultResponse                 *galleryCarDocuments;

@property (nonatomic, strong) NSString                              *selectedSource;
@property (nonatomic, assign) BOOL                                  stopDismiss;

@property (nonatomic) BOOL                                          multiPickerSwitch;
@property (nonatomic) BOOL                                          pickingSourceCamera;
@property (nonatomic) BOOL                                          photoPickerSwitch;
@property (nonatomic) BOOL                                          videoPickerSwitch;
@property (nonatomic) BOOL                                          audioPickerSwitch;
@property (nonatomic) BOOL                                          rearCaptureSwitch;
@property (nonatomic) BOOL                                          flashOffSwitch;

@end

@implementation RetypeVehicleCtrl {
    IQMediaPickerSelection *selectedMedias;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //INITIALIZE USER APP MODEL
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    [self.saveBtn setTitle:localizeString(@"Save") forState:UIControlStateNormal];
    
    _licensePlateField.colorNormal = [UIColor groupTableViewBackgroundColor];
    _licensePlateField.colorHighlight = [Color lightSeparatorColor];
    _licensePlateField.leftIconNormal = [UIImage imageNamed:@"carService_plate"];
    _licensePlateField.leftIconHighlight = [UIImage imageNamed:@"carService_plate"];
    _licensePlateField.showHighlightedEditing = YES;
    _licensePlateField.showBottomLine = YES;
    [_licensePlateField setTintColor:[UIColor darkGrayColor]];
    _licensePlateField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [_licensePlateField setReturnKeyType:UIReturnKeyNext];
    _licensePlateField.placeholder = localizeString(@"LICENSE PLATE");
    
    _vinField.colorNormal = [UIColor groupTableViewBackgroundColor];
    _vinField.colorHighlight = [Color lightSeparatorColor];
    _vinField.leftIconNormal = [UIImage imageNamed:@"carService_number"];
    _vinField.leftIconHighlight = [UIImage imageNamed:@"carService_number"];
    _vinField.showHighlightedEditing = YES;
    _vinField.showBottomLine = YES;
    [_vinField setTintColor:[UIColor darkGrayColor]];
    _vinField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [_vinField setReturnKeyType:UIReturnKeyNext];
    _vinField.placeholder = localizeString(@"VIN NUMBER");
    
    _manufacturerField.colorNormal = [UIColor groupTableViewBackgroundColor];
    _manufacturerField.colorHighlight = [Color lightSeparatorColor];
    _manufacturerField.leftIconNormal = [UIImage imageNamed:@"carService_manufacturer"];
    _manufacturerField.leftIconHighlight = [UIImage imageNamed:@"carService_manufacturer"];
    _manufacturerField.showHighlightedEditing = YES;
    _manufacturerField.showBottomLine = YES;
    [_manufacturerField setTintColor:[UIColor darkGrayColor]];
    _manufacturerField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [_manufacturerField setReturnKeyType:UIReturnKeyNext];
    _manufacturerField.placeholder = localizeString(@"MAKE");
    
    _modelField.colorNormal = [UIColor groupTableViewBackgroundColor];
    _modelField.colorHighlight = [Color lightSeparatorColor];
    _modelField.leftIconNormal = [UIImage imageNamed:@"carService_model"];
    _modelField.leftIconHighlight = [UIImage imageNamed:@"carService_model"];
    _modelField.showHighlightedEditing = YES;
    _modelField.showBottomLine = YES;
    [_modelField setTintColor:[UIColor darkGrayColor]];
    _modelField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [_modelField setReturnKeyType:UIReturnKeyNext];
    _modelField.placeholder = localizeString(@"MODEL");
    
    _carTypeField.colorNormal = [UIColor groupTableViewBackgroundColor];
    _carTypeField.colorHighlight = [Color lightSeparatorColor];
    _carTypeField.leftIconNormal = [UIImage imageNamed:@"carService_carType"];
    _carTypeField.leftIconHighlight = [UIImage imageNamed:@"carService_carType"];
    _carTypeField.showHighlightedEditing = YES;
    _carTypeField.showBottomLine = YES;
    [_carTypeField setTintColor:[UIColor darkGrayColor]];
    _carTypeField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [_carTypeField setReturnKeyType:UIReturnKeyNext];
    _carTypeField.placeholder = localizeString(@"CAR TYPE");
    
    _carNicknameField.colorNormal = [UIColor groupTableViewBackgroundColor];
    _carNicknameField.colorHighlight = [Color lightSeparatorColor];
    _carNicknameField.leftIconNormal = [UIImage imageNamed:@"carService_nickname"];
    _carNicknameField.leftIconHighlight = [UIImage imageNamed:@"carService_nickname"];
    _carNicknameField.showHighlightedEditing = YES;
    _carNicknameField.showBottomLine = YES;
    [_carNicknameField setTintColor:[UIColor darkGrayColor]];
    _carNicknameField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [_carNicknameField setReturnKeyType:UIReturnKeyNext];
    _carNicknameField.placeholder = localizeString(@"VEHICLE NICKNAME");
    
    _carYearIssueField.colorNormal = [UIColor groupTableViewBackgroundColor];
    _carYearIssueField.colorHighlight = [Color lightSeparatorColor];
    _carYearIssueField.leftIconNormal = [UIImage imageNamed:@"carService_carYear"];
    _carYearIssueField.leftIconHighlight = [UIImage imageNamed:@"carService_carYear"];
    _carYearIssueField.showHighlightedEditing = YES;
    _carYearIssueField.showBottomLine = YES;
    [_carYearIssueField setTintColor:[UIColor darkGrayColor]];
    _carYearIssueField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [_carYearIssueField setReturnKeyType:UIReturnKeyNext];
    _carYearIssueField.placeholder = localizeString(@"VEHICLE YEAR");
    
    _mileageField.colorNormal = [UIColor groupTableViewBackgroundColor];
    _mileageField.colorHighlight = [Color lightSeparatorColor];
    _mileageField.leftIconNormal = [UIImage imageNamed:@"carService_mileage"];
    _mileageField.leftIconHighlight = [UIImage imageNamed:@"carService_mileage"];
    _mileageField.showHighlightedEditing = YES;
    _mileageField.showBottomLine = YES;
    [_mileageField setTintColor:[UIColor darkGrayColor]];
    _mileageField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [_mileageField setReturnKeyType:UIReturnKeyNext];
    _mileageField.placeholder = localizeString(@"INITIAL MILEAGE");
    
    _paintingTypeField.colorNormal = [UIColor groupTableViewBackgroundColor];
    _paintingTypeField.colorHighlight = [Color lightSeparatorColor];
    _paintingTypeField.leftIconNormal = [UIImage imageNamed:@"carService_painting"];
    _paintingTypeField.leftIconHighlight = [UIImage imageNamed:@"carService_painting"];
    _paintingTypeField.showHighlightedEditing = YES;
    _paintingTypeField.showBottomLine = YES;
    [_paintingTypeField setTintColor:[UIColor darkGrayColor]];
    _paintingTypeField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [_paintingTypeField setReturnKeyType:UIReturnKeyNext];
    _paintingTypeField.placeholder = localizeString(@"PAINTING TYPE");
    
    _multiPickerSwitch = YES;
    _pickingSourceCamera = YES;
    _photoPickerSwitch = YES;
    _videoPickerSwitch = NO;
    _audioPickerSwitch = NO;
    _rearCaptureSwitch = YES;
    _flashOffSwitch = YES;
    
    arrayCarYears = @[@"1980", @"1981" , @"1982", @"1983", @"1984", @"1985", @"1986", @"1987", @"1988", @"1989", @"1990", @"1991", @"1992", @"1993", @"1994", @"1995", @"1996", @"1997", @"1998", @"1999", @"2000", @"2001" , @"2002", @"2003", @"2004", @"2005", @"2006", @"2007", @"2008", @"2009", @"2010", @"2011", @"2012", @"2013", @"2014", @"2015", @"2016", @"2017", @"2018", @"2019", @"2020", @"2021"];
    
    arrayPaintingTypes = @[@"Solid", @"Metallic" , @"Pearl"];
    
    self.pickerCarYearSelected = 40;
    
    [self registerForKeyboardNotifications];
    self.shiftHeight = -1;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self setVehicleCacheData];
    
    if (!self.carPicker) {
        self.carPicker = [self.storyboard instantiateViewControllerWithIdentifier:@"CarPickerCtrl"];
        self.carPicker.delegate = self;
    }
    
    UITapGestureRecognizer *scrollTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    scrollTap.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:scrollTap];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getAllCarsDict];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setVehicleCacheData {
    _licensePlateField.text = self.plateString;
    _vinField.text = self.vinCodeStr;
    _manufacturerField.text = self.manufacturerString;
    _carTypeField.text = self.typeString;
    _carNicknameField.text = self.nicknameString;
    _carYearIssueField.text = self.yearString;
    _mileageField.text = self.mileageString;
    _paintingTypeField.text = self.paintingString;
    
    if (self.paintingString != nil) {
        if ([self.paintingString isEqualToString:@"Solid"]) {
            _paintingTypeField.text = arrayPaintingTypes[0];
            [_pickerViewPaintingType selectRow:0 inComponent:0 animated:NO];
            _paintingSelectByUser = @"Solid";
        } else if ([self.paintingString isEqualToString:@"Metallic"])  {
            _paintingTypeField.text = arrayPaintingTypes[1];
            [_pickerViewPaintingType selectRow:1 inComponent:0 animated:NO];
            _paintingSelectByUser = @"Metallic";
        } else if ([self.paintingString isEqualToString:@"Pearl"])  {
            _paintingTypeField.text = arrayPaintingTypes[2];
            [_pickerViewPaintingType selectRow:2 inComponent:0 animated:NO];
            _paintingSelectByUser = @"Pearl";
        }
    }
    
    _modelField.text = self.modelString;
    if ([self.modelString isEqualToString:@"No option"] || [self.modelString isEqualToString:@"No Option"]) {
        _modelField.text = @"";
    }
}


#pragma mark - Backend methods

- (void)editVehicleUpdateAction:(void (^ __nullable)(void))completionSaveVehicle {
        
    [self showPreloader];
    [self endEditing];
    
    VehicleRequestData* saveVehicleData = [[VehicleRequestData alloc] init];
    if (_licensePlateField.text.length > 0) {
        saveVehicleData.plateNumber = _licensePlateField.text;
    }
    if (_vinField.text.length > 0) {
        saveVehicleData.vin = _vinField.text;
    }
    if (_manufacturerField.text.length > 0) {
        saveVehicleData.manufacturerName = _manufacturerField.text;
    }
    if (_modelField.text.length > 0) {
        saveVehicleData.modelName = _modelField.text;
    }
    if (_carTypeField.text.length > 0) {
        saveVehicleData.typeName = _carTypeField.text;
    }
    if (_carNicknameField.text.length > 0) {
        saveVehicleData.name = _carNicknameField.text;
    }
    if (_carYearIssueField.text.length > 0) {
        saveVehicleData.carYear = _carYearIssueField.text;
    }
    if (_paintingTypeField.text.length > 0) {
        saveVehicleData.colorType = _paintingSelectByUser;
    }
    
    if (![self.vehicleTokenString isEqualToString:@""]) {
        
        if ([_modelField.text isEqualToString:@""] || [_modelField.text isEqualToString:@"No option"]) {
            saveVehicleData.modelName = @"No option";
        }
        
        if (self.mileageString == nil && _mileageField.text.length > 0) {
            saveVehicleData.initialMilage = _mileageField.text;
        }
        
        [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
            NSLog(@"%s %@ %@", __func__, response, error);
            [self hidePreloader];
            if (!error && [response isSuccesful]) {
                completionSaveVehicle();
                [[GeneralService sharedService] loadProfile];
                [self quitAndUpdateVehiclesTableData];
            } else {
                completionSaveVehicle();
                [[GeneralService sharedService] loadProfile];
                [self quitAndUpdateVehiclesTableData];
            }
        }] putVehicle:saveVehicleData vehicle:self.vehicleTokenString];

    } else {
        
        if (_mileageField.text.length > 0) {
            saveVehicleData.initialMilage = _mileageField.text;
        }
        
        saveVehicleData.entityStatus = @1; //required
        
        [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
            [self hidePreloader];
            if ([response isSuccesful]) {
                completionSaveVehicle();
            } else {
                completionSaveVehicle();
            }
        }] updateVehicle:saveVehicleData];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _licensePlateField) {
        [_vinField becomeFirstResponder];
    } else if (textField == _vinField) {
        [_manufacturerField becomeFirstResponder];
    } else if (textField == _manufacturerField) {
        [_modelField becomeFirstResponder];
    } else if (textField == _modelField) {
        [_carNicknameField becomeFirstResponder];
    } else if (textField == _carNicknameField) {
        [_carYearIssueField becomeFirstResponder];
    } else if (textField == _carYearIssueField) {
        [_mileageField becomeFirstResponder];
    } else if (textField == _mileageField) {
        [_paintingTypeField becomeFirstResponder];
    } else {
        [self endEditing];
    }
    return YES;
}

- (void)endEditing {
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _carYearIssueField) {
        
        _pickerViewCarYear = [[UIPickerView alloc] init];
        _pickerViewCarYear.delegate = self;
        [_pickerViewCarYear setBackgroundColor:[Color officialWhiteColor]];
        _carYearIssueField.inputView = _pickerViewCarYear;
        
        if (_carYearIssueField.text != nil && self.pickerCarYearSelected != 40) {
            [_pickerViewCarYear selectRow:self.pickerCarYearSelected inComponent:0 animated:NO];
        } else {
            if (self.yearString != nil && ![self.yearString isEqualToString:@""]) {
                NSUInteger indexCar = [arrayCarYears indexOfObject:self.yearString];
                [_pickerViewCarYear selectRow:indexCar inComponent:0 animated:NO];
                _carYearIssueField.text = arrayCarYears[indexCar];
                self.pickerCarYearSelected = indexCar;
            } else {
                [_pickerViewCarYear selectRow:40 inComponent:0 animated:NO];
                _carYearIssueField.text = arrayCarYears[40];
            }
        }
        
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [toolBar setTintColor:[Color officialMainAppColor]];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:localizeString(@"Next") style:UIBarButtonItemStylePlain target:self action:@selector(donePickerSelectedCarYear)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [toolBar setItems:[NSArray arrayWithObjects:space, doneBtn, nil]];
        [_carYearIssueField setInputAccessoryView:toolBar];
        
    } else if (textField == _manufacturerField) {
        self.carPicker.pickType = PickBrand;
        self.carPicker.brands = self.allCarsManufacturers.copy;
        self.carPicker.brandsFiltered = self.allCarsManufacturers.copy;
        [self presentViewController:self.carPicker animated:YES completion:nil];
        
    } else if (textField == _modelField) {
        self.carPicker.pickType = PickModel;
        self.carPicker.models = self.allCarsModels.copy;
        self.carPicker.modelsFiltered = self.allCarsModels.copy;
        [self presentViewController:self.carPicker animated:YES completion:nil];
        
    } else if (textField == _mileageField) {
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [toolBar setTintColor:[Color officialMainAppColor]];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:localizeString(@"Next") style:UIBarButtonItemStylePlain target:self action:@selector(donePickerSelectedMileage)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [toolBar setItems:[NSArray arrayWithObjects:space, doneBtn, nil]];
        [_mileageField setInputAccessoryView:toolBar];
        
    } else if (textField == _paintingTypeField) {
        
        _pickerViewPaintingType = [[UIPickerView alloc] init];
        _pickerViewPaintingType.delegate = self;
        [_pickerViewPaintingType setBackgroundColor:[Color officialWhiteColor]];
        _paintingTypeField.inputView = _pickerViewPaintingType;
        
        if ([self.paintingString isEqualToString:@"Solid"]) {
            _paintingTypeField.text = arrayPaintingTypes[0];
            [_pickerViewPaintingType selectRow:0 inComponent:0 animated:NO];
            _paintingSelectByUser = @"Solid";
            [_pickerViewPaintingType selectRow:0 inComponent:0 animated:NO];
        } else if ([self.paintingString isEqualToString:@"Metallic"])  {
            _paintingTypeField.text = arrayPaintingTypes[1];
            [_pickerViewPaintingType selectRow:1 inComponent:0 animated:NO];
            _paintingSelectByUser = @"Metallic";
            [_pickerViewPaintingType selectRow:1 inComponent:0 animated:NO];
        } else if ([self.paintingString isEqualToString:@"Pearl"])  {
            _paintingTypeField.text = arrayPaintingTypes[2];
            [_pickerViewPaintingType selectRow:2 inComponent:0 animated:NO];
            _paintingSelectByUser = @"Pearl";
            [_pickerViewPaintingType selectRow:2 inComponent:0 animated:NO];
        } else {
            _paintingTypeField.text = arrayPaintingTypes[0];
            [_pickerViewPaintingType selectRow:0 inComponent:0 animated:NO];
            _paintingSelectByUser = @"Solid";
            [_pickerViewPaintingType selectRow:0 inComponent:0 animated:NO];
        }
        
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [toolBar setTintColor:[Color officialMainAppColor]];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:localizeString(@"Done") style:UIBarButtonItemStylePlain target:self action:@selector(donePickerSelectedPaintingType)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [toolBar setItems:[NSArray arrayWithObjects:space, doneBtn, nil]];
        [_paintingTypeField setInputAccessoryView:toolBar];
    }
    
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeTextField = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    //VIN VALIDATE
//    if (textField == _vinField) {
//        int limit = 16;
//        return !([textField.text length] > limit && [string length] > range.length);
//    }
    
//    //MILEAGE VALIDATE
//    if (textField == _mileageField && self.mileageString != nil) {
//        [self.errorHandler showErrorNow:@"Mileage can't be changed after adding a car"];
//        return NO;
//    }

    return YES;
}


#pragma mark - CarPicker Delegate

- (void)carPickerDidPick:(NSString *)stringDict {
    if (self.carPicker.pickType == PickBrand) {
        _manufacturerField.text = [stringDict valueForKey:@"Name"];
        [self getBrandModels:[stringDict valueForKey:@"Id"]];
    } else if (self.carPicker.pickType == PickModel) {
        _modelField.text = [stringDict valueForKey:@"Name"];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)carPickerDidCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Cars & Models Dictionary

- (void)getAllCarsDict {
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if ([response isSuccesful]) {
            self.allCarsManufacturers = ((VehiclesDictionaryResponse*)response).Result;
            [self getBrandModelsByIdsIfNeeded];
        } else {
            [self.errorHandler handleError:error response:response];
        }
    }] getAllCarsManufacturers];
}

- (void)getBrandModels:(NSString *)brandId {
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if ([response isSuccesful]) {
            self.allCarsModels = ((VehiclesDictionaryResponse*)response).Result;
            [self checkIfUserUpdatedManufacturerWithModel];
        } else {
            [self.errorHandler handleError:error response:response];
        }
    }] getAllBrandModels:brandId];
}

- (void)getBrandModelsByIdsIfNeeded {
    for (int i=0; i < self.allCarsManufacturers.count && self.allCarsManufacturers.count != 0; i++) {
        NSString *selBrandName = [[self.allCarsManufacturers valueForKey:@"Name"] objectAtIndex:i];
        if ([selBrandName isEqualToString:_manufacturerField.text]) {
            NSString *selBrandId = [[self.allCarsManufacturers valueForKey:@"Id"] objectAtIndex:i];
            [self getBrandModels:selBrandId];
        }
    }
}

- (void)checkIfUserUpdatedManufacturerWithModel {
    BOOL cleanModelField = NO;
    for (int i=0; i < self.allCarsModels.count && self.allCarsModels.count != 0; i++) {
        NSString *selModelName = [[self.allCarsModels valueForKey:@"Name"] objectAtIndex:i];
        if (![_modelField.text isEqualToString:@""]) {
            if ([selModelName isEqualToString:_modelField.text]) {
                cleanModelField = YES;
            }
        }
    }
    
    if (!cleanModelField) {
        _modelField.text = nil;
    }
}


#pragma mark - Keyboard Delegate

- (void)keyboardWasShown:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(aRect, _activeTextField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, _activeTextField.frame.origin.y - (keyboardSize.height-15));
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


#pragma mark - PickerView CarYear & ColorType Delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == _pickerViewCarYear) {
        _carYearIssueField.text = arrayCarYears[row];
        self.pickerCarYearSelected = row;
    } else if (pickerView == _pickerViewPaintingType) {
        _paintingTypeField.text = arrayPaintingTypes[row];
        self.pickerPaintingTypeSelected = row;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView == _pickerViewCarYear) {
        return [arrayCarYears count];
    } else if (pickerView == _pickerViewPaintingType) {
        return [arrayPaintingTypes count];
    } else {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (pickerView == _pickerViewCarYear) {
        return arrayCarYears[row];
    } else if (pickerView == _pickerViewPaintingType) {
        return arrayPaintingTypes[row];
    } else {
        return 0;
    }
}

- (void)donePickerSelectedCarYear {
    [_carYearIssueField resignFirstResponder];
    [_mileageField becomeFirstResponder];
    
    self.pickerCarYearSelected = [_pickerViewCarYear selectedRowInComponent:0];
}

- (void)donePickerSelectedMileage {
    [_paintingTypeField becomeFirstResponder];
}

- (void)donePickerSelectedPaintingType {
    [_paintingTypeField resignFirstResponder];
}

- (IBAction)saveBtnClickVehicle:(id)sender {
//    if ([_vinField.text length] < 17) {
//        [self showValidateVinError];
//        return;
//    }
    
    if ([_licensePlateField.text isEqualToString:@""]) {
        [self.errorHandler showErrorNow:@"License Plate can't be empty"];
        return;
    }
    if ([_vinField.text isEqualToString:@""]) {
        [self.errorHandler showErrorNow:@"VIN number can't be empty"];
        return;
    }
    if ([_manufacturerField.text isEqualToString:@""]) {
        [self.errorHandler showErrorNow:@"Model can't be empty"];
        return;
    }
    if ([_modelField.text isEqualToString:@""]) {
        [self.errorHandler showErrorNow:@"Model can't be empty"];
        return;
    }
    if ([_carNicknameField.text isEqualToString:@""]) {
        [self.errorHandler showErrorNow:@"Vehicle Nickname can't be empty"];
        return;
    }
    if ([_carYearIssueField.text isEqualToString:@""]) {
        [self.errorHandler showErrorNow:@"Car Year can't be empty"];
        return;
    }
    if ([_mileageField.text isEqualToString:@""]) {
        [self.errorHandler showErrorNow:@"Initial Mileage can't be empty"];
        return;
    }
    if ([_paintingTypeField.text isEqualToString:@""]) {
        [self.errorHandler showErrorNow:@"Painting Type can't be empty"];
        return;
    }
    
    self.stopDismiss = NO;
    [self showPreloader];
    [self editVehicleUpdateAction:^{
        [self hidePreloader];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateProfileTableDataWait" object:self];
    }];
}

- (IBAction)backBtnClick:(id)sender {
    if (self.navigationController.presentingViewController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if (@available(iOS 13.0, *)) { 
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
}

- (void)quitAndUpdateVehiclesTableData {
    [self showPreloader];
    if (!self.stopDismiss) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateProfileTableDataWait" object:self];
                
                [self hidePreloader];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"userUpdatedVehicleManually" object:self];
            }];
        });
    }
}

- (NSMutableAttributedString*)createVerifedLabel:(NSString*)text {
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"profile_verifed"];
    imageAttachment.bounds = CGRectMake(5, -2, imageAttachment.image.size.width/1.5, imageAttachment.image.size.height/1.5);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:text];
    [completeText appendAttributedString:attachmentString];
    return completeText;
}

+ (BOOL)validateVin:(NSString *)vinNumber {
    NSString *vinRegEx = @"^(?=.{16,})([@#$%^&=a-zA-Z0-9_-]+)$";
    NSPredicate *vinCheck = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", vinRegEx];
    return [vinCheck evaluateWithObject:vinNumber];
}

@end
