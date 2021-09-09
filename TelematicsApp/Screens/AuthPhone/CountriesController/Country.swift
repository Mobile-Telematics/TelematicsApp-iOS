//
//  Country.swift
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 25.01.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

import Foundation

open class Country: NSObject {
    
    @objc open var countryCode:     String
    @objc open var phoneExtension:  String
    @objc open var isMain:          Bool
    
    @objc public static var emptyCountry: Country {
        return Country(countryCode: "", phoneExtension: "", isMain: true)
    }
    
    @objc public static var currentCountry: Country {
        
        let localIdentifier = Locale.current.identifier
        
        let locale = NSLocale(localeIdentifier: localIdentifier)
        if let countryCode = locale.object(forKey: .countryCode) as? String {
            return Countries.countryFromCountryCode(countryCode.uppercased())
        }
        
        return Country.emptyCountry
    }
    
    @objc public init(countryCode: String, phoneExtension: String, isMain: Bool) {
        
        self.countryCode = countryCode
        self.phoneExtension = phoneExtension
        self.isMain = isMain
        
    }
    
    @objc open var name: String {
        
        let localIdentifier = Locale.current.identifier
        let locale = NSLocale(localeIdentifier: localIdentifier)
        
        if let country:String = locale.displayName(forKey: .countryCode, value: countryCode.uppercased()) {
            return country
            
        } else {
            return "Invalid country code"
        }
    }
}

public func ==(lhs: Country, rhs: Country) -> Bool {
    return lhs.countryCode == rhs.countryCode
}

