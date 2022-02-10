//
//  LoginAuthCore.h
//  LoginAuth
//
//  Created by DATA MOTION PTE. LTD.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

// Object callbacks types
typedef void (^CompleteCreateDeviceToken)(NSString *deviceToken, NSString *jwToken, NSString *refreshToken);
typedef void (^CompleteRefreshJWToken)(NSString* jwToken, NSString* refreshToken);
typedef void (^CompleteNewJWTokenByDeviceToken)(NSString* jwToken, NSString* refreshToken);

typedef void (^CompleteGetUserProfile)(NSString* email, NSString* phone, NSString* firstName, NSString* lastName, NSString* address, NSString* birthday, NSString* gender, NSString* maritalStatus, NSNumber* childrenCount, NSString* clientId);
typedef void (^CompleteUpdateUserProfile)(NSString *success);


@interface LoginAuthCore : NSObject

@property (copy, nonatomic) CompleteCreateDeviceToken           successCreateCompletionBlock;
@property (copy, nonatomic) CompleteRefreshJWToken              successRefreshCompletionBlock;
@property (copy, nonatomic) CompleteNewJWTokenByDeviceToken     successGetNewJwtByDeviceTokenCompletionBlock;
@property (copy, nonatomic) CompleteGetUserProfile              userProfileGetCompletionBlock;
@property (copy, nonatomic) CompleteUpdateUserProfile           userProfileUpdateCompletionBlock;


// BASIC CONCEPTS
//
//
// Create new user & get deviceToken, jwToken, refreshToken
// instanceId & instanceKey required
//
- (void)createDeviceTokenForUserWithInstanceId:(NSString *)instanceId
                                   instanceKey:(NSString *)instanceKey
                                        result:(void (^)(NSString* deviceToken,
                                                         NSString* jwToken,
                                                         NSString* refreshToken))completion;



//
// Refresh jwToken for user with old's jwToken & refreshToken, previously obtained when /createDeviceTokenForUserWith/
//
- (void)refreshJWTokenForUserWith:(NSString *)jwToken
                     refreshToken:(NSString *)refreshToken
                           result:(void (^)(NSString* newJWToken,
                                            NSString* newRefreshToken))completion;



//
// Get new jwToken for user by deviceToken, previously obtained when /createDeviceTokenForUserWith/
// deviceToken, instanceId & instanceKey required
//
- (void)getJWTokenForUserWithDeviceToken:(NSString *)deviceToken
                              instanceId:(NSString *)instanceId
                             instanceKey:(NSString *)instanceKey
                                  result:(void (^)(NSString* jwToken,
                                                   NSString* refreshToken))completion;



//
// ADDITIONAL FOR EXPERIENCE USING
//
//
// Create new user with parameters & get deviceToken, jwToken, refreshToken
// instanceId & instanceKey required
//
- (void)createDeviceTokenForUserWithParametersAndInstanceId:(NSString *)instanceId
                                                instanceKey:(NSString *)instanceKey
                                                      email:(NSString *)email
                                                      phone:(NSString *)phone
                                                  firstName:(NSString *)firstName
                                                   lastName:(NSString *)lastName
                                                    address:(NSString *)address
                                                   birthday:(NSString *)birthday
                                                     gender:(NSString *)gender              //   String Male/Female
                                              maritalStatus:(NSString *)maritalStatus       //   String 1/2/3/4 = "Married"/"Widowed"/"Divorced"/"Single"
                                              childrenCount:(NSNumber *)childrenCount       //   Number count 1-10
                                                   clientId:(NSString *)clientId
                                                     result:(void (^)(NSString* deviceToken,
                                                                      NSString* jwToken,
                                                                      NSString* refreshToken
                                                                      ))completion;



//
// Get user profile info
// instanceId & instanceKey required
//
- (void)getUserProfileWithInstanceId:(NSString *)instanceId
                         instanceKey:(NSString *)instanceKey
                             jwToken:(NSString *)jwToken
                              result:(void (^)(NSString* email,
                                               NSString* phone,
                                               NSString* firstName,
                                               NSString* lastName,
                                               NSString* address,
                                               NSString* birthday,
                                               NSString* gender,
                                               NSString* maritalStatus,
                                               NSNumber* childrenCount,
                                               NSString* clientId
                                               ))completion;


//
// Update user profile info with parameters
// instanceId & instanceKey required
//
- (void)updateUserProfileWithParametersAndInstanceId:(NSString *)instanceId
                                         instanceKey:(NSString *)instanceKey
                                             jwToken:(NSString *)jwToken
                                               email:(NSString *)email
                                               phone:(NSString *)phone
                                           firstName:(NSString *)firstName
                                            lastName:(NSString *)lastName
                                             address:(NSString *)address
                                            birthday:(NSString *)birthday
                                              gender:(NSString *)gender             //   String Male/Female
                                       maritalStatus:(NSString *)maritalStatus      //   String 1/2/3/4 = "Married"/"Widowed"/"Divorced"/"Single"
                                       childrenCount:(NSNumber *)childrenCount      //   Number count 1-10
                                            clientId:(NSString *)clientId
                                              result:(void (^)(NSString *))completion;


//
// Create new user with invite code & get deviceToken, jwToken, refreshToken
// instanceId, instanceKey & invite code required
//
- (void)createDeviceTokenForUserWithInviteCodeAndInstanceId:(NSString *)instanceId
                                                instanceKey:(NSString *)instanceKey
                                                 inviteCode:(NSString *)inviteCode
                                                   clientId:(NSString *)clientId
                                                     result:(void (^)(NSString *, NSString *, NSString *))completion;

    
//+ (id)sharedManager;
+ (LoginAuthCore *)sharedManager;

@end
