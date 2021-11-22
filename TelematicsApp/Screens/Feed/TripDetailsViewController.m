//
//  TripDetailsViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 10.06.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TripDetailsViewController.h"
#import "BottomSheetPresenter.h"
#import "Format.h"
#import "Color.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"
#import <NMAKit/NMAKit.h>
#import "GearLoadingView.h"
#import "UIViewController+Preloader.h"
#import "ClaimAlertPopupDelegate.h"
#import "DriverSignaturePopupDelegate.h"
#import "MapPopTip.h"
#import "UIImage+FixOrientation.h"
#import "HapticHelper.h"
#import "Helpers.h"


@interface TripDetailsViewController () <NMAMapViewDelegate, BottomSheetPresenterDelegate, ClaimAlertPopupProtocol, DriverSignaturePopupProtocol> {
    ClaimAlertPopupDelegate *claimPopup;
    DriverSignaturePopupDelegate *signatureOnTripPopup;
}

@property (weak, nonatomic) IBOutlet NMAMapView         *mapView;
@property (nonatomic) NSArray<NMAGeoCoordinates *>      *speedPoints;
@property (nonatomic) NSArray<NMAGeoCoordinates *>      *markerPoints;
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
@property (weak, nonatomic) IBOutlet UILabel            *mainTitle;
@property (weak, nonatomic) IBOutlet UIButton           *centerBtn;
@property (weak, nonatomic) IBOutlet UIButton           *tripBackBtn;
@property (weak, nonatomic) IBOutlet UIButton           *tripForwardBtn;
@property int                                           counter;

@end

@implementation TripDetailsViewController {
    NMAMapMarker* _gestureMarker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = localizeString(@"trip_detailed_title");
    self.mainTitle.text = localizeString(@"trip_detailed_title");
    self.view.backgroundColor = [Color blackColor];
    
    [NMAMapView class];
    self.mapView.delegate = self;
    self.mapView.gestureDelegate = self;
    self.mapView.copyrightLogoPosition = NMALayoutPositionBottomCenter;
    [self.mapView useDisplayLanguageFromLocale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
    
    [self.mapView setMapScheme:NMAMapSchemeNormalNight];
    self.mapView.transitDisplayMode = NMAMapTransitDisplayModeNothing;
    self.mapView.trafficDisplayFilter = NMATrafficSeverityUndefined;
    self.mapView.trafficVisible = NO;
    self.mapView.safetySpotsVisible = NO;
    self.mapView.landmarksVisible = NO;
    self.mapView.extrudedBuildingsVisible = NO;
    [self.mapView setVisibility:NO forPoiCategory:NMAMapPoiCategoryAll]; //all off

    //INITIALIZE USER APP MODEL
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    contentView.backgroundColor = UIColor.whiteColor;
    self.bottomSheetPresenter = [[BottomSheetPresenter alloc] initWith:self.view andDelegate:self];
    self.bottomSheetPresenter.isBottomSheetHidden = YES;
    [self.bottomSheetPresenter setupBottomSheetViewWith:contentView];
    
    UIScreenEdgePanGestureRecognizer *gesture = (UIScreenEdgePanGestureRecognizer*)[self.navigationController.view.gestureRecognizers objectAtIndex:0];
    [gesture addTarget:self action:@selector(moved:)];
    
    self.mapObjectsArray = [[NSMutableArray alloc] init];
    self.mapMarkers = [[NSMutableArray alloc] init];
    
    self.popTip = [MapPopTip popTip];
    self.popTip.font = [UIFont fontWithName:@"Avenir-Medium" size:12];
    self.popTip.edgeMargin = 5;
    self.popTip.offset = 7;
    if (IS_IPHONE_11 || IS_IPHONE_13_PRO || IS_IPHONE_8 || IS_IPHONE_5 || IS_IPHONE_4) {
        self.popTip.offset = 2;
    }
    self.popTip.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    self.popTip.shouldDismissOnTap = NO;
    self.popTip.actionAnimation = MapPopTipActionAnimationNone;
    self.popTip.tapHandler = ^{
        NSLog(@"Tap mini sheet");
    };
    self.popTip.dismissHandler = ^{
        NSLog(@"Dismiss mini sheet");
    };
    
    claimPopup = [[ClaimAlertPopupDelegate alloc] initOnView:self.view];
    claimPopup.delegate = self;
    claimPopup.dismissOnBackgroundTap = YES;
    
    __weak typeof(claimPopup) weakClaimPopup = claimPopup;
    typeof(self) __weak weakSelf = self;
    self.popTip.wrongEventTapHandler = ^{
        [weakSelf startEventsTrackBrowsing];
        __strong typeof(weakClaimPopup) strongWeakPopup = weakClaimPopup;
        [strongWeakPopup showClaimAlertPopup:weakSelf.selectedEventTypeMarker];
    };
    
    signatureOnTripPopup = [[DriverSignaturePopupDelegate alloc] initOnView:self.view];
    signatureOnTripPopup.delegate = self;
    signatureOnTripPopup.dismissOnBackgroundTap = YES;
    
    defaults_set_object(@"selectedTrackToken", self.trackToken);
    _counter = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSignaturePopup:) name:@"openDriverSignaturePopup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteThisTrip) name:@"readyDeleteThisTrip" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GearLoadingView showGearLoadingForView:self.view];
    self.mapView.hidden = YES;
    
    [self loadMap];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self findIndexOfCurrentTrip];
    [self checkTripsArrayNumbers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.bottomSheetPresenter = nil;
    self.mapView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"openDriverSignaturePopup" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"readyDeleteThisTrip" object:nil];
}

