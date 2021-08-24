//
//  APIRequest.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.01.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "APIRequest.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "AppDelegate.h"
#import "DashboardResponse.h"
#import "NSString+Date.h"
#import "RefreshTokenRequestData.h"

@import AVFoundation;
@import CoreLocation;

static NSString* const kAPIRequestErrorDomain = @"APIRequestErrorDomain";

@interface APIRequest () {
}

@property (nonatomic, strong) NSMutableURLRequest* request;
@property (nonatomic, strong) NSMutableURLRequest* savedRequest;
@property (nonatomic, strong) NSURLSessionDataTask* currentOperation;
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) BOOL isColdRequest;
@property (nonatomic, assign) Class responseClass;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, strong) APIRequestCompletionBlock completionBlock;
@property (nonatomic, strong) void (^progressBlock)(float);
@property (nonatomic, strong) NSDictionary *responseHeaders;
@property int extraMainResetCounter;
@property int counter;

@end

@implementation APIRequest

- (void)dealloc {
    DDLogDebug(@"%s %@", __func__, NSStringFromClass([self class]));
}

+ (NSString *)userServiceRootURL {
    @throw [NSException exceptionWithName:@"" reason:@"Subclass APIRequest and override [userServiceRootURL] method to provide server URL" userInfo:nil];
    return nil;
}

+ (NSString *)indicatorsServiceURL {
    @throw [NSException exceptionWithName:@"" reason:@"Subclass APIRequest and override [indicatorsServiceURL] method to provide server URL" userInfo:nil];
    return nil;
}

+ (NSString *)leaderboardServiceURL {
    @throw [NSException exceptionWithName:@"" reason:@"Subclass APIRequest and override [leaderboardServiceURL] method to provide server URL" userInfo:nil];
    return nil;
}

+ (NSString *)carServiceURL {
    @throw [NSException exceptionWithName:@"" reason:@"Subclass APIRequest and override [carServiceURL] method to provide server URL" userInfo:nil];
    return nil;
}

+ (NSString *)claimsServiceURL {
    @throw [NSException exceptionWithName:@"" reason:@"Subclass APIRequest and override [claimsServiceURL] method to provide server URL" userInfo:nil];
    return nil;
}

+ (NSString *)driveCoinsServiceURL {
    @throw [NSException exceptionWithName:@"" reason:@"Subclass APIRequest and override [driveCoinsServiceURL] method to provide server URL" userInfo:nil];
    return nil;
}

+ (NSString *)contentTypePathToJson {
    @throw [NSException exceptionWithName:@"" reason:@"Subclass APIRequest and override [contentTypePathToJson] method to provide server URL" userInfo:nil];
    return nil;
}

+ (NSString *)instanceId {
    @throw [NSException exceptionWithName:@"" reason:@"Subclass APIRequest and override [instanceId] method to provide server URL" userInfo:nil];
    return nil;
}

+ (NSString *)instanceKey {
    @throw [NSException exceptionWithName:@"" reason:@"Subclass APIRequest and override [instanceKey] method to provide server URL" userInfo:nil];
    return nil;
}

+ (NSDictionary *)customRequestHeaders {
    return @{};
}

+ (AFHTTPSessionManager*)sharedHTTPSessionManager {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[self userServiceRootURL]]];
        _sharedInstance = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[self indicatorsServiceURL]]];
        ((AFHTTPSessionManager*)_sharedInstance).requestSerializer = [AFJSONRequestSerializer serializer];
        ((AFHTTPSessionManager*)_sharedInstance).responseSerializer = [AFJSONResponseSerializer serializer];
    });
    return _sharedInstance;
}

+ (instancetype)requestWithDelegate:(id<APIRequestDelegate>)aDelegate {
    return [[self alloc] initWithDelegate:aDelegate];
}

+ (instancetype)requestWithCompletion:(APIRequestCompletionBlock)completion {
    return [self requestWithCompletion:completion progress:NULL];
}

+ (instancetype)coldRequestWithCompletion:(APIRequestCompletionBlock)completion {
    APIRequest* result = [self requestWithCompletion:completion progress:NULL];
    result.isColdRequest = YES;
    return result;
}

