//
//  ConnectErrorViewCtrl.swift
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 25.03.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

import UIKit

class ConnectErrorViewCtrl: UIViewController {

    @IBOutlet weak var tryAgainBtn:             UIButton!
    @IBOutlet weak var mainErrorLbl:            UILabel!
    @IBOutlet weak var additionalErrorLbl:      UILabel!
    @IBOutlet weak var groupErrorLbl:           UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidesBottomBarWhenPushed = true
        self.lowFontsForOldDevices()
        
        self.tryAgainBtn.addTarget(self, action: #selector(ConnectErrorViewCtrl.tryAgainAction(_:)), for: UIControl.Event.touchUpInside)
        self.tryAgainBtn.layer.cornerRadius = 18
        self.tryAgainBtn.backgroundColor = Color.officialMainAppColor()
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
            groupErrorLbl.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.light)
            groupErrorLbl.contentMode = UIView.ContentMode.top
        }
    }
}

class AlignableUILabel: UILabel {

    override func drawText(in rect: CGRect) {

        var newRect = CGRect(x: rect.origin.x,y: rect.origin.y,width: rect.width, height: rect.height)
        let fittingSize = sizeThatFits(rect.size)

        if contentMode == UIView.ContentMode.top {
            newRect.size.height = min(newRect.size.height, fittingSize.height)
        } else if contentMode == UIView.ContentMode.bottom {
            newRect.origin.y = max(0, newRect.size.height - fittingSize.height)
        }

        super.drawText(in: newRect)
    }

}
