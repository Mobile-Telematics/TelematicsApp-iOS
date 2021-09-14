//
//  NotSupportErrorViewCtrl.swift
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 25.03.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

import UIKit

class NotSupportErrorViewCtrl: UIViewController {

    @IBOutlet weak var quitBtn:             UIButton!
    @IBOutlet weak var mainTextLbl:         UILabel!
    @IBOutlet weak var notSupportedLbl:     UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidesBottomBarWhenPushed = true
        
        self.createRedTextString()
        self.quitBtn.addTarget(self, action: #selector(NotSupportErrorViewCtrl.quitBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.quitBtn.layer.cornerRadius = 18
        self.quitBtn.backgroundColor = Color.officialMainAppColor()
        
        self.lowFontsForOldDevices()
    }
    
    func createRedTextString() {
        let main_text = "Give us a call at:\n\n1 300 824 227\n\nor chat with us\nthrough the app"
        let phone_to_color = "1 300 824 227"
        
        let range = (main_text as NSString).range(of: phone_to_color)
        
        let colorAttribute = NSMutableAttributedString.init(string: main_text)
        colorAttribute.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor(rgb: 0x50c75d), range:range)
        mainTextLbl.attributedText = colorAttribute
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(NotSupportErrorViewCtrl.callToCompany))
        mainTextLbl.isUserInteractionEnabled = true
        mainTextLbl.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func callToCompany() {
        let url: NSURL = URL(string: "TEL://1300824227")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .`default`
    }
    
    @IBAction func actionOpenChat(_ sender: Any) {
        //
    }
    
    @objc func quitBtnAction(_ sender:UIButton!) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func lowFontsForOldDevices() {
        if Global.DeviceType.IS_IPHONE_4_OR_LESS || Global.DeviceType.IS_IPHONE_5 {
            notSupportedLbl.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.light)
        }
    }
}

