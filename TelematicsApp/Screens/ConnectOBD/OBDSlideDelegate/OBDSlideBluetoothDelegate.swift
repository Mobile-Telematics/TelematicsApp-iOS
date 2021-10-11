//
//  OBDSlideBluetoothDelegate.swift
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.03.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

import UIKit

protocol OBDSlideConnectCtrlDelegate {
    func scrolledToPage(_ page: Int)
}

@IBDesignable

class OBDSlideBluetoothDelegate: UIView {
    
    var delegate: OBDSlideConnectCtrlDelegate?
    
    @IBInspectable var showPageControl: Bool = false {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var pageControlMaxItems: Int = 10 {
        didSet {
            setupView()
        }
    }
    
    var mainPageLabel = UILabel()
    
    var pageLabel = UILabel()
    var carouselScrollView: UIScrollView!
    var counter = 1
    
    var images = [UIImage]() {
        didSet {
            setupView()
        }
    }
    
    var pageControl = UIPageControl()
    
    var currentPage: Int! {
        return Int(round(carouselScrollView.contentOffset.x / self.bounds.width))
    }
    
    @IBInspectable var pageColor: UIColor? {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var currentPageColor: UIColor? {
        didSet {
            setupView()
        }
    }
    
    func setupView() {
        for view in subviews {
            view.removeFromSuperview()
        }
        
        carouselScrollView = UIScrollView(frame: bounds)
        carouselScrollView.showsHorizontalScrollIndicator = false
        
        addImages()
        
        if showPageControl {
            addPageControl()
            carouselScrollView.delegate = self
        }
    }
    
    func addImages() {
        carouselScrollView.isPagingEnabled = true
        carouselScrollView.contentSize = CGSize(width: bounds.width * CGFloat(images.count), height: bounds.height)
        if #available(iOS 11.0, *) {
            carouselScrollView.contentInsetAdjustmentBehavior = .never
        }
        
        for i in 0..<images.count {
            if i == 0 {
                
                let imageView = UIImageView(frame: CGRect(x: bounds.width * CGFloat(i), y: 0, width: bounds.width, height: bounds.height))
                imageView.image = images[i]
                imageView.contentMode = .scaleAspectFit
                imageView.layer.masksToBounds = true
                imageView.isUserInteractionEnabled = true
                carouselScrollView.addSubview(imageView)
                
                let mainLabel = UILabel(frame: CGRect(x: bounds.width * CGFloat(i), y: bounds.height - bounds.height/2 - bounds.height/3 - 20, width: bounds.width, height: 55))
                mainLabel.text = ""
                mainLabel.font = UIFont.boldSystemFont(ofSize: 23.0)
                mainLabel.numberOfLines = 0
                mainLabel.lineBreakMode = .byWordWrapping
                mainLabel.textAlignment = .center
                mainLabel.textColor = UIColor.green
                carouselScrollView.addSubview(mainLabel)
                
                let secondLabel = UILabel(frame: CGRect(x: bounds.width * CGFloat(i), y: bounds.height - bounds.height/2 - bounds.height/4 - 30, width: bounds.width, height: 55))
                secondLabel.text = "Prepare the Device for pairing"
                secondLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
                if Global.DeviceType.IS_IPHONE_4_OR_LESS || Global.DeviceType.IS_IPHONE_5 {
                    secondLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
                }
                secondLabel.numberOfLines = 0
                secondLabel.lineBreakMode = .byWordWrapping
                secondLabel.textAlignment = .center
                secondLabel.textColor = UIColor.darkGray
                carouselScrollView.addSubview(secondLabel)
                
                let thirdLabel = UILabel(frame: CGRect(x: bounds.width * CGFloat(i), y: bounds.height - bounds.height/2 - 190, width: bounds.width, height: 105))
                thirdLabel.text = "Make sure the Device is plugged into\nthe CAN Port."
                thirdLabel.font = UIFont.systemFont(ofSize: 16.0)
                if Global.DeviceType.IS_IPHONE_4_OR_LESS || Global.DeviceType.IS_IPHONE_5 {
                    thirdLabel.frame.origin = CGPoint(x: bounds.width * CGFloat(i), y: 150)
                    thirdLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.light)
                }
                thirdLabel.numberOfLines = 0
                thirdLabel.lineBreakMode = .byWordWrapping
                thirdLabel.textAlignment = .center
                thirdLabel.textColor = UIColor(rgb: 0x9a9a9a)
                carouselScrollView.addSubview(thirdLabel)
                
            } else if i == 1 {
                
                let imageView = UIImageView(frame: CGRect(x: bounds.width * CGFloat(i), y: 0, width: bounds.width, height: bounds.height))
                imageView.image = images[i]
                imageView.contentMode = .scaleAspectFit
                imageView.layer.masksToBounds = true
                imageView.isUserInteractionEnabled = true
                carouselScrollView.addSubview(imageView)
                
                let mainLabel = UILabel(frame: CGRect(x: bounds.width * CGFloat(i), y: bounds.height - bounds.height/2 - bounds.height/3 - 20, width: bounds.width, height: 55))
                mainLabel.text = ""
                mainLabel.font = UIFont.boldSystemFont(ofSize: 23.0)
                mainLabel.numberOfLines = 0
                mainLabel.lineBreakMode = .byWordWrapping
                mainLabel.textAlignment = .center
                mainLabel.textColor = UIColor.green
                carouselScrollView.addSubview(mainLabel)
                
                let secondLabel = UILabel(frame: CGRect(x: bounds.width * CGFloat(i), y: bounds.height - bounds.height/2 - bounds.height/4 - 30, width: bounds.width, height: 55))
                secondLabel.text = "Turn on Bluetooth"
                secondLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
                if Global.DeviceType.IS_IPHONE_4_OR_LESS || Global.DeviceType.IS_IPHONE_5 {
                    secondLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
                }
                secondLabel.numberOfLines = 0
                secondLabel.lineBreakMode = .byWordWrapping
                secondLabel.textAlignment = .center
                secondLabel.textColor = UIColor.darkGray
                carouselScrollView.addSubview(secondLabel)
                
                let thirdLabel = UILabel(frame: CGRect(x: bounds.width * CGFloat(i), y: bounds.height - bounds.height/2 - 190, width: bounds.width, height: 105))
                thirdLabel.text = "To continue, please enable Bluetooth in\nSettings or Control Centre on your phone."
                thirdLabel.font = UIFont.systemFont(ofSize: 16.0)
                if Global.DeviceType.IS_IPHONE_4_OR_LESS || Global.DeviceType.IS_IPHONE_5 {
                    thirdLabel.frame.origin = CGPoint(x: bounds.width * CGFloat(i), y: 150)
                    thirdLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.light)
                }
                thirdLabel.numberOfLines = 0
                thirdLabel.lineBreakMode = .byWordWrapping
                thirdLabel.textAlignment = .center
                thirdLabel.textColor = UIColor(rgb: 0x9a9a9a)
                carouselScrollView.addSubview(thirdLabel)
            }
        }
        
