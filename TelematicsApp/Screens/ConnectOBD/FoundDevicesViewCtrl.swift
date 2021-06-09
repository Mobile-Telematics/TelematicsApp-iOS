//
//  FoundDevicesViewCtrl.swift
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 25.03.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

import UIKit
import RaxelPulse

class FoundDevicesViewCtrl: UIViewController {

    @IBOutlet weak var tableView:           UITableView!
    
    fileprivate let kCellHeight:            CGFloat = 50
    fileprivate let kCellIdentifier =       "FoundCell"
    
    @IBOutlet weak var nextBtn:             UIButton!
    @IBOutlet weak var repeatBtn:           UIButton!
    @IBOutlet weak var foundedLbl:          UILabel!
    
    var elmFounded:                         NSArray = []
    var selectedElmUUID:                    String = ""
    
    var isNeedStopPairing:                  Bool = false
    fileprivate var                         elmConnectCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidesBottomBarWhenPushed = true
        
        self.nextBtn.addTarget(self, action: #selector(FoundDevicesViewCtrl.nextBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.nextBtn.isEnabled = false
        self.nextBtn.layer.cornerRadius = 18
        self.nextBtn.backgroundColor = Color.officialMainAppColorAlpha8()
        
        self.repeatBtn.addTarget(self, action: #selector(FoundDevicesViewCtrl.repeatBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.repeatBtn.titleLabel?.textAlignment = .center
        
        tableView.separatorColor = UIColor.white
        tableView.reloadData()
    }
    
    @objc func nextBtnAction(_ sender:UIButton!) {
        DispatchQueue.main.asyncAfter(deadline:  .now() + 1.0) {
            SwiftSpinner.show("Please wait")
        }
        self.isNeedStopPairing = true
            
        let carToken = UserDefaults.cachedCarToken()
        
        let defaults = UserDefaults.standard
        elmConnectCounter = defaults.integer(forKey: "com.zr.elm_counter")
        elmConnectCounter += 1
        
        let elmSuccessCounterString = "com.zr.elm" + String(elmConnectCounter)
        DispatchQueue.reset(token: elmSuccessCounterString)
        defaults.set(elmConnectCounter, forKey: "com.zr.elm_counter")
        //DispatchQueue.reset(token: "com.zr.elm")
            
        RPELMEntry.instance().connectDevice(self.selectedElmUUID, vehicleToken: carToken!, withCompletion: {[weak self] response, errors in
            guard let strongSelf = self else {
                return
            }
                
                DispatchQueue.main.asyncAfter(deadline:  .now() + 1.0) {
                    SwiftSpinner.hide()
                }
                
                if let theerrors = errors as? [NSError] {
                    var isNetwork = false
                    for item in theerrors {
                        if item.code == 2005 {
                            isNetwork = true
                            break;
                        }
                    }
                    if isNetwork {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            let connectStoryboard: UIStoryboard = UIStoryboard(name: "ConnectOBD", bundle: nil)
                            let internetErrorViewController = connectStoryboard.instantiateViewController(withIdentifier: "InternetErrorViewCtrl") as! InternetErrorViewCtrl
                            strongSelf.navigationController?.pushViewController(internetErrorViewController, animated: true)
                        }
                        return;
                    }
                }
                
                DispatchQueue.main.async {
                    
                    if response == true {
                        print("\(response)")
                        
                        DispatchQueue.once(token: elmSuccessCounterString) {
                            DispatchQueue.main.async {
                                let connectStoryboard: UIStoryboard = UIStoryboard(name: "ConnectOBD", bundle: nil)
                                let successViewController = connectStoryboard.instantiateViewController(withIdentifier: "SuccessPairedViewCtrl") as! SuccessPairedViewCtrl
                                successViewController.elmNumber = strongSelf.selectedElmUUID
                                strongSelf.isNeedStopPairing = false
                                strongSelf.navigationController?.pushViewController(successViewController, animated: true)
                            }
                        }
                    } else {
                        print("\(response)")

                        DispatchQueue.once(token: "com.zr.elm") {
                            DispatchQueue.main.async {
                                let connectStoryboard: UIStoryboard = UIStoryboard(name: "ConnectOBD", bundle: nil)
                                let errorCtrl = connectStoryboard.instantiateViewController(withIdentifier: "NotSupportErrorViewCtrl") as! NotSupportErrorViewCtrl
                                strongSelf.isNeedStopPairing = false
                                strongSelf.navigationController?.pushViewController(errorCtrl, animated: true)
                            }
                        }
                    }
                }
            })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .`default`
    }
    
    @IBAction func actionOpenChat(_ sender: Any) {
        //
    }
    
    @objc func repeatBtnAction(_ sender:UIButton!) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}


extension FoundDevicesViewCtrl: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier) as! FoundCell
        cell.layer.borderWidth = 5
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.cornerRadius = 24
        cell.contentView.backgroundColor = Color.officialMainAppColorAlpha()
        cell.selectionStyle = .blue

        if Global.DefaultKeys.USE_ELM_API {
            let elm = self.elmFounded[indexPath.row] as? RPELMItem
            cell.deviceName.text = elm?.name
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.elmFounded.count
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
        
        self.nextBtn.isEnabled = true
        self.nextBtn.backgroundColor = Color.officialMainAppColor()
        
        RPEntry.enableELM(true)
        
        if Global.DefaultKeys.USE_ELM_API {
            let elm = self.elmFounded[indexPath.row] as? RPELMItem
            self.selectedElmUUID = elm!.uuid
        }
    }
}


public extension DispatchQueue {

    private static var _onceTracker = [String]()

    class func once(token: String, block:()->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }

        if _onceTracker.contains(token) {
            return
        }

        _onceTracker.append(token)
        block()
    }
}
