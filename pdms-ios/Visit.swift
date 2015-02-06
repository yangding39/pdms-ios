//
//  Visit.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-10.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//

import Foundation

class Visit {
    var id : NSNumber!
    var typeLabel : String!
    var type : NSNumber!
    var number : String!
    var departmentLabel : String!
    var department : NSNumber!
    var mainDiagonse : String!
    var startTime : String!
    var endTime :  String!
    var patient : Patient!
    init() {
        
    }
    
    func generateDetail() -> String {
        var detailString = ""
        
        if let number = self.number {
            detailString +=  "就诊号：\(self.number)"
        }
        if let department = self.departmentLabel {
            detailString += "\n科室：\(self.departmentLabel)"
        }
        if let mainDiagonse = self.mainDiagonse {
            detailString += "\n\(self.mainDiagonse)"
        }
        
        if let startTime =  self.startTime {
            detailString += "\n开始时间：" + startTime
        }
        
        if let endTime = self.endTime {
            if !endTime.isEmpty {
                 detailString += "\n结束时间：" + endTime
            }
        }
        
        return detailString
    }
}