//
//  CustomLocationPickerVC.m
//  Damoov ZenRoad Telematics Platform
//
//  Created by pp@datamotion.ai on 25.07.21.
//  Copyright © 2022 DATA MOTION PTE. LTD. All rights reserved.
//

#import "CustomLocationPickerVC.h"
#import <AVKit/AVKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BottomSheetPresenter.h"
#import "ClaimAlertPopupDelegate.h"
#import "DriverSignaturePopupDelegate.h"
#import "MapPopTip.h"
#import "UIImage+FixOrientation.h"
#import "HapticHelper.h"
#import "GearLoadingView.h"
#import "UIViewController+Preloader.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"

@interface CustomLocationPickerVC () <CLLocationManagerDelegate, BottomSheetPresenterDelegate, ClaimAlertPopupProtocol, DriverSignaturePopupProtocol> {
    ClaimAlertPopupDelegate *claimPopup;
    DriverSignaturePopupDelegate *signatureOnTripPopup;
}

@property (weak, nonatomic) IBOutlet UILabel            *mainTitle;

@property (nonatomic) NSMutableArray                    *speedPoints;

@property (nonatomic) NSMutableArray                    *mapObjectsArray;
@property (nonatomic) NSMutableArray                    *mapMarkers;

@property (nonatomic) NSString                          *selectedDateMarker;
@property (nonatomic) NSString                          *selectedLatMarker;
@property (nonatomic) NSString                          *selectedLonMarker;
@property (nonatomic) NSString                          *selectedEventTypeMarker;
@property (nonatomic) NSString                          *selectedNewEventTypeMarker;

@property (nonatomic, strong) NSString                  *selectedDriverSignatureRole;
@property (strong, nonatomic) TelematicsAppModel        *appModel;
@property (strong, nonatomic) BottomSheetPresenter      *bottomSheetPresenter;
@property (nonatomic, strong) MapPopTip                 *popTip;
@property (weak, nonatomic) IBOutlet UIButton           *centerBtn;
@property (weak, nonatomic) IBOutlet UIButton           *tripBackBtn;
@property (weak, nonatomic) IBOutlet UIButton           *tripForwardBtn;
@property int                                           counter;


@end


@implementation CustomLocationPickerVC {
  GMSMapStyle *_retroStyle;
  GMSMapStyle *_nightStyle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:NO];

    self.addressLabel.text = self.address;

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.lat doubleValue] longitude:[self.lng doubleValue] zoom:16];
    [_googleMapView setCamera:camera];
    _googleMapView.myLocationEnabled = NO;
    _googleMapView.delegate = self;
    
    if ([defaults_object(@"needWhiteMapType") boolValue]) {
        _googleMapView.mapStyle = nil;
    } else if ([defaults_object(@"needRetroMapType") boolValue]) {
        NSURL *retroURL = [[NSBundle mainBundle] URLForResource:@"mapstyle-retro"
                                                  withExtension:@"json"];
        _retroStyle = [GMSMapStyle styleWithContentsOfFileURL:retroURL error:NULL];
        _googleMapView.mapStyle = _retroStyle;
    } else {
        NSURL *nightURL = [[NSBundle mainBundle] URLForResource:@"mapstyle-night"
                                                  withExtension:@"json"];
        _nightStyle = [GMSMapStyle styleWithContentsOfFileURL:nightURL error:NULL];
        _googleMapView.mapStyle = _nightStyle;
    }
        
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    contentView.backgroundColor = UIColor.whiteColor;
    self.bottomSheetPresenter = [[BottomSheetPresenter alloc] initWith:self.view andDelegate:self];
    self.bottomSheetPresenter.isBottomSheetHidden = YES;
    [self.bottomSheetPresenter setupBottomSheetViewWith:contentView];
    
    UIScreenEdgePanGestureRecognizer *gesture = (UIScreenEdgePanGestureRecognizer*)[self.navigationController.view.gestureRecognizers objectAtIndex:0];
    [gesture addTarget:self action:@selector(movedExcellentGesture:)];
    
    self.mapObjectsArray = [[NSMutableArray alloc] init];
    self.mapMarkers = [[NSMutableArray alloc] init];
    
    self.popTip = [MapPopTip popTip];
    self.popTip.font = [UIFont fontWithName:@"Avenir-Medium" size:12];
    self.popTip.edgeMargin = 5;
        
    self.popTip.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    self.popTip.shouldDismissOnTap = NO;
    self.popTip.actionAnimation = MapPopTipActionAnimationNone;
    self.popTip.tapHandler = ^{
        NSLog(@"User Tap Open Trip Details mini sheet");
    };
    self.popTip.dismissHandler = ^{
        NSLog(@"User Tap Dismiss Trip Details mini sheet");
    };
    
    NSLog(@"USER NOW SELECTED & OPEN THIS TRACK TOKEN: %@", self.tripToken);
    defaults_set_object(@"selectedTrackToken", self.tripToken);
    _counter = 0;
    
    
    //LOAD USER DATABASE COREDATA INFO
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    claimPopup = [[ClaimAlertPopupDelegate alloc] initOnView:self.view];
    claimPopup.delegate = self;
    claimPopup.dismissOnBackgroundTap = YES;
    
    __weak typeof(claimPopup) weakClaimPopup = claimPopup;
    typeof(self) __weak weakSelf = self;
    self.popTip.wrongEventTapHandler = ^{
        __strong typeof(weakClaimPopup) strongWeakPopup = weakClaimPopup;
        [strongWeakPopup showClaimAlertPopup:weakSelf.selectedEventTypeMarker];
    };
    signatureOnTripPopup = [[DriverSignaturePopupDelegate alloc] initOnView:self.view];
    signatureOnTripPopup.delegate = self;
    signatureOnTripPopup.dismissOnBackgroundTap = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSignaturePopup:) name:@"openDriverSignaturePopup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteThisTrip) name:@"readyDeleteThisTrip" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.delegate = nil;
    
    [GearLoadingView showGearLoadingForView:self.view];
    [self loadMap];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self findIndexOfCurrentTrip];
    [self checkTripsArrayNumbers];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_googleMapView clear];
    [_googleMapView removeFromSuperview];
}

- (void)loadMap {
    __weak typeof(self) weakSelf = self;
    [[RPEntry instance].api getTrackWithTrackToken:self.tripToken completion:^(id response, NSError *error) {
        [weakSelf processMapLoadingResponse:response];
    }];
}

- (void)processMapLoadingResponse:(id)response {
    self.track = response;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL loadMainData = NO;
        if (!self.track) {
            loadMainData = YES;
        }
        [self loadMainPointsForMapView];
        [self loadPointsToMapView];
        
        if (loadMainData) {
            [self loadMainTrackDataForBottomSheet];
        }
        [self loadMainTrackDataForBottomSheet];
    });
}

