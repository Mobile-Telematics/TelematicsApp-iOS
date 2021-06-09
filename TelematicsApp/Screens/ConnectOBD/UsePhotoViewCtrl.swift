//
//  ConnectOBDViewCtrl.swift
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.03.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

import UIKit

class UsePhotoViewCtrl: UIViewController {

    @IBOutlet weak var confirmPhotoBtn:         UIButton!
    @IBOutlet weak var takeAgainPhotoBtn:       UIButton!
    @IBOutlet weak var odometerImageView:       UIImageView!
    @IBOutlet weak var usePhotoLbl:             UILabel!
    
    var odometerPhoto =                         UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidesBottomBarWhenPushed = true
        
        self.takeAgainPhotoBtn.addTarget(self, action: #selector(UsePhotoViewCtrl.takeAgainPhotoAction(_:)), for: UIControl.Event.touchUpInside)
        self.confirmPhotoBtn.addTarget(self, action: #selector(UsePhotoViewCtrl.confirmPhotoAction(_:)), for: UIControl.Event.touchUpInside)
        self.confirmPhotoBtn.layer.cornerRadius = 18
        self.confirmPhotoBtn.backgroundColor = Color.officialMainAppColor()
        
        DispatchQueue.main.async {
            self.setupPhoto()
        }
    }
    
    func setupPhoto() {
        if odometerPhoto.imageAsset != nil {
            odometerImageView.image = odometerPhoto
        }
    }
    
    @objc func confirmPhotoAction(_ sender:UIButton!) {
        let connectStoryboard: UIStoryboard = UIStoryboard(name: "ConnectOBD", bundle: nil)
        let connectViewController = connectStoryboard.instantiateViewController(withIdentifier: "OBDSlideBluetoothViewCtrl") as! OBDSlideBluetoothViewCtrl
        self.navigationController?.pushViewController(connectViewController, animated: true)
    }
    
    @objc func takeAgainPhotoAction(_ sender:UIButton!) {
        odometerImageView.image = nil
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
    
}

