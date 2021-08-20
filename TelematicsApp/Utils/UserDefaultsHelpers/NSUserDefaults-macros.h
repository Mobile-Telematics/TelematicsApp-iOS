//
//  NSUserDefaults-macros.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.01.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#define defaults()                          [NSUserDefaults standardUserDefaults]
#define defaults_init(dictionary)			[defaults() registerDefaults:dictionary]
#define defaults_save()                     [defaults() synchronize]
#define defaults_object(key)                [defaults() objectForKey:key]
#define defaults_set_object(key, object)    [defaults() setObject:object forKey:key]; defaults_save(); defaults_post_notification(key)
#define defaults_remove(key)				[defaults() removeObjectForKey:key]

#define defaults_object_from_notification(n) [n.userInfo objectForKey:@"value"]
#define defaults_observe_object(key, block) [[NSNotificationCenter defaultCenter] addObserverForName:key object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){ block( defaults_object_from_notification(n) ); }]
#define defaults_post_notification(defaults_key) [[NSNotificationCenter defaultCenter] postNotificationName:defaults_key object:nil userInfo:@{ @"value" : defaults_object(defaults_key) }]


//remember this
//defaults_set_object(@"user/username", @"John");
//defaults_set_object(@"user/loggedIn", @(YES));
//NSString *email = defaults_object(@"user/email");
//NSString *username = defaults_object(@"user/username");
//BOOL loggedIn = [defaults_object(@"user/loggedIn") boolValue];
