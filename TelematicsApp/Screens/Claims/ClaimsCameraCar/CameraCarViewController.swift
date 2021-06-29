//
//  CameraCarViewController.swift
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

extension UIImageView {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

@objc public class CameraCarViewController: UIViewController, AVCapturePhotoCaptureDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var cameraActionView: UIView!
    @IBOutlet weak var choosePhotoActionView: UIView!
    
    @IBOutlet weak var photoSaveButton: UIButton!
    @IBOutlet weak var photoCancelButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var dismissCameraButton: UIButton!
    
    var tutorialView: UIView!
    var lblTextInfo: UILabel!
    var carImg: UIImageView!
    var lblSelectFromGallery: UILabel!
    
    var croppedImageView = UIImageView()
    var cropImageRect = CGRect()
    var cropImageRectCorner = UIRectCorner()
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var imagePicker = UIImagePickerController()
    
    var mFirstStart = true
    @objc public var photoBlock = 1
    @objc public var photoCounter = 1
    var uploadFromGallery = false
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        
        UserDefaults.standard.set(true, forKey: "needClaimsTutorial")
        
        let pb = UserDefaults.standard.object(forKey: "claimSelectedPhotoBlock")
        photoBlock = pb as! Int
        
        let ph = UserDefaults.standard.object(forKey: "claimSelectedPhotoShot")
        photoCounter = ph as! Int
        photoCounter += 1
        
