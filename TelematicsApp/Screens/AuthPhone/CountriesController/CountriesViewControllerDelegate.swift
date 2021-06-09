//
//  CountriesViewControllerDelegate.swift
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 25.01.19.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

import Foundation

@objc public protocol CountriesViewControllerDelegate {
    
    func countriesViewControllerDidCancel(_ countriesViewController: CountriesViewController)
    
    func countriesViewController(_ countriesViewController: CountriesViewController, didSelectCountry country: Country)
    
    func countriesViewController(_ countriesViewController: CountriesViewController, didUnselectCountry country: Country)
    
    func countriesViewController(_ countriesViewController: CountriesViewController, didSelectCountries countries: [Country])
    
}