- (void)loadMainPointsForMapView {
    
    NSMutableArray *allPoints = [[NSMutableArray alloc] init];
    
    GMSMutablePath *coord = [GMSMutablePath path];
    for (int i = 0; i < self.track.points.count; i++) {
        RPTrackPointProcessed *point = self.track.points[i];
        [coord addCoordinate:CLLocationCoordinate2DMake(point.latitude, point.longitude)];
        [allPoints addObject:coord];
        [self.speedPoints addObject:coord];
    }
    
    //self.speedPoints = [NSArray arrayWithArray:allPoints];
    
    GMSPolyline *line = [GMSPolyline polylineWithPath:coord];
    line.strokeColor = [Color officialMainAppColor];
    line.strokeWidth = 4.0;
    line.tappable = TRUE;
    line.map = _googleMapView;
    
    RPTrackPointProcessed *pointStart = self.track.points[0];
    RPTrackPointProcessed *pointFinish = self.track.points[self.track.points.count - 1];
    
    GMSMarker *markerStart = [[GMSMarker alloc] init];
    markerStart.position = CLLocationCoordinate2DMake(pointStart.latitude, pointStart.longitude);
    markerStart.icon = [UIImage imageNamed:@"point_a"];
    markerStart.map = _googleMapView;
    
    GMSMarker *markerFinish = [[GMSMarker alloc] init];
    markerFinish.position = CLLocationCoordinate2DMake(pointFinish.latitude, pointFinish.longitude);
    markerFinish.icon = [UIImage imageNamed:@"point_b"];
    markerFinish.map = _googleMapView;
    
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:pointCenter.latitude longitude:pointCenter.longitude zoom:16];
//    [_googleMapView setCamera:camera];
    
    CLLocationCoordinate2D c_first = CLLocationCoordinate2DMake(pointStart.latitude, pointStart.longitude);
    CLLocationCoordinate2D c_last = CLLocationCoordinate2DMake(pointFinish.latitude, pointFinish.longitude);
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:c_first coordinate:c_last];
    
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(120.0, 70.0, 120.0, 70.0);
    GMSCameraPosition *camera = [_googleMapView cameraForBounds:bounds insets:mapInsets];
    _googleMapView.camera = camera;
          
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"You tapped at %f,%f", coordinate.latitude, coordinate.longitude);
}

- (void)loadPointsToMapView {
    
    for (int i = 1; i < self.track.points.count; i++) {
        RPTrackPointProcessed *point = self.track.points[i];
        RPTrackPointProcessed *previousPoint = self.track.points[i-1];
        
        //RPTrackPointProcessed *mainTrackPoints = self.track.points[i];
        
        if ((BOOL)point.phoneUsage == true) {
            //[phoneCoord addCoordinate:CLLocationCoordinate2DMake(point.latitude, point.longitude)];
            GMSMutablePath *phoneCoord = [GMSMutablePath path];
            [phoneCoord addCoordinate:CLLocationCoordinate2DMake(previousPoint.latitude, previousPoint.longitude)];
            [phoneCoord addCoordinate:CLLocationCoordinate2DMake(point.latitude, point.longitude)];
            
            GMSPolyline *phoneLine = [GMSPolyline polylineWithPath:phoneCoord];
            phoneLine.strokeColor = [UIColor blueColor];
            phoneLine.strokeWidth = 4.0;
            phoneLine.tappable = TRUE;
            phoneLine.map = _googleMapView;
        }
    }
    
    ///////////
    
    for (int i = 1; i < self.track.points.count; i++) {
        RPTrackPointProcessed *realTrackPoint = self.track.points[i];
        RPTrackPointProcessed *previousTrackPoint = self.track.points[i-1];
        
        //GMSPolyline *midSpeedLine = [GMSPolyline polylineWithPath:midSpeedCoord];
        //GMSPolyline *midSpeedLine = [GMSPolyline polylineWithPath:midSpeedCoord];
        
        if (realTrackPoint.speedType == RPSpeedTypeMedium) {
            GMSMutablePath *midSpeedCoord = [GMSMutablePath path];
            [midSpeedCoord addCoordinate:CLLocationCoordinate2DMake(previousTrackPoint.latitude, previousTrackPoint.longitude)];
            [midSpeedCoord addCoordinate:CLLocationCoordinate2DMake(realTrackPoint.latitude, realTrackPoint.longitude)];
            
            GMSPolyline *midSpeedLine = [GMSPolyline polylineWithPath:midSpeedCoord];
            midSpeedLine.strokeColor = [Color officialYellowColor];
            midSpeedLine.strokeWidth = 4.0;
            midSpeedLine.tappable = TRUE;
            midSpeedLine.map = _googleMapView;
        } else if (realTrackPoint.speedType == RPSpeedTypeHigh) {
            GMSMutablePath *highSpeedCoord = [GMSMutablePath path];
            [highSpeedCoord addCoordinate:CLLocationCoordinate2DMake(previousTrackPoint.latitude, previousTrackPoint.longitude)];
            [highSpeedCoord addCoordinate:CLLocationCoordinate2DMake(realTrackPoint.latitude, realTrackPoint.longitude)];
            
            GMSPolyline *highSpeedLine = [GMSPolyline polylineWithPath:highSpeedCoord];
            highSpeedLine.strokeColor = [Color curveRedColor];
            highSpeedLine.strokeWidth = 4.0;
            highSpeedLine.tappable = TRUE;
            highSpeedLine.map = _googleMapView;
        }
        
        switch (realTrackPoint.alertType) {
            //ACCELERATION
            case RPAlertTypeAcceleration: {
                
                GMSMarker *accelMarker = [[GMSMarker alloc] init];
                accelMarker.position = CLLocationCoordinate2DMake(realTrackPoint.latitude, realTrackPoint.longitude);
                accelMarker.icon = [UIImage imageNamed:@"events_acceleration"];
                accelMarker.map = _googleMapView;
                
                //[self.mapView addMapObject:accelMarker];
                [self.mapObjectsArray addObject:accelMarker];

                NSDictionary *markerParams = @{@"Type": localizeString(@"tripdetails_acc"),
                                               @"Icon": @"events_acceleration_short",
                                               @"Lat": @(realTrackPoint.latitude),
                                               @"Lon": @(realTrackPoint.longitude),
                                               @"Date": realTrackPoint.pointDate,
                                               @"Speed": @(realTrackPoint.speed),
                                               @"MaxForce": @(realTrackPoint.alertValue)
                                               };
                [self.mapMarkers addObject:markerParams];
                break;
            }
                
            //BRAKING
            case RPAlertTypeDeceleration: {
                
                GMSMarker *decelerationMarker = [[GMSMarker alloc] init];
                decelerationMarker.position = CLLocationCoordinate2DMake(realTrackPoint.latitude, realTrackPoint.longitude);
                decelerationMarker.icon = [UIImage imageNamed:@"events_braking"];
                decelerationMarker.map = _googleMapView;

                [self.mapObjectsArray addObject:decelerationMarker];

                NSDictionary *markerParams = @{@"Type": localizeString(@"tripdetails_brake"),
                                               @"Icon": @"events_braking_short",
                                               @"Lat": @(realTrackPoint.latitude),
                                               @"Lon": @(realTrackPoint.longitude),
                                               @"Date": realTrackPoint.pointDate,
                                               @"Speed": @(realTrackPoint.speed),
                                               @"MaxForce": @(realTrackPoint.alertValue)
                                               };

                [self.mapMarkers addObject:markerParams];
                break;
            }
            default:
                break;
        }
        
        if (realTrackPoint.cornering == YES) {
            
            GMSMarker *cornerMarker = [[GMSMarker alloc] init];
            cornerMarker.position = CLLocationCoordinate2DMake(realTrackPoint.latitude, realTrackPoint.longitude);
            cornerMarker.icon = [UIImage imageNamed:@"events_cornering"];
            cornerMarker.map = _googleMapView;
            
            [self.mapObjectsArray addObject:cornerMarker];

            NSDictionary *cornerMarkerParams = @{@"Type": localizeString(@"tripdetails_corner"),
                                                 @"Icon": @"events_cornering_short",
                                                 @"Lat": @(realTrackPoint.latitude),
                                                 @"Lon": @(realTrackPoint.longitude),
                                                 @"Date": realTrackPoint.pointDate,
                                                 @"Speed": @(realTrackPoint.speed),
                                                 @"MaxForce": @(realTrackPoint.alertValue)
                                                };

            [self.mapMarkers addObject:cornerMarkerParams];
        }
    }
    
    [UIView animateWithDuration:2.0 animations:^{
        [GearLoadingView hideGearLoadingForView:self.view];
        [self hidePreloader];
    } completion:^(BOOL finished) {
        //
    }];
    
}

