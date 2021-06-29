//
//  Configurator.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 03.03.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Helpers.h"
#import "VisibleBuildConfig.h"

#define TelematicsApp_CONFIG @"TelematicsApp_Configuration"

@interface Configurator : VisibleBuildConfig

@property(nonatomic, strong) NSString       *userServiceRootURL;
@property(nonatomic, strong) NSString       *userServiceRootURLv2;
@property(nonatomic, strong) NSString       *statisticServiceURL;
@property(nonatomic, strong) NSString       *leaderboardServiceURL;
@property(nonatomic, strong) NSString       *carServiceURL;
@property(nonatomic, strong) NSString       *claimsServiceURL;
@property(nonatomic, strong) NSString       *instanceId;
@property(nonatomic, strong) NSString       *instanceKey;

@property(nonatomic, strong) NSString       *mapsAppIdKey;
@property(nonatomic, strong) NSString       *mapsAppCode;
@property(nonatomic, strong) NSString       *mapsLicenseKey;
@property(nonatomic, strong) NSString       *mapsRestApiKey;
@property(nonatomic, strong) NSString       *googleApiKey;

@property(nonatomic, strong) NSString       *linkPrivacyPolicy;
@property(nonatomic, strong) NSString       *linkTermsOfUse;
@property(nonatomic, strong) NSString       *linkHowItWorks;
@property(nonatomic, strong) NSString       *telematicsSettingsOS12;
@property(nonatomic, strong) NSString       *telematicsSettingsOS13;
@property(nonatomic, strong) NSString       *linkSupportEmail;

@property(nonatomic, strong) NSString       *mainBackgroundImg;
@property(nonatomic, strong) NSString       *additionalBackgroundImg;

@property(nonatomic, strong) NSString       *mainLogoColor;
@property(nonatomic, strong) NSString       *mainLogoClear;

@property(nonatomic, assign) BOOL           sdkEnableHF;
@property(nonatomic, strong) NSString       *appStoreAppId;

@property(nonatomic, strong) NSNumber       *mainTabBarNumber;
@property(nonatomic, strong) NSNumber       *feedTabBarNumber;
@property(nonatomic, strong) NSNumber       *dashboardTabBarNumber;
@property(nonatomic, strong) NSNumber       *profileTabBarNumber;

@property(nonatomic, strong) NSNumber       *needDistanceForScoringKm;

@property(nonatomic, assign) BOOL           showTrackSignatureCustomButton;
@property(nonatomic, assign) BOOL           showTrackTagCustomButton;
@property(nonatomic, assign) BOOL           needTripsDeleting;
@property(nonatomic, assign) BOOL           needDistanceInMiles;
@property(nonatomic, assign) BOOL           needAmPmTime;
@property(nonatomic, assign) BOOL           needEventsReviewButton;

+ (void)setMainAppConfigurationFromPlist;

@end