        self.addSubview(carouselScrollView)
    }
    
    func addPageControl() {
        if images.count <= pageControlMaxItems {
            pageControl.numberOfPages = images.count
            pageControl.sizeToFit()
            pageControl.currentPage = 0
            
            if Global.DeviceType.IS_IPHONE_X || Global.DeviceType.IS_IPHONE_13_PRO || Global.DeviceType.IS_IPHONE_XS_MAX || Global.DeviceType.IS_IPHONE_13_PROMAX {
                pageControl.center = CGPoint(x: self.center.x, y: bounds.height - pageControl.bounds.height/2 - 80)
            } else if Global.DeviceType.IS_IPHONE_8 || Global.DeviceType.IS_IPHONE_8P {
                pageControl.center = CGPoint(x: self.center.x, y: bounds.height - pageControl.bounds.height/2 - 52)
            } else if Global.DeviceType.IS_IPHONE_5 || Global.DeviceType.IS_IPHONE_4_OR_LESS {
                pageControl.center = CGPoint(x: self.center.x, y: bounds.height - pageControl.bounds.height/2 - 57)
            } else {
                pageControl.center = CGPoint(x: self.center.x, y: bounds.height - pageControl.bounds.height/2 - 87)
            }
            
            if let pageColor = self.pageColor {
                pageControl.pageIndicatorTintColor = pageColor
            }
            if let currentPageColor = self.currentPageColor {
                pageControl.currentPageIndicatorTintColor = currentPageColor
                pageControl.currentPageIndicatorTintColor = Color.officialMainAppColor()
            }
            
            self.addSubview(pageControl)
        } else {
            pageLabel.text = "1 / \(images.count)"
            pageLabel.font = UIFont.systemFont(ofSize: 10.0, weight: UIFont.Weight.light)
            pageLabel.frame.size = CGSize(width: 40, height: 20)
            pageLabel.textAlignment = .center
            pageLabel.layer.cornerRadius = 10
            pageLabel.layer.masksToBounds = true
            
            pageLabel.backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.3)
            pageLabel.textColor = UIColor.white
            pageLabel.center = CGPoint(x: self.center.x, y: bounds.height - pageLabel.bounds.height/2 - 8)
            
            self.addSubview(pageLabel)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupView()
    }
    
}

extension OBDSlideBluetoothDelegate: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = self.currentPage
        self.pageLabel.text = "\(self.currentPage+1) / \(images.count)"
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.delegate?.scrolledToPage(self.currentPage)
        self.counter = self.currentPage+1
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OnboardConnectChanged"), object: nil)
    }
    
}
