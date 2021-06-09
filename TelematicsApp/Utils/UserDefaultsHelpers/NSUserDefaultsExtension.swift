//
//  NSUserDefaultsExtension.swift
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 30.03.21
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static func cachedEmailAddress() -> String? {
        return UserDefaults.standard.string(forKey: Global.DefaultKeys.emailAddress)
    }
    
    static func setEmailAddress(_ email: String) {
        UserDefaults.standard.set(email, forKey: Global.DefaultKeys.emailAddress)
    }
    
    static func cachedCarToken() -> String? {
        return UserDefaults.standard.string(forKey: Global.DefaultKeys.carToken)
    }
    
    static func setCarToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: Global.DefaultKeys.carToken)
    }
}
