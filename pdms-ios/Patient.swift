//
//  Patient.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-5.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//

import Foundation
class Patient {
    var id : NSNumber!
    var name : String!
    var gender : String!
    var age : Int!
    var birthday : String!
    var caseNo : String!
    init() {
        
    }
    
    func generateDetail() -> NSMutableAttributedString {
        let detailString : NSMutableAttributedString = NSMutableAttributedString()
        
        if let gender = self.gender {
            let tmpString = NSMutableAttributedString(string: "性别：\(self.gender)       ")
            tmpString.addAttribute(NSForegroundColorAttributeName, value: UIColor.columnColor(), range: NSMakeRange(0, 3))
            detailString.appendAttributedString(tmpString)
        }
        if let age = self.age {
            let tmpString = NSMutableAttributedString(string: "年龄：\(self.age)")
            tmpString.addAttribute(NSForegroundColorAttributeName, value: UIColor.columnColor(), range: NSMakeRange(0, 3))
            detailString.appendAttributedString(tmpString)
        }
        if let birthday = self.birthday {
            let tmpString = NSMutableAttributedString(string: "\n出生日期：" + self.birthday + "     ")
            tmpString.addAttribute(NSForegroundColorAttributeName, value: UIColor.columnColor(), range: NSMakeRange(0, 5))
            detailString.appendAttributedString(tmpString)
        }
        if let caseNo = self.caseNo {
            if !caseNo.isEmpty {
                let tmpString = NSMutableAttributedString(string: "病案号：\(caseNo)")
                tmpString.addAttribute(NSForegroundColorAttributeName, value: UIColor.columnColor(), range: NSMakeRange(0, 4))
                detailString.appendAttributedString(tmpString)
            }
        }
        return detailString
    }
}