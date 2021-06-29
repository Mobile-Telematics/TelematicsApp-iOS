//
//  CommonFunctions.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 13.06.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "CommonFunctions.h"
#import <objc/runtime.h>

@implementation CommonFunctions


#pragma mark - NSUserDefault methods

+ (void)setUserDefaultForKey:(NSString *)key value:(id)value {
    if (key != nil && value != nil) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:key];
        [userDefaults setObject:value forKey:key];
        [userDefaults synchronize];
    }
}

+ (id)getUserDefaultValueForKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:key]) {
        return [userDefaults objectForKey:key];
    }
    return nil;
}


#pragma mark - Navigation bar methods

+ (void)setLeftBarButtonItemWithimage:(UIImage *)image andSelector:(SEL)selector withTarget: (id)target onController:(UIViewController *)controller {
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    leftBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -7, 0, 0);
    [leftBtn setImage:image forState:UIControlStateNormal];
    [leftBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    leftBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *leftBtnItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    controller.navigationItem.leftBarButtonItem = leftBtnItem;
}

+ (void)setRightBarButtonItemWithTitle:(NSString *)title andBackGroundImage:(UIImage *)backImage andSelector:(SEL)selector withTarget:(id)target onController:(UIViewController *)controller {
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 25)];
    [rightBtn setTitle:title forState:UIControlStateNormal];
    [rightBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    if (backImage != nil) {
        [rightBtn setImage:backImage forState:UIControlStateNormal];
        [rightBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:10.f]];
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

        rightBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        
    } else {
        
        rightBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -7);
        
        rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
        [rightBtn setTitleColor:[UIColor colorWithRed:28.f/255.f green:181.f/255.f blue:234.f/255.f alpha:1.f] forState:UIControlStateNormal];
    }
    
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    controller.navigationItem.rightBarButtonItem = rightBtnItem;
}

+ (void)openSharingSheetActionToShare:(NSArray *)array
                     onViewController:(UIViewController *)vc
{
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
    
    NSArray *excludeActivities = @[
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeOpenInIBooks,
                                   ];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [vc presentViewController:activityVC animated:YES completion:nil];
}

+ (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2 {
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    return [data1 isEqual:data2];
}


#pragma mark - getting dynamic height of a string

+ (CGFloat)heightForText:(NSString *)bodyText width:(CGFloat)width {
    if (bodyText.length <= 0) {
        return 0;
    }
    
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:15.0f];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    
    [paragraphStyle setLineSpacing:1];
    paragraphStyle.lineHeightMultiple = 1.0f;
    
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentNatural;
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          cellFont, NSFontAttributeName,
                                          paragraphStyle,NSParagraphStyleAttributeName,
                                          nil];
    
    CGSize expectedLabelSize = [bodyText boundingRectWithSize:CGSizeMake(width, FLT_MAX)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:attributesDictionary
                                                      context:nil].size;
    NSLog(@"height%@",NSStringFromCGSize(expectedLabelSize));
    return expectedLabelSize.height;
}


+ (BOOL)isWiFiEnabled {
    
    NSCountedSet * cset = [NSCountedSet new];
    struct ifaddrs *interfaces;
    if( ! getifaddrs(&interfaces) ) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
}

@end
