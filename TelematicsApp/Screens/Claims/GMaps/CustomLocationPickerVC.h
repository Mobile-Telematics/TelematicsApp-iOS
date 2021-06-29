//
//  CustomLocationPickerVC.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 11.06.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigGMaps.h"
#import "CommonFunctions.h"
@import GoogleMaps;
@import GooglePlaces;


@interface CustomLocationPickerVC : UIViewController <GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UILabel            *addressLabel;
@property (weak, nonatomic) IBOutlet GMSMapView         *googleMapView;
@property (weak, nonatomic) IBOutlet UIView             *viewAddressContainer;
@property (weak, nonatomic) IBOutlet UIImageView        *locationSelectIcon;
@property (weak, nonatomic) IBOutlet UIImageView        *locationTextViewIcon;
@property (weak, nonatomic) IBOutlet UIButton           *buttonSetAddress;
@property (strong, nonatomic) NSString                  *address;
@property (strong, nonatomic) NSString                  *lat;
@property (strong, nonatomic) NSString                  *lng;
@property (strong, nonatomic) NSString                  *city;
@property (strong, nonatomic) NSString                  *country;

- (IBAction)setAddressButtonAction:(id)sender;
- (IBAction)locateCurrentLocation:(id)sender;

- (void)getCurrentLocation;
- (void)getAddressFromLocation:(CLLocation*)location;

@end