- (void)loadMap {
    [[RPEntry instance].api getTrackWithTrackToken:self.trackToken completion:^(id response, NSError *error) {
        self.track = response;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL loadMainData = NO;
            if (!self.track) {
                loadMainData = YES;
            }
            [self loadMainPointsForMapView];
            [self loadPointsToMapView];
            if (loadMainData) {
                [self loadMainTrackData];
            }
            [self loadMainTrackData];
        });
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.track) {
            [self loadMainTrackData];
        }
    });
}

- (void)loadMainTrackData {
    
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
    } else if ([self.track.trackOriginCode isEqual:@"Passanger"] || [self.track.trackOriginCode isEqual:@"Passenger"]) {
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


#pragma mark - NMAMapView

- (void)loadMainPointsForMapView {
    
    NSMutableArray *points = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.track.points.count; i++) {
        RPTrackPointProcessed *point = self.track.points[i];
        NMAGeoCoordinates *coord = [[NMAGeoCoordinates alloc] initWithLatitude:point.latitude
                                                                     longitude:point.longitude];
        [points addObject:coord];
    }
    self.speedPoints = [NSArray arrayWithArray:points];
}

- (void)loadPointsToMapView {
    
    NMAMapPolyline *greenLine = [[NMAMapPolyline alloc] initWithVertices:self.speedPoints];
    greenLine = [[NMAMapPolyline alloc] initWithVertices:self.speedPoints];
    if (IS_IPHONE_8 || IS_IPHONE_5 || IS_IPHONE_4) {
        greenLine.lineWidth = 8;
    } else {
        greenLine.lineWidth = 10;
    }
    greenLine.lineColor = UIColorFromHex(0x54c751);
    
    for (int i = 1; i < self.speedPoints.count; i++) {
        NMAGeoCoordinates *point = self.speedPoints[i];
        NMAGeoCoordinates *previousPoint = self.speedPoints[i - 1];
        
        RPTrackPointProcessed *mainTrackPoints = self.track.points[i];
        NMAMapPolyline *mainPhoneLine = [[NMAMapPolyline alloc] initWithVertices:@[previousPoint, point]];
        
        if ((BOOL)mainTrackPoints.phoneUsage == true) {
            if ([mainPhoneLine isKindOfClass:[NMAMapObject class]]) {
                mainPhoneLine.lineColor = [UIColor blueColor];
                if (IS_IPHONE_8 || IS_IPHONE_5 || IS_IPHONE_4) {
                    mainPhoneLine.lineWidth = 17;
                } else {
                    mainPhoneLine.lineWidth = 27;
                }
                [self.mapView addMapObject:mainPhoneLine];
                [self.mapObjectsArray addObject:mainPhoneLine];
            }
        }
    }
        
    [self.mapView addMapObject:greenLine];
    [self.mapObjectsArray addObject:greenLine];
    
    for (int i = 1; i < self.speedPoints.count; i++) {
        NMAGeoCoordinates *point = self.speedPoints[i];
        NMAGeoCoordinates *previousPoint = self.speedPoints[i - 1];
        
        NMAMapPolyline *speedLine = [[NMAMapPolyline alloc] initWithVertices:@[previousPoint, point]];
        
        if (IS_IPHONE_8 || IS_IPHONE_5 || IS_IPHONE_4) {
            speedLine.lineWidth = 8;
        } else {
            speedLine.lineWidth = 10;
        }
        
        RPTrackPointProcessed *trackPoint = self.track.points[i];
        switch (trackPoint.speedType) {
            case RPSpeedTypeHigh:
                speedLine.lineColor = UIColorFromHex(0xff0a0b);
                break;
            case RPSpeedTypeMedium:
                speedLine.lineColor = UIColorFromHex(0xf5eb30);
                break;
            default:
                speedLine.lineColor = UIColorFromHex(0x40d450);
                break;
        }
        
        if ([speedLine isKindOfClass:[NMAMapObject class]] && trackPoint.speedType != RPSpeedTypeNormal) {
            [self.mapView addMapObject:speedLine];
            [self.mapObjectsArray addObject:speedLine];
        }
        
        
        switch (trackPoint.alertType) {
            case RPAlertTypeAcceleration: {
                UIImage *accelIcon = [UIImage imageNamed:@"cl_white_acc_big"];
                if (IS_IPHONE_11 || IS_IPHONE_13_PRO || IS_IPHONE_8 || IS_IPHONE_5 || IS_IPHONE_4) {
                    accelIcon = [UIImage imageWithImageHelper:accelIcon scale:0.8];
                }
                
                NMAMapMarker *accelMarker =
                [NMAMapMarker mapMarkerWithGeoCoordinates:[NMAGeoCoordinates geoCoordinatesWithLatitude:point.latitude
                                                                                              longitude:point.longitude]
                                                    image:accelIcon];
                accelMarker.zIndex = 2;
                [self.mapView addMapObject:accelMarker];
                [self.mapObjectsArray addObject:accelMarker];

                NSDictionary *markerParams = @{@"Type": localizeString(@"tripdetails_acc"),
                                               @"Icon": @"cl_gray_acc_big",
                                               @"Lat": @(point.latitude),
                                               @"Lon": @(point.longitude),
                                               @"Date": trackPoint.pointDate,
                                               @"Speed": @(trackPoint.speed),
                                               @"MaxForce": @(trackPoint.alertValue)
                                               };

                [self.mapMarkers addObject:markerParams];
                break;
            }
            case RPAlertTypeDeceleration: {

                UIImage *decelIcon = [UIImage imageNamed:@"cl_white_brake_big"];
                if (IS_IPHONE_11 || IS_IPHONE_13_PRO || IS_IPHONE_8 || IS_IPHONE_5 || IS_IPHONE_4) {
                    decelIcon = [UIImage imageWithImageHelper:decelIcon scale:0.8];
                }
                
                NMAMapMarker *decelMarker =
                [NMAMapMarker mapMarkerWithGeoCoordinates:[NMAGeoCoordinates geoCoordinatesWithLatitude:point.latitude
                                                                                              longitude:point.longitude]
                                                    image:decelIcon];
                decelMarker.zIndex = 3;
                [self.mapView addMapObject:decelMarker];
                [self.mapObjectsArray addObject:decelMarker];

                NSDictionary *markerParams = @{@"Type": localizeString(@"tripdetails_brake"),
                                               @"Icon": @"cl_gray_brake_big",
                                               @"Lat": @(point.latitude),
                                               @"Lon": @(point.longitude),
                                               @"Date": trackPoint.pointDate,
                                               @"Speed": @(trackPoint.speed),
                                               @"MaxForce": @(trackPoint.alertValue)
                                               };

                [self.mapMarkers addObject:markerParams];
                break;
            }
            default:
                break;
        }
        
        if (trackPoint.cornering == YES) {
            UIImage *cornerIcon = [UIImage imageNamed:@"cl_white_turn_big"];
            if (IS_IPHONE_11 || IS_IPHONE_13_PRO || IS_IPHONE_8 || IS_IPHONE_5 || IS_IPHONE_4) {
                cornerIcon = [UIImage imageWithImageHelper:cornerIcon scale:0.8];
            }
            
            NMAMapMarker *cornerMarker =
            [NMAMapMarker mapMarkerWithGeoCoordinates:[NMAGeoCoordinates geoCoordinatesWithLatitude:point.latitude
                                                                                          longitude:point.longitude]
                                                image:cornerIcon];
            cornerMarker.zIndex = 4;
            [self.mapView addMapObject:cornerMarker];
            [self.mapObjectsArray addObject:cornerMarker];

            NSDictionary *cornerMarkerParams = @{@"Type": localizeString(@"tripdetails_corner"),
                                                 @"Icon": @"cl_gray_turn_big",
                                                 @"Lat": @(point.latitude),
                                                 @"Lon": @(point.longitude),
                                                 @"Date": trackPoint.pointDate,
                                                 @"Speed": @(trackPoint.speed),
                                                 @"MaxForce": @(trackPoint.alertValue)
            };

            [self.mapMarkers addObject:cornerMarkerParams];
        }
    }
    
    NMAGeoBoundingBox *routeBounds = [NMAGeoBoundingBox geoBoundingBoxContainingGeoCoordinates:self.speedPoints];
    routeBounds = [NMAGeoBoundingBox geoBoundingBoxWithCenter:routeBounds.center
                                                        width:routeBounds.width*1.2 //2
                                                       height:routeBounds.height*1.2]; //2
    [self.mapView setBoundingBox:routeBounds withAnimation:NMAMapAnimationLinear];
    
    NMAGeoCoordinates *start = self.speedPoints.firstObject;
    UIImage *startPin = [UIImage imageNamed:@"point_a"];
    startPin = [self imageWithImage:startPin scale:0.66];
    NMAMapMarker *startMarker = [NMAMapMarker
                                 mapMarkerWithGeoCoordinates:[NMAGeoCoordinates geoCoordinatesWithLatitude:start.latitude
                                                                                                 longitude:start.longitude]
                                 image:startPin];
    startMarker.zIndex = 1;
    [self.mapView addMapObject:startMarker];
    [self.mapObjectsArray addObject:startMarker];
    
    NMAGeoCoordinates *end = self.speedPoints.lastObject;
    UIImage *endPin = [UIImage imageNamed:@"point_b"];
    endPin = [self imageWithImage:endPin scale:0.66];
    NMAMapMarker *endMarker = [NMAMapMarker
                               mapMarkerWithGeoCoordinates:[NMAGeoCoordinates geoCoordinatesWithLatitude:end.latitude
                                                                                               longitude:end.longitude]
                               image:endPin];
    endMarker.zIndex = 1;
    [self.mapView addMapObject:endMarker];
    [self.mapObjectsArray addObject:endMarker];
    
    [UIView animateWithDuration:DELAY_IMMEDIATELY_3_SEC animations:^{
        [GearLoadingView hideGearLoadingForView:self.view];
        [self hidePreloader];
    } completion:^(BOOL finished) {
        //
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_1_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.mapView.hidden = NO;
    });
}