+ (instancetype)requestWithCompletion:(APIRequestCompletionBlock)completion progress:(void (^)(float))progress {
    APIRequest* result = [[self alloc] initWithDelegate:(id<UIDropInteractionDelegate>)self];
    [result setCompletionBlock:completion];
    [result setProgressBlock:progress];
    return result;
}

- (AFHTTPSessionManager *)sessionManager {
    return [[self class] sharedHTTPSessionManager];
}

- (id)initWithDelegate:(id<APIRequestDelegate>)aDelegate {
    self = [super init];
    if (self) {
        self.delegate = aDelegate;
    }
    return self;
}


#pragma mark - TelematicsApp Request V1

- (void)performRequestWithPath:(NSString*)path responseClass:(Class)responseClass parameters:(NSDictionary*)parameters method:(NSString*)httpMethod {
    self.responseClass = responseClass;
    if (![path hasPrefix:@"http"]) {
        path = [NSString stringWithFormat:@"%@/%@", [[self class] userServiceRootURL], path];
    }
    path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    DDLogDebug(@"%s: %@ %@ , params: %@", __FUNCTION__, httpMethod, path, parameters);
    AFHTTPSessionManager *manager = [[self class] sharedHTTPSessionManager];
    NSError* error = nil;
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:httpMethod URLString:path parameters:parameters error:&error];
    request.timeoutInterval = 120;
    NSLog(@"req %@", request.URL.absoluteString);
    NSDictionary* customHeaders = [[self class] customRequestHeaders];
    for (NSString* key in customHeaders.allKeys) {
        [request setValue:customHeaders[key] forHTTPHeaderField:key];
    }
    [self performRequest:request withResponseClass:responseClass];
}


#pragma mark - Indicators Statistics Service

- (void)performRequestIndicatorsService:(NSString*)path responseClass:(Class)responseClass parameters:(NSDictionary*)parameters method:(NSString*)httpMethod {
    self.responseClass = responseClass;
    if (![path hasPrefix:@"http"]) {
        path = [NSString stringWithFormat:@"%@/%@", [[self class] indicatorsServiceURL], path];
    }
    path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    DDLogDebug(@"%s: %@ %@ , params: %@", __FUNCTION__, httpMethod, path, parameters);
    AFHTTPSessionManager *manager = [[self class] sharedHTTPSessionManager];
    NSError* error = nil;
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:httpMethod URLString:path parameters:parameters error:&error];
    NSLog(@"req %@", request.URL.absoluteString);
    NSDictionary* customHeaders = [[self class] customRequestHeaders];
    for (NSString* key in customHeaders.allKeys) {
        [request setValue:customHeaders[key] forHTTPHeaderField:key];
    }
    [self performRequest:request withResponseClass:responseClass];
}


#pragma mark - Coins/Rewarding Service

- (void)performRequestCoinsService:(NSString*)path responseClass:(Class)responseClass parameters:(NSDictionary*)parameters method:(NSString*)httpMethod {
    self.responseClass = responseClass;
    if (![path hasPrefix:@"http"]) {
        path = [NSString stringWithFormat:@"%@/%@", [[self class] driveCoinsServiceURL], path];
    }
    path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    DDLogDebug(@"%s: %@ %@ , params: %@", __FUNCTION__, httpMethod, path, parameters);
    AFHTTPSessionManager *manager = [[self class] sharedHTTPSessionManager];
    NSError* error = nil;
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:httpMethod URLString:path parameters:parameters error:&error];
    NSLog(@"req %@", request.URL.absoluteString);
    NSDictionary* customHeaders = [[self class] customRequestHeaders];
    for (NSString* key in customHeaders.allKeys) {
        [request setValue:customHeaders[key] forHTTPHeaderField:key];
    }
    [self performRequest:request withResponseClass:responseClass];
}


#pragma mark - Car Servive

