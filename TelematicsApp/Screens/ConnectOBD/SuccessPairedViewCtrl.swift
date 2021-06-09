//
//  SuccessPairedViewCtrl.swift
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.03.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

import UIKit

class SuccessPairedViewCtrl: UIViewController {

    @IBOutlet weak var successNextBtn:          UIButton!
    @IBOutlet weak var successPairedLbl:        UILabel!
    @IBOutlet weak var deviceAndPolicyLbl:      UILabel!
    @IBOutlet weak var successImg:              UIImageView!
    
    var elmNumber: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidesBottomBarWhenPushed = true
        
        self.successNextBtn.addTarget(self, action: #selector(SuccessPairedViewCtrl.successNextBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.successNextBtn.layer.cornerRadius = 18
        self.successNextBtn.backgroundColor = Color.officialMainAppColor()
        
        deviceAndPolicyLbl.text = "Device number: " + elmNumber
    }
    
    @objc func successNextBtnAction(_ sender:UIButton!) {
        self.dismiss(animated: true, completion: nil)
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
}