- (void)mapView:(NMAMapView *)mapView didSelectObjects:(NSArray *)objects {
    
    if ([self.popTip isVisible]) {
        [self.popTip hide];
    }
    
    for (NMAMapMarker *object in objects) {
        if ([object isKindOfClass:[NMAMapMarker class]]) {
            
            for (int i = 0 ; i < self.mapMarkers.count; i++) {
                
                double latMarker = object.coordinates.latitude;
                double lonMarker = object.coordinates.longitude;
                
                double latForCheck = [[[self.mapMarkers valueForKey:@"Lat"] objectAtIndex:i] doubleValue];
                double lonForCheck = [[[self.mapMarkers valueForKey:@"Lon"] objectAtIndex:i] doubleValue];
                
                if (latMarker == latForCheck && lonMarker == lonForCheck) {
                    
                    NSString *typePoint = [[self.mapMarkers valueForKey:@"Type"] objectAtIndex:i];
                    NSString *icPoint = [[self.mapMarkers valueForKey:@"Icon"] objectAtIndex:i];
                    NSDate *datePoint = [[self.mapMarkers valueForKey:@"Date"] objectAtIndex:i];
                    NSString *datePointStr = [datePoint dateTimePosixFull];
                    
                    //CORNERING NEW
                    if ([Configurator sharedInstance].needEventsReviewButton) {
                        if (i != self.mapMarkers.count-1) {
                            double latForCheckRepeat = [[[self.mapMarkers valueForKey:@"Lat"] objectAtIndex:i+1] doubleValue];
                            double lonForCheckRepeat = [[[self.mapMarkers valueForKey:@"Lon"] objectAtIndex:i+1] doubleValue];
                            NSString *typePointRepeat = [[self.mapMarkers valueForKey:@"Type"] objectAtIndex:i+1];
                            if (latMarker == latForCheckRepeat && lonMarker == lonForCheckRepeat && [typePointRepeat isEqualToString:localizeString(@"tripdetails_corner")]) {
                                typePoint = [[self.mapMarkers valueForKey:@"Type"] objectAtIndex:i+1];
                                icPoint = [[self.mapMarkers valueForKey:@"Icon"] objectAtIndex:i+1];
                                datePoint = [[self.mapMarkers valueForKey:@"Date"] objectAtIndex:i+1];
                                datePointStr = [datePoint dateTimePosixFull];
                            }
                        }
                        
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"];
                        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
                        [dateFormatter setLocale:enUSPOSIXLocale];
                        [dateFormatter setCalendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierISO8601]];
                        NSString *dateString = [dateFormatter stringFromDate:datePoint];
                        
                        self.selectedDateMarker = dateString;
                        self.selectedLatMarker = [NSString stringWithFormat:@"%.15lf", latMarker];
                        self.selectedLonMarker = [NSString stringWithFormat:@"%.15lf", lonMarker];
                        self.selectedEventTypeMarker = typePoint;
                    }
                    
                    if ([Configurator sharedInstance].needAmPmTime || [defaults_object(@"needDateSpecialFormat") boolValue] || [defaults_object(@"needAmPmFormat") boolValue]) {
                        if ([defaults_object(@"needDateSpecialFormat") boolValue] && ![defaults_object(@"needAmPmFormat") boolValue]) {
                            datePointStr = [datePoint dateTimeStringShortMmDd24];
                        } else if (![defaults_object(@"needDateSpecialFormat") boolValue] && [defaults_object(@"needAmPmFormat") boolValue]) {
                            datePointStr = [datePoint dateTimeStringShortDdMmAmPm];
                        } else if (![defaults_object(@"needDateSpecialFormat") boolValue] && ![defaults_object(@"needAmPmFormat") boolValue]) {
                            datePointStr = [datePoint dateTimeStringShortDdMm24];
                        } else {
                            datePointStr = [datePoint dateTimeStringShortMmDdAmPm];
                        }
                    }
                    
                    double speedPoint = [[[self.mapMarkers valueForKey:@"Speed"] objectAtIndex:i] doubleValue];
                    NSString *speedPointStr = [NSString stringWithFormat:@"%.1f", speedPoint];
                    
                    double maxForcePoint = [[[self.mapMarkers valueForKey:@"MaxForce"] objectAtIndex:i] doubleValue];
                    NSString *maxForcePointStr = [NSString stringWithFormat:@"%.1f", maxForcePoint];
                    
                    NSString *finalStr = [NSString stringWithFormat:localizeString(@"%@\n%@\n\nSpeed: %@ km/h\nMax Force: %@ m/s/s"), typePoint, datePointStr, speedPointStr, maxForcePointStr];
                    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                        double milesSpeed = convertKmToMiles(speedPoint);
                        NSString *speedPointStr = [NSString stringWithFormat:@"%.1f", milesSpeed];
                        finalStr = [NSString stringWithFormat:localizeString(@"%@\n%@\n\nSpeed: %@ mi/h\nMax Force: %@ m/s/s"), typePoint, datePointStr, speedPointStr, maxForcePointStr];
                    }
                    
                    NSMutableAttributedString *finalAttributesStr = [[NSMutableAttributedString alloc] initWithString:finalStr];
                    
                    UIFont *mainFont = [Font regular12];
                    NSRange range = [finalStr rangeOfString:finalStr];
                    [finalAttributesStr addAttribute:NSForegroundColorAttributeName value:[Color darkGrayColor] range:range];
                    [finalAttributesStr addAttribute:NSFontAttributeName value:mainFont range:range];
                    
                    UIFont *addFont = [Font bold15];
                    NSRange rangeAdd = [finalStr rangeOfString:typePoint];
                    [finalAttributesStr addAttribute:NSForegroundColorAttributeName value:[Color darkGrayColor43] range:rangeAdd];
                    [finalAttributesStr addAttribute:NSFontAttributeName value:addFont range:rangeAdd];
                    
                    self.popTip.bubbleOffset = 0;
                    
                    NMAGeoCoordinates* coords = object.coordinates;
                    UILabel *hiddenLbl = [[UILabel alloc] initWithFrame:CGRectZero];
                    hiddenLbl.hidden = YES;
                    hiddenLbl.frame = CGRectMake(0, -5, 70, 30);
                    
                    NMAMapOverlay *overlay = [NMAMapOverlay mapOverlayWithSubview:hiddenLbl geoCoordinates:coords];
                    [mapView addMapOverlay:overlay];
                    
                    if ([Configurator sharedInstance].needEventsReviewButton) {
                        if (objects.count >= 3) {
                            NSMutableArray *points = [[NSMutableArray alloc] init];
                            NMAGeoCoordinates *coord = [[NMAGeoCoordinates alloc] initWithLatitude:coords.latitude
                                                                                        longitude:coords.longitude];
                            [points addObject:coord];
                            self.markerPoints = [NSArray arrayWithArray:points];
                            
                            NMAGeoBoundingBox *routeBounds = [NMAGeoBoundingBox geoBoundingBoxContainingGeoCoordinates:self.markerPoints];
                            routeBounds = [NMAGeoBoundingBox geoBoundingBoxWithCenter:routeBounds.center
                                                                                width:routeBounds.width*1.2
                                                                               height:routeBounds.height*1.2];
                            
                            [self.mapView setGeoCenter:routeBounds.center zoomLevel:19 withAnimation:NMAMapAnimationRocket];
                        }
                    }
                    
                    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icPoint]];
                    imageView.frame = CGRectMake(customView.frame.size.width/2 - imageView.frame.size.width/2, 4, imageView.frame.size.width, imageView.frame.size.height);
                    [customView addSubview:imageView];
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.size.height, 150, 150 - imageView.frame.size.height)];
                    label.numberOfLines = 0;
                    label.attributedText = finalAttributesStr;
                    label.textAlignment = NSTextAlignmentCenter;
                    [customView addSubview:label];
                    
                    self.popTip.popoverColor = [Color officialWhiteColor];
                    
                    if ([Configurator sharedInstance].needEventsReviewButton) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_06_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.popTip showCustomView:customView direction:MapPopTipDirectionUp inView:self.mapView.superview fromFrame:overlay.frame];
                        });
                    } else {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_03_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.popTip showCustomView:customView direction:MapPopTipDirectionUp inView:self.mapView.superview fromFrame:overlay.frame];
                        });
                    }
                }
            }
        }
    }
}

