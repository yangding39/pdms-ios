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
    
    func generateDetail() -> String {
        var detailString = ""
        
        if let gender = self.gender {
            detailString += self.gender
        }
        if let age = self.age {
            detailString += "   年龄：\(self.age)   "
        }
        if let birthday = self.birthday {
            detailString += "出生日期：" + self.birthday
        }
        if let caseNo = self.caseNo {
            if !caseNo.isEmpty {
                detailString += "\n病案号：\(caseNo)"
            }
        }
        return detailString
    }
}