- (void)loadMainTrackDataForBottomSheet {
    
    if (self.track.startDate == nil || self.track.endDate == nil) {
        return;
    }
    
    NSDateComponents *comps = [[Format calendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute)
                                                   fromDate:self.track.startDate
                                                     toDate:self.track.endDate
                                                    options:0];
    NSString *time = [[Format dateFormatterTimeHoursMinutes] stringFromDate:[[Format calendar] dateFromComponents:comps]];
    NSString *distance = [NSString stringWithFormat:@"%.0f", _trackDistanceSummary.floatValue];
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        distance = [NSString stringWithFormat:@"%.1f", _trackDistanceSummary.floatValue];
    }
    
    float ratingAcceleration = [self.track.ratingAcceleration100 intValue];
    if (ratingAcceleration == 0)
        ratingAcceleration = [self.track.ratingAcceleration intValue]*20;

    float ratingBraking = [self.track.ratingBraking100 intValue];
    if (ratingBraking == 0)
        ratingBraking = [self.track.ratingBraking intValue]*20;

    float ratingPhoneUsage = [self.track.ratingPhoneUsage100 intValue];
    if (ratingPhoneUsage == 0)
        ratingPhoneUsage = [self.track.ratingPhoneUsage intValue]*20;

    float ratingSpeeding = [self.track.ratingSpeeding100 intValue];
    if (ratingSpeeding == 0)
        ratingSpeeding = [self.track.ratingSpeeding intValue]*20;

    float ratingCornering = [self.track.ratingCornering100 intValue];
    if (ratingCornering == 0)
        ratingCornering = [self.track.ratingCornering intValue]*20;
    
    [self.bottomSheetPresenter updateAllScores:ratingAcceleration brake:ratingBraking phone:ratingPhoneUsage speed:ratingSpeeding corner:ratingCornering];
    
    [self.bottomSheetPresenter updatePointsLabel:_trackPointsSummary];
    [self.bottomSheetPresenter updateKmLabel:distance];
    [self.bottomSheetPresenter updateTimeLabel:time];
    
    NSString *districtStart = self.track.addressStartParts.district;
    NSString *districtEnd = self.track.addressFinishParts.district;
    
    if ([districtStart isEqual:@""] || districtStart == nil) {
        districtStart = self.track.cityStart;
    }
    
    if ([districtEnd isEqual:@""] || districtEnd == nil) {
        districtEnd = self.track.cityFinish;
    }
    
    [self.bottomSheetPresenter updateStartAddressLabel:districtStart];
    [self.bottomSheetPresenter updateEndAddressLabel:districtEnd];
    
    [self.bottomSheetPresenter updateStartTimeLabel:_simpleStartTime];
    [self.bottomSheetPresenter updateEndTimeLabel:_simpleEndTime];
    
    [self.bottomSheetPresenter updateStartCityLabel:self.track.cityStart];
    [self.bottomSheetPresenter updateEndCityLabel:self.track.cityFinish];
    
    //SETUP DRIVER SIGNATURE ROLE ON SHEET
    defaults_set_object(@"selectedTrackSignatureOriginalRole", self.track.trackOriginCode);
    
    if ([self.track.trackOriginCode isEqual:@"OriginalDriver"]) {
        [self.bottomSheetPresenter updateTrackOriginButton:@"OriginalDriver"];
    } else if ([self.track.trackOriginCode isEqual:@"Passenger"] || [self.track.trackOriginCode isEqual:@"Passanger"]) {
        [self.bottomSheetPresenter updateTrackOriginButton:@"Passenger"];
    } else if ([self.track.trackOriginCode isEqual:@"Bus"]) {
        [self.bottomSheetPresenter updateTrackOriginButton:@"Bus"];
    } else if ([self.track.trackOriginCode isEqual:@"Motorcycle"]) {
        [self.bottomSheetPresenter updateTrackOriginButton:@"Motorcycle"];
    } else if ([self.track.trackOriginCode isEqual:@"Train"]) {
        [self.bottomSheetPresenter updateTrackOriginButton:@"Train"];
    } else if ([self.track.trackOriginCode isEqual:@"Taxi"]) {
        [self.bottomSheetPresenter updateTrackOriginButton:@"Taxi"];
    } else if ([self.track.trackOriginCode isEqual:@"Bicycle"]) {
        [self.bottomSheetPresenter updateTrackOriginButton:@"Bicycle"];
    } else if ([self.track.trackOriginCode isEqual:@"Other"]) {
        [self.bottomSheetPresenter updateTrackOriginButton:@"Other"];
    } else {
        [self.bottomSheetPresenter updateTrackOriginButton:@"OriginalDriver"];
    }
    
    //SETUP TAGS BUTTON ON SHEET
    //NSLog(@"%@", self.track.tags);
    NSMutableArray *tags = [[NSMutableArray alloc] init];
    if (self.track.tags.count != 0) {
        for (RPTag *tag in self.track.tags) {
            [tags addObject:tag];
        }
        [self.bottomSheetPresenter updateTrackTagsButton:tags];
    } else {
        [self.bottomSheetPresenter updateTrackTagsButton:tags];
    }
}

#pragma mark - Events Review PopUp