- (IBAction)resetMapToGeoCenter:(id)sender {
    NMAGeoBoundingBox *routeBounds = [NMAGeoBoundingBox geoBoundingBoxContainingGeoCoordinates:self.speedPoints];
    routeBounds = [NMAGeoBoundingBox geoBoundingBoxWithCenter:routeBounds.center
                                                        width:routeBounds.width*1.2 //2
                                                       height:routeBounds.height*1.2]; //2
    [self.mapView setBoundingBox:routeBounds withAnimation:NMAMapAnimationLinear];
}


#pragma mark - Trips Navigation

- (IBAction)nextTrip:(id)sender {
    
    [self showPreloader];
    if ([self.popTip isVisible]) {
        [self.popTip hide];
    }
    
    RPTrackProcessed *event = self.sortedOnlyTrips[self.trackTag+1];
    self.trackToken = event.trackToken;
    self.trackTag = self.trackTag+1;
    
    float rating = event.rating100;
    if (rating == 0)
        rating = event.rating*20;
    
    self.trackPointsSummary = [NSString stringWithFormat:@"%.0f", rating];
    self.trackDistanceSummary = [NSString stringWithFormat:@"%.0f", event.distance];
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        float miles = convertKmToMiles(event.distance);
        self.trackDistanceSummary = [NSString stringWithFormat:@"%.1f", miles];
    }
    
    NSDate* dateStart = event.startDate;
    NSDate* dateEnd = event.endDate;
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
    
    defaults_set_object(@"selectedTrackToken", self.trackToken);
    
    [self cleanMap];
    [self loadMap];
    [self checkTripsArrayNumbers];
}

