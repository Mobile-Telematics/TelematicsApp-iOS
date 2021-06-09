//
//  OBDCell.swift
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 26.03.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

import UIKit

class OBDCell: UITableViewCell {

    @IBOutlet weak var carName: UILabel!
    @IBOutlet weak var carCentralName: UILabel!
    @IBOutlet weak var carConnectionStatus: UILabel!
    @IBOutlet weak var carStatus: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let screenSize = UIScreen.main.bounds
        let separatorHeight = CGFloat(2.0)
        let additionalSeparator = UIView.init(frame: CGRect(x: 0, y: self.frame.size.height+separatorHeight, width: screenSize.width, height: separatorHeight))
        self.addSubview(additionalSeparator)
    }
}
