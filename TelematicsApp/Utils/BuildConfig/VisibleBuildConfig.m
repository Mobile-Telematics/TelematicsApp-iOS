//
//  VisibleBuildConfig.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 03.03.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "VisibleBuildConfig.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>


#define LPThemeColor        [UIColor colorWithWhite:0.2 alpha:1.0]
#define LPSelectedColor     [UIColor colorWithRed:105/255.0 green:178/255.0 blue:115/255.0 alpha:1];

#define LPWindowPadding     20

#define kconfigNameKey      @"configName"
#define kCurrentconfigName  @"kCurrentconfigName"


@interface VisibleBuildConfigViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView   *tableView;
@property (nonatomic, strong) UIButton      *btnClose;

@end


@interface VisibleBuildConfig (){
    UIWindow                                *_window;
    VisibleBuildConfigViewController        *_configVC;
    NSArray                                 *_configArray;
    NSDictionary                            *_configDict;
    NSMutableArray                          *_propertyNames;
    BOOL                                    _releaseBuildConfig;
}

- (void)setCurrentconfigName:(NSString *)configName;
- (NSDictionary *)currentBuildConfigDict;
- (NSArray *)configArray;

@end


#pragma mark - VisibleBuildConfig

@implementation VisibleBuildConfig

+ (instancetype)sharedInstance
{
    static VisibleBuildConfig* instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}


#pragma mark - Init

- (void)setupWithPlist:(NSString *)plistFile
{
    [self setupBuildConfigDataFromPlist:plistFile];
    [self setupPropertyNames];
    [self populateProperties];
}

- (void)setupBuildConfigDataFromPlist:(NSString *)plistFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:plistFile ofType:@"plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSLog(@"[VisibleBuildConfig] no config plist at %@", path);
        abort();
    }
    _configArray = [[NSArray alloc] init];
    _configArray = [NSArray arrayWithContentsOfFile:path];
    
    if (_configArray == nil || _configArray.count == 0) {
        NSLog(@"[VisibleBuildConfig] build config is empty");
        abort();
    }
    
    _configDict = [NSMutableDictionary dictionaryWithCapacity:_configArray.count];
    for (NSDictionary *dict in _configArray) {
        if (![dict isKindOfClass:[NSDictionary class]]) {
            NSLog(@"[VisibleBuildConfig] build config format shoulde be Array[Dictionary{}, ...]");
            abort();
        }
        
        NSString *configName = [dict objectForKey:kconfigNameKey];
        if (![configName isKindOfClass:[NSString class]]) {
            NSLog(@"[VisibleBuildConfig] configName should be string type");
            abort();
        }
        
        if (configName == nil || configName.length == 0) {
            NSLog(@"[VisibleBuildConfig] configName is reqired and cannot be empty for build config");
            abort();
        }
        
        if ([dict objectForKey:configName]) {
            NSLog(@"[VisibleBuildConfig] configName must be unique");
            abort();
        }
        
        [_configDict setValue:dict forKey:configName];
    }
}

- (void)setupPropertyNames {
    _propertyNames = [NSMutableArray array];
    
    Class class = [self class];
    while ([class isSubclassOfClass:[VisibleBuildConfig class]]) {
        
        unsigned count;
        objc_property_t *properties = class_copyPropertyList(class, &count);
        
        for (int i = 0; i < count; i++) {
            objc_property_t property = properties[i];
            const char * name = property_getName(property);
            
            const char * attributes = property_getAttributes(property);
            NSString * attributeString = [NSString stringWithUTF8String:attributes];
            NSArray * attributesArray = [attributeString componentsSeparatedByString:@","];
            
            if ([attributesArray containsObject:@"R"]) {
                NSLog(@"Properties can NOT be readonly to work properly.  %s will not be set", name);
            } else {
                NSString * propertyName = [NSString stringWithUTF8String:name];
                [_propertyNames addObject:propertyName];
            }
        }
        
        free(properties);
        
        class = [class superclass];
    }
}


#pragma mark - Build Config data

- (NSDictionary *)currentBuildConfigDict
{
    NSDictionary *buildConfig = nil;
    if (_releaseBuildConfig) {
        for (NSDictionary *dict in _configArray) {
            NSNumber *release = [dict objectForKey:@"Release"];
            if (release != nil && release.boolValue) {
                buildConfig = dict;
                break;
            }
        }
        
        if (buildConfig == nil) {
            buildConfig = _configArray.firstObject;
        }
    } else {
        NSString *configName = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentconfigName];
        if (configName.length > 0){
            buildConfig = [_configDict objectForKey:configName];
        }
        if (buildConfig == nil) {
            buildConfig = _configArray.firstObject;
        }
    }
    return buildConfig;
}