- (IBAction)lastTrip:(id)sender {
    
    [self showPreloader];
    if ([self.popTip isVisible]) {
        [self.popTip hide];
    }
    
    RPTrackProcessed *event = self.sortedOnlyTrips[self.trackTag-1];
    self.trackToken = event.trackToken;
    self.trackTag = self.trackTag-1;
    
    float rating = event.rating100;
    if (rating == 0)
        rating = event.rating*20;
    
    self.trackPointsSummary = [NSString stringWithFormat:@"%.0f", rating];
    self.trackDistanceSummary = [NSString stringWithFormat:@"%.0f", event.distance];
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        float miles = convertKmToMiles(event.distance);
        self.trackDistanceSummary = [NSString stringWithFormat:@"%.1f", miles];
    }
    
    NSDate* dateStart = event.startDate;
    NSDate* dateEnd = event.endDate;
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
    
    defaults_set_object(@"selectedTrackToken", self.trackToken);
    
    [self cleanMap];
    [self loadMap];
    [self checkTripsArrayNumbers];
}

- (void)cleanMap {
    if ([self.mapObjectsArray count] > 0) {
        [self.mapView removeMapObjects:self.mapObjectsArray];
        [self.mapObjectsArray removeAllObjects];
    }
}


#pragma mark - Here Maps Gestures

