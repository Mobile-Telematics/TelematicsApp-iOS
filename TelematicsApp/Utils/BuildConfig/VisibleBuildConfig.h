//
//  VisibleBuildConfig.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 03.03.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//


#import <Foundation/Foundation.h>

#define kVisibleBuildConfigChanged  @"kVisibleBuildConfigChanged"

@interface VisibleBuildConfig : NSObject


@property(nonatomic, strong) NSString *configName;

+ (instancetype)sharedInstance;

- (void)setupWithPlist:(NSString *)plistFile;

- (void)setCurrentconfigName:(NSString *)configName;

- (void)setAsRelease;
- (void)showConfigBrowser;
- (id)configValueForKey:(NSString *)key;

@end
