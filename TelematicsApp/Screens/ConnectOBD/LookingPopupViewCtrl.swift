//
//  LookingPopupViewCtrl.swift
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 23.03.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

import UIKit
import KDLoadingView

class LookingPopupViewCtrl: UIViewController {

    @IBOutlet private weak var viewPopupUI:     UIView!
    @IBOutlet private weak var viewMain:        UIView!
    @IBOutlet weak var mainFirstColorLbl:       UILabel!
    @IBOutlet weak var loadingView:             KDLoadingView!
    @IBOutlet weak var lookingTopLbl:           UILabel!
    @IBOutlet weak var lookingBottomLbl:        UILabel!
    @IBOutlet weak var tooLongBtn:              UIButton!
    @IBOutlet weak var searchLogo:              UIImageView!
    
    private var animating =                     false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lowFontsForOldDevices()
        self.showViewWithAnimation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LookingPopupViewCtrl.hideViewWithAnimation), name:NSNotification.Name(rawValue: "SearchCompleted"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction private func btnGoOfflinePressed(btnSender: UIButton) {
        self.hideViewWithAnimation()
    }
    
    private func showViewWithAnimation() {
        
        self.view.alpha = 0
        self.viewPopupUI.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.2) {
            self.viewPopupUI.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.view.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.loadingView.startAnimating()
        }
    }
    
    @objc private func hideViewWithAnimation() {
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.viewPopupUI.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.view.alpha = 0
            
        }, completion: {
            (value: Bool) in
            
            self.removeFromParent()
            self.view.removeFromSuperview()
        })
    }
    
    @IBAction func actionOpenChat(_ sender: Any) {
        //
    }
    
    func lowFontsForOldDevices() {
        if Global.DeviceType.IS_IPHONE_4_OR_LESS || Global.DeviceType.IS_IPHONE_5 {
            lookingTopLbl.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.light)
            lookingBottomLbl.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.light)
            tooLongBtn.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.light)
        }
    }
}
