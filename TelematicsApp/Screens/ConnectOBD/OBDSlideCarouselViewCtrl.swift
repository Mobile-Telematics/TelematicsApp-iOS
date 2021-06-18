//
//  OBDSlideCarouselViewCtrl.swift
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 25.03.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

import UIKit
//import ImagePicker
import SafariServices

class OBDSlideCarouselViewCtrl: UIViewController, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var carousel:                OBDSlideCarouselDelegate!
    @IBOutlet weak var openCameraBtn:           UIButton!
    @IBOutlet weak var canFindCanPortBtn:       UIButton!
    
    var images:                                 [UIImage]!
    //var imagePickerController:                  ImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.loadInstallSlides()

        self.openCameraBtn.isHidden = true
        self.openCameraBtn.addTarget(self, action: #selector(OBDSlideCarouselViewCtrl.buttonOpenCameraAction(_:)), for: UIControl.Event.touchUpInside)
        self.openCameraBtn.layer.cornerRadius = 18
        self.openCameraBtn.backgroundColor = Color.officialMainAppColor()
        
        self.canFindCanPortBtn.isHidden = false
        self.canFindCanPortBtn.addTarget(self, action: #selector(OBDSlideCarouselViewCtrl.canFindCanPortAction(_:)), for: UIControl.Event.touchUpInside)

        NotificationCenter.default.addObserver(self, selector: #selector(OBDSlideCarouselViewCtrl.changeBtnName), name:NSNotification.Name(rawValue: "OnboardSlideChanged"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func loadInstallSlides() {
        images = [ UIImage(named: "obd_board1")!,
                   UIImage(named: "obd_board2")!,
                   UIImage(named: "obd_board3")!]
        carousel.images = images
    }
    
    @objc func changeBtnName() {
        if carousel.currentPage == 2 {
            self.openCameraBtn.isHidden = false
            self.canFindCanPortBtn.isHidden = true
        } else if carousel.currentPage == 1 {
            self.openCameraBtn.isHidden = true
            self.canFindCanPortBtn.isHidden = true
        } else {
            self.openCameraBtn.isHidden = true
            self.canFindCanPortBtn.isHidden = false
        }
    }
    
    @objc func buttonOpenCameraAction(_ sender:UIButton!) {
        //self.openCameraForPhoto()
    }
    
    @objc func canFindCanPortAction(_ sender:UIButton!) {
        //
    }
    
    
    // MARK: - ====================== Camera =================
    
//    func setupImagePicker() {
//        imagePickerController.delegate = self
//        imagePickerController.imageLimit = 1
//        imagePickerController.modalPresentationStyle = .fullScreen
//    }
    
//    func showImagePicker() {
//
//        if imagePickerController == nil {
//
//            let configuration = Configuration()
//            configuration.recordLocation = false
//            //configuration.savePhotosToCameraRoll = false
//            imagePickerController = ImagePickerController(configuration: configuration)
//
//            //imagePickerController = ImagePickerController()
//            setupImagePicker()
//        }
//        present(imagePickerController, animated: true, completion: nil)
//    }
//
//    func closeImagePicker() {
//        imagePickerController.dismiss(animated: true){ [unowned self] in
//            self.imagePickerController = nil
//        }
//    }
//
//    func openCameraForPhoto() {
//        showImagePicker()
//    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .`default`
    }
    
    @IBAction func actionOpenChat(_ sender: Any) {
        //
    }
    
    @IBAction func backToRootClick(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}


//extension OBDSlideCarouselViewCtrl: ImagePickerDelegate {
//
//    func pictureWasTaken(_ imagePicker: ImagePickerController, image: UIImage) {
//
//        closeImagePicker()
//
//        DispatchQueue.main.async {
//            let connectStoryboard: UIStoryboard = UIStoryboard(name: "ConnectOBD", bundle: nil)
//            let usePhotoViewController = connectStoryboard.instantiateViewController(withIdentifier: "OBDSlideBluetoothViewCtrl") as! OBDSlideBluetoothViewCtrl
//            //usePhotoViewController.odometerPhoto = image
//            self.navigationController?.pushViewController(usePhotoViewController, animated: true)
//        }
//    }
//
//    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
//        // Do nothing
//    }
//
//    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
//
//        if (images.count != 1) {
//            return
//        }
//        closeImagePicker()
//
//        DispatchQueue.main.async {
//            let connectStoryboard: UIStoryboard = UIStoryboard(name: "ConnectOBD", bundle: nil)
//            let usePhotoViewController = connectStoryboard.instantiateViewController(withIdentifier: "UsePhotoViewCtrl") as! UsePhotoViewCtrl
//            usePhotoViewController.odometerPhoto = images.first!
//            self.navigationController?.pushViewController(usePhotoViewController, animated: true)
//        }
//    }
//
//    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
//        closeImagePicker()
//    }
//}
