//
//  CustomLocationPickerVC.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 11.06.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "CustomLocationPickerVC.h"
#import <AVKit/AVKit.h>
#import <CoreLocation/CoreLocation.h>


@interface CustomLocationPickerVC () <CLLocationManagerDelegate> {
    GMSPlace *selectedPlace;
}
@end


@implementation CustomLocationPickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.city = @"";
    self.country = @"";
    self.title = @"Select Location";
    
    [CommonFunctions setRightBarButtonItemWithTitle:nil andBackGroundImage:[UIImage imageNamed:@"search"] andSelector:@selector(searchButtonAction) withTarget:self onController:self];

    [self.navigationController setNavigationBarHidden:NO];

    CLLocationCoordinate2D center;
    center.latitude = [self.lat doubleValue];
    center.longitude = [self.lng doubleValue];

    self.addressLabel.text = self.address;

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.lat doubleValue] longitude:[self.lng doubleValue] zoom:16];
    [_googleMapView setCamera:camera];
    _googleMapView.myLocationEnabled = YES;
    _googleMapView.delegate = self;

    [self.viewAddressContainer.layer setCornerRadius:25.f];
    self.viewAddressContainer.layer.borderWidth = 1.f;
    self.viewAddressContainer.layer.borderColor = [Color officialMainAppColor].CGColor;
    [self.viewAddressContainer.layer masksToBounds];
    
    [self.buttonSetAddress setTintColor:[Color officialWhiteColor]];
    [self.buttonSetAddress setBackgroundColor:[Color officialMainAppColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.delegate = nil;
    [self getCurrentLocation];
}

- (void)searchButtonAction {
    selectedPlace = nil;
    
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    
    if (selectedPlace != nil) {
        selectedPlace = nil;
        return;
    }
    double latitude = mapView.camera.target.latitude;
    double longitude = mapView.camera.target.longitude;
    
    CLLocationCoordinate2D addressCoordinates = CLLocationCoordinate2DMake(latitude, longitude);
    
    NSNumber *latitudeStr = [[NSNumber alloc] initWithDouble:addressCoordinates.latitude];
    NSNumber *longitudeStr = [[NSNumber alloc] initWithDouble:addressCoordinates.longitude];
    
    [ClaimsService sharedService].Lat = [latitudeStr stringValue];
    [ClaimsService sharedService].Lng = [longitudeStr stringValue];
    
    GMSGeocoder* coder = [[GMSGeocoder alloc] init];
    [coder reverseGeocodeCoordinate:addressCoordinates completionHandler:^(GMSReverseGeocodeResponse *results, NSError *error) {
        if (error) {
            // NSLog(@"Error %@", error.description);
            self.country = @"";
            self.city = @"";
        } else {
            GMSAddress* address = [results firstResult];
            self.city = address.locality ? address.locality : @"";
            self.country = address.country ? address.country : @"";
            NSArray *arr = [address valueForKey:@"lines"];
            NSString *str1 = [NSString stringWithFormat:@"%lu",(unsigned long)[arr count]];
            
            if ([str1 isEqualToString:@"0"]) {
                self.addressLabel.text = @"";
                
            } else if ([str1 isEqualToString:@"1"]) {
                NSString *str2 = [arr objectAtIndex:0];
                self.addressLabel.text = str2;
                
                if (str2 != nil && ![str2 isEqualToString:@"0"]) {
                    [ClaimsService sharedService].LocationStr = str2;
                }
                
            } else if ([str1 isEqualToString:@"2"]) {
                NSString *str2 = [arr objectAtIndex:0];
                NSString *str3 = [arr objectAtIndex:1];
                if (str2.length > 1 ) {
                    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@", str2, str3];
                } else {
                    self.addressLabel.text = [NSString stringWithFormat:@"%@",str3];
                }
            }
        }
    }]; 
}

- (IBAction)setAddressButtonAction:(id)sender {
    if (self.addressLabel.text.length == 0) {
        self.addressLabel.text = @"Location not specified";
        self.buttonSetAddress.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.addressLabel.text = nil;
            self.buttonSetAddress.userInteractionEnabled = YES;
        });
        return;
    }
    self.address = self.addressLabel.text;
    self.lat = [NSString stringWithFormat:@"%f", self.googleMapView.camera.target.latitude];
    self.lng = [NSString stringWithFormat:@"%f", self.googleMapView.camera.target.longitude];
    [self performSegueWithIdentifier:@"unwindFromLocationPickerView" sender:nil];
}

- (IBAction)locateCurrentLocation:(id)sender {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.lat doubleValue] longitude:[self.lng doubleValue] zoom:16];
    [_googleMapView setCamera:camera];
    
    [locationManager startUpdatingLocation];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_googleMapView animateToCameraPosition:camera];
        //[locationManager stopUpdatingLocation];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - GMaps Location search

- (void)getCurrentLocation {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager requestAlwaysAuthorization];
    [locationManager startUpdatingLocation];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.lat doubleValue] longitude:[self.lng doubleValue] zoom:16];
    [_googleMapView setCamera:camera];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_googleMapView animateToCameraPosition:camera];
        [locationManager stopUpdatingLocation];
    });
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"ZR didUpdateToLocation: %@", [locations lastObject]);
    currentLocation = [locations lastObject];
    if (currentLocation != nil) {
        CURRENT_LATITUDE = currentLocation.coordinate.latitude;
        CURRENT_LONGITUDE = currentLocation.coordinate.longitude;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            [self getAddressFromLocation:currentLocation];
        });
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:CURRENT_LATITUDE longitude:CURRENT_LONGITUDE zoom:16];
        [_googleMapView setCamera:camera];
         dispatch_async(dispatch_get_main_queue(), ^{
             [self->_googleMapView animateToCameraPosition:camera];
             [locationManager stopUpdatingLocation];
         });
    }
}

- (void)getAddressFromLocation:(CLLocation*) location {
    if (CURRENT_ADDRESS) {
        return;
    }
    
    NSString *req = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&output=csv&key=%@", [NSString stringWithFormat:@"%f", location.coordinate.latitude], [NSString stringWithFormat:@"%f", location.coordinate.longitude], [Configurator sharedInstance].googleApiKey];
    
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    
    if (result) {
        NSError *error;
        NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        NSArray *resultArr = [dictResponse objectForKey:@"results"];
        
        if (resultArr.count > 0) {
            NSDictionary *dict = [resultArr objectAtIndex:0];
            if ([dict objectForKey:@"formatted_address"]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    CURRENT_ADDRESS = [dict objectForKey:@"formatted_address"];
                });
            }
        }
    }
}


#pragma mark - Navigation

- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    
    self.country = @"";
    self.city = @"";
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    
    selectedPlace = place;
    double latitude = place.coordinate.latitude;
    double longitude = place.coordinate.longitude;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude  longitude:longitude zoom:16];
    [_googleMapView setCamera:camera];
    
    self.addressLabel.text = place.formattedAddress;
    
    for (GMSAddressComponent *compCity in place.addressComponents) {
        if ([compCity.type isEqualToString:@"locality"]) {
            self.city = compCity.name ? compCity.name : @"";
        }
        else if ([compCity.type isEqualToString:@"country"]) {
            self.country = compCity.name ? compCity.name : @"";
        }
    }
}

- (IBAction)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Error: %@", [error description]);
}

- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