- (void)performRequestCarService:(NSString*)path responseClass:(Class)responseClass parameters:(NSDictionary*)parameters method:(NSString*)httpMethod {
    self.responseClass = responseClass;
    if (![path hasPrefix:@"http"]) {
        path = [NSString stringWithFormat:@"%@/%@", [[self class] carServiceURL], path];
    }
    path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    DDLogDebug(@"%s: %@ %@ , params: %@", __FUNCTION__, httpMethod, path, parameters);
    AFHTTPSessionManager *manager = [[self class] sharedHTTPSessionManager];
    NSError* error = nil;
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:httpMethod URLString:path parameters:parameters error:&error];
    NSLog(@"req %@", request.URL.absoluteString);
    NSDictionary* customHeaders = [[self class] customRequestHeaders];
    for (NSString* key in customHeaders.allKeys) {
        [request setValue:customHeaders[key] forHTTPHeaderField:key];
    }
    [self performRequest:request withResponseClass:responseClass];
}


#pragma mark - Claims Servive

- (void)performRequestClaimsService:(NSString*)path responseClass:(Class)responseClass parameters:(NSDictionary*)parameters method:(NSString*)httpMethod {
    self.responseClass = responseClass;
    if (![path hasPrefix:@"http"]) {
        path = [NSString stringWithFormat:@"%@/%@", [[self class] claimsServiceURL], path];
    }
    path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    DDLogDebug(@"%s: %@ %@ , params: %@", __FUNCTION__, httpMethod, path, parameters);
    AFHTTPSessionManager *manager = [[self class] sharedHTTPSessionManager];
    NSError* error = nil;
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:httpMethod URLString:path parameters:parameters error:&error];
    request.timeoutInterval = 120;
    NSLog(@"req %@", request.URL.absoluteString);
    [request setValue:[GeneralService sharedService].claimsToken forHTTPHeaderField:@"Authorization"];
    [self performRequest:request withResponseClass:responseClass];
}


#pragma mark - Leaderboard Service

- (void)performRequestLeaderboardService:(NSString*)path responseClass:(Class)responseClass parameters:(NSDictionary*)parameters method:(NSString*)httpMethod {
    self.responseClass = responseClass;
    if (![path hasPrefix:@"http"]) {
        path = [NSString stringWithFormat:@"%@/%@", [[self class] leaderboardServiceURL], path];
    }
    path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    DDLogDebug(@"%s: %@ %@ , params: %@", __FUNCTION__, httpMethod, path, parameters);
    AFHTTPSessionManager *manager = [[self class] sharedHTTPSessionManager];
    NSError* error = nil;
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:httpMethod URLString:path parameters:parameters error:&error];
    NSLog(@"req %@", request.URL.absoluteString);
    NSDictionary* customHeaders = [[self class] customRequestHeaders];
    for (NSString* key in customHeaders.allKeys) {
        [request setValue:customHeaders[key] forHTTPHeaderField:key];
    }
    [self performRequest:request withResponseClass:responseClass];
}


#pragma mark - TelematicsApp Request with Body

- (void)performRequestWithPathBodyObject:(NSString*)path responseClass:(Class)responseClass parameters:(NSDictionary*)parameters bodyObject:(NSDictionary*)bodyObject method:(NSString*)httpMethod {
    
    self.responseClass = responseClass;
    if (![path hasPrefix:@"http"]) {
        path = [NSString stringWithFormat:@"%@/%@", [[self class] userServiceRootURL], path];
    }
    path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL* URL = [NSURL URLWithString:path];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    
    [request addValue:[[self class] contentTypePathToJson] forHTTPHeaderField:@"Content-Type"];
    [request addValue:[[self class] instanceId] forHTTPHeaderField:@"InstanceId"];
    [request addValue:[[self class] instanceKey] forHTTPHeaderField:@"InstanceKey"];
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:bodyObject options:kNilOptions error:NULL];
    
    [self performRequest:request withResponseClass:responseClass];
}


#pragma mark - Root Request

