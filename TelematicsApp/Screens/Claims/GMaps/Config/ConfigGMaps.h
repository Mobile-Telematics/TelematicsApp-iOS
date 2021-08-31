//
//  ConfigGMaps.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define REVERSE_GEOCODE_ADDRESS_NOTIFICATION @"REVERSE_GEOCODE_ADDRESS_NOTIFICATION"
#define GEOCODE_ADDRESS_NOTIFICATION @"GEOCODE_ADDRESS_NOTIFICATION"
#define PLACEHOLDER_COLOR ([UIColor whiteColor])

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)
#define IS_HEIGHT_GTE_780 ([[UIScreen mainScreen ] bounds].size.height >= 780.0f)

#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define NAV_BAR_HEIGHT 64.0f

#define ApplicationThemePatternImage    [UIImage imageNamed:@"bg_pattern_image.png"]
#define ApplicationThemeColor           [UIColor colorWithRed:242/255.0f green:0/255.0f blue:48/255.0f alpha:1.0f]
#define TextFieldInputColor             [UIColor colorWithRed:1/255.0f green:86/255.0f blue:166/255.0f alpha:1.0f]



typedef enum
{
    RegistrationInvalidCountry,
    RegistrationInvalidPhone,
    RegistrationInvalidEmail,
    RegistrationInvalidPassword,
    RegistrationInvalidConfirmPassword,
    RegistrationUnknownError,
    RegistrationInvalidTerms
}RegistrationErrorDomain;


#define NETWORK_REACHABILITY_NOTIFY @"NetworkReachableNotify"
#define NETWORK_UNREACHABILITY_NOTIFY @"NetworkUnReachableNotify"

#define RUPEE_SYMBOL @"\u20B9"

#define REPLY_KEY @"message"



@interface ConfigGMaps : NSObject

extern double CURRENT_LATITUDE;
extern double CURRENT_LONGITUDE;
extern NSString *CURRENT_ADDRESS;
extern CLLocationManager *locationManager;
extern  CLLocation  *currentLocation;

@end