- (void)noEventButtonAction:(ClaimAlertPopup *)popupView button:(UIButton *)button {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:localizeString(@"Are you sure?")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:localizeString(@"Yes") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self->claimPopup hideClaimAlertPopup];
        [self wrongEventBrowsingNoEvent];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:localizeString(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    [alert addAction:yesAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)event1ButtonAction:(ClaimAlertPopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    self.selectedNewEventTypeMarker = newType;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:localizeString(@"Are you sure?")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:localizeString(@"Yes") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self->claimPopup hideClaimAlertPopup];
        [self wrongEventBrowsingNewEvent];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:localizeString(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    [alert addAction:yesAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)event2ButtonAction:(ClaimAlertPopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    self.selectedNewEventTypeMarker = newType;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:localizeString(@"Are you sure?")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:localizeString(@"Yes") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self->claimPopup hideClaimAlertPopup];
        [self wrongEventBrowsingNewEvent];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:localizeString(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    [alert addAction:yesAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)event3ButtonAction:(ClaimAlertPopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    self.selectedNewEventTypeMarker = newType;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:localizeString(@"Are you sure?")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:localizeString(@"Yes") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self->claimPopup hideClaimAlertPopup];
        [self wrongEventBrowsingNewEvent];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:localizeString(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    [alert addAction:yesAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)cancelClaimButtonAction:(ClaimAlertPopup *)popupView button:(UIButton *)button {
    [claimPopup hideClaimAlertPopup];
}


#pragma mark - Driver Signature Role on Trip Details

- (void)showSignaturePopup:(NSNotification*)notification {
    if ([notification.name isEqualToString:@"openDriverSignaturePopup"]) {
        NSDictionary* userInfo = notification.userInfo;
        NSString* selectedSignatureForChange = (NSString*)userInfo[@"driverOriginalRole"];
        [signatureOnTripPopup showDriverSignaturePopup:selectedSignatureForChange];
    }
}


- (void)event1_Driver_ButtonAction:(DriverSignaturePopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    [popupView.event1Btn setBackgroundImage:[UIImage imageNamed:@"driver_green"] forState:UIControlStateNormal];
    [popupView.event2Btn setBackgroundImage:[UIImage imageNamed:@"passenger_white"] forState:UIControlStateNormal];
    [popupView.event3Btn setBackgroundImage:[UIImage imageNamed:@"bus_white"] forState:UIControlStateNormal];
    [popupView.event4Btn setBackgroundImage:[UIImage imageNamed:@"motorcycle_white"] forState:UIControlStateNormal];
    [popupView.event5Btn setBackgroundImage:[UIImage imageNamed:@"train_white"] forState:UIControlStateNormal];
    [popupView.event6Btn setBackgroundImage:[UIImage imageNamed:@"taxi_white"] forState:UIControlStateNormal];
    [popupView.event7Btn setBackgroundImage:[UIImage imageNamed:@"bicycle_white"] forState:UIControlStateNormal];
    [popupView.event8Btn setBackgroundImage:[UIImage imageNamed:@"other_white"] forState:UIControlStateNormal];
    self.selectedDriverSignatureRole = @"OriginalDriver";
}

- (void)event2_Passenger_ButtonAction:(DriverSignaturePopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    [popupView.event1Btn setBackgroundImage:[UIImage imageNamed:@"driver_white"] forState:UIControlStateNormal];
    [popupView.event2Btn setBackgroundImage:[UIImage imageNamed:@"passenger_green"] forState:UIControlStateNormal];
    [popupView.event3Btn setBackgroundImage:[UIImage imageNamed:@"bus_white"] forState:UIControlStateNormal];
    [popupView.event4Btn setBackgroundImage:[UIImage imageNamed:@"motorcycle_white"] forState:UIControlStateNormal];
    [popupView.event5Btn setBackgroundImage:[UIImage imageNamed:@"train_white"] forState:UIControlStateNormal];
    [popupView.event6Btn setBackgroundImage:[UIImage imageNamed:@"taxi_white"] forState:UIControlStateNormal];
    [popupView.event7Btn setBackgroundImage:[UIImage imageNamed:@"bicycle_white"] forState:UIControlStateNormal];
    [popupView.event8Btn setBackgroundImage:[UIImage imageNamed:@"other_white"] forState:UIControlStateNormal];
    self.selectedDriverSignatureRole = @"Passenger";
}

- (void)event3_Bus_ButtonAction:(DriverSignaturePopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    [popupView.event1Btn setBackgroundImage:[UIImage imageNamed:@"driver_white"] forState:UIControlStateNormal];
    [popupView.event2Btn setBackgroundImage:[UIImage imageNamed:@"passenger_white"] forState:UIControlStateNormal];
    [popupView.event3Btn setBackgroundImage:[UIImage imageNamed:@"bus_green"] forState:UIControlStateNormal];
    [popupView.event4Btn setBackgroundImage:[UIImage imageNamed:@"motorcycle_white"] forState:UIControlStateNormal];
    [popupView.event5Btn setBackgroundImage:[UIImage imageNamed:@"train_white"] forState:UIControlStateNormal];
    [popupView.event6Btn setBackgroundImage:[UIImage imageNamed:@"taxi_white"] forState:UIControlStateNormal];
    [popupView.event7Btn setBackgroundImage:[UIImage imageNamed:@"bicycle_white"] forState:UIControlStateNormal];
    [popupView.event8Btn setBackgroundImage:[UIImage imageNamed:@"other_white"] forState:UIControlStateNormal];
    self.selectedDriverSignatureRole = @"Bus";
}

- (void)event4_Motorcycle_ButtonAction:(DriverSignaturePopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    [popupView.event1Btn setBackgroundImage:[UIImage imageNamed:@"driver_white"] forState:UIControlStateNormal];
    [popupView.event2Btn setBackgroundImage:[UIImage imageNamed:@"passenger_white"] forState:UIControlStateNormal];
    [popupView.event3Btn setBackgroundImage:[UIImage imageNamed:@"bus_white"] forState:UIControlStateNormal];
    [popupView.event4Btn setBackgroundImage:[UIImage imageNamed:@"motorcycle_green"] forState:UIControlStateNormal];
    [popupView.event5Btn setBackgroundImage:[UIImage imageNamed:@"train_white"] forState:UIControlStateNormal];
    [popupView.event6Btn setBackgroundImage:[UIImage imageNamed:@"taxi_white"] forState:UIControlStateNormal];
    [popupView.event7Btn setBackgroundImage:[UIImage imageNamed:@"bicycle_white"] forState:UIControlStateNormal];
    [popupView.event8Btn setBackgroundImage:[UIImage imageNamed:@"other_white"] forState:UIControlStateNormal];
    self.selectedDriverSignatureRole = @"Motorcycle";
}

- (void)event5_Train_ButtonAction:(DriverSignaturePopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    [popupView.event1Btn setBackgroundImage:[UIImage imageNamed:@"driver_white"] forState:UIControlStateNormal];
    [popupView.event2Btn setBackgroundImage:[UIImage imageNamed:@"passenger_white"] forState:UIControlStateNormal];
    [popupView.event3Btn setBackgroundImage:[UIImage imageNamed:@"bus_white"] forState:UIControlStateNormal];
    [popupView.event4Btn setBackgroundImage:[UIImage imageNamed:@"motorcycle_white"] forState:UIControlStateNormal];
    [popupView.event5Btn setBackgroundImage:[UIImage imageNamed:@"train_green"] forState:UIControlStateNormal];
    [popupView.event6Btn setBackgroundImage:[UIImage imageNamed:@"taxi_white"] forState:UIControlStateNormal];
    [popupView.event7Btn setBackgroundImage:[UIImage imageNamed:@"bicycle_white"] forState:UIControlStateNormal];
    [popupView.event8Btn setBackgroundImage:[UIImage imageNamed:@"other_white"] forState:UIControlStateNormal];
    self.selectedDriverSignatureRole = @"Train";
}

- (void)event6_Taxi_ButtonAction:(DriverSignaturePopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    [popupView.event1Btn setBackgroundImage:[UIImage imageNamed:@"driver_white"] forState:UIControlStateNormal];
    [popupView.event2Btn setBackgroundImage:[UIImage imageNamed:@"passenger_white"] forState:UIControlStateNormal];
    [popupView.event3Btn setBackgroundImage:[UIImage imageNamed:@"bus_white"] forState:UIControlStateNormal];
    [popupView.event4Btn setBackgroundImage:[UIImage imageNamed:@"motorcycle_white"] forState:UIControlStateNormal];
    [popupView.event5Btn setBackgroundImage:[UIImage imageNamed:@"train_white"] forState:UIControlStateNormal];
    [popupView.event6Btn setBackgroundImage:[UIImage imageNamed:@"taxi_green"] forState:UIControlStateNormal];
    [popupView.event7Btn setBackgroundImage:[UIImage imageNamed:@"bicycle_white"] forState:UIControlStateNormal];
    [popupView.event8Btn setBackgroundImage:[UIImage imageNamed:@"other_white"] forState:UIControlStateNormal];
    self.selectedDriverSignatureRole = @"Taxi";
}

- (void)event7_Bicycle_ButtonAction:(DriverSignaturePopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    [popupView.event1Btn setBackgroundImage:[UIImage imageNamed:@"driver_white"] forState:UIControlStateNormal];
    [popupView.event2Btn setBackgroundImage:[UIImage imageNamed:@"passenger_white"] forState:UIControlStateNormal];
    [popupView.event3Btn setBackgroundImage:[UIImage imageNamed:@"bus_white"] forState:UIControlStateNormal];
    [popupView.event4Btn setBackgroundImage:[UIImage imageNamed:@"motorcycle_white"] forState:UIControlStateNormal];
    [popupView.event5Btn setBackgroundImage:[UIImage imageNamed:@"train_white"] forState:UIControlStateNormal];
    [popupView.event6Btn setBackgroundImage:[UIImage imageNamed:@"taxi_white"] forState:UIControlStateNormal];
    [popupView.event7Btn setBackgroundImage:[UIImage imageNamed:@"bicycle_green"] forState:UIControlStateNormal];
    [popupView.event8Btn setBackgroundImage:[UIImage imageNamed:@"other_white"] forState:UIControlStateNormal];
    self.selectedDriverSignatureRole = @"Bicycle";
}

- (void)event8_Other_ButtonAction:(DriverSignaturePopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    [popupView.event1Btn setBackgroundImage:[UIImage imageNamed:@"driver_white"] forState:UIControlStateNormal];
    [popupView.event2Btn setBackgroundImage:[UIImage imageNamed:@"passenger_white"] forState:UIControlStateNormal];
    [popupView.event3Btn setBackgroundImage:[UIImage imageNamed:@"bus_white"] forState:UIControlStateNormal];
    [popupView.event4Btn setBackgroundImage:[UIImage imageNamed:@"motorcycle_white"] forState:UIControlStateNormal];
    [popupView.event5Btn setBackgroundImage:[UIImage imageNamed:@"train_white"] forState:UIControlStateNormal];
    [popupView.event6Btn setBackgroundImage:[UIImage imageNamed:@"taxi_white"] forState:UIControlStateNormal];
    [popupView.event7Btn setBackgroundImage:[UIImage imageNamed:@"bicycle_white"] forState:UIControlStateNormal];
    [popupView.event8Btn setBackgroundImage:[UIImage imageNamed:@"other_green"] forState:UIControlStateNormal];
    self.selectedDriverSignatureRole = @"Other";
}

- (void)submitSignatureButtonAction:(DriverSignaturePopup *)popupView button:(UIButton *)button {
    NSString *realSelectedTripToken = defaults_object(@"selectedTrackToken");
    
    __weak UIViewController *currentTopVC = [self currentTopViewController];
    [currentTopVC showPreloader];
    __weak typeof(self) weakSelf = self;
    [[RPEntry instance].api changeTrackOrigin:self.selectedDriverSignatureRole forTrackToken:realSelectedTripToken completion:^(id response, NSError *error) {
        __strong UIViewController *strongTopVC = currentTopVC;
        [weakSelf processChangeTrackOriginResponse:strongTopVC error:error];
    }];
}

- (void)processChangeTrackOriginResponse:(UIViewController *)topViewController error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!error) {
            [self->signatureOnTripPopup hideDriverSignaturePopup];
            
            defaults_set_object(@"confirmTripRoleNeeded", @(NO));
            defaults_set_object(@"needUpdateForFeedScreen", @(YES));
            defaults_set_object(@"selectedTrackSignatureOriginalRole", self.selectedDriverSignatureRole);
            
            if ([self.selectedDriverSignatureRole isEqual:@"OriginalDriver"]) {
                [self.bottomSheetPresenter updateTrackOriginButton:@"OriginalDriver"];
            } else if ([self.selectedDriverSignatureRole isEqual:@"Passenger"] || [self.selectedDriverSignatureRole isEqual:@"Passanger"]) {
                [self.bottomSheetPresenter updateTrackOriginButton:@"Passenger"];
            } else if ([self.selectedDriverSignatureRole isEqual:@"Bus"]) {
                [self.bottomSheetPresenter updateTrackOriginButton:@"Bus"];
            } else if ([self.selectedDriverSignatureRole isEqual:@"Motorcycle"]) {
                [self.bottomSheetPresenter updateTrackOriginButton:@"Motorcycle"];
            } else if ([self.selectedDriverSignatureRole isEqual:@"Train"]) {
                [self.bottomSheetPresenter updateTrackOriginButton:@"Train"];
            } else if ([self.selectedDriverSignatureRole isEqual:@"Taxi"]) {
                [self.bottomSheetPresenter updateTrackOriginButton:@"Taxi"];
            } else if ([self.selectedDriverSignatureRole isEqual:@"Bicycle"]) {
                [self.bottomSheetPresenter updateTrackOriginButton:@"Bicycle"];
            } else if ([self.selectedDriverSignatureRole isEqual:@"Other"]) {
                [self.bottomSheetPresenter updateTrackOriginButton:@"Other"];
            } else {
                [self.bottomSheetPresenter updateTrackOriginButton:@"OriginalDriver"];
            }
        }
        
        [topViewController hidePreloader];
    });
}