- (void)setCurrentconfigName:(NSString *)configName
{
    if ([_configDict objectForKey:configName] == nil) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:configName forKey:kCurrentconfigName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self populateProperties];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kVisibleBuildConfigChanged object:nil];
}

- (NSArray *)configArray
{
    return _configArray;
}


#pragma mark - Setup property

- (void)populateProperties {
    [_propertyNames enumerateObjectsUsingBlock:^(NSString * propertyName, NSUInteger idx, BOOL *stop) {
        [self setPropertyFromDictionaryValueWithName:propertyName];
    }];
}

- (void)setPropertyFromDictionaryValueWithName:(NSString *)propertyName {
    
    NSDictionary *curConfigDict = [self currentBuildConfigDict];
    __block NSString * dictionaryKey = propertyName;
    
    if (!curConfigDict[propertyName]) {
         
        [curConfigDict.allKeys enumerateObjectsUsingBlock:^(NSString * key, NSUInteger idx, BOOL *stop) {
            if ([key caseInsensitiveCompare:propertyName] == NSOrderedSame) {
                dictionaryKey = key;
                *stop = YES;
            }
        }];
    }
    
    SEL propertySetterSelector = [self setterSelectorForPropertyName:propertyName];
    
    if ([self respondsToSelector:propertySetterSelector]) {
        
        const char * typeOfProperty = [self typeOfArgumentForSelector:propertySetterSelector atIndex:2];
        IMP imp = [self methodForSelector:propertySetterSelector];
        
        if (curConfigDict[dictionaryKey]) {
            
            id objectFromDictionaryForProperty = curConfigDict[dictionaryKey];
            
            if (strcmp(typeOfProperty, @encode(id)) == 0) {
                void (*func)(id, SEL, id) = (void *)imp;
                func(self, propertySetterSelector, objectFromDictionaryForProperty);
            }
            else if (strcmp(typeOfProperty, @encode(BOOL)) == 0) {
                void (*func)(id, SEL, BOOL) = (void *)imp;
                func(self, propertySetterSelector, [objectFromDictionaryForProperty boolValue]);
            }
            else if (strcmp(typeOfProperty, @encode(int)) == 0) {
                void (*func)(id, SEL, int) = (void *)imp;
                func(self, propertySetterSelector, [objectFromDictionaryForProperty intValue]);
            }
            else if (strcmp(typeOfProperty, @encode(float)) == 0) {
                void (*func)(id, SEL, float) = (void *)imp;
                func(self, propertySetterSelector, [objectFromDictionaryForProperty floatValue]);
            }
            else if (strcmp(typeOfProperty, @encode(double)) == 0) {
                void (*func)(id, SEL, double) = (void *)imp;
                func(self, propertySetterSelector, [objectFromDictionaryForProperty doubleValue]);
            }
            
        }
        else {
            IMP imp = [self methodForSelector:propertySetterSelector];
            
            if (strcmp(typeOfProperty, @encode(id)) == 0) {
                void (*func)(id, SEL, id) = (void *)imp;
                func(self, propertySetterSelector, [NSNull new]);
            }
            else if (strcmp(typeOfProperty, @encode(BOOL)) == 0) {
                void (*func)(id, SEL, BOOL) = (void *)imp;
                func(self, propertySetterSelector, NO);
            }
            else if (strcmp(typeOfProperty, @encode(int)) == 0) {
                void (*func)(id, SEL, int) = (void *)imp;
                func(self, propertySetterSelector, 0);
            }
            else if (strcmp(typeOfProperty, @encode(float)) == 0) {
                void (*func)(id, SEL, float) = (void *)imp;
                func(self, propertySetterSelector, 0);
            }
            else if (strcmp(typeOfProperty, @encode(double)) == 0) {
                void (*func)(id, SEL, double) = (void *)imp;
                func(self, propertySetterSelector, 0);
            }
        }
    }
}


#pragma mark - Runtime property

- (SEL)setterSelectorForPropertyName:(NSString *)propertyName {
    NSString * capitalizedPropertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[propertyName substringToIndex:1] capitalizedString]];
    NSString * methodString = [NSString stringWithFormat:@"set%@:", capitalizedPropertyName];
    SEL propertySetterSelector = NSSelectorFromString(methodString);
    return propertySetterSelector;
}

- (SEL)getterSelectorForPropertyName:(NSString *)propertyName {
    return NSSelectorFromString(propertyName);
}

- (const char *)returnTypeOfSelector:(SEL)selector {
    NSMethodSignature * sig = [self methodSignatureForSelector:selector];
    return [sig methodReturnType];
}

