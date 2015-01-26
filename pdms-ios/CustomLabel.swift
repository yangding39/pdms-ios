//
//  CustomLabel.swift
//  pdms-ios
//
//  Created by IMEDS on 15-1-24.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//

import Foundation

extension UILabel {
    
    class func heightForDynamicText(str : String, font : UIFont, width : CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.font = font
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.text = str
        label.sizeToFit()
        return label.frame.height
    }
}