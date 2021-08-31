//
//  Color.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.05.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import Foundation;

#define UIColorFromHex(hexValue) \
[UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 \
green:((float)((hexValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((hexValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#define UIColorFromRGBWithValue(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGBAlpha(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

#define UIColorFromRGB(R, G, B) \
[UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]


@class UIColor;

@interface Color: NSObject

+ (UIColor*)officialMainAppColor;
+ (UIColor*)officialMainAppColorAlpha;
+ (UIColor*)officialMainAppColorAlpha8;
+ (UIColor*)officialGreenColor;
+ (UIColor*)officialOrangeColor;
+ (UIColor*)officialOrangeColorAlpha;
+ (UIColor*)officialRedColor;
+ (UIColor*)officialDarkRedColor;
+ (UIColor*)officialYellowColor;
+ (UIColor*)officialWhiteColor;
+ (UIColor*)lightSeparatorColor;
+ (UIColor*)lightGrayColor;
+ (UIColor*)separatorLightGrayColor;
+ (UIColor*)grayColor;
+ (UIColor*)softGrayColor;
+ (UIColor*)buttonGrayTextColor;
+ (UIColor*)darkGrayColor83;
+ (UIColor*)darkGrayColor43;
+ (UIColor*)darkGrayColor;
+ (UIColor*)tabBarLightColor;
+ (UIColor*)tabBarDarkColor;
+ (UIColor*)curveRedColor;
+ (UIColor*)curveRedColorAlpha;
+ (UIColor*)curveRedBordoColor;
+ (UIColor*)curveRedBordoColorAlpha;
+ (UIColor*)curveOrangeFantaColor;
+ (UIColor*)curveOrangeFantaColorAlpha;
+ (UIColor*)curveOrangeColor;
+ (UIColor*)curveOrangeColorAlpha;
+ (UIColor*)curveYellowColor;
+ (UIColor*)curveYellowColorAlpha;
+ (UIColor*)curveGreenColor;
+ (UIColor*)blackColor;
+ (UIColor*)whiteSpinnerColor;

@end
