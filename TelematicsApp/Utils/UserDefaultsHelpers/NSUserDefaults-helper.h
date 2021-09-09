//
//  NSUserDefaults-helper.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.01.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import Foundation;

#define ZenInit static inline

ZenInit void __defaults_post_notification(NSString *key);
ZenInit void __defaults_save(void);


ZenInit NSUserDefaults *defaults() {
	return [NSUserDefaults standardUserDefaults]; 
}

ZenInit void defaults_init(NSDictionary *dictionary) {
	[defaults() registerDefaults:dictionary]; 
}

ZenInit id defaults_object(NSString *key) {
	return [defaults() objectForKey:key]; 
}

ZenInit void defaults_set_object(NSString *key, NSObject *object) {
	[defaults() setObject:object forKey:key];
	__defaults_save();
	__defaults_post_notification(key);
}

ZenInit void defaults_remove(NSString *key) {
    [defaults() removeObjectForKey:key];
	__defaults_save();
    __defaults_post_notification(key);
}

ZenInit void defaults_observe(NSString *key, void (^block) (id object)) {
	[[NSNotificationCenter defaultCenter] addObserverForName:key object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
		block( [n.userInfo objectForKey:@"value"] );
	}];
}

ZenInit void defaults_reset(){
	NSDictionary *defaultsDictionary = [defaults() dictionaryRepresentation];
	for (NSString *key in [defaultsDictionary allKeys]) {
	    defaults_remove(key);
	}
}

ZenInit void __defaults_post_notification(NSString *key) {
    id object = defaults_object(key);
	[[NSNotificationCenter defaultCenter] postNotificationName:key object:nil userInfo: object ? [NSDictionary dictionaryWithObject:object forKey:@"value"] : [NSDictionary dictionary]];
}

ZenInit void __defaults_save() {
	[defaults() synchronize]; 
}
