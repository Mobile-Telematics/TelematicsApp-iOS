//
//  InternetErrorViewCtrl.swift
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.09.18.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

import UIKit

class InternetErrorViewCtrl: UIViewController {

    @IBOutlet weak var tryAgainBtn:             UIButton!
    @IBOutlet weak var mainErrorLbl:            UILabel!
    @IBOutlet weak var additionalErrorLbl:      UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidesBottomBarWhenPushed = true
        self.lowFontsForOldDevices()
        
        self.tryAgainBtn.addTarget(self, action: #selector(ConnectErrorViewCtrl.tryAgainAction(_:)), for: UIControl.Event.touchUpInside)
        self.tryAgainBtn.layer.cornerRadius = 18
        self.tryAgainBtn.backgroundColor = Color.officialMainAppColor()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func tryAgainAction(_ sender:UIButton!) {
        self.navigationController?.popViewController(animated: true)
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
    
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func lowFontsForOldDevices() {
        if Global.DeviceType.IS_IPHONE_4_OR_LESS || Global.DeviceType.IS_IPHONE_5 {
            mainErrorLbl.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
            additionalErrorLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        }
    }
}