- (const char *)typeOfArgumentForSelector:(SEL)selector atIndex:(int)index {
    NSMethodSignature * sig = [self methodSignatureForSelector:selector];
    
    if (index < sig.numberOfArguments) {
        const char * argType = [sig getArgumentTypeAtIndex:index];
        return argType;
    } else {
        NSLog(@"Index out of range of arguments");
        return nil;
    }
}


#pragma mark - Public Method

- (void)setAsRelease
{
    _releaseBuildConfig = YES;
    [self populateProperties];
}

- (void)onSwipeDetected:(UISwipeGestureRecognizer*)gs
{
    [self showConfigBrowser];
}

- (void)showConfigBrowser {
    if (_window == nil) {
        _window = [UIWindow new];
        CGRect keyFrame = [UIScreen mainScreen].bounds;
        keyFrame.origin.y += 64;
        keyFrame.size.height -= 64;
        _window.frame = CGRectInset(keyFrame, LPWindowPadding, LPWindowPadding);
        _window.backgroundColor = [Color officialWhiteColor];
        _window.layer.borderColor = LPThemeColor.CGColor;
        _window.layer.borderWidth = 2.0;
        _window.windowLevel = UIWindowLevelStatusBar;
        
        _configVC = [VisibleBuildConfigViewController new];
        _window.rootViewController = _configVC;
    }
    _window.hidden = false;
}

- (id)configValueForKey:(NSString *)key
{
    return [[self currentBuildConfigDict] objectForKey:key];
}

@end


#pragma mark - VisibleBuildConfigViewController

@implementation VisibleBuildConfigViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    [_tableView reloadData];

    _btnClose = [UIButton new];
    [self.view addSubview:_btnClose];
    _btnClose.backgroundColor = LPThemeColor;
    [_btnClose setTitleColor:[Color officialWhiteColor] forState:UIControlStateNormal];
    [_btnClose setTitle:@"Close" forState:UIControlStateNormal];
    [_btnClose addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    int viewWidth = [UIScreen mainScreen].bounds.size.width - 2 * LPWindowPadding;
    int closeWidth = 60;
    int closeHeight = 28;
    
    _btnClose.frame = CGRectMake(viewWidth-closeWidth-4, 4, closeWidth, closeHeight);
    
    CGRect tableFrame = self.view.frame;
    tableFrame.origin.y += (closeHeight+4);
    tableFrame.size.height -= (closeHeight+4);
    _tableView.frame = tableFrame;
}

- (void)btnCloseClick
{
    self.view.window.hidden = true;
}

- (void)onHeaderTapped:(UIGestureRecognizer *)gr
{
    NSInteger section = gr.view.tag;
    if (section >= [[VisibleBuildConfig sharedInstance] configArray].count) {
        return;
    }
    NSDictionary *config = [[VisibleBuildConfig sharedInstance] configArray][section];
    [[VisibleBuildConfig sharedInstance] setCurrentconfigName:config[kconfigNameKey]];
    [self.tableView reloadData];
}


#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[VisibleBuildConfig sharedInstance] configArray].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dict = [[VisibleBuildConfig sharedInstance] configArray][section];
    return dict.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [[VisibleBuildConfig sharedInstance] configArray][indexPath.section];
    NSString *key = [dict.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2] == NSOrderedDescending;
    }][indexPath.row];
    id value = [dict objectForKey:key];
    
    static NSString* cellIdentifier = @"BuildConfigCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = key;
    if ([value isKindOfClass:[NSDictionary class]]) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Dict: %lu", (unsigned long)((NSDictionary *)value).count];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else if ([value isKindOfClass:[NSArray class]]) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Array: %lu", (unsigned long)((NSArray *)value).count];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else if ([value isKindOfClass:[NSData class]]) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Bytes: %lu", (unsigned long)((NSData *)value).length];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", value];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString* reuseIdentifier = @"BuildConfigHeader";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
    if (headerView == nil) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:reuseIdentifier];
        [headerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHeaderTapped:)]];

    }
    return headerView;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    NSDictionary *dict = [[VisibleBuildConfig sharedInstance] configArray][section];
    if ([[dict objectForKey:kconfigNameKey] isEqualToString:[VisibleBuildConfig sharedInstance].configName]) {
        headerView.contentView.backgroundColor = LPSelectedColor;
    } else {
        headerView.contentView.backgroundColor = LPThemeColor;
    }
    headerView.textLabel.textColor = [Color officialWhiteColor];
    headerView.textLabel.text = [dict objectForKey:kconfigNameKey];
    headerView.textLabel.font = [UIFont boldSystemFontOfSize:15];
    headerView.tag = section;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [[VisibleBuildConfig sharedInstance] configArray][indexPath.section];
    NSString *key = [dict.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2] == NSOrderedDescending;
    }][indexPath.row];
    id value = [dict objectForKey:key];
    
    if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSData class]]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSStringFromClass([value class]) message:[value description] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

@end

