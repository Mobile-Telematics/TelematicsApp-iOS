//
//  SlideCarouselCtrl.swift
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.03.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

import UIKit
import RaxelPulse
import CoreBluetooth

class OBDSlideBluetoothViewCtrl: UIViewController, CBCentralManagerDelegate {
    
    @IBOutlet weak var carouselBle:         OBDSlideBluetoothDelegate!
    @IBOutlet weak var runSearchBtn:        UIButton!
    
    var images:                             [UIImage]!
    var elmList:                            NSArray = []
    
    var centralManager:                     CBCentralManager!
    var isNeedSearching:                    Bool = false
    
    var bluetoothErrorAlert:                UIAlertController?
    var timer =                             Timer()
    fileprivate var                         bleConnectCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.loadSlides()
        
        self.runSearchBtn.isHidden = true
        self.runSearchBtn.addTarget(self, action: #selector(OBDSlideBluetoothViewCtrl.runSearchAction(_:)), for: UIControl.Event.touchUpInside)
        self.runSearchBtn.layer.cornerRadius = 18
        self.runSearchBtn.backgroundColor = Color.officialMainAppColor()
        
        NotificationCenter.default.addObserver(self, selector: #selector(OBDSlideBluetoothViewCtrl.changeBtnName), name:NSNotification.Name(rawValue: "OnboardConnectChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func appMovedToBackground() {
        bluetoothErrorAlert?.dismiss(animated: false, completion: nil)
        bluetoothErrorAlert = nil
    }
    
    func loadSlides() {
        images = [UIImage(named: "obd_board4")!,
                  UIImage(named: "obd_board5")!]
        carouselBle.images = images
    }
    
    @objc func changeBtnName() {
        if carouselBle.currentPage == 1 {
            self.runSearchBtn.isHidden = false
        } else {
            self.runSearchBtn.isHidden = true
        }
    }
    
    func searchELM() {
        
        if Global.DefaultKeys.USE_ELM_API {
            centralManager = CBCentralManager(delegate: nil, queue: nil)

            timer = Timer.scheduledTimer(timeInterval: 12, target: self, selector: #selector(showSearchError), userInfo: nil, repeats: false)
            RPELMEntry.instance().getELMDevices(completion: {[weak self] response, errors in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.timer.invalidate()
                strongSelf.timer = Timer.scheduledTimer(timeInterval: 3, target: strongSelf, selector: #selector(strongSelf.workWithODBList), userInfo: ["response": response, "errors": errors], repeats: false)
                for item in response as! NSArray {
                    if let elm = item as? RPELMItem {
                        NSLog("%@ - %@", elm.uuid, elm.name)
                    }
                }
            })
        }
    }
    
    @objc func runSearchAction(_ sender:UIButton!) {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        isNeedSearching = true
        
        let popupVC = storyboard?.instantiateViewController(withIdentifier: "LookingPopupViewCtrl") as! LookingPopupViewCtrl
        view.addSubview(popupVC.view)
        addChild(popupVC)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
            switch central.state{
            case .unauthorized:
                print("This app is not authorised to use Bluetooth low energy")
            case .unknown:
                print("Unknown")
            case .resetting:
                print("Resetting")
            case .poweredOff:
                print("Bluetooth is currently powered off")
                self.showErrorAlert()
            case .poweredOn:
                print("Bluetooth is currently powered on and available to use.")
                if isNeedSearching {
                    self.searchELM()
                    //timer = Timer.scheduledTimer(timeInterval: 12, target: self, selector: #selector(showSearchError), userInfo: nil, repeats: false) //TODO
                }
            default:
                self.showErrorAlert()
                break
            }
    }
    
    @objc func workWithODBList(timer:Timer) {
        RPELMEntry.instance().stopScan()
        
        let defaults = UserDefaults.standard
        bleConnectCounter = defaults.integer(forKey: "com.zr.ble_counter")
        
        bleConnectCounter += 1
        let bleSuccessCounterString = "com.zr.ble" + String(bleConnectCounter)
        DispatchQueue.reset(token: bleSuccessCounterString)
        
        defaults.set(bleConnectCounter, forKey: "com.zr.ble_counter")
        
        let userInfo = timer.userInfo as! Dictionary<String, AnyObject?>
        let errors = userInfo["errors"]
        let response = userInfo["response"]
        
        if (errors as? NSArray) == nil {
            if let response = response {
                self.elmList = response as! NSArray
                
                DispatchQueue.once(token: bleSuccessCounterString) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        let connectStoryboard: UIStoryboard = UIStoryboard(name: "ConnectOBD", bundle: nil)
                        let foundedViewController = connectStoryboard.instantiateViewController(withIdentifier: "FoundDevicesViewCtrl") as! FoundDevicesViewCtrl
                        foundedViewController.elmFounded = self.elmList
                        self.navigationController?.pushViewController(foundedViewController, animated: true)

                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SearchCompleted"), object: nil)
                    }
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let connectStoryboard: UIStoryboard = UIStoryboard(name: "ConnectOBD", bundle: nil)
                let internetErrorViewController = connectStoryboard.instantiateViewController(withIdentifier: "InternetErrorViewCtrl") as! InternetErrorViewCtrl
                self.navigationController?.pushViewController(internetErrorViewController, animated: true)
            }
        }
        timer.invalidate()
    }
    
    @objc func showSearchError() {
        timer.invalidate()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SearchCompleted"), object: nil)
        
        if self.elmList.count == 0 {
            let connectStoryboard: UIStoryboard = UIStoryboard(name: "ConnectOBD", bundle: nil)
            let errorViewController = connectStoryboard.instantiateViewController(withIdentifier: "ConnectErrorViewCtrl") as! ConnectErrorViewCtrl
            self.navigationController?.pushViewController(errorViewController, animated: true)
        }
    }
    
    @IBAction func actionOpenChat(_ sender: Any) {
        //
    }
    
    @IBAction func backToRootClick(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func showErrorAlert() {

        self.timer.invalidate()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SearchCompleted"), object: nil)
        
        bluetoothErrorAlert = UIAlertController(title: "Bluetooth is turned Off", message: "Go to Settings and turn On Bluetooth on your iPhone", preferredStyle: UIAlertController.Style.alert)
        
        bluetoothErrorAlert!.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { action in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        
        bluetoothErrorAlert!.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
            UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)! , options:[:], completionHandler: nil)
        }))
        
        self.present(bluetoothErrorAlert!, animated: true, completion: nil)
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .`default`
    }
}