- (void)cancelSignatureButtonAction:(DriverSignaturePopup *)popupView button:(UIButton *)button {
    [signatureOnTripPopup hideDriverSignaturePopup];
}


#pragma mark - Track Browsing

- (void)startEventsTrackBrowsing {
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            NSLog(@"Success START track events browsing");
        } else {
            NSLog(@"Error track events browsing");
        }
    }] trackEventsStartBrowse:self.tripToken];
}

- (void)wrongEventBrowsingNoEvent {
    __weak typeof(self) weakSelf = self;
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSLog(@"%s %@ %@", __func__, response, error);
        
        if (!error && [response isSuccesful]) {
            if ([strongSelf.popTip isVisible]) {
                [strongSelf.popTip hide];
            }
            
            [strongSelf reloadMapMarkersNoEvent];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:localizeString(@"Thank you, we’ve received your feedback. It will take some time to apply the changes")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:localizeString(@"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                //
            }];
            [alert addAction:action];
            [strongSelf presentViewController:alert animated:YES completion:nil];
        } else {
            if ([strongSelf.popTip isVisible]) {
                [strongSelf.popTip hide];
            }
        }
    }] reportWrongEventNoEvent:self.tripToken lat:self.selectedLatMarker lon:self.selectedLonMarker eventType:self.selectedEventTypeMarker date:self.selectedDateMarker];
}

- (void)wrongEventBrowsingNewEvent {
    if ([self.selectedNewEventTypeMarker isEqualToString:@"Phone Usage"])
        self.selectedNewEventTypeMarker = @"PhoneUsage";
    __weak typeof(self) weakSelf = self;
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSLog(@"%s %@ %@", __func__, response, error);
        
        if (!error && [response isSuccesful]) {
            if ([strongSelf.popTip isVisible]) {
                [strongSelf.popTip hide];
            }
            
            [strongSelf reloadMapMarkersNewEvent];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:localizeString(@"Thank you, we’ve received your feedback. It will take some time to apply the changes")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:localizeString(@"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                //No Action
            }];
            [alert addAction:action];
            [strongSelf presentViewController:alert animated:YES completion:nil];
        } else {
            if ([strongSelf.popTip isVisible]) {
                [strongSelf.popTip hide];
            }
        }
    }] reportWrongEventNewEvent:self.tripToken lat:self.selectedLatMarker lon:self.selectedLonMarker eventType:self.selectedEventTypeMarker newEventType:self.selectedNewEventTypeMarker date:self.selectedDateMarker];
}


#pragma mark - Reload Map Markers

