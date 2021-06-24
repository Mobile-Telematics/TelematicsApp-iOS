//
//  LoginAuthCore.h
//  LoginAuth
//
//  Created by DATA MOTION PTE. LTD.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

// Object callbacks types
typedef void (^CompleteCreateDeviceToken)(NSString* deviceToken, NSString* jwToken, NSString* refreshToken);
typedef void (^CompleteRefreshJWToken)(NSString* jwToken, NSString* refreshToken);
typedef void (^CompleteNewJWTokenByDeviceToken)(NSString* jwToken, NSString* refreshToken);


// Interface [LoginAuthCore sharedManager]
@interface LoginAuthCore : NSObject

@property (copy, nonatomic) CompleteCreateDeviceToken           successCompleteBlock;
@property (copy, nonatomic) CompleteRefreshJWToken              refreshCompleteBlock;
@property (copy, nonatomic) CompleteNewJWTokenByDeviceToken     byDeviceTokenCompleteBlock;



//
// Create new user & get deviceToken, jwToken, refreshToken
// instanceId & instanceKey required
//
- (void)createDeviceTokenForUserWithInstanceId:(NSString *)instanceId
                                   instanceKey:(NSString *)instanceKey
                                        result:(void (^)(NSString* deviceToken, NSString* jwToken, NSString* refreshToken))completion;



//
// Refresh jwToken for user with old's jwToken & refreshToken, previously obtained when /createDeviceTokenForUserWith/
//
- (void)refreshJWTokenForUserWith:(NSString *)jwToken
                     refreshToken:(NSString *)refreshToken
                           result:(void (^)(NSString* newJWToken, NSString* newRefreshToken))completion;



//
// Get new jwToken for user by deviceToken, previously obtained when /createDeviceTokenForUserWith/
// deviceToken, instanceId & instanceKey required
//
- (void)getJWTokenForUserWithDeviceToken:(NSString *)deviceToken
                              instanceId:(NSString *)instanceId
                             instanceKey:(NSString *)instanceKey
                                  result:(void (^)(NSString* jwToken, NSString* refreshToken))completion;


//+ (id)sharedManager;
+ (LoginAuthCore *)sharedManager;

@end