        self.runTutorial()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CameraCarViewController.detectDeviceOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium //.high
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera")
                return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            stillImageOutput.isHighResolutionCaptureEnabled = true
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                
                if (photoBlock == 1) {
                    if (photoCounter == 1) { //LEFT
                        setupCameraPreview1()
                    } else if (photoCounter == 2) {
                        setupCameraPreview2()
                    } else if (photoCounter == 3) {
                        setupCameraPreview3()
                    } else if (photoCounter == 4) {
                        setupCameraPreview4()
                    } else if (photoCounter == 5) {
                        setupCameraPreview5()
                    }
                    
                } else if (photoBlock == 2) { //REAR
                    if (photoCounter == 11) {
                        setupCameraPreview11()
                    } else if (photoCounter == 12) {
                        setupCameraPreview12()
                    } else if (photoCounter == 13) {
                        setupCameraPreview13()
                    }
                    
                } else if (photoBlock == 3) { //RIGHT
                    if (photoCounter == 6) {
                        setupCameraPreview6()
                    } else if (photoCounter == 7) {
                        setupCameraPreview7()
                    } else if (photoCounter == 8) {
                        setupCameraPreview8()
                    } else if (photoCounter == 9) {
                        setupCameraPreview9()
                    } else if (photoCounter == 10) {
                        setupCameraPreview10()
                    }
                    
                } else if (photoBlock == 4) { //FRONT
                    if (photoCounter == 14) {
                        setupCameraPreview14()
                    } else if (photoCounter == 15) {
                        setupCameraPreview15()
                    } else if (photoCounter == 16) {
                        setupCameraPreview16()
                    } else if (photoCounter == 17) {
                        setupCameraPreview17()
                    } else if (photoCounter == 18) {
                        setupCameraPreview18()
                    }
                } else {
                    setupCameraPreview1()
                }
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession?.stopRunning()
    }
    
    func runTutorial() {
        tutorialView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        tutorialView.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = tutorialView.bounds
        tutorialView.center = self.view.center
        tutorialView.addSubview(blurView)
        
        lblTextInfo = UILabel(frame: CGRect(x: 10, y: self.view.frame.height/2 - 130, width: self.view.frame.width - 20, height: 190))
        lblTextInfo.textAlignment = .center
        lblTextInfo.text = "Please rotate your iPhone in horizontal mode first and take a picture of the car as shown\n\nIf the screen doesn't rotate on your iPhone, make sure that Portrait Orientation Lock is turned off. To check, open Control Center"
        lblTextInfo.textColor = .white
        lblTextInfo.font = UIFont.systemFont(ofSize: 19)
        lblTextInfo.numberOfLines = 0
        lblTextInfo.lineBreakMode = .byWordWrapping
        tutorialView.addSubview(lblTextInfo)
        self.view.addSubview(tutorialView)
        
        self.updateCarMiniImage()
    }
    
    func updateCarMiniImage() {
        var imageName = "claims_left_allside"
        var sideText = "Left All Side | Photo 1 of 5 on this side"
        if (photoCounter == 1) {
            imageName = "claims_left_allside"
            sideText = "Left All Side | Photo 1 of 5 on this side"
        } else if (photoCounter == 2) {
            imageName = "claims_left_front_wing"
            sideText = "Left Front Wing | Photo 2 of 5 on this side"
        } else if (photoCounter == 3) {
            imageName = "claims_left_front_door"
            sideText = "Left Front Door | Photo 3 of 5 on this side"
        } else if (photoCounter == 4) {
            imageName = "claims_left_rear_door"
            sideText = "Left Rear Door | Photo 4 of 5 on this side"
        } else if (photoCounter == 5) {
            imageName = "claims_left_rear_wing"
            sideText = "Left Rear Wing | Photo 5 of 5 on this side"
        } else if (photoCounter == 6) {
            imageName = "claims_right_allside"
            sideText = "Right All Side | Photo 1 of 5 on this side"
        } else if (photoCounter == 7) {
            imageName = "claims_right_front_wing"
            sideText = "Right Front Wing | Photo 2 of 5 on this side"
        } else if (photoCounter == 8) {
            imageName = "claims_right_front_door"
            sideText = "Right Front Door | Photo 3 of 5 on this side"
        } else if (photoCounter == 9) {
            imageName = "claims_right_rear_door"
            sideText = "Right Rear Door | Photo 4 of 5 on this side"
        } else if (photoCounter == 10) {
            imageName = "claims_right_rear_wing"
            sideText = "Right Rear Wing | Photo 5 of 5 on this side"
        } else if (photoCounter == 11) {
            imageName = "claims_left_rear_diagonal"
            sideText = "Rear Left Diagonal | Photo 1 of 3 on this side"
        } else if (photoCounter == 12) {
            imageName = "claims_car_backside"
            sideText = "Rear Side | Photo 2 of 3 on this side"
        } else if (photoCounter == 13) {
            imageName = "claims_right_rear_diagonal"
            sideText = "Rear Right Diagonal | Photo 3 of 3 on this side"
        } else if (photoCounter == 14) {
            imageName = "claims_right_front_diagonal"
            sideText = "Front Right Diagonal | Photo 1 of 5 on this side"
        } else if (photoCounter == 15) {
            imageName = "claims_car_frontside"
            sideText = "Front Side | Photo 2 of 5 on this side"
        } else if (photoCounter == 16) {
            imageName = "claims_left_front_diagonal"
            sideText = "Front Left Diagonal | Photo 3 of 5 on this side"
        } else if (photoCounter == 17) {
            imageName = "claims_car_windshield"
            sideText = "Windshield | Photo 4 of 5 on this side"
        } else if (photoCounter == 18) {
            imageName = "claims_car_dashboard"
            sideText = "Dashboard | Photo 5 of 5 on this side"
        }
        
        carImg?.removeFromSuperview()
        lblSelectFromGallery?.removeFromSuperview()
        carImg = nil
        lblSelectFromGallery = nil
        
        let image = UIImage(named: imageName)
        let newImage = image!.rotate(radians: -.pi/2)
        carImg = UIImageView(image: newImage!)
        carImg.frame = CGRect(x: self.view.frame.width/2-40 , y: self.view.frame.height/2+150, width: 80, height: 60)
        carImg.contentMode = .scaleAspectFit
        
        let imgGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CameraCarViewController.actionSelectFromGallery(_:)))
        carImg.addGestureRecognizer(imgGestureRecognizer)
        carImg.isUserInteractionEnabled = true
        self.view.addSubview(carImg)
        
        lblSelectFromGallery = UILabel(frame: CGRect(x: 10, y: self.view.frame.height/2+210, width: self.view.frame.width - 20, height: 70))
        lblSelectFromGallery.textAlignment = .center
        lblSelectFromGallery.text = sideText + "\n\nSelect from Photo Gallery"
        lblSelectFromGallery.textColor = .white
        lblSelectFromGallery.font = UIFont.systemFont(ofSize: 14)
        lblSelectFromGallery.numberOfLines = 0
        lblSelectFromGallery.lineBreakMode = .byWordWrapping
        
        let galleryGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CameraCarViewController.actionSelectFromGallery(_:)))
        lblSelectFromGallery.addGestureRecognizer(galleryGestureRecognizer)
        lblSelectFromGallery.isUserInteractionEnabled = true
        self.view.addSubview(lblSelectFromGallery)
    }
    
    
    // MARK: - AVCapturePhotoCaptureDelegate
    
    @available(iOS 11.0, *)
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            
        guard error == nil else {
            print("Fail to capture photo: \(String(describing: error))")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Fail to convert pixel buffer")
            return
        }
            
        let orgImage : UIImage = UIImage(data: imageData)!
        capturedImageView.image = orgImage
        let originalSize: CGSize
        let visibleLayerFrame = cropImageRect
            
        let metaRect = (videoPreviewLayer?.metadataOutputRectConverted(fromLayerRect: visibleLayerFrame )) ?? CGRect.zero
            
        if (orgImage.imageOrientation == UIImage.Orientation.left || orgImage.imageOrientation == UIImage.Orientation.right) {
            originalSize = CGSize(width: orgImage.size.height, height: orgImage.size.width)
        } else {
            originalSize = orgImage.size
        }
        let cropRect: CGRect = CGRect(x: metaRect.origin.x * originalSize.width, y: metaRect.origin.y * originalSize.height, width: metaRect.size.width * originalSize.width, height: metaRect.size.height * originalSize.height).integral
            
        if let finalCgImage = orgImage.cgImage?.cropping(to: cropRect) {
            let image = UIImage(cgImage: finalCgImage, scale: 1.0, orientation: UIImage.Orientation.up) //let image = UIImage(cgImage: finalCgImage, scale: 1.0, orientation: orgImage.imageOrientation)
            previewViewLayerMode(image: image, isCameraMode: false)

            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            var imageName = "000.png"
            if (photoCounter == 1) {
                imageName = "photoLEFT0.png"
            } else if (photoCounter == 2) {
                imageName = "photoLEFT1.png"
            } else if (photoCounter == 3) {
                imageName = "photoLEFT2.png"
            } else if (photoCounter == 4) {
                imageName = "photoLEFT3.png"
            } else if (photoCounter == 5) {
                imageName = "photoLEFT4.png"
            } else if (photoCounter == 6) {
                imageName = "photoRIGHT0.png"
            } else if (photoCounter == 7) {
                imageName = "photoRIGHT1.png"
            } else if (photoCounter == 8) {
                imageName = "photoRIGHT2.png"
            } else if (photoCounter == 9) {
                imageName = "photoRIGHT3.png"
            } else if (photoCounter == 10) {
                imageName = "photoRIGHT4.png"
            } else if (photoCounter == 11) {
                imageName = "photoREAR0.png"
            } else if (photoCounter == 12) {
                imageName = "photoREAR1.png"
            } else if (photoCounter == 13) {
                imageName = "photoREAR2.png"
            } else if (photoCounter == 14) {
                imageName = "photoFRONT0.png"
            } else if (photoCounter == 15) {
                imageName = "photoFRONT1.png"
            } else if (photoCounter == 16) {
                imageName = "photoFRONT2.png"
            } else if (photoCounter == 17) {
                imageName = "photoWIND0.png"
            } else if (photoCounter == 18) {
                imageName = "photoDASH0.png"
            }
            
            let imageUrl = documentDirectory.appendingPathComponent("\(imageName)")
            if let data = image.jpegData(compressionQuality: 1.0){
                do {
                    try data.write(to: imageUrl)
                    
                    if (photoCounter == 1) {
                        ClaimsService.shared()?.photo_Left_Wide = imageUrl.absoluteString
                    } else if (photoCounter == 2) {
                        ClaimsService.shared()?.photo_Left_Front_Wing = imageUrl.absoluteString
                    } else if (photoCounter == 3) {
                        ClaimsService.shared()?.photo_Left_Front_Door = imageUrl.absoluteString
                    } else if (photoCounter == 4) {
                        ClaimsService.shared()?.photo_Left_Rear_Door = imageUrl.absoluteString
                    } else if (photoCounter == 5) {
                        ClaimsService.shared()?.photo_Left_Rear_Wing = imageUrl.absoluteString
                    } else if (photoCounter == 6) {
                        ClaimsService.shared()?.photo_Right_Wide = imageUrl.absoluteString
                    } else if (photoCounter == 7) {
                        ClaimsService.shared()?.photo_Right_Front_Wing = imageUrl.absoluteString
                    } else if (photoCounter == 8) {
                        ClaimsService.shared()?.photo_Right_Front_Door = imageUrl.absoluteString
                    } else if (photoCounter == 9) {
                        ClaimsService.shared()?.photo_Right_Rear_Door = imageUrl.absoluteString
                    } else if (photoCounter == 10) {
                        ClaimsService.shared()?.photo_Right_Rear_Wing = imageUrl.absoluteString
                    } else if (photoCounter == 11) {
                        ClaimsService.shared()?.photo_Rear_Left_Diagonal = imageUrl.absoluteString
                    } else if (photoCounter == 12) {
                        ClaimsService.shared()?.photo_Rear_Wide = imageUrl.absoluteString
                    } else if (photoCounter == 13) {
                        ClaimsService.shared()?.photo_Rear_Right_Diagonal = imageUrl.absoluteString
                    } else if (photoCounter == 14) {
                        ClaimsService.shared()?.photo_Front_Right_Diagonal = imageUrl.absoluteString
                    } else if (photoCounter == 15) {
                        ClaimsService.shared()?.photo_Front_Wide = imageUrl.absoluteString
                    } else if (photoCounter == 16) {
                        ClaimsService.shared()?.photo_Front_Left_Diagonal = imageUrl.absoluteString
                    } else if (photoCounter == 17) {
                        ClaimsService.shared()?.photo_Windshield_Wide = imageUrl.absoluteString
                    } else if (photoCounter == 18) {
                        ClaimsService.shared()?.photo_Dashboard_Wide = imageUrl.absoluteString
                    }
                } catch {
                    print("error saving", error)
                }
            }
        }
    }
    