- (void)reloadMapMarkersNoEvent {
    for (int i = 0 ; i < self.mapMarkers.count; i++) {
    
        double latMarker = self.selectedLatMarker.doubleValue;
        double lonMarker = self.selectedLonMarker.doubleValue;
    
        double latForCheck = [[[self.mapMarkers valueForKey:@"Lat"] objectAtIndex:i] doubleValue];
        double lonForCheck = [[[self.mapMarkers valueForKey:@"Lon"] objectAtIndex:i] doubleValue];
        
        NSDate *dateTimeForCheck = [[self.mapMarkers valueForKey:@"Date"] objectAtIndex:i];
        double speedForCheck = [[[self.mapMarkers valueForKey:@"Speed"] objectAtIndex:i] doubleValue];
        double maxForceForCheck = [[[self.mapMarkers valueForKey:@"MaxForce"] objectAtIndex:i] doubleValue];
        
        if (latMarker == latForCheck && lonMarker == lonForCheck) {
            
            NSString *typeName = @"Acceleration";
            NSString *iconName = @"events_acceleration_short";
            UIImage *eventIcon = [UIImage imageNamed:@"events_acceleration"];
            
            if ([self.selectedEventTypeMarker isEqualToString:@"Braking"]) {
                typeName = @"Braking";
                iconName = @"events_braking_short";
                eventIcon = [UIImage imageNamed:@"events_braking"];
            } else if ([self.selectedEventTypeMarker isEqualToString:@"Cornering"]) {
                typeName = @"Cornering";
                iconName = @"events_cornering_short";
                eventIcon = [UIImage imageNamed:@"events_cornering"];
            } else if ([self.selectedEventTypeMarker isEqualToString:@"Phone Usage"]) {
                typeName = @"Phone Usage";
                iconName = @""; //@"cl_red_phone_big";
                eventIcon = nil; //[UIImage imageNamed:@"cl_red_phone"];
            }
            
            GMSMarker *cornerMarker = [[GMSMarker alloc] init];
            cornerMarker.position = CLLocationCoordinate2DMake(latForCheck, lonForCheck);
            cornerMarker.icon = [UIImage imageNamed:@"events_cornering"];
            cornerMarker.map = _googleMapView;
            [self.mapObjectsArray addObject:cornerMarker];

            NSDictionary *cornerMarkerParams = @{@"Type": typeName,
                                                 @"Icon": iconName,
                                                 @"Lat": @(latForCheck),
                                                 @"Lon": @(lonForCheck),
                                                 @"Date": dateTimeForCheck,
                                                 @"Speed": @(speedForCheck),
                                                 @"MaxForce": @(maxForceForCheck)
            };

            [self.mapMarkers addObject:cornerMarkerParams];
            return;
        }
    }
}

- (void)reloadMapMarkersNewEvent {
    for (int i = 0 ; i < self.mapMarkers.count; i++) {
    
        double latMarker = self.selectedLatMarker.doubleValue;
        double lonMarker = self.selectedLonMarker.doubleValue;
    
        double latForCheck = [[[self.mapMarkers valueForKey:@"Lat"] objectAtIndex:i] doubleValue];
        double lonForCheck = [[[self.mapMarkers valueForKey:@"Lon"] objectAtIndex:i] doubleValue];
        
        NSDate *dateTimeForCheck = [[self.mapMarkers valueForKey:@"Date"] objectAtIndex:i];
        double speedForCheck = [[[self.mapMarkers valueForKey:@"Speed"] objectAtIndex:i] doubleValue];
        double maxForceForCheck = [[[self.mapMarkers valueForKey:@"MaxForce"] objectAtIndex:i] doubleValue];
        
        if (latMarker == latForCheck && lonMarker == lonForCheck) {
            
            NSString *typeName = @"Acceleration";
            NSString *iconName = @"events_acceleration_short";
            UIImage *eventIcon = nil;
            
            if ([self.selectedNewEventTypeMarker isEqualToString:@"Braking"]) {
                typeName = @"Braking";
                iconName = @"events_braking_short";
                eventIcon = nil;
            } else if ([self.selectedNewEventTypeMarker isEqualToString:@"Cornering"]) {
                typeName = @"Cornering";
                iconName = @"events_cornering_short";
                eventIcon = nil;
            } else if ([self.selectedNewEventTypeMarker isEqualToString:@"PhoneUsage"]) {
                typeName = @"Phone Usage";
                
                if ([self.selectedEventTypeMarker isEqualToString:@"Acceleration"]) {
                    iconName = @"events_acceleration_short";
                } else if ([self.selectedEventTypeMarker isEqualToString:@"Braking"]) {
                    iconName = @"events_braking_short";
                } else if ([self.selectedEventTypeMarker isEqualToString:@"Cornering"]) {
                    iconName = @"events_cornering_short";
                } else if ([self.selectedEventTypeMarker isEqualToString:@"Phone Usage"]) {
                    iconName = @"";
                }
                
                //iconName = @"";
                eventIcon = nil;
            }
            
            GMSMarker *cornerMarker = [[GMSMarker alloc] init];
            cornerMarker.position = CLLocationCoordinate2DMake(latForCheck, lonForCheck);
            cornerMarker.icon = [UIImage imageNamed:@"events_cornering"];
            cornerMarker.map = _googleMapView;
            [self.mapObjectsArray addObject:cornerMarker];

            NSDictionary *cornerMarkerParams = @{@"Type": typeName,
                                                 @"Icon": iconName,
                                                 @"Lat": @(latForCheck),
                                                 @"Lon": @(lonForCheck),
                                                 @"Date": dateTimeForCheck,
                                                 @"Speed": @(speedForCheck),
                                                 @"MaxForce": @(maxForceForCheck)
            };

            [self.mapMarkers addObject:cornerMarkerParams];
            return;
        }
    }
}

