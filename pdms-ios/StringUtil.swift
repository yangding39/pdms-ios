//
//  StringUtil.swift
//  pdms-ios
//
//  Created by IMEDS on 15-1-13.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//

import Foundation


class StringUtil {
    
    class func igonreNilString(str : String?) -> String {
        if let strString =  str {
            if strString.isEmpty {
                return " "
            } else {
                return strString
            }
        } else {
            return " "
        }
    }
}