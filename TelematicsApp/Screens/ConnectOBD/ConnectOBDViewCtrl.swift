//
//  ConnectOBDViewCtrl.swift
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 23.03.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

import UIKit
import CoreFoundation
import RaxelPulse
import KDLoadingView

class ConnectOBDViewCtrl: UIViewController {

    @IBOutlet weak var tableView:               UITableView!
    @IBOutlet weak var tablePlaceholderLbl:     UILabel!
    private let refreshControl =                UIRefreshControl()
    
    fileprivate let kCellHeight:                CGFloat = 105
    fileprivate let kCellIdentifier =           "OBDCell"
    
    @IBOutlet weak var loadingView:             KDLoadingView!
    @IBOutlet weak var activityIndicator:       UIActivityIndicatorView!
    
    @IBOutlet weak var statusElmConnection:     IconRightLabel!
    @IBOutlet weak var statusElmLastDate:       UILabel!
    @IBOutlet weak var selectVehicleLbl:        UILabel!
    @IBOutlet weak var whiteBottomView:         UIView!
    @IBOutlet weak var plusBtn:                 UIButton!
    var vehiclesArray:                          NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lowFontsForOldDevices()
        
        self.hidesBottomBarWhenPushed = true
        self.tablePlaceholderLbl.isHidden = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.refreshControl = refreshControl
        self.refreshControl.addTarget(self, action: #selector(refreshVehiclesData(_:)), for: .valueChanged)
        
        self.loadingView.firstColor = Color.officialMainAppColor()
        self.loadingView.secondColor = Color.officialMainAppColor()
        self.loadingView.thirdColor = Color.officialMainAppColor()
        self.activityIndicator.color = Color.officialMainAppColor()
        
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.loadingView.startAnimating()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.getConnectionStatus()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.searchVehicles()
    }
    