- (void)processAddTagResponse:(id)response selectedTrack:(NSString *)tmpToken error:(NSArray *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            if (self.sortedOnlyTrips.count == 1) {
                [self backBtnClick:self];
                [self hidePreloader];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAllFeedPage" object:nil];
                return;
            }
            
            if (self.trackTag <= 0 && self.trackTag != self.sortedOnlyTrips.count-1) {
                if (self.trackTag == 0 && self.sortedOnlyTrips.count == 2) {
                    [self nextTrip:self];
                } else if (self.trackTag == 0 && self.sortedOnlyTrips.count > 2) {
                    [self nextTrip:self];
                    self.trackTag = self.trackTag-1;
                } else {
                    [self backBtnClick:self];
                    [self hidePreloader];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAllFeedPage" object:nil];
                }
                
            } else if (self.trackTag >= self.sortedOnlyTrips.count-1) {
                if (self.trackTag == 1 && self.sortedOnlyTrips.count == 2) {
                    [self backBtnClick:self];
                    [self hidePreloader];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAllFeedPage" object:nil];
                } else {
                    [self backBtnClick:self];
                    [self hidePreloader];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAllFeedPage" object:nil];
                }
                
            } else {
                [self nextTrip:self];
                self.trackTag = self.trackTag-1;
            }
            
            for (int i = 0; i < self.sortedOnlyTrips.count; i++) {
                NSString *simpleToken = [[self.sortedOnlyTrips valueForKey:@"trackToken"] objectAtIndex:i];
                if ([simpleToken isEqual:tmpToken]) {
                    [self.sortedOnlyTrips removeObjectAtIndex:i];
                    defaults_set_object(@"needUpdateForFeedScreen", @(YES));
                }
            }
            
            defaults_set_object(@"LatestTripToken", @"");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLatestTripDashboardMap" object:self];
            
        } else {
            [self hidePreloader];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:localizeString(@"An error occurred while trip hiding. Try again later.")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:localizeString(@"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self backBtnClick:self];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    });
}


#pragma mark - Delete Trip

- (void)deleteThisTrip {
    [self showPreloader];
    
    NSString *realToken = defaults_object(@"selectedTrackToken");
    NSString *tmpTokenForDeleting = defaults_object(@"selectedTrackToken");
    NSLog(@"tToken %@", realToken);
    NSLog(@"tmpTokenForDeleting %@", tmpTokenForDeleting);
    
   [self deleteThisTripSendStatusForBackEnd:realToken];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSLog(@"%ld", (long)self.trackTag);
        NSLog(@"%ld", self.sortedOnlyTrips.count);
        
        if (self.sortedOnlyTrips.count == 1) {
            [self backBtnClick:self];
            [self hidePreloader];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAllFeedPage" object:nil];
            return;
        }
        
        if (self.trackTag == 0) {
            self.tripBackBtn.enabled = NO;
            self.tripBackBtn.alpha = 0.4;
        }
        
        if (self.trackTag <= 0 && self.trackTag != self.sortedOnlyTrips.count-1) {
            if (self.trackTag == 0 && self.sortedOnlyTrips.count == 2) {
                [self nextTrip:self];
            } else if (self.trackTag == 0 && self.sortedOnlyTrips.count > 2) {
                [self nextTrip:self];
                self.trackTag = self.trackTag-1;
            } else {
                [self backBtnClick:self];
                [self hidePreloader];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAllFeedPage" object:nil];
            }
            
        } else if (self.trackTag >= self.sortedOnlyTrips.count-1) {
            if (self.trackTag == 1 && self.sortedOnlyTrips.count == 2) {
                [self backBtnClick:self];
                [self hidePreloader];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAllFeedPage" object:nil];
                
                //DEPRECATED
                //[self lastTrip:self];
                //self.trackTag = self.trackTag+1;
            } else {
                [self backBtnClick:self];
                [self hidePreloader];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAllFeedPage" object:nil];
            }
            
        } else {
            [self nextTrip:self];
            self.trackTag = self.trackTag-1;
        }
        
        for (int i = 0; i < self.sortedOnlyTrips.count; i++) {
            NSString *simpleToken = [[self.sortedOnlyTrips valueForKey:@"trackToken"] objectAtIndex:i];
            if ([simpleToken isEqual:tmpTokenForDeleting]) {
                [self.sortedOnlyTrips removeObjectAtIndex:i];
                defaults_set_object(@"needUpdateForFeedScreen", @(YES));
            }
        }
        
        defaults_set_object(@"LatestTripToken", @"");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLatestTripDashboardMap" object:self];
    });
}

- (void)deleteThisTripSendStatusForBackEnd:(NSString *)trackToken {
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            NSLog(@"Success Deleting Track");
        } else {
            NSLog(@"%@", error);
        }
    }] deleteThisTripSendStatusForBackEnd:trackToken];
}


#pragma mark - Trips Left/Right Navigation

- (IBAction)nextTrip:(id)sender {
    
    [self showPreloader];
    
    if ([self.popTip isVisible]) {
        [self.popTip hide];
    }
    
    RPTrackProcessed *nextTrack = self.sortedOnlyTrips[self.trackTag+1];
    self.tripToken = [nextTrack valueForKey:@"Id"];
    self.trackTag = self.trackTag+1;
    
    float rating = [[[nextTrack valueForKey:@"Scores"] valueForKey:@"Safety"] floatValue];
    float distance = [[[nextTrack valueForKey:@"Statistics"] valueForKey:@"Mileage"] floatValue];
    
    self.trackPointsSummary = [NSString stringWithFormat:@"%.0f", rating];
    self.trackDistanceSummary = [NSString stringWithFormat:@"%.0f", distance];
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        float miles = convertKmToMiles(distance);
        self.trackDistanceSummary = [NSString stringWithFormat:@"%.1f", miles];
    }
    
    NSString* startDateStr = [[nextTrack valueForKey:@"Data"] valueForKey:@"StartDate"];
    NSString* endDateStr = [[nextTrack valueForKey:@"Data"] valueForKey:@"EndDate"];
    
    NSDate *dateStart = [NSDate dateWithISO8601String:startDateStr];
    NSDate *dateEnd = [NSDate dateWithISO8601String:endDateStr];
    
    NSString *dateStartFormat = [dateStart dateTimeStringShort];
    NSString *dateEndFormat = [dateEnd dateTimeStringShort];
    
    if ([Configurator sharedInstance].needAmPmTime || [defaults_object(@"needDateSpecialFormat") boolValue] || [defaults_object(@"needAmPmFormat") boolValue]) {
        if ([defaults_object(@"needDateSpecialFormat") boolValue] && ![defaults_object(@"needAmPmFormat") boolValue]) {
            dateStartFormat = [dateStart dateTimeStringShortMmDd24];
            dateEndFormat = [dateEnd dateTimeStringShortMmDd24];
        } else if (![defaults_object(@"needDateSpecialFormat") boolValue] && [defaults_object(@"needAmPmFormat") boolValue]) {
            dateStartFormat = [dateStart dateTimeStringShortDdMmAmPm];
            dateEndFormat = [dateEnd dateTimeStringShortDdMmAmPm];
        } else if (![defaults_object(@"needDateSpecialFormat") boolValue] && ![defaults_object(@"needAmPmFormat") boolValue]) {
            dateStartFormat = [dateStart dateTimeStringShortDdMm24];
            dateEndFormat = [dateEnd dateTimeStringShortDdMm24];
        } else {
            dateStartFormat = [dateStart dateTimeStringShortMmDdAmPm];
            dateEndFormat = [dateEnd dateTimeStringShortMmDdAmPm];
        }
    }
    
    self.simpleStartTime = dateStartFormat;
    self.simpleEndTime = dateEndFormat;
    
    defaults_set_object(@"selectedTrackToken", self.tripToken);
    
    [_googleMapView clear];
    [self loadMap];
    [self checkTripsArrayNumbers];
}