// MARK: - IBAction Camera
    
    @IBAction func actionCameraCapture(_ sender: AnyObject) {
            
        var photoSettings: AVCapturePhotoSettings
        if #available(iOS 11.0, *) {
            photoSettings = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        } else {
            photoSettings = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecJPEG])
        }
        
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.flashMode = .auto
        stillImageOutput.capturePhoto(with: photoSettings, delegate: self)
            
        UserDefaults.standard.set(false, forKey: "needClaimsTutorial")
    }
        
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let alertController = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (alert: UIAlertAction!) in
                self.previewViewLayerMode(image: nil, isCameraMode: true)
            }))
            present(alertController, animated: true)
        } else {
            let alertController = UIAlertController(title: "Saved", message: "Captured guided image saved successfully.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) in
                self.previewViewLayerMode(image: nil, isCameraMode: true)
            }))
            present(alertController, animated: true)
        }
    }
        
    @IBAction func cancelPhotoPressed(_ sender: Any) {
        previewViewLayerMode(image: nil, isCameraMode: true)
        UserDefaults.standard.set(true, forKey: "needClaimsTutorial")
        detectDeviceOrientation()
    }
        
    @IBAction func dismissCamera(_ sender: Any) {
        self.photoCounter = 1
        videoPreviewLayer = nil
        previewView = nil
        captureSession = nil
        self.dismiss(animated: true, completion: nil)
    }
        
    @IBAction func savePhotoPressed(_ sender: Any) {
            
        self.photoCounter += 1
        UserDefaults.standard.set(true, forKey: "needClaimsTutorial")
        
        if (photoBlock == 1) {
            if self.photoCounter == 2 {
                previewViewLayerMode2(image: nil, isCameraMode: true)
            } else if self.photoCounter == 3 {
                previewViewLayerMode3(image: nil, isCameraMode: true)
            } else if self.photoCounter == 4 {
                previewViewLayerMode4(image: nil, isCameraMode: true)
            } else if self.photoCounter == 5 {
                previewViewLayerMode5(image: nil, isCameraMode: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            
        } else if (photoBlock == 2) {
            if self.photoCounter == 11 {
                previewViewLayerMode11(image: nil, isCameraMode: true)
            } else if self.photoCounter == 12 {
                previewViewLayerMode12(image: nil, isCameraMode: true)
            } else if self.photoCounter == 13 {
                previewViewLayerMode13(image: nil, isCameraMode: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            
        } else if (photoBlock == 3) {
            if self.photoCounter == 6 {
                previewViewLayerMode6(image: nil, isCameraMode: true)
            } else if self.photoCounter == 7 {
                previewViewLayerMode7(image: nil, isCameraMode: true)
            } else if self.photoCounter == 8 {
                previewViewLayerMode8(image: nil, isCameraMode: true)
            } else if self.photoCounter == 9 {
                previewViewLayerMode9(image: nil, isCameraMode: true)
            } else if self.photoCounter == 10 {
                previewViewLayerMode10(image: nil, isCameraMode: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            
        } else if (photoBlock == 4) {
            if self.photoCounter == 14 {
                previewViewLayerMode14(image: nil, isCameraMode: true)
            } else if self.photoCounter == 15 {
                previewViewLayerMode15(image: nil, isCameraMode: true)
            } else if self.photoCounter == 16 {
                previewViewLayerMode16(image: nil, isCameraMode: true)
            } else if self.photoCounter == 17 {
                previewViewLayerMode17(image: nil, isCameraMode: true)
            } else if self.photoCounter == 18 {
                previewViewLayerMode18(image: nil, isCameraMode: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
            
        self.updateCarMiniImage()
        detectDeviceOrientation()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "checkVehicleImageStatus"), object: nil)
    }
    
    func previewViewLayerMode(image: UIImage?, isCameraMode: Bool) {
        if isCameraMode {
            self.captureSession.startRunning()
            
            cameraActionView.isHidden = false
            choosePhotoActionView.isHidden = true
            
            previewView.isHidden = false
            capturedImageView.isHidden = true
        } else {
            self.captureSession.stopRunning()
            
            cameraActionView.isHidden = true
            choosePhotoActionView.isHidden = false
            
            previewView.isHidden = true
            capturedImageView.isHidden = false
        }
    }
    
    
// MARK: - IBAction Gallery
    
    @IBAction func actionSelectFromGallery(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            imagePicker.modalPresentationStyle = .overFullScreen
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    open func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
//        DispatchQueue.main.async {
//            SwiftSpinner.show("Please wait")
//        }
        
        guard info[UIImagePickerController.InfoKey.originalImage] != nil else {
            print("Fail to convert pixel buffer")
            return
        }
        
        let orgImage : UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imagePicker.dismiss(animated: false, completion: { () -> Void in
            
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            var imageName = "000.png"
            if (self.photoCounter == 1) {
                imageName = "photoLEFT0.png"
            } else if (self.photoCounter == 2) {
                imageName = "photoLEFT1.png"
            } else if (self.photoCounter == 3) {
                imageName = "photoLEFT2.png"
            } else if (self.photoCounter == 4) {
                imageName = "photoLEFT3.png"
            } else if (self.photoCounter == 5) {
                imageName = "photoLEFT4.png"
            } else if (self.photoCounter == 6) {
                imageName = "photoRIGHT0.png"
            } else if (self.photoCounter == 7) {
                imageName = "photoRIGHT1.png"
            } else if (self.photoCounter == 8) {
                imageName = "photoRIGHT2.png"
            } else if (self.photoCounter == 9) {
                imageName = "photoRIGHT3.png"
            } else if (self.photoCounter == 10) {
                imageName = "photoRIGHT4.png"
            } else if (self.photoCounter == 11) {
                imageName = "photoREAR0.png"
            } else if (self.photoCounter == 12) {
                imageName = "photoREAR1.png"
            } else if (self.photoCounter == 13) {
                imageName = "photoREAR2.png"
            } else if (self.photoCounter == 14) {
                imageName = "photoFRONT0.png"
            } else if (self.photoCounter == 15) {
                imageName = "photoFRONT1.png"
            } else if (self.photoCounter == 16) {
                imageName = "photoFRONT2.png"
            } else if (self.photoCounter == 17) {
                imageName = "photoWIND0.png"
            } else if (self.photoCounter == 18) {
                imageName = "photoDASH0.png"
            }

            let imageUrl = documentDirectory.appendingPathComponent("\(imageName)")
            if let data = orgImage.jpegData(compressionQuality: 0.8) {
                do {

                    try data.write(to: imageUrl)

                    if (self.photoCounter == 1) {
                        ClaimsService.shared()?.photo_Left_Wide = imageUrl.absoluteString
                        self.previewViewLayerMode2(image: nil, isCameraMode: true)
                    } else if (self.photoCounter == 2) {
                        ClaimsService.shared()?.photo_Left_Front_Wing = imageUrl.absoluteString
                        self.previewViewLayerMode3(image: nil, isCameraMode: true)
                    } else if (self.photoCounter == 3) {
                        ClaimsService.shared()?.photo_Left_Front_Door = imageUrl.absoluteString
                        self.previewViewLayerMode4(image: nil, isCameraMode: true)
                    } else if (self.photoCounter == 4) {
                        ClaimsService.shared()?.photo_Left_Rear_Door = imageUrl.absoluteString
                        self.previewViewLayerMode5(image: nil, isCameraMode: true)
                    } else if (self.photoCounter == 5) {
                        ClaimsService.shared()?.photo_Left_Rear_Wing = imageUrl.absoluteString
                        //previewViewLayerMode6(image: nil, isCameraMode: true)
                        self.dismiss(animated: true, completion: nil)
                        
                    } else if (self.photoCounter == 6) {
                        ClaimsService.shared()?.photo_Right_Wide = imageUrl.absoluteString
                        self.previewViewLayerMode7(image: nil, isCameraMode: true)
                    } else if (self.photoCounter == 7) {
                        ClaimsService.shared()?.photo_Right_Front_Wing = imageUrl.absoluteString
                        self.previewViewLayerMode8(image: nil, isCameraMode: true)
                    } else if (self.photoCounter == 8) {
                        ClaimsService.shared()?.photo_Right_Front_Door = imageUrl.absoluteString
                        self.previewViewLayerMode9(image: nil, isCameraMode: true)
                    } else if (self.photoCounter == 9) {
                        ClaimsService.shared()?.photo_Right_Rear_Door = imageUrl.absoluteString
                        self.previewViewLayerMode10(image: nil, isCameraMode: true)
                    } else if (self.photoCounter == 10) {
                        ClaimsService.shared()?.photo_Right_Rear_Wing = imageUrl.absoluteString
                        //previewViewLayerMode11(image: nil, isCameraMode: true)
                        self.dismiss(animated: true, completion: nil)
                        
                    } else if (self.photoCounter == 11) {
                        ClaimsService.shared()?.photo_Rear_Left_Diagonal = imageUrl.absoluteString
                        self.previewViewLayerMode12(image: nil, isCameraMode: true)
                    } else if (self.photoCounter == 12) {
                        ClaimsService.shared()?.photo_Rear_Wide = imageUrl.absoluteString
                        self.previewViewLayerMode13(image: nil, isCameraMode: true)
                    } else if (self.photoCounter == 13) {
                        ClaimsService.shared()?.photo_Rear_Right_Diagonal = imageUrl.absoluteString
                        self.dismiss(animated: true, completion: nil)
                        
                    } else if (self.photoCounter == 14) {
                        ClaimsService.shared()?.photo_Front_Right_Diagonal = imageUrl.absoluteString
                        self.previewViewLayerMode15(image: nil, isCameraMode: true)
                    } else if (self.photoCounter == 15) {
                        ClaimsService.shared()?.photo_Front_Wide = imageUrl.absoluteString
                        self.previewViewLayerMode16(image: nil, isCameraMode: true)
                    } else if (self.photoCounter == 16) {
                        ClaimsService.shared()?.photo_Front_Left_Diagonal = imageUrl.absoluteString
                        self.previewViewLayerMode17(image: nil, isCameraMode: true)
                    } else if (self.photoCounter == 17) {
                        ClaimsService.shared()?.photo_Windshield_Wide = imageUrl.absoluteString
                        self.previewViewLayerMode18(image: nil, isCameraMode: true)
                    } else if (self.photoCounter == 18) {
                        ClaimsService.shared()?.photo_Dashboard_Wide = imageUrl.absoluteString
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                        return
                    }

                    self.photoCounter += 1
                    self.updateCarMiniImage()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "checkVehicleImageStatus"), object: nil)
                    //SwiftSpinner.hide()
                } catch {
                    print("error saving", error)
                    //SwiftSpinner.hide()
                }
            }
        })
    }
    
    open func imagePickerControllerDidCancel(_: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }

    
// MARK: - LEFT Photo 1
    func setupCameraPreview1() {
        DispatchQueue.main.async {
            let imageView = self.setupGuideLineArea1()
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.videoPreviewLayer.videoGravity = .resizeAspectFill
            self.videoPreviewLayer.connection?.videoOrientation = .portrait
            self.previewView.layer.addSublayer(self.videoPreviewLayer)
            self.previewView.addSubview(imageView)
            self.cropImageRect = imageView.frame
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
                DispatchQueue.main.async {
                    self.videoPreviewLayer.frame = self.previewView.bounds
                    
                    let lbl = UILabel(frame: CGRect(x: 35, y: 0, width: 200, height: 30))
                    lbl.addIconToLabel(imageName: "ic_info", labelText: "Left All Side", bounds_x: -5, bounds_y: -3, boundsWidth: 19, boundsHeight: 19)
                    lbl.textAlignment = .center
                    lbl.textColor = .lightGray
                    lbl.font = UIFont.systemFont(ofSize: 17)
                    lbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                    self.previewView.addSubview(lbl)
                    lbl.frame = CGRect(x: self.previewView.frame.size.width-40, y: -20, width: 30, height: 200)
                }
            }
        }
    }
    
    func setupGuideLineArea1() -> UIImageView {
        
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let resizableImage = (UIImage(named: "claims_left_allside")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: previewView.frame.size.width, height: previewView.frame.size.height)
        cropImageRectCorner = [.allCorners]
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.contentMode = .scaleAspectFit //?
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }
    
    
// MARK: - LEFT Photo 2
    func previewViewLayerMode2(image: UIImage?, isCameraMode: Bool) {
        self.previewView.subviews.forEach({ $0.removeFromSuperview() })
        self.setupCameraPreview2()
        
        self.captureSession.startRunning()
        cameraActionView.isHidden = false
        choosePhotoActionView.isHidden = true
        previewView.isHidden = false
        capturedImageView.isHidden = true
    }
    
    func setupCameraPreview2() {
        let imageView = setupGuideLineArea2()
        if videoPreviewLayer == nil {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
        //videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        previewView.addSubview(imageView)
        cropImageRect = imageView.frame
        
        DispatchQueue.global(qos: .userInitiated).async {
            //self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
                
                let lbl = UILabel(frame: CGRect(x: 35, y: 0, width: 200, height: 30))
                lbl.addIconToLabel(imageName: "ic_info", labelText: "Left Front Wing", bounds_x: -5, bounds_y: -3, boundsWidth: 19, boundsHeight: 19)
                lbl.textAlignment = .center
                lbl.textColor = .lightGray
                lbl.font = UIFont.systemFont(ofSize: 17)
                lbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                self.previewView.addSubview(lbl)
                lbl.frame = CGRect(x: self.previewView.frame.size.width-40, y: -20, width: 30, height: 200)
            }
        }
    }
    
    func setupGuideLineArea2() -> UIImageView {
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let resizableImage = (UIImage(named: "claims_left_front_wing")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: previewView.frame.size.width, height: previewView.frame.size.height)
        cropImageRectCorner = [.allCorners]
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.contentMode = .scaleAspectFit //?
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }
    
    
// MARK: - LEFT Photo 3
    func previewViewLayerMode3(image: UIImage?, isCameraMode: Bool) {
        previewView.subviews.forEach({ $0.removeFromSuperview() })
        setupCameraPreview3()
        
        self.captureSession.startRunning()
        cameraActionView.isHidden = false
        choosePhotoActionView.isHidden = true
        previewView.isHidden = false
        capturedImageView.isHidden = true
    }
    
    func setupCameraPreview3() {
        let imageView = setupGuideLineArea3()
        if videoPreviewLayer == nil {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
        //videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        previewView.addSubview(imageView)
        cropImageRect = imageView.frame
        DispatchQueue.global(qos: .userInitiated).async {
            //self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
                
                let lbl = UILabel(frame: CGRect(x: 35, y: 0, width: 200, height: 30))
                lbl.addIconToLabel(imageName: "ic_info", labelText: "Left Front Door", bounds_x: -5, bounds_y: -3, boundsWidth: 19, boundsHeight: 19)
                lbl.textAlignment = .center
                lbl.textColor = .lightGray
                lbl.font = UIFont.systemFont(ofSize: 17)
                lbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                self.previewView.addSubview(lbl)
                lbl.frame = CGRect(x: self.previewView.frame.size.width-40, y: -20, width: 30, height: 200)
            }
        }
    }
    
    func setupGuideLineArea3() -> UIImageView {
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let resizableImage = (UIImage(named: "claims_left_front_door")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: previewView.frame.size.width, height: previewView.frame.size.height)
        cropImageRectCorner = [.allCorners]
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.contentMode = .scaleAspectFit //?
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }
    
    
// MARK: - LEFT Photo 4
    func previewViewLayerMode4(image: UIImage?, isCameraMode: Bool) {
        previewView.subviews.forEach({ $0.removeFromSuperview() })
        setupCameraPreview4()
        
        self.captureSession.startRunning()
        cameraActionView.isHidden = false
        choosePhotoActionView.isHidden = true
        previewView.isHidden = false
        capturedImageView.isHidden = true
    }
    
    func setupCameraPreview4() {
        let imageView = setupGuideLineArea4()
        if videoPreviewLayer == nil {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
        //videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        previewView.addSubview(imageView)
        cropImageRect = imageView.frame
        DispatchQueue.global(qos: .userInitiated).async {
            //self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
                
                let lbl = UILabel(frame: CGRect(x: 35, y: 0, width: 200, height: 30))
                lbl.addIconToLabel(imageName: "ic_info", labelText: "Left Rear Door", bounds_x: -5, bounds_y: -3, boundsWidth: 19, boundsHeight: 19)
                lbl.textAlignment = .center
                lbl.textColor = .lightGray
                lbl.font = UIFont.systemFont(ofSize: 17)
                lbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                self.previewView.addSubview(lbl)
                lbl.frame = CGRect(x: self.previewView.frame.size.width-40, y: -20, width: 30, height: 200)
            }
        }
    }
    
    func setupGuideLineArea4() -> UIImageView {
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let resizableImage = (UIImage(named: "claims_left_rear_door")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: previewView.frame.size.width, height: previewView.frame.size.height)
        cropImageRectCorner = [.allCorners]
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.contentMode = .scaleAspectFit //?
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }
    
    
// MARK: - LEFT Photo 5
    func previewViewLayerMode5(image: UIImage?, isCameraMode: Bool) {
        previewView.subviews.forEach({ $0.removeFromSuperview() })
        setupCameraPreview5()
        
        self.captureSession.startRunning()
        cameraActionView.isHidden = false
        choosePhotoActionView.isHidden = true
        previewView.isHidden = false
        capturedImageView.isHidden = true
    }
    
    func setupCameraPreview5() {
        let imageView = setupGuideLineArea5()
        if videoPreviewLayer == nil {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
        //videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        previewView.addSubview(imageView)
        cropImageRect = imageView.frame
        DispatchQueue.global(qos: .userInitiated).async {
            //self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
                
                let lbl = UILabel(frame: CGRect(x: 35, y: 0, width: 200, height: 30))
                lbl.addIconToLabel(imageName: "ic_info", labelText: "Left Rear Wing", bounds_x: -5, bounds_y: -3, boundsWidth: 19, boundsHeight: 19)
                lbl.textAlignment = .center
                lbl.textColor = .lightGray
                lbl.font = UIFont.systemFont(ofSize: 17)
                lbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                self.previewView.addSubview(lbl)
                lbl.frame = CGRect(x: self.previewView.frame.size.width-40, y: -20, width: 30, height: 200)
            }
        }
    }
    
    func setupGuideLineArea5() -> UIImageView {
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let resizableImage = (UIImage(named: "claims_left_rear_wing")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: previewView.frame.size.width, height: previewView.frame.size.height)
        cropImageRectCorner = [.allCorners]
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.contentMode = .scaleAspectFit //?
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }
    
    
// MARK: - RIGHT Photo 6
    func previewViewLayerMode6(image: UIImage?, isCameraMode: Bool) {
        previewView.subviews.forEach({ $0.removeFromSuperview() })
        setupCameraPreview6()
        
        self.captureSession.startRunning()
        cameraActionView.isHidden = false
        choosePhotoActionView.isHidden = true
        previewView.isHidden = false
        capturedImageView.isHidden = true
    }
    
    func setupCameraPreview6() {
        DispatchQueue.main.async {
            let imageView = self.setupGuideLineArea6()
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.videoPreviewLayer.videoGravity = .resizeAspectFill
            self.videoPreviewLayer.connection?.videoOrientation = .portrait
            self.previewView.layer.addSublayer(self.videoPreviewLayer)
            self.previewView.addSubview(imageView)
            self.cropImageRect = imageView.frame
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
                DispatchQueue.main.async {
                    self.videoPreviewLayer.frame = self.previewView.bounds
                    
                    let lbl = UILabel(frame: CGRect(x: 35, y: 0, width: 200, height: 30))
                    lbl.addIconToLabel(imageName: "ic_info", labelText: "Right All Side", bounds_x: -5, bounds_y: -3, boundsWidth: 19, boundsHeight: 19)
                    lbl.textAlignment = .center
                    lbl.textColor = .lightGray
                    lbl.font = UIFont.systemFont(ofSize: 17)
                    lbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                    self.previewView.addSubview(lbl)
                    lbl.frame = CGRect(x: self.previewView.frame.size.width-40, y: -20, width: 30, height: 200)
                }
            }
        }
    }
    
    func setupGuideLineArea6() -> UIImageView {
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let resizableImage = (UIImage(named: "claims_right_allside")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: previewView.frame.size.width, height: previewView.frame.size.height)
        cropImageRectCorner = [.allCorners]
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.contentMode = .scaleAspectFit //?
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }
    
    
// MARK: - RIGHT Photo 7
    func previewViewLayerMode7(image: UIImage?, isCameraMode: Bool) {
        previewView.subviews.forEach({ $0.removeFromSuperview() })
        setupCameraPreview7()
        
        self.captureSession.startRunning()
        cameraActionView.isHidden = false
        choosePhotoActionView.isHidden = true
        previewView.isHidden = false
        capturedImageView.isHidden = true
    }
    
    func setupCameraPreview7() {
        let imageView = setupGuideLineArea7()
        if videoPreviewLayer == nil {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        previewView.addSubview(imageView)
        cropImageRect = imageView.frame
        DispatchQueue.global(qos: .userInitiated).async {
            //self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
                
                let lbl = UILabel(frame: CGRect(x: 35, y: 0, width: 200, height: 30))
                lbl.addIconToLabel(imageName: "ic_info", labelText: "Right Front Wing", bounds_x: -5, bounds_y: -3, boundsWidth: 19, boundsHeight: 19)
                lbl.textAlignment = .center
                lbl.textColor = .lightGray
                lbl.font = UIFont.systemFont(ofSize: 17)
                lbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                self.previewView.addSubview(lbl)
                lbl.frame = CGRect(x: self.previewView.frame.size.width-40, y: -20, width: 30, height: 200)
            }
        }
    }
    
    func setupGuideLineArea7() -> UIImageView {
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let resizableImage = (UIImage(named: "claims_right_front_wing")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: previewView.frame.size.width, height: previewView.frame.size.height)
        cropImageRectCorner = [.allCorners]
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.contentMode = .scaleAspectFit //?
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }
    
// MARK: - RIGHT Photo 8
    func previewViewLayerMode8(image: UIImage?, isCameraMode: Bool) {
        previewView.subviews.forEach({ $0.removeFromSuperview() })
        setupCameraPreview8()
        
        self.captureSession.startRunning()
        cameraActionView.isHidden = false
        choosePhotoActionView.isHidden = true
        previewView.isHidden = false
        capturedImageView.isHidden = true
    }
    
    func setupCameraPreview8() {
        let imageView = setupGuideLineArea8()
        if videoPreviewLayer == nil {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        previewView.addSubview(imageView)
        cropImageRect = imageView.frame
        DispatchQueue.global(qos: .userInitiated).async {
            //self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
                
                let lbl = UILabel(frame: CGRect(x: 35, y: 0, width: 200, height: 30))
                lbl.addIconToLabel(imageName: "ic_info", labelText: "Right Front Door", bounds_x: -5, bounds_y: -3, boundsWidth: 19, boundsHeight: 19)
                lbl.textAlignment = .center
                lbl.textColor = .lightGray
                lbl.font = UIFont.systemFont(ofSize: 17)
                lbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                self.previewView.addSubview(lbl)
                lbl.frame = CGRect(x: self.previewView.frame.size.width-40, y: -20, width: 30, height: 200)
            }
        }
    }
    
    func setupGuideLineArea8() -> UIImageView {
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let resizableImage = (UIImage(named: "claims_right_front_door")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: previewView.frame.size.width, height: previewView.frame.size.height)
        cropImageRectCorner = [.allCorners]
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.contentMode = .scaleAspectFit //?
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }


// MARK: - RIGHT Photo 9
    func previewViewLayerMode9(image: UIImage?, isCameraMode: Bool) {
        previewView.subviews.forEach({ $0.removeFromSuperview() })
        setupCameraPreview9()
        
        self.captureSession.startRunning()
        cameraActionView.isHidden = false
        choosePhotoActionView.isHidden = true
        previewView.isHidden = false
        capturedImageView.isHidden = true
    }
    
    func setupCameraPreview9() {
        let imageView = setupGuideLineArea9()
        if videoPreviewLayer == nil {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        previewView.addSubview(imageView)
        cropImageRect = imageView.frame
        DispatchQueue.global(qos: .userInitiated).async {
            //self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
                
                let lbl = UILabel(frame: CGRect(x: 35, y: 0, width: 200, height: 30))
                lbl.addIconToLabel(imageName: "ic_info", labelText: "Right Rear Door", bounds_x: -5, bounds_y: -3, boundsWidth: 19, boundsHeight: 19)
                lbl.textAlignment = .center
                lbl.textColor = .lightGray
                lbl.font = UIFont.systemFont(ofSize: 17)
                lbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                self.previewView.addSubview(lbl)
                lbl.frame = CGRect(x: self.previewView.frame.size.width-40, y: -20, width: 30, height: 200)
            }
        }
    }
    
    func setupGuideLineArea9() -> UIImageView {
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let resizableImage = (UIImage(named: "claims_right_rear_door")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: previewView.frame.size.width, height: previewView.frame.size.height)
        cropImageRectCorner = [.allCorners]
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.contentMode = .scaleAspectFit //?
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }
    

// MARK: - RIGHT Photo 10
    func previewViewLayerMode10(image: UIImage?, isCameraMode: Bool) {
        previewView.subviews.forEach({ $0.removeFromSuperview() })
        setupCameraPreview10()
        
        self.captureSession.startRunning()
        cameraActionView.isHidden = false
        choosePhotoActionView.isHidden = true
        previewView.isHidden = false
        capturedImageView.isHidden = true
    }
    
    func setupCameraPreview10() {
        let imageView = setupGuideLineArea10()
        if videoPreviewLayer == nil {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        previewView.addSubview(imageView)
        cropImageRect = imageView.frame
        DispatchQueue.global(qos: .userInitiated).async {
            //self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
                
                let lbl = UILabel(frame: CGRect(x: 35, y: 0, width: 200, height: 30))
                lbl.addIconToLabel(imageName: "ic_info", labelText: "Right Rear Wing", bounds_x: -5, bounds_y: -3, boundsWidth: 19, boundsHeight: 19)
                lbl.textAlignment = .center
                lbl.textColor = .lightGray
                lbl.font = UIFont.systemFont(ofSize: 17)
                lbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                self.previewView.addSubview(lbl)
                lbl.frame = CGRect(x: self.previewView.frame.size.width-40, y: -20, width: 30, height: 200)
            }
        }
    }
    
    func setupGuideLineArea10() -> UIImageView {
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let resizableImage = (UIImage(named: "claims_right_rear_wing")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: previewView.frame.size.width, height: previewView.frame.size.height)
        cropImageRectCorner = [.allCorners]
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.contentMode = .scaleAspectFit //?
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }
    
    
// MARK: - REAR Photo 11
    func previewViewLayerMode11(image: UIImage?, isCameraMode: Bool) {
        previewView.subviews.forEach({ $0.removeFromSuperview() })
        setupCameraPreview11()
        
        self.captureSession.startRunning()
        cameraActionView.isHidden = false
        choosePhotoActionView.isHidden = true
        previewView.isHidden = false
        capturedImageView.isHidden = true
    }
    
    func setupCameraPreview11() {
        let imageView = self.setupGuideLineArea11()
        if videoPreviewLayer == nil {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
        //self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.videoPreviewLayer.videoGravity = .resizeAspectFill
        self.videoPreviewLayer.connection?.videoOrientation = .portrait
        self.previewView.layer.addSublayer(self.videoPreviewLayer)
        self.previewView.addSubview(imageView)
        self.cropImageRect = imageView.frame
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
                
                let lbl = UILabel(frame: CGRect(x: 35, y: 0, width: 200, height: 30))
                lbl.addIconToLabel(imageName: "ic_info", labelText: "Rear Left Diagonal", bounds_x: -5, bounds_y: -3, boundsWidth: 19, boundsHeight: 19)
                lbl.textAlignment = .center
                lbl.textColor = .lightGray
                lbl.font = UIFont.systemFont(ofSize: 17)
                lbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                self.previewView.addSubview(lbl)
                lbl.frame = CGRect(x: self.previewView.frame.size.width-40, y: -20, width: 30, height: 200)
            }
        }
    }
    
    func setupGuideLineArea11() -> UIImageView {
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let resizableImage = (UIImage(named: "claims_left_rear_diagonal")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: previewView.frame.size.width, height: previewView.frame.size.height)
        cropImageRectCorner = [.allCorners]
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.contentMode = .scaleAspectFit //?
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }
    
    
// MARK: - REAR Photo 12
    func previewViewLayerMode12(image: UIImage?, isCameraMode: Bool) {
        previewView.subviews.forEach({ $0.removeFromSuperview() })
        setupCameraPreview12()
        
        self.captureSession.startRunning()
        cameraActionView.isHidden = false
        choosePhotoActionView.isHidden = true
        previewView.isHidden = false
        capturedImageView.isHidden = true
    }
    
    func setupCameraPreview12() {
        let imageView = self.setupGuideLineArea12()
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.videoPreviewLayer.videoGravity = .resizeAspectFill
        self.videoPreviewLayer.connection?.videoOrientation = .portrait
        self.previewView.layer.addSublayer(self.videoPreviewLayer)
        self.previewView.addSubview(imageView)
        self.cropImageRect = imageView.frame
        DispatchQueue.global(qos: .userInitiated).async {
            //self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
                
                let lbl = UILabel(frame: CGRect(x: 35, y: 0, width: 200, height: 30))
                lbl.addIconToLabel(imageName: "ic_info", labelText: "Rear Side", bounds_x: -5, bounds_y: -3, boundsWidth: 19, boundsHeight: 19)
                lbl.textAlignment = .center
                lbl.textColor = .lightGray
                lbl.font = UIFont.systemFont(ofSize: 17)
                lbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                self.previewView.addSubview(lbl)
                lbl.frame = CGRect(x: self.previewView.frame.size.width-40, y: -20, width: 30, height: 200)
            }
        }
    }
    
    func setupGuideLineArea12() -> UIImageView {
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let resizableImage = (UIImage(named: "claims_car_backside")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: previewView.frame.size.width, height: previewView.frame.size.height)
        cropImageRectCorner = [.allCorners]
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.contentMode = .scaleAspectFit //?
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }
    
    
// MARK: - REAR Photo 13
    func previewViewLayerMode13(image: UIImage?, isCameraMode: Bool) {
        previewView.subviews.forEach({ $0.removeFromSuperview() })
        setupCameraPreview13()
        
        self.captureSession.startRunning()
        cameraActionView.isHidden = false
        choosePhotoActionView.isHidden = true
        previewView.isHidden = false
        capturedImageView.isHidden = true
    }
    
    func setupCameraPreview13() {
        let imageView = self.setupGuideLineArea13()
        if videoPreviewLayer == nil {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
        //self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.videoPreviewLayer.videoGravity = .resizeAspectFill
        self.videoPreviewLayer.connection?.videoOrientation = .portrait
        self.previewView.layer.addSublayer(self.videoPreviewLayer)
        self.previewView.addSubview(imageView)
        self.cropImageRect = imageView.frame
        DispatchQueue.global(qos: .userInitiated).async {
            //self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
                
                let lbl = UILabel(frame: CGRect(x: 35, y: 0, width: 200, height: 30))
                lbl.addIconToLabel(imageName: "ic_info", labelText: "Rear Right Diagonal", bounds_x: -5, bounds_y: -3, boundsWidth: 19, boundsHeight: 19)
                lbl.textAlignment = .center
                lbl.textColor = .lightGray
                lbl.font = UIFont.systemFont(ofSize: 17)
                lbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                self.previewView.addSubview(lbl)
                lbl.frame = CGRect(x: self.previewView.frame.size.width-40, y: -20, width: 30, height: 200)
            }
        }
    }
    
    func setupGuideLineArea13() -> UIImageView {
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let resizableImage = (UIImage(named: "claims_right_rear_diagonal")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: previewView.frame.size.width, height: previewView.frame.size.height)
        cropImageRectCorner = [.allCorners]
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.contentMode = .scaleAspectFit //?
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }
    

// MARK: - FRONT Photo 14
    func previewViewLayerMode14(image: UIImage?, isCameraMode: Bool) {
        previewView.subviews.forEach({ $0.removeFromSuperview() })
        setupCameraPreview14()
        
        self.captureSession.startRunning()
        cameraActionView.isHidden = false
        choosePhotoActionView.isHidden = true
        previewView.isHidden = false
        capturedImageView.isHidden = true
    }
    
    func setupCameraPreview14() {
        let imageView = self.setupGuideLineArea14()
        if videoPreviewLayer == nil {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
        //self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.videoPreviewLayer.videoGravity = .resizeAspectFill
        self.videoPreviewLayer.connection?.videoOrientation = .portrait
        self.previewView.layer.addSublayer(self.videoPreviewLayer)
        self.previewView.addSubview(imageView)
        self.cropImageRect = imageView.frame
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
                
                let lbl = UILabel(frame: CGRect(x: 35, y: 0, width: 200, height: 30))
                lbl.addIconToLabel(imageName: "ic_info", labelText: "Front Right Diagonal", bounds_x: -5, bounds_y: -3, boundsWidth: 19, boundsHeight: 19)
                lbl.textAlignment = .center
                lbl.textColor = .lightGray
                lbl.font = UIFont.systemFont(ofSize: 17)
                lbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                self.previewView.addSubview(lbl)
                lbl.frame = CGRect(x: self.previewView.frame.size.width-40, y: -20, width: 30, height: 200)
            }
        }
    }
    
    func setupGuideLineArea14() -> UIImageView {
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let resizableImage = (UIImage(named: "claims_right_front_diagonal")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: previewView.frame.size.width, height: previewView.frame.size.height)
        cropImageRectCorner = [.allCorners]
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.contentMode = .scaleAspectFit //?
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }
    
    
// MARK: - FRONT Photo 15
    func previewViewLayerMode15(image: UIImage?, isCameraMode: Bool) {
        previewView.subviews.forEach({ $0.removeFromSuperview() })
        setupCameraPreview15()
        
        self.captureSession.startRunning()
        cameraActionView.isHidden = false
        choosePhotoActionView.isHidden = true
        previewView.isHidden = false
        capturedImageView.isHidden = true
    }
    
    func setupCameraPreview15() {
        let imageView = self.setupGuideLineArea15()
        if videoPreviewLayer == nil {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
        //self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.videoPreviewLayer.videoGravity = .resizeAspectFill
        self.videoPreviewLayer.connection?.videoOrientation = .portrait
        self.previewView.layer.addSublayer(self.videoPreviewLayer)
        self.previewView.addSubview(imageView)
        self.cropImageRect = imageView.frame
        DispatchQueue.global(qos: .userInitiated).async {
            //self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
                
                let lbl = UILabel(frame: CGRect(x: 35, y: 0, width: 200, height: 30))
                lbl.addIconToLabel(imageName: "ic_info", labelText: "Front Side", bounds_x: -5, bounds_y: -3, boundsWidth: 19, boundsHeight: 19)
                lbl.textAlignment = .center
                lbl.textColor = .lightGray
                lbl.font = UIFont.systemFont(ofSize: 17)
                lbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                self.previewView.addSubview(lbl)
                lbl.frame = CGRect(x: self.previewView.frame.size.width-40, y: -20, width: 30, height: 200)
            }
        }
    }
    
    func setupGuideLineArea15() -> UIImageView {
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let resizableImage = (UIImage(named: "claims_car_frontside")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: previewView.frame.size.width, height: previewView.frame.size.height)
        cropImageRectCorner = [.allCorners]
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.contentMode = .scaleAspectFit //?
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }
    
    
// MARK: - FRONT Photo 16
    func previewViewLayerMode16(image: UIImage?, isCameraMode: Bool) {
        previewView.subviews.forEach({ $0.removeFromSuperview() })
        setupCameraPreview16()
        
        self.captureSession.startRunning()
        cameraActionView.isHidden = false
        choosePhotoActionView.isHidden = true
        previewView.isHidden = false
        capturedImageView.isHidden = true
    }
    
    func setupCameraPreview16() {
        let imageView = self.setupGuideLineArea16()
        if videoPreviewLayer == nil {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
        //self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.videoPreviewLayer.videoGravity = .resizeAspectFill
        self.videoPreviewLayer.connection?.videoOrientation = .portrait
        self.previewView.layer.addSublayer(self.videoPreviewLayer)
        self.previewView.addSubview(imageView)
        self.cropImageRect = imageView.frame
        DispatchQueue.global(qos: .userInitiated).async {
            //self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
                
                let lbl = UILabel(frame: CGRect(x: 35, y: 0, width: 200, height: 30))
                lbl.addIconToLabel(imageName: "ic_info", labelText: "Front Left Diagonal", bounds_x: -5, bounds_y: -3, boundsWidth: 19, boundsHeight: 19)
                lbl.textAlignment = .center
                lbl.textColor = .lightGray
                lbl.font = UIFont.systemFont(ofSize: 17)
                lbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                self.previewView.addSubview(lbl)
                lbl.frame = CGRect(x: self.previewView.frame.size.width-40, y: -20, width: 30, height: 200)
            }
        }
    }
    
    func setupGuideLineArea16() -> UIImageView {
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let resizableImage = (UIImage(named: "claims_left_front_diagonal")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: previewView.frame.size.width, height: previewView.frame.size.height)
        cropImageRectCorner = [.allCorners]
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.contentMode = .scaleAspectFit //?
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }
    
    
// MARK: - FRONT Photo 17
    func previewViewLayerMode17(image: UIImage?, isCameraMode: Bool) {
        previewView.subviews.forEach({ $0.removeFromSuperview() })
        setupCameraPreview17()
        
        self.captureSession.startRunning()
        cameraActionView.isHidden = false
        choosePhotoActionView.isHidden = true
        previewView.isHidden = false
        capturedImageView.isHidden = true
    }
    
    func setupCameraPreview17() {
        let imageView = setupGuideLineArea17()
        if videoPreviewLayer == nil {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        previewView.addSubview(imageView)
        cropImageRect = imageView.frame
        DispatchQueue.global(qos: .userInitiated).async {
            //self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
                
                let lbl = UILabel(frame: CGRect(x: 35, y: 0, width: 200, height: 30))
                lbl.addIconToLabel(imageName: "ic_info", labelText: "Windshield", bounds_x: -5, bounds_y: -3, boundsWidth: 19, boundsHeight: 19)
                lbl.textAlignment = .center
                lbl.textColor = .lightGray
                lbl.font = UIFont.systemFont(ofSize: 17)
                lbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                self.previewView.addSubview(lbl)
                lbl.frame = CGRect(x: self.previewView.frame.size.width-40, y: -20, width: 30, height: 200)
            }
        }
    }
    
    func setupGuideLineArea17() -> UIImageView {
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let resizableImage = (UIImage(named: "claims_car_windshield")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: previewView.frame.size.width, height: previewView.frame.size.height)
        cropImageRectCorner = [.allCorners]
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.contentMode = .scaleAspectFit //?
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }
    
    
// MARK: - FRONT Photo 18
    func previewViewLayerMode18(image: UIImage?, isCameraMode: Bool) {
        previewView.subviews.forEach({ $0.removeFromSuperview() })
        setupCameraPreview18()
        
        self.captureSession.startRunning()
        cameraActionView.isHidden = false
        choosePhotoActionView.isHidden = true
        previewView.isHidden = false
        capturedImageView.isHidden = true
    }
    
    func setupCameraPreview18() {
        let imageView = setupGuideLineArea18()
        if videoPreviewLayer == nil {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        previewView.addSubview(imageView)
        cropImageRect = imageView.frame
        DispatchQueue.global(qos: .userInitiated).async {
            //self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
                
                let lbl = UILabel(frame: CGRect(x: 35, y: 0, width: 200, height: 30))
                lbl.addIconToLabel(imageName: "ic_info", labelText: "Dashboard", bounds_x: -5, bounds_y: -3, boundsWidth: 19, boundsHeight: 19)
                lbl.textAlignment = .center
                lbl.textColor = .lightGray
                lbl.font = UIFont.systemFont(ofSize: 17)
                lbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                self.previewView.addSubview(lbl)
                lbl.frame = CGRect(x: self.previewView.frame.size.width-40, y: -20, width: 30, height: 200)
            }
        }
    }
    
    func setupGuideLineArea18() -> UIImageView {
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let resizableImage = (UIImage(named: "claims_car_dashboard")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: previewView.frame.size.width, height: previewView.frame.size.height)
        cropImageRectCorner = [.allCorners]
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.contentMode = .scaleAspectFit //?
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }
    
    
// MARK: - Additional
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (mFirstStart) {
            mFirstStart = false
            detectDeviceOrientation()
        }
    }
    
    @objc func detectDeviceOrientation() {
        if UIDevice.current.orientation.isLandscape {
            UIView.animate(withDuration: 0.4, delay : 0, options: .curveLinear , animations: {
                self.photoSaveButton.transform = CGAffineTransform(rotationAngle: CGFloat(360 * Float.pi * 3 / 180))
            }, completion : nil)
            
            let showTutorial = UserDefaults.standard.bool(forKey: "needClaimsTutorial")
            if showTutorial {
                tutorialView.isHidden = true
                carImg.isHidden = true
                lblSelectFromGallery.isHidden = true
            }
            
        } else {
            UIView.animate(withDuration: 0.5, delay : 0, options: .curveLinear , animations: {
                self.photoSaveButton.transform = CGAffineTransform(rotationAngle: CGFloat(90 * Float.pi * 3 / 180))
            }, completion : nil)
            
            let showTutorial = UserDefaults.standard.bool(forKey: "needClaimsTutorial")
            if showTutorial {
                tutorialView.isHidden = false
                carImg.isHidden = false
                lblSelectFromGallery.isHidden = false
                self.view.bringSubviewToFront(dismissCameraButton)
            }
        }
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        detectDeviceOrientation()
    }
}


extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        context.rotate(by: CGFloat(radians))
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}


extension UILabel {
    func addIconToLabel(imageName: String, labelText: String, bounds_x: Double, bounds_y: Double, boundsWidth: Double, boundsHeight: Double) {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: imageName)
        attachment.bounds = CGRect(x: bounds_x, y: bounds_y, width: boundsWidth, height: boundsHeight)
        let attachmentStr = NSAttributedString(attachment: attachment)
        let string = NSMutableAttributedString(string: "")
        string.append(attachmentStr)
        let stringTextAdd = NSMutableAttributedString(string: labelText)
        string.append(stringTextAdd)
        self.attributedText = string
    }
}