- (void)performRequest:(NSMutableURLRequest*)arequest withResponseClass:(Class)responseClass {
    self.request = arequest;
    
    AFHTTPSessionManager *manager = [[self class] sharedHTTPSessionManager];
    
    self.currentOperation = [manager dataTaskWithRequest:arequest uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable parsedObject, NSError * _Nullable error) {
        if (error) {
            
            NSLog(@"%@ %ld", error.localizedDescription, (long)error.code);
            if (error.code == 405 || [error.localizedDescription isEqualToString:@"Request failed: method not allowed (405)"]) {
                NSLog(@"FULL STOP 405");
                if (self.completionBlock) {
                    self.completionBlock(nil, error);
                }
                return;
            }
            
            NSString *clUrl = [NSString stringWithFormat:@"%@", arequest.URL];
            if ([clUrl isEqualToString:@"https://insp.telematicssdk.com/api/v1/profiles/login"]) {
                if (self.completionBlock) {
                    self.completionBlock(nil, error);
                }
                return;
            }
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            self.completed = YES;
            DDLogError(@"%s %@ ERROR %@ JSON: %@", __func__, arequest.URL.absoluteString, error, parsedObject);
            
            if (((NSHTTPURLResponse*)response).statusCode == 401) {
                
                self.savedRequest = arequest;
                RefreshTokenRequestData* refreshData = [[RefreshTokenRequestData alloc] init];

                NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];

                NSString *fileTokenKey = [NSString stringWithFormat:@"%@/authBearerTokenKey.txt", documentsDirectory];
                NSString *contentTK = [[NSString alloc] initWithContentsOfFile:fileTokenKey usedEncoding:nil error:nil];
                refreshData.accessToken = contentTK;

                NSString *fileRefreshKey = [NSString stringWithFormat:@"%@/authBearerRefreshTokenKey.txt", documentsDirectory];
                NSString *contentRT = [[NSString alloc] initWithContentsOfFile:fileRefreshKey usedEncoding:nil error:nil];
                refreshData.refreshToken = contentRT;
                
                NSDate *date = [NSDate new];
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSObject *savedObject = defaults_object(@"lastAuthTokenRequest");
                
                if (savedObject != nil) {
                    NSDate *savedAdDay = defaults_object(@"lastAuthTokenRequest");
                    int differenceInMilliSec = (int)([calendar ordinalityOfUnit:NSCalendarUnitSecond inUnit:NSCalendarUnitEra forDate:date] - [calendar ordinalityOfUnit:NSCalendarUnitSecond inUnit:NSCalendarUnitEra forDate:savedAdDay]);
                    
                    if (differenceInMilliSec < 0)
                        differenceInMilliSec = 1000;
                    NSLog(@"differenceInMilliSec %d", differenceInMilliSec);
                    
                    if (differenceInMilliSec >= 200) {
                        
                        defaults_set_object(@"lastAuthTokenRequest", date);
                        
                        [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
                            if ([response isSuccesful] && ((RootResponse*)response).Status.intValue != 400) {
                                if (((RootResponse*)response).Status.intValue == 405) {
                                    if (self.completionBlock) {
                                        self.completionBlock(nil, error);
                                    }
                                    [[NSOperationQueue mainQueue] cancelAllOperations];
                                    [self.currentOperation cancel];
                                    return;
                                }

                                NSLog(@"<<<<<<<<<<WE REFRESH MAIN AUTH TOKEN ONCE: RESPONSE CODE %d", ((RootResponse*)response).Status.intValue);
                                [[GeneralService sharedService] refreshJWToken:response];

                                NSMutableURLRequest *request = self.savedRequest;
                                NSDictionary* customHeaders = [[self class] customRequestHeaders];
                                for (NSString* key in customHeaders.allKeys) {
                                    [request setValue:customHeaders[key] forHTTPHeaderField:key];
                                }
                                NSString *reqUrl = [NSString stringWithFormat:@"%@%@", [Configurator sharedInstance].userServiceRootURL, @"/Auth/RefreshToken"];
                                NSString *savedUrl = [NSString stringWithFormat:@"%@", self.savedRequest.URL];
                                if (![savedUrl isEqual:reqUrl] && ![savedUrl isEqualToString:@"(null)"]) {
                                    [self performRequest:request withResponseClass:responseClass];
                                    [[NSOperationQueue mainQueue] cancelAllOperations];
                                    [self.currentOperation cancel];
                                }

                            } else if (((RootResponse*)response).Status.intValue == 419) {
                                [[NSOperationQueue mainQueue] cancelAllOperations];
                                [self.currentOperation cancel];
                                [[AppDelegate appDelegate] logoutOn419];
                            } else {
                                if (self.completionBlock) {
                                    self.completionBlock(nil, error);
                                }
                                
                                NSLog(@"<<<<<<<<<<400 400 400 400 400 RESPONSE %d", ((RootResponse*)response).Status.intValue);
                                if (((RootResponse*)response).Status.intValue == 400) {
                                    [[NSOperationQueue mainQueue] cancelAllOperations];
                                    [self.currentOperation cancel];
                                    [[AppDelegate appDelegate] logoutOn401];
                                }
                            }
                        }] refreshJWToken:refreshData];
                    }
                } else {
                    
                    defaults_set_object(@"lastAuthTokenRequest", date);
                    
                    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
                        if ([response isSuccesful] && ((RootResponse*)response).Status.intValue != 400) {
                            if (((RootResponse*)response).Status.intValue == 405) {
                                if (self.completionBlock) {
                                    self.completionBlock(nil, error);
                                }
                                [[NSOperationQueue mainQueue] cancelAllOperations];
                                [self.currentOperation cancel];
                                return;
                            }

                            NSLog(@"<<<<<<<<<<WE REFRESH MAIN JWTOKEN TOKEN ONCE: RESPONSE CODE %d", ((RootResponse*)response).Status.intValue);
                            [[GeneralService sharedService] refreshJWToken:response];

                        } else if (((RootResponse*)response).Status.intValue == 419) {
                            [[NSOperationQueue mainQueue] cancelAllOperations];
                            [self.currentOperation cancel];
                            [[AppDelegate appDelegate] logoutOn419];
                        } else {
                            if (self.completionBlock) {
                                self.completionBlock(nil, error);
                            }
                            
                            NSLog(@"<<<<<<<<<<400 400 400 400 400 RESPONSE %d", ((RootResponse*)response).Status.intValue);
                            if (((RootResponse*)response).Status.intValue == 400) {
                                [[NSOperationQueue mainQueue] cancelAllOperations];
                                [self.currentOperation cancel];
                                [[AppDelegate appDelegate] logoutOn401];
                            }
                        }
                    }] refreshJWToken:refreshData];
                    
                }
                
            } else {
                
                NSDictionary* respDict = nil;
                id responseObject = nil;
                if ([parsedObject isKindOfClass:[NSDictionary class]]) {
                    respDict = parsedObject;
                    if (responseClass) {
                        NSError* err = nil;
                        responseObject = [[responseClass alloc] initWithDictionary:respDict error:&err];
                    } else {
                        responseObject = respDict;
                    }
                }
                if (self.completionBlock) {
                    self.completionBlock(nil, error);
                }
                if ([self.delegate respondsToSelector:@selector(apiRequest:didFailWithError:result:)]) {
                    [self.delegate apiRequest:self didFailWithError:error result:responseObject];
                }
                if (error.code == NSURLErrorNotConnectedToInternet) {
                    //SITUATION NOT NEED
                    //[[[UIAlertView alloc] initWithTitle:@"" message:localizeString(@"Check your Internet connection") delegate:self.delegate cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                    //[[NSOperationQueue mainQueue] cancelAllOperations];
                } else {
                    //if (!self.dontShowErrorAlert) {
                    //    [[[UIAlertView alloc] initWithTitle:@"" message:error.userInfo[@"NSLocalizedDescription"] delegate:self.delegate cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                    //}
                }
            }
            
        } else {
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            self.completed = YES;
            
            NSLog(@"********PARSED RESULT BACKEND>>>>>>>>>> %@", parsedObject);
            
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                self.responseHeaders = ((NSHTTPURLResponse *)response).allHeaderFields;
            }
            NSDictionary* respDict = nil;
            respDict = parsedObject;
            id responseObject;
            if (responseClass) {
                NSError* err = nil;
                responseObject = [[responseClass alloc] initWithDictionary:respDict error:&err];
            } else {
                responseObject = respDict;
            }
            
            if ([responseObject isKindOfClass:[RootResponse class]]) {
                if (((RootResponse*)responseObject).Status.intValue == 401) {

                    RefreshTokenRequestData* refreshData = [[RefreshTokenRequestData alloc] init];

                    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];

                    NSString *fileTokenKey = [NSString stringWithFormat:@"%@/authBearerTokenKey.txt", documentsDirectory];
                    NSString *contentTK = [[NSString alloc] initWithContentsOfFile:fileTokenKey usedEncoding:nil error:nil];
                    refreshData.accessToken = contentTK;

                    NSString *fileRefreshKey = [NSString stringWithFormat:@"%@/authBearerRefreshTokenKey.txt", documentsDirectory];
                    NSString *contentRT = [[NSString alloc] initWithContentsOfFile:fileRefreshKey usedEncoding:nil error:nil];
                    refreshData.refreshToken = contentRT;

                    self.counter = [[[NSUserDefaults standardUserDefaults] objectForKey:@"counterRefreshKey"] intValue];
                    self.counter += 1;
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.counter] forKey:@"counterRefreshKey"];

                    NSLog(@">>> >>> >>> >>> NOT NOT NOT AUTHORIZED %d", self.counter);
                    if (self.counter == 1) {
                        self.counter = 100;
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.counter] forKey:@"counterRefreshKey"];

                        [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
                            NSLog(@">>> >>> >>> >>> %s %@ %@", __func__, response, error);
                            if ([response isSuccesful] && ((RootResponse*)response).Status.intValue != 400) {
                                if (((RootResponse*)response).Status.intValue == 405) {
                                    if (self.completionBlock) {
                                        self.completionBlock(nil, error);
                                    }
                                    [[NSOperationQueue mainQueue] cancelAllOperations];
                                    [self.currentOperation cancel];
                                    return;
                                }

                                NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<JWT TOKEN ONCE: RESPONSE %d", ((RootResponse*)response).Status.intValue);

                                [[GeneralService sharedService] refreshJWToken:response];
                                
                                self.counter = 0;
                                self.extraMainResetCounter = 0;
                                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.counter] forKey:@"counterRefreshKey"];
                                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.extraMainResetCounter] forKey:@"counterMainReset"];

                            } else if (((RootResponse*)response).Status.intValue == 419) {
                                [[NSOperationQueue mainQueue] cancelAllOperations];
                                [self.currentOperation cancel];
                                [[AppDelegate appDelegate] logoutOn419];
                            } else {
                                NSLog(@"RESET COUNTER");
                                self.counter = 0;
                                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.counter] forKey:@"counterRefreshKey"];
                            }
                        }] refreshJWToken:refreshData];
                    }

                    if ((self.counter >= 10 && self.counter < 100) || self.counter >= 110) {
                        self.counter = 0;
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.counter] forKey:@"counterRefreshKey"];

                        self.extraMainResetCounter = [[[NSUserDefaults standardUserDefaults] objectForKey:@"counterMainReset"] intValue];
                        self.extraMainResetCounter += 1;
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.extraMainResetCounter] forKey:@"counterMainReset"];
                    }
                    if (self.extraMainResetCounter >= 5) {
                        NSLog(@"LogOut?");
                        [[NSOperationQueue mainQueue] cancelAllOperations];
                        [self.currentOperation cancel];
                        [[AppDelegate appDelegate] logoutOn401];
                    }
                }
            }

            if (self.completionBlock) {
                self.completionBlock(responseObject, nil);
            }
            if ([self.delegate respondsToSelector:@selector(apiRequest:didLoadResult:)]) {
                [self.delegate apiRequest:self didLoadResult:responseObject];
            }
        }
    }];
    if (!self.isColdRequest) {
        [self.currentOperation resume];
    }
}

- (void)cancel {
    [self.currentOperation cancel];
}

- (void)returnOnInvalidParams {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: localizeString(@"Request failed"), NSLocalizedFailureReasonErrorKey: localizeString(@"Invalid parameters")};
    NSError *error = [NSError errorWithDomain:kAPIRequestErrorDomain code:1 userInfo:userInfo];
    if (self.completionBlock) {
        self.completionBlock(nil, error);
    }
    if ([self.delegate respondsToSelector:@selector(apiRequest:didFailWithError:result:)]) {
        [self.delegate apiRequest:self didFailWithError:error result:nil];
    }
}

@end
