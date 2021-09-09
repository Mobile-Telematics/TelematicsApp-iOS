//
//  IconRightLabel.swift
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 19.01.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//


import UIKit

open class IconRightLabel: UILabel {
    
    public enum HorizontalPosition {
        case left
        case right
    }
    
    public enum VerticalPosition {
        case top
        case center
        case bottom
    }
    
    public typealias Position = (horizontal: HorizontalPosition, vertical: VerticalPosition)
    
    open var icon: UIImage? {
        didSet {
            if icon == nil {
                iconView?.removeFromSuperview()
            }
            setNeedsDisplay()
        }
    }
    
    open var iconPosition: Position = ( .left, .top )
    
    open var iconPadding: CGFloat = 0
    fileprivate var iconView: UIImageView?
    
    
    // MARK: - Custom text drawings

    open override func drawText(in rect: CGRect) {
        guard let text = self.text as NSString? else { return }
        guard let icon = icon else {
            super.drawText(in: rect)
            return
        }
        
        iconView?.removeFromSuperview()
        iconView = UIImageView(image: icon)

        var newRect = CGRect.zero
        let size = text.boundingRect(
            with: CGSize(
                width: frame.width - icon.size.width - iconPadding,
                height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [ .font : font! ],
            context: nil).size
        

        guard let iconView = iconView else { return }
        let iconYPosition = (frame.height - iconView.frame.height) / 2
        let height = frame.height

        if iconPosition.horizontal == .left {
            if textAlignment == .left {
                iconView.frame = iconView.frame.offsetBy(dx: 0, dy: iconYPosition)
                newRect = CGRect(
                    x: iconView.frame.width + iconPadding, y: 0,
                    width: frame.width - (iconView.frame.width + iconPadding), height: height)
            } else if textAlignment == .right {
                iconView.frame = iconView.frame.offsetBy(
                    dx: frame.width - size.width - iconView.frame.width - iconPadding,
                    dy: iconYPosition)
                newRect = CGRect(
                    x: frame.width - size.width - iconPadding, y: 0,
                    width: size.width + iconPadding, height: height)
            } else if textAlignment == .center {
                iconView.frame = iconView.frame.offsetBy(
                    dx: (frame.width - size.width) / 2 - iconPadding - iconView.frame.width,
                    dy: iconYPosition)
                newRect = CGRect(
                    x: (frame.width - size.width) / 2, y: 0,
                    width: size.width + iconPadding, height: height)
            }
        } else if iconPosition.horizontal == .right {
            if textAlignment == .left {
                iconView.frame = iconView.frame.offsetBy(
                    dx: size.width + iconPadding, dy: iconYPosition)
                newRect = CGRect(x: 0, y: 0, width: size.width, height: height)
            } else if textAlignment == .right {
                iconView.frame = iconView.frame.offsetBy(
                    dx: frame.width - iconView.frame.width, dy: iconYPosition)
                newRect = CGRect(
                    x: frame.width - size.width - iconView.frame.width - iconPadding, y: 0,
                    width: size.width, height: height)
            } else if textAlignment == .center {
                iconView.frame = iconView.frame.offsetBy(
                    dx: frame.width / 2 + size.width / 2 + iconPadding, dy: iconYPosition)
                newRect = CGRect(
                    x: (frame.width - size.width) / 2, y: 0,
                    width: size.width, height: height)
            }
        }

        switch iconPosition.vertical {
        case .top:
            iconView.frame.origin.y = (frame.height - size.height) / 2

        case .center:
            iconView.frame.origin.y = (frame.height - iconView.frame.height) / 2

        case .bottom:
            iconView.frame.origin.y = frame.height - (frame.height - size.height) / 2
                - iconView.frame.size.height
        }

        addSubview(iconView)
        super.drawText(in: newRect)
    }
}