- (void)mapView:(NMAMapView *)mapView didReceiveTapAtLocation:(CGPoint)location {
    if ([self.popTip isVisible]) {
        [self.popTip hide];
    }
    [mapView.defaultGestureHandler mapView:mapView didReceiveTapAtLocation:location];
}

- (void)mapView:(nonnull NMAMapView *)mapView didReceiveDoubleTapAtLocation:(CGPoint)location {
    if ([self.popTip isVisible]) {
        [self.popTip hide];
    }
    [mapView.defaultGestureHandler mapView:mapView didReceiveDoubleTapAtLocation:location];
}

- (void)mapView:(nonnull NMAMapView *)mapView didReceiveTwoFingerTapAtLocation:(CGPoint)location {
    if ([self.popTip isVisible]) {
        [self.popTip hide];
    }
    [mapView.defaultGestureHandler mapView:mapView didReceiveTwoFingerTapAtLocation:location];
}

- (void)mapView:(nonnull NMAMapView *)mapView didReceivePan:(CGPoint)translation atLocation:(CGPoint)location {
    if ([self.popTip isVisible]) {
        [self.popTip hide];
    }
    [mapView.defaultGestureHandler mapView:mapView didReceivePan:translation atLocation:location];
}

- (void)mapView:(nonnull NMAMapView *)mapView didReceiveTwoFingerPan:(CGPoint)translation atLocation:(CGPoint)location {
    if ([self.popTip isVisible]) {
        [self.popTip hide];
    }
    [mapView.defaultGestureHandler mapView:mapView didReceiveTwoFingerPan:translation atLocation:location];
}

- (void)mapView:(nonnull NMAMapView *)mapView didReceiveRotation:(float)rotation atLocation:(CGPoint)location {
    if ([self.popTip isVisible]) {
        [self.popTip hide];
    }
    [mapView.defaultGestureHandler mapView:mapView didReceiveRotation:rotation atLocation:location];
}

- (void)mapView:(nonnull NMAMapView *)mapView didReceivePinch:(float)pinch atLocation:(CGPoint)location {
    if ([self.popTip isVisible]) {
        [self.popTip hide];
    }
    [mapView.defaultGestureHandler mapView:mapView didReceivePinch:pinch atLocation:location];
}

- (void)mapView:(nonnull NMAMapView *)mapView didReceiveLongPressAtLocation:(CGPoint)location {
    if ([self.popTip isVisible]) {
        [self.popTip hide];
    }
    [mapView.defaultGestureHandler mapView:mapView didReceiveLongPressAtLocation:location];
}


#pragma mark - Claims PopUp

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


#pragma mark - BottomSheet

- (void)animationFinished {
    //NSLog(@"TripSheet Animation Finished");
}

- (double)bounceHeight {
    return 500;
}

- (double)expandedHeight {
    return 460;
}

- (double)collapsedHeight {
    return 90;
}


