//
//  CustomColor.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-17.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//

import UIKit

extension UIColor {
     class func appColor() -> UIColor {
        return UIColor(red: 83.0/255, green: 163.0/255, blue: 221.0/255, alpha: 1.0)
    }
    
    class func sectionColor() -> UIColor {
        return UIColor(red: 55.0/255, green: 148.0/255, blue: 217.0/255, alpha: 1.0)
    }
    
    class func columnColor() -> UIColor {
        return UIColor(red: 155.0/255, green: 155.0/255, blue: 155.0/255, alpha: 1.0)
    }
    class func valueColor() -> UIColor {
        return UIColor(red: 78.0/255, green: 78.0/255, blue: 78.0/255, alpha: 1.0)
    }
    class func sectionHeaderColor() -> UIColor {
        return UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1.0)
    }
    class func sectionTextColor() -> UIColor {
        return UIColor(red: 100.0/255, green: 100.0/255, blue: 100.0/255, alpha: 1.0)
    }
}
