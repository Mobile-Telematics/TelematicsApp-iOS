//
//  Helpers.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 19.01.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#ifndef MyForm_Helpers_h
#define MyForm_Helpers_h
#import <CommonCrypto/CommonDigest.h>
@import UIKit;

#define APP_VERSION [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4 (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_8 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_8P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_11 (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)
#define IS_IPHONE_11_PROMAX (IS_IPHONE && SCREEN_MAX_LENGTH == 896.0)
#define IS_IPHONE_13_PRO (IS_IPHONE && SCREEN_MAX_LENGTH == 844.0)
#define IS_IPHONE_13_PROMAX (IS_IPHONE && SCREEN_MAX_LENGTH == 926.0)

#define IS_OS_12_OR_OLD ([[[UIDevice currentDevice] systemVersion] floatValue] < 13.0)
#define IS_OS_13_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0)

#define NULL_TO_NIL(obj) ({ __typeof__ (obj) __obj = (obj); __obj == [NSNull null] ? @0 : obj; })
#define NSStringFromBOOL(aBOOL)    ((aBOOL) ? @"YES" : @"NO")

#define AVATAR_RADIUS 50
#define AVATAR_ORIGIN_Y 56

#define AVATAR_RADIUS2 150
#define AVATAR_ORIGIN_Y2 156

#define DefaultAnimationDuration 0.3
#define DefaultInAnimation 1
#define DefaultOutAnimation 2

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

static inline BOOL isIpad() {
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

static inline NSString* createUUID() {
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString* uuidStr = (__bridge NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
    return uuidStr;
}

static inline BOOL isWidescreenEnabled() {
    return (BOOL)(fabs((double)[UIScreen mainScreen].bounds.size.height - (double)568) < DBL_EPSILON);
}

static inline NSString* nonNilString(NSString* str) {
    return str ? str : @"";
}

static inline BOOL NSStringIsInviteValid(NSString* checkString) {
    NSString *inviteRegEx =
    @"^(?=.{4,})([@#$%^&=a-zA-Z0-9_-]+)$";
    NSPredicate *inviteTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", inviteRegEx];
    return [inviteTest evaluateWithObject:checkString];
}

static inline BOOL NSStringIsPsswordValidSymbols(NSString* checkString) {
    NSString *passRegEx =
    @"([@#$%^&=a-zA-Z0-9_-]+)$";
    NSPredicate *passTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passRegEx];
    return [passTest evaluateWithObject:checkString];
}

static inline BOOL NSStringIsPsswordValidSixLength(NSString* checkString) {
    NSString *passRegEx =
    @"^(?=.{6,})([@#$%^&=a-zA-Z0-9_-]+)$";
    NSPredicate *passTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passRegEx];
    return [passTest evaluateWithObject:checkString];
}

static inline BOOL NSStringIsValidEmail(NSString* checkString) {
    NSString *emailRegEx =
    @"(?:[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-zA-Z0-9](?:[a-"
    @"zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-zA-Z0-9-]*[a-zA-Z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [emailTest evaluateWithObject:checkString];
}

static inline BOOL NSStringIsValidPhone(NSString* checkString) {
    NSString *phoneRegEx = @"([0-9]){8,14}";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegEx];
    return [phoneTest evaluateWithObject:checkString];
}

static inline NSString* md5FromString(NSString* str) {
    CC_MD5_CTX md5;
	CC_MD5_Init (&md5);
	CC_MD5_Update (&md5, [str UTF8String], (uint)[str length]);
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5_Final (digest, &md5);
	NSString *s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   digest[0],  digest[1],
				   digest[2],  digest[3],
				   digest[4],  digest[5],
				   digest[6],  digest[7],
				   digest[8],  digest[9],
				   digest[10], digest[11],
				   digest[12], digest[13],
				   digest[14], digest[15]];
    
	return s;
}

static inline CGFloat colorComponentFrom(NSString *string, NSUInteger start, NSUInteger length) {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

static inline UIColor *colorFromHexString(NSString *hexString) {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = colorComponentFrom(colorString, 0, 1);
            green = colorComponentFrom(colorString, 1, 1);
            blue  = colorComponentFrom(colorString, 2, 1);
            break;
        case 4: // #ARGB
            alpha = colorComponentFrom(colorString, 0, 1);
            red   = colorComponentFrom(colorString, 1, 1);
            green = colorComponentFrom(colorString, 2, 1);
            blue  = colorComponentFrom(colorString, 3, 1);
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = colorComponentFrom(colorString, 0, 2);
            green = colorComponentFrom(colorString, 2, 2);
            blue  = colorComponentFrom(colorString, 4, 2);
            break;
        case 8: // #AARRGGBB
            alpha = colorComponentFrom(colorString, 0, 2);
            red   = colorComponentFrom(colorString, 2, 2);
            green = colorComponentFrom(colorString, 4, 2);
            blue  = colorComponentFrom(colorString, 6, 2);
            break;
        default:
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid. It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

static inline float convertKmToMiles(float kms) {
    float miles = kms * 0.621371192;
    return miles;
}


#define RGB1(color) [UIColor colorWithRed:((float)color)/255.0 green:((float)color)/255.0 blue:((float)color)/255.0 alpha:1.0]
#define RGB1A(color,a) [UIColor colorWithRed:((float)color)/255.0 green:((float)color)/255.0 blue:((float)color)/255.0 alpha:(float)a]
#define RGB3(r,g,b) [UIColor colorWithRed:((float)r)/255.0 green:((float)g)/255.0 blue:((float)b)/255.0 alpha:1.0]
#define RGB3A(r,g,b,a) [UIColor colorWithRed:((float)r)/255.0 green:((float)g)/255.0 blue:((float)b)/255.0 alpha:(float)a]

#define MIN_VERTICAL_SCROLLING_VALUE_FOR_HIDING 50
#define HOMES_POPUP_ANIMATION_SPEED 0.2

#endif