#pragma mark - Track Browsing

- (void)startEventsTrackBrowsing {
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            NSLog(@"Success track events browsing");
        } else {
            NSLog(@"Error track events browsing");
        }
    }] trackEventsStartBrowse:self.trackToken];
}

- (void)wrongEventBrowsingNoEvent {
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        
        if (!error && [response isSuccesful]) {
            if ([self.popTip isVisible]) {
                [self.popTip hide];
            }
            
            [self reloadMapMarkersNoEvent];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:localizeString(@"Thank you, we’ve received your feedback!")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:localizeString(@"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                //
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            if ([self.popTip isVisible]) {
                [self.popTip hide];
            }
        }
    }] reportWrongEventNoEvent:self.trackToken lat:self.selectedLatMarker lon:self.selectedLonMarker eventType:self.selectedEventTypeMarker date:self.selectedDateMarker];
}

- (void)wrongEventBrowsingNewEvent {
    if ([self.selectedNewEventTypeMarker isEqualToString:@"Phone Usage"])
        self.selectedNewEventTypeMarker = @"PhoneUsage";
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        
        if (!error && [response isSuccesful]) {
            if ([self.popTip isVisible]) {
                [self.popTip hide];
            }
            
            [self reloadMapMarkersNewEvent];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:localizeString(@"Thank you, we’ve received your feedback!")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:localizeString(@"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                //[self reloadMapMarkersNewEvent];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            if ([self.popTip isVisible]) {
                [self.popTip hide];
            }
        }
    }] reportWrongEventNewEvent:self.trackToken lat:self.selectedLatMarker lon:self.selectedLonMarker eventType:self.selectedEventTypeMarker newEventType:self.selectedNewEventTypeMarker date:self.selectedDateMarker];
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
            NSString *iconName = @"cl_red_acc_big";
            UIImage *cornerIcon = [UIImage imageNamed:@"cl_red_acc"];
            if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX || IS_IPHONE_8P) {
                cornerIcon = [UIImage imageNamed:@"cl_red_acc_big"];
            }
            
            if ([self.selectedEventTypeMarker isEqualToString:@"Braking"]) {
                typeName = @"Braking";
                iconName = @"cl_red_brake_big";
                cornerIcon = [UIImage imageNamed:@"cl_red_brake"];
                if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX || IS_IPHONE_8P) {
                    cornerIcon = [UIImage imageNamed:@"cl_red_brake_big"];
                }
            } else if ([self.selectedEventTypeMarker isEqualToString:@"Cornering"]) {
                typeName = @"Cornering";
                iconName = @"cl_red_turn_big";
                cornerIcon = [UIImage imageNamed:@"cl_red_turn"];
                if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX || IS_IPHONE_8P) {
                    cornerIcon = [UIImage imageNamed:@"cl_red_turn_big"];
                }
            } else if ([self.selectedEventTypeMarker isEqualToString:@"Phone Usage"]) {
                typeName = @"Phone Usage";
                iconName = @"cl_red_phone_big";
                cornerIcon = [UIImage imageNamed:@"cl_red_phone"];
                if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX || IS_IPHONE_8P) {
                    cornerIcon = [UIImage imageNamed:@"cl_red_phone_big"];
                }
            }
            
            NMAMapMarker *cornerMarker =
            [NMAMapMarker mapMarkerWithGeoCoordinates:[NMAGeoCoordinates geoCoordinatesWithLatitude:latForCheck
                                                                                          longitude:lonForCheck]
                                                image:cornerIcon];
            cornerMarker.zIndex = 5;
            [self.mapView addMapObject:cornerMarker];
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
            NSString *iconName = @"cl_orange_acc_big";
            UIImage *cornerIcon = [UIImage imageNamed:@"cl_orange_acc"];
            if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX || IS_IPHONE_8P) {
                cornerIcon = [UIImage imageNamed:@"cl_orange_acc_big"];
            }
            
            if ([self.selectedNewEventTypeMarker isEqualToString:@"Braking"]) {
                typeName = @"Braking";
                iconName = @"cl_orange_brake_big";
                cornerIcon = [UIImage imageNamed:@"cl_orange_brake"];
                if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX || IS_IPHONE_8P) {
                    cornerIcon = [UIImage imageNamed:@"cl_orange_brake_big"];
                }
            } else if ([self.selectedNewEventTypeMarker isEqualToString:@"Cornering"]) {
                typeName = @"Cornering";
                iconName = @"cl_orange_turn_big";
                cornerIcon = [UIImage imageNamed:@"cl_orange_turn"];
                if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX || IS_IPHONE_8P) {
                    cornerIcon = [UIImage imageNamed:@"cl_orange_turn_big"];
                }
            } else if ([self.selectedNewEventTypeMarker isEqualToString:@"PhoneUsage"]) {
                typeName = @"Phone Usage";
                iconName = @"cl_orange_phone_big";
                cornerIcon = [UIImage imageNamed:@"cl_orange_phone"];
                if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX || IS_IPHONE_8P) {
                    cornerIcon = [UIImage imageNamed:@"cl_orange_phone_big"];
                }
            }
            
            NMAMapMarker *cornerMarker =
            [NMAMapMarker mapMarkerWithGeoCoordinates:[NMAGeoCoordinates geoCoordinatesWithLatitude:latForCheck
                                                                                          longitude:lonForCheck]
                                                image:cornerIcon];
            cornerMarker.zIndex = 5;
            [self.mapView addMapObject:cornerMarker];
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
     [self dismissViewControllerAnimated:true completion:nil];
}