    func searchVehicles() {
        
        if Global.DefaultKeys.USE_ELM_API {
            RPELMEntry.instance().getVehicles({ response, errors in
                if let theErrors = errors as? [NSError] {
                    if theErrors.count > 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            let connectStoryboard: UIStoryboard = UIStoryboard(name: "ConnectOBD", bundle: nil)
                            let internetErrorViewController = connectStoryboard.instantiateViewController(withIdentifier: "InternetErrorViewCtrl") as! InternetErrorViewCtrl
                            self.navigationController?.pushViewController(internetErrorViewController, animated: true)
                        }
                    } else if let response = response {
                        self.vehiclesArray = response as! NSArray
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.refreshControl.endRefreshing()
                                self.loadingView.stopAnimating()
                                self.tableView.reloadData()
                                
                                if (self.vehiclesArray.count == 0) {
                                    self.tablePlaceholderLbl.isHidden = false
                                } else {
                                    self.tablePlaceholderLbl.isHidden = true
                                }
                            }
                            
                            let items = response as! NSArray
                            for item in items {
                                guard let item = item as? RPVehicle else {
                                    continue
                                }
                                print("\(item.vin)")
                            }
                            
                        } else if errors != nil {
                            print("\(String(describing: errors))")
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.refreshControl.endRefreshing()
                                self.loadingView.stopAnimating()
                                self.tablePlaceholderLbl.isHidden = false
                            }
                        }
                }
            })
        }
    }
    
    @objc private func refreshVehiclesData(_ sender: Any) {
        self.searchVehicles()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            GeneralService.sharedInstance()?.loadProfile()
        }
    }
    
    func getConnectionStatus() {
        
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true

        let topAlignment: IconRightLabel.VerticalPosition = .center
        statusElmConnection.iconPosition = (.right, topAlignment)
        statusElmConnection.textAlignment = .center
        statusElmConnection.iconPadding = 7
        statusElmConnection.clipsToBounds = true

        if Global.DefaultKeys.USE_ELM_API {
            let isConnect = RPELMEntry.instance().getLastSession().isConnect
            let lastConnect = RPELMEntry.instance().getLastSession().lastConnect

            if Global.DeviceType.IS_IPHONE_4_OR_LESS || Global.DeviceType.IS_IPHONE_5 {
                statusElmConnection.font = UIFont.systemFont(ofSize: 11.0, weight: UIFont.Weight.regular)
                statusElmLastDate.font = UIFont.systemFont(ofSize: 11.0, weight: UIFont.Weight.regular)
            }
            
            if (isConnect == true) {
                statusElmConnection.text = "Connected   "
                let image = UIImage(named: "connect_yes")
                statusElmConnection.icon = image

                let timeSession = self.getPastTime(for: lastConnect)
                statusElmLastDate.text = "Last session: " + timeSession
            } else {
                statusElmConnection.text = "Not connected   "
                let image = UIImage(named: "connect_no")
                statusElmConnection.icon = image

                let timeSession = self.getPastTime(for: lastConnect)
                statusElmLastDate.text = "Last session: " + timeSession
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .`default`
    }
    
    @IBAction func addCarAction(_ sender: Any) {
        let connectStoryboard: UIStoryboard = UIStoryboard(name: "ConnectOBD", bundle: nil)
        let addCarVC = connectStoryboard.instantiateViewController(withIdentifier: "AddCarCtrl")
        self.navigationController?.pushViewController(addCarVC, animated: true)
    }
    
    @IBAction func actionOpenChat(_ sender: Any) {
        //
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getPastTime(for date : Date?) -> String {
        if date == nil {
            return "Never before"
        }
        var secondsAgo = Int(Date().timeIntervalSince(date!))
        if secondsAgo < 0 {
            secondsAgo = secondsAgo * (-1)
        }

        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        if secondsAgo < minute  {
            if secondsAgo < 45 {
                return "just now"
            } else {
                return "\(secondsAgo) seconds ago"
            }
        } else if secondsAgo < hour {
            let min = secondsAgo/minute
            if min == 1{
                return "\(min) min ago"
            } else {
                return "\(min) mins ago"
            }
        } else if secondsAgo < day {
            let hr = secondsAgo/hour
            if hr == 1{
                return "\(hr) hr ago"
            } else {
                return "\(hr) hrs ago"
            }
        } else if secondsAgo < week {
            let day = secondsAgo/day
            if day == 1 {
                return "\(day) day ago"
            } else {
                return "\(day) days ago"
            }
        } else if secondsAgo < month {
            let day = secondsAgo/week
            if day == 1 {
                return "\(day) week ago"
            } else {
                return "\(day) weeks ago"
            }
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, hh:mm a"
            formatter.locale = Locale(identifier: "en_US")
            let strDate: String = formatter.string(from: date!)
            return strDate
        }
    }
    
    func lowFontsForOldDevices() {
        if Global.DeviceType.IS_IPHONE_4_OR_LESS || Global.DeviceType.IS_IPHONE_5 {
            
            statusElmConnection.font = UIFont.systemFont(ofSize: 11.0, weight: UIFont.Weight.regular)
            statusElmLastDate.font = UIFont.systemFont(ofSize: 11.0, weight: UIFont.Weight.regular)
            
            let heightConstraint = NSLayoutConstraint(item: self.whiteBottomView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 48)
            view.addConstraints([heightConstraint])
        }
    }
}


extension ConnectOBDViewCtrl: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier) as! OBDCell
        cell.carCentralName.isHidden = true
        
        if Global.DefaultKeys.USE_ELM_API {
            let carObject = self.vehiclesArray[indexPath.row] as? RPVehicle

            //print("plateNumber \(String(describing: carObject?.plateNumber))")
            //print("vin \(String(describing: carObject?.vin))")
            //print("manufacturer \(String(describing: carObject?.manufacturer))")
            //print("model \(String(describing: carObject?.model))")
            //print("token \(String(describing: carObject?.token))")

            if (carObject?.manufacturer != "") {
                cell.carName.text = carObject?.manufacturer
            } else if (carObject?.vin != "") {
                cell.carName.text = carObject?.vin
            } else if (carObject?.manufacturer != "") {
                cell.carName.text = carObject?.manufacturer
            } else if (carObject?.model != "") {
                cell.carName.text = carObject?.model
                if carObject!.model == ", " {
                    cell.carName.text = carObject?.token
                }
            } else if (carObject?.name != "") {
                cell.carName.text = carObject?.name
            } else {
                cell.carName.text = "Car"
            }

            if (carObject?.isELMRegistered == true) {
                cell.carCentralName.isHidden = true
                cell.carName.isHidden = false

                cell.carConnectionStatus.text = "Device Activated"
                cell.carConnectionStatus.textColor = Color.officialMainAppColor()
            } else {
                cell.carCentralName.isHidden = true
                cell.carName.isHidden = false

                //cell.carCentralName.text = cell.carName.text
                cell.carConnectionStatus.text = "Device Not Activated"
                cell.carConnectionStatus.textColor = Color.lightGrayColor()
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vehiclesArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kCellHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return kCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

        if Global.DefaultKeys.USE_ELM_API {
            let car = self.vehiclesArray[indexPath.row] as? RPVehicle
            UserDefaults.setCarToken(car!.token)
            print(car!.token)

            let installCtrl = self.storyboard?.instantiateViewController(withIdentifier: "OBDSlideCarouselViewCtrl") as! OBDSlideCarouselViewCtrl
            self.navigationController?.pushViewController(installCtrl, animated: true)
        }
    }
}


extension Date {
    static func -(lhs: Date, rhs: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -rhs, to: lhs)!
    }
}
