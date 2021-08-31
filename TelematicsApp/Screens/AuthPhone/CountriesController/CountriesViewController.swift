//
//  CountriesViewController.swift
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 25.01.20.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

import UIKit
import Foundation
import CoreData

@objc public final class CountriesViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @objc public var unfilteredCountries:           [[Country]]! { didSet { filteredCountries = unfilteredCountries } }
    @objc public var filteredCountries:             [[Country]]!
    @objc public var majorCountryLocaleIdentifiers: [String] = []
    @objc public var delegate:                      CountriesViewControllerDelegate?
    @objc public var allowMultipleSelection: Bool = true
    @objc public var selectedCountries: [Country] = [Country]() {
        didSet {
            self.navigationItem.rightBarButtonItem?.isEnabled = self.selectedCountries.count > 0
        }
    }
    
    public fileprivate(set) lazy var tableView: UITableView = {
        
        let tableView:UITableView = UITableView()
        tableView.backgroundColor = .white
        tableView.sectionIndexColor = Color.officialMainAppColor()
        return tableView
    }()
    
    public fileprivate(set) lazy var searchBar: UISearchBar = {
        
        let searchBar:UISearchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13, *) {
            searchBar.backgroundColor = Color.officialMainAppColor()// UIColor.green
        }
        return searchBar
    }()
    
    public fileprivate(set) lazy var stackView: UIStackView = {
        
        let stackView = UIStackView(arrangedSubviews: [self.searchBar, self.tableView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var cancelButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem?
    
    private var searchString:String = ""
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.title = allowMultipleSelection ? "Select Countries" : "Select Country"
        self.navigationController?.navigationBar.barTintColor  = .white
        self.navigationController!.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = Color.officialMainAppColor()
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(CountriesViewController.cancel))
        self.navigationItem.leftBarButtonItem = cancelButton
        
        if allowMultipleSelection {
            doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CountriesViewController.done))
            self.navigationItem.rightBarButtonItem = doneButton
            self.navigationItem.rightBarButtonItem?.isEnabled = selectedCountries.count > 0
        }
        
        tableView.sectionIndexTrackingBackgroundColor = UIColor.clear
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.keyboardDismissMode = .onDrag
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        self.view.addSubview(stackView)
        
        let viewsDictionary = [
            "stackView" :   stackView
            ] as [String : Any]
        
        let stackView_H = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[stackView]-0-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary
        )
        
        let stackView_V = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-[stackView]-0-|",
            options: NSLayoutConstraint.FormatOptions(rawValue:0),
            metrics: nil,
            views: viewsDictionary
        )
        
        searchBar.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 0).isActive  = true
        searchBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive     = true
        searchBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive   = true
        searchBar.heightAnchor.constraint(equalToConstant: CGFloat(40)).isActive            = true
        
        view.addConstraints(stackView_H)
        view.addConstraints(stackView_V)
        
        setupCountries()
        
        self.edgesForExtendedLayout = []
        
    }
    
    @objc func done() {
        delegate?.countriesViewController(self, didSelectCountries: selectedCountries)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancel() {
        delegate?.countriesViewControllerDidCancel(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText
        searchForText(searchText)
        tableView.reloadData()
    }


    fileprivate func searchForText(_ text: String) {
        if text.isEmpty {
            filteredCountries = unfilteredCountries
        } else {
            let allCountries: [Country] = Countries.countries.filter { $0.name.range(of: text) != nil }
            filteredCountries = partionedArray(allCountries, usingSelector: #selector(getter: NSFetchedResultsSectionInfo.name))
            filteredCountries.insert([], at: 0)
        }
        tableView.reloadData()
    }
    
    fileprivate func setupCountries() {
        
        unfilteredCountries = partionedArray(Countries.countries, usingSelector: #selector(getter: NSFetchedResultsSectionInfo.name))
        unfilteredCountries.insert(Countries.countriesFromCountryCodes(majorCountryLocaleIdentifiers), at: 0)
        tableView.reloadData()
        
        if let selectedCountry = selectedCountries.first {
            for (index, countries) in unfilteredCountries.enumerated() {
                if let countryIndex = countries.firstIndex(of: selectedCountry) {
                    let indexPath = IndexPath(row: countryIndex, section: index)
                    tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    break
                }
            }
        }
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return filteredCountries.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCountries[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
                return UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "Cell")
            }
            return cell
        }()
        
        let country                 = filteredCountries[indexPath.section][indexPath.row]
        cell.textLabel?.text        = country.name
        cell.detailTextLabel?.text  = "+" + country.phoneExtension
        cell.accessoryType          = (selectedCountries.firstIndex(of: country) != nil) ? .checkmark : .none

        return cell
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let countries = filteredCountries[section]
        if countries.isEmpty {
            return nil
        }
        if section == 0 {
            return ""
        }
        return UILocalizedIndexedCollation.current().sectionTitles[section - 1]
    
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return searchString != "" ? nil : UILocalizedIndexedCollation.current().sectionTitles
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return UILocalizedIndexedCollation.current().section(forSectionIndexTitle: index + 1)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if allowMultipleSelection {
            if let cell = tableView.cellForRow(at: indexPath) {
                if cell.accessoryType == .checkmark{
                    cell.accessoryType = .none
                    let co = filteredCountries[indexPath.section][indexPath.row]
                    selectedCountries = selectedCountries.filter({
                        $0 != co
                    })
                    delegate?.countriesViewController(self, didUnselectCountry: co)
                    
                } else {
                    delegate?.countriesViewController(self, didSelectCountry: filteredCountries[indexPath.section][indexPath.row])
                    
                    selectedCountries.append(filteredCountries[indexPath.section][indexPath.row])
                    cell.accessoryType = .checkmark
                }
            }
        } else {
            
            delegate?.countriesViewController(self, didSelectCountry: filteredCountries[indexPath.section][indexPath.row])
            self.dismiss(animated: true) { () -> Void in }

        }
    }
    
    @objc public class func Show(countriesViewController co:CountriesViewController, to: UIViewController) {
        let navController  = UINavigationController(rootViewController: co)
        to.present(navController, animated: true) { () -> Void in }
    }
}


private func partionedArray<T: AnyObject>(_ array: [T], usingSelector selector: Selector) -> [[T]] {
    
    let collation = UILocalizedIndexedCollation.current()
    let numberOfSectionTitles = collation.sectionTitles.count
    var unsortedSections: [[T]] = Array(repeating: [], count: numberOfSectionTitles)
    
    for object in array {
        let sectionIndex = collation.section(for: object, collationStringSelector: selector)
        unsortedSections[sectionIndex].append(object)
    }
    
    var sortedSections: [[T]] = []
    
    for section in unsortedSections {
        let sortedSection = collation.sortedArray(from: section, collationStringSelector: selector) as! [T]
        sortedSections.append(sortedSection)
    }
    
    return sortedSections

}