- (void)swipeHandlerRight:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)moved:(id)sender {
    [[self.navigationController.view.gestureRecognizers objectAtIndex:0] removeTarget:self action:@selector(moved:)];
}

- (void)findIndexOfCurrentTrip {
    for (int i = 0; i < self.sortedOnlyTrips.count; i++) {
        NSString *simpleToken = [[self.sortedOnlyTrips valueForKey:@"trackToken"] objectAtIndex:i];
        if ([simpleToken isEqual:self.trackToken]) {
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
    
    if ((self.trackTag == 0 || self.trackTag <= 0) && self.trackTag != self.sortedOnlyTrips.count-1) {
        self.tripBackBtn.enabled = NO;
        self.tripBackBtn.alpha = 0.4;
        
        if (self.trackTag == 0 && self.sortedOnlyTrips.count == 2) {
            self.tripForwardBtn.enabled = YES;
            self.tripForwardBtn.alpha = 0.7;
        }
    } else if (self.trackTag == self.sortedOnlyTrips.count-1 || self.trackTag >= self.sortedOnlyTrips.count-1) {
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


#pragma mark - DriverSignatureOnTrip

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
    NSString *tToken = defaults_object(@"selectedTrackToken");
    
    [[RPEntry instance].api changeTrackOrigin:self.selectedDriverSignatureRole forTrackToken:tToken completion:^(id response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [self->signatureOnTripPopup hideDriverSignaturePopup];
                defaults_set_object(@"needUpdateViewForFeedScreen", @(YES));
                defaults_set_object(@"selectedTrackSignatureOriginalRole", self.selectedDriverSignatureRole);
                
                if ([self.selectedDriverSignatureRole isEqual:@"OriginalDriver"]) {
                    [self.bottomSheetPresenter updateTrackOriginButton:@"OriginalDriver"];
                } else if ([self.selectedDriverSignatureRole isEqual:@"Passenger"]) {
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
                }
            }
        });
    }];
}

- (void)cancelSignatureButtonAction:(DriverSignaturePopup *)popupView button:(UIButton *)button {
    [signatureOnTripPopup hideDriverSignaturePopup];
}


#pragma mark - Delete Trip

- (void)deleteThisTrip {
    [self showPreloader];
    
    RPTag *tag = [[RPTag alloc] init];
    tag.tag = @"DEL";
    tag.source = localizeString(@"TelematicsApp");

    NSString *tToken = defaults_object(@"selectedTrackToken");
    NSString *tmpTokenForDeleting = defaults_object(@"selectedTrackToken");
    NSLog(@"tToken %@", tToken);
    NSLog(@"tmpTokenForDeleting %@", tmpTokenForDeleting);
    
    [[RPEntry instance].api addTrackTags:[[NSArray alloc] initWithObjects:tag, nil] to:tToken completion:^(id response, NSArray *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (self.sortedOnlyTrips.count == 1) {
                    [self backBtnClick:self];
                    [self hidePreloader];
                    return;
                }
                
                if ((self.trackTag == 0 || self.trackTag <= 0) && self.trackTag != self.sortedOnlyTrips.count-1) {
                    if (self.trackTag == 0 && self.sortedOnlyTrips.count == 2) {
                        [self nextTrip:self];
                        //self.trackTag = self.trackTag+1;
                    } else {
                        [self backBtnClick:self];
                    }
                    
                } else if (self.trackTag == self.sortedOnlyTrips.count-1 || self.trackTag >= self.sortedOnlyTrips.count-1) {
                    if (self.trackTag == 1 && self.sortedOnlyTrips.count == 2) {
                        [self lastTrip:self];
                        self.trackTag = self.trackTag+1;
                    } else {
                        [self backBtnClick:self];
                    }
                    
                } else {
                    [self nextTrip:self];
                    self.trackTag = self.trackTag-1;
                }
                
                for (int i = 0; i < self.sortedOnlyTrips.count; i++) {
                    NSString *simpleToken = [[self.sortedOnlyTrips valueForKey:@"trackToken"] objectAtIndex:i];
                    if ([simpleToken isEqual:tmpTokenForDeleting]) {
                        [self.sortedOnlyTrips removeObjectAtIndex:i];
                        //self.trackTag = self.trackTag-1;
                    }
                }
            } else {
                [self hidePreloader];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                               message:localizeString(@"An error occurred while trip deleting. Try again later.")
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:localizeString(@"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self backBtnClick:self];
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
}

@end
