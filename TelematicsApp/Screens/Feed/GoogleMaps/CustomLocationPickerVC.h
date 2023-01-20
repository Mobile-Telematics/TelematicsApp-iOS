//
//  CustomLocationPickerVC.h
//  Damoov ZenRoad Telematics Platform
//
//  Created by pp@datamotion.ai on 25.07.21.
//  Copyright © 2022 DATA MOTION PTE. LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;
@import GooglePlaces;


@interface CustomLocationPickerVC : UIViewController <GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate>

@property (nonatomic) RPTrackProcessed *track;
@property (nonatomic) NSString *tripToken;
@property (nonatomic) NSInteger trackTag;

@property (nonatomic) NSString *trackDistanceSummary;
@property (nonatomic) NSString *trackPointsSummary;
@property (nonatomic) NSString *simpleStartTime;
@property (nonatomic) NSString *simpleEndTime;

@property (nonatomic) NSMutableArray *sortedOnlyTrips;

//

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