- (IBAction)lastTrip:(id)sender {
    
    NSLog(@"%ld", (long)self.trackTag);
    NSLog(@"%ld", self.sortedOnlyTrips.count);
    
    if (self.trackTag == 0) {
        self.tripBackBtn.enabled = NO;
        self.tripBackBtn.alpha = 0.4;
        return;
    }
    
    [self showPreloader];
    
    if ([self.popTip isVisible]) {
        [self.popTip hide];
    }
    
    RPTrackProcessed *lastTrack = self.sortedOnlyTrips[self.trackTag-1];
    self.tripToken = [lastTrack valueForKey:@"Id"];
    self.trackTag = self.trackTag-1;
    
    float rating = [[[lastTrack valueForKey:@"Scores"] valueForKey:@"Safety"] floatValue];
    float distance = [[[lastTrack valueForKey:@"Statistics"] valueForKey:@"Mileage"] floatValue];
    
    self.trackPointsSummary = [NSString stringWithFormat:@"%.0f", rating];
    self.trackDistanceSummary = [NSString stringWithFormat:@"%.0f", distance];
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        float miles = convertKmToMiles(distance);
        self.trackDistanceSummary = [NSString stringWithFormat:@"%.1f", miles];
    }
    
    NSString* startDateStr = [[lastTrack valueForKey:@"Data"] valueForKey:@"StartDate"];
    NSString* endDateStr = [[lastTrack valueForKey:@"Data"] valueForKey:@"EndDate"];
    
    NSDate *dateStart = [NSDate dateWithISO8601String:startDateStr];
    NSDate *dateEnd = [NSDate dateWithISO8601String:endDateStr];
    
    NSString *dateStartFormat = [dateStart dateTimeStringShort];
    NSString *dateEndFormat = [dateEnd dateTimeStringShort];
    
    if ([Configurator sharedInstance].needAmPmTime || [defaults_object(@"needDateSpecialFormat") boolValue] || [defaults_object(@"needAmPmFormat") boolValue]) {
        if ([defaults_object(@"needDateSpecialFormat") boolValue] && ![defaults_object(@"needAmPmFormat") boolValue]) {
            dateStartFormat = [dateStart dateTimeStringShortMmDd24];
            dateEndFormat = [dateEnd dateTimeStringShortMmDd24];
        } else if (![defaults_object(@"needDateSpecialFormat") boolValue] && [defaults_object(@"needAmPmFormat") boolValue]) {
            dateStartFormat = [dateStart dateTimeStringShortDdMmAmPm];
            dateEndFormat = [dateEnd dateTimeStringShortDdMmAmPm];
        } else if (![defaults_object(@"needDateSpecialFormat") boolValue] && ![defaults_object(@"needAmPmFormat") boolValue]) {
            dateStartFormat = [dateStart dateTimeStringShortDdMm24];
            dateEndFormat = [dateEnd dateTimeStringShortDdMm24];
        } else {
            dateStartFormat = [dateStart dateTimeStringShortMmDdAmPm];
            dateEndFormat = [dateEnd dateTimeStringShortMmDdAmPm];
        }
    }
    
    self.simpleStartTime = dateStartFormat;
    self.simpleEndTime = dateEndFormat;
    
    defaults_set_object(@"selectedTrackToken", self.tripToken);
    
    [_googleMapView clear];
    [self loadMap];
    [self checkTripsArrayNumbers];
}

- (void)findIndexOfCurrentTrip {
    for (int i = 0; i < self.sortedOnlyTrips.count; i++) {
        NSString *simpleToken = [[self.sortedOnlyTrips valueForKey:@"trackToken"] objectAtIndex:i];
        if ([simpleToken isEqual:self.tripToken]) {
            self.trackTag = i;
        }
    }
}

- (void)checkTripsArrayNumbers {
    if (self.sortedOnlyTrips.count == 1) {
        self.tripBackBtn.enabled = NO;
        self.tripBackBtn.alpha = 0.4;
        
        self.tripForwardBtn.enabled = NO;
        self.tripForwardBtn.alpha = 0.4;
        return;
    }
    
    NSLog(@"%ld", (long)self.trackTag);
    NSLog(@"%ld", self.sortedOnlyTrips.count);
    
    if (self.trackTag <= 0 && self.trackTag != self.sortedOnlyTrips.count-1) {
        self.tripBackBtn.enabled = NO;
        self.tripBackBtn.alpha = 0.4;
        
        if (self.trackTag == 0 && self.sortedOnlyTrips.count == 2) {
            self.tripForwardBtn.enabled = YES;
            self.tripForwardBtn.alpha = 0.7;
        }
    } else if (self.trackTag == 1 && self.sortedOnlyTrips.count > 2) {
        self.tripForwardBtn.enabled = YES;
        self.tripForwardBtn.alpha = 0.7;
        
        if (self.trackTag >= 1 && self.trackTag != self.sortedOnlyTrips.count-1) { //TODO!!!
            self.tripBackBtn.enabled = YES;
            self.tripBackBtn.alpha = 0.7;
        }
        
    } else if (self.trackTag >= self.sortedOnlyTrips.count-1) {
        self.tripForwardBtn.enabled = NO;
        self.tripForwardBtn.alpha = 0.4;
        
        if (self.trackTag == 1 && self.sortedOnlyTrips.count == 2) {
            self.tripBackBtn.enabled = YES;
            self.tripBackBtn.alpha = 0.7;
        }
    } else {
        self.tripBackBtn.enabled = YES;
        self.tripBackBtn.alpha = 0.7;
        
        self.tripForwardBtn.enabled = YES;
        self.tripForwardBtn.alpha = 0.7;
    }
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    
//    if (selectedPlace != nil) {
//        selectedPlace = nil;
//        return;
//    }
//    double latitude = mapView.camera.target.latitude;
//    double longitude = mapView.camera.target.longitude;
//
//    CLLocationCoordinate2D addressCoordinates = CLLocationCoordinate2DMake(latitude, longitude);
//
//    NSNumber *latitudeStr = [[NSNumber alloc] initWithDouble:addressCoordinates.latitude];
//    NSNumber *longitudeStr = [[NSNumber alloc] initWithDouble:addressCoordinates.longitude];
//
//    [ClaimsService sharedService].Lat = [latitudeStr stringValue];
//    [ClaimsService sharedService].Lng = [longitudeStr stringValue];
//
//    GMSGeocoder* coder = [[GMSGeocoder alloc] init];
//    [coder reverseGeocodeCoordinate:addressCoordinates completionHandler:^(GMSReverseGeocodeResponse *results, NSError *error) {
//        if (error) {
//            // NSLog(@"Error %@", error.description);
//            self.country = @"";
//            self.city = @"";
//        } else {
//            GMSAddress* address = [results firstResult];
//            self.city = address.locality ? address.locality : @"";
//            self.country = address.country ? address.country : @"";
//            NSArray *arr = [address valueForKey:@"lines"];
//            NSString *str1 = [NSString stringWithFormat:@"%lu",(unsigned long)[arr count]];
//
//            if ([str1 isEqualToString:@"0"]) {
//                self.addressLabel.text = @"";
//
//            } else if ([str1 isEqualToString:@"1"]) {
//                NSString *str2 = [arr objectAtIndex:0];
//                self.addressLabel.text = str2;
//
//                if (str2 != nil && ![str2 isEqualToString:@"0"]) {
//                    [ClaimsService sharedService].LocationStr = str2;
//                }
//
//            } else if ([str1 isEqualToString:@"2"]) {
//                NSString *str2 = [arr objectAtIndex:0];
//                NSString *str3 = [arr objectAtIndex:1];
//                if (str2.length > 1 ) {
//                    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@", str2, str3];
//                } else {
//                    self.addressLabel.text = [NSString stringWithFormat:@"%@",str3];
//                }
//            }
//        }
//    }];
}


#pragma mark - Utils

- (UIImage *)imageWithImage:(UIImage *)image scale:(CGFloat)scale {
    CGSize newSize = CGSizeMake(image.size.width*scale, image.size.height*scale);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (IBAction)backBtnClick:(id)sender {
    //[_googleMapView clear];
    //[_googleMapView removeFromSuperview];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)swipeHandlerRight:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)movedExcellentGesture:(id)sender {
    [[self.navigationController.view.gestureRecognizers objectAtIndex:0] removeTarget:self action:@selector(movedExcellentGesture:)];
}


#pragma mark - Bottom Sheet View

- (void)animationFinished {
    //NSLog(@"Bottom Trip Sheet View Animation Finished");
}

- (double)bounceHeight {
    return 550;
}

- (double)expandedHeight {
    return 510;
}

- (double)collapsedHeight {
    return 90;
}

#pragma mark - Navigation

- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    
    self.country = @"";
    self.city = @"";
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
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


#pragma mark - View Detecting

- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

@end
