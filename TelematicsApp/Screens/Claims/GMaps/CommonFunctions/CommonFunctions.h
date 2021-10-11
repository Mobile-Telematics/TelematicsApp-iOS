//
//  CommonFunctions.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 13.06.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <GoogleMaps/GoogleMaps.h>
#import "ifaddrs.h"
#import "net/if.h"

@interface CommonFunctions : NSObject


/**
   Used to get user default key-value pair
 
   @param key : key
   @return : value
*/
+ (id)getUserDefaultValueForKey:(NSString *)key;

/**
   Used to set user default key-value pair
 
   @param key   : key
   @param value : value
*/
+ (void)setUserDefaultForKey:(NSString *)key
                       value:(id)value;

/**
   Selector used to get array of model properties
 
   @param modelClass : model whose properties to be returned in array
 
   @return : returns array of properties
*/
+ (NSArray *)getModelPropertiesToArray:(Class)modelClass;

/**
   Used to set left bar button item on navigation bar
 
   @param image      image to set
   @param selector   selector method to be called on click
   @param target     target object
   @param controller Controller on which button is to be shown
*/
+ (void) setLeftBarButtonItemWithimage:(UIImage *)image andSelector:(SEL)selector withTarget: (id)target onController:(UIViewController *)controller;

/**
   Used to set right bar button item on navigation bar
 
   @param title      title to set
   @param backImage      image to set
   @param selector   selector method to be called on click
   @param target     target object
   @param controller Controller on which button is to be shown
*/
+ (void)setRightBarButtonItemWithTitle:(NSString *)title andBackGroundImage:(UIImage *)backImage andSelector:(SEL)selector withTarget: (id)target onController:(UIViewController *)controller;

/**
   Used to identify whether network available or not
 
   @return YES if network available / NO if network not available
*/
+(BOOL)networkConnectionAvailability;


/**
 Used to clear all stored values from device
 */
+ (void)clearUserDefaultValues;


/**
 Used to get error information from NSError

 @param error error from Network
 @return error dictionary
 */
+ (NSDictionary *)getErrorDict :(NSError *)error;


/**
 Used to show Progress Indicatore
 */
+(void)showOnlyHUD;


/**
 Used to show Progress Indicatore with text

 @param msg msg string
 */
+(void)showHUDwithText:(NSString *)msg;

/**
 Used to hide Progress Indicatore
 */
+(void)hideHUD;


/**
 To open share sheet

 @param array objects to share
 @param vc controller to open sheet upon
 */
+ (void)openSharingSheetActionToShare:(NSArray *)array
                     onViewController:(UIViewController *)vc;

/**
 Used to compare 2 images

 @param image1 image1
 @param image2 image2
 @return Returns YES if images are same otherwise NO
 */
+ (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2;

/**
 Used to get the height of label according to text

 @param bodyText text
 @param width width of label
 @return height of label
 */
+ (CGFloat)heightForText:(NSString *)bodyText width:(CGFloat)width;

/**
 Used to check if Wifi is enabled on device

 @return returns YES if wifi is on otherwise NO
 */
+ (BOOL) isWiFiEnabled ;

/**
 Used to retry connection failure

 @param apiCallingBlock calling block for retry api call
 */
+ (void)connectionErrorMessageOnClass: (void (^)())apiCallingBlock;

@end
