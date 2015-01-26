//
//  Visit.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-10.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//

import Foundation

class Visit {
    var id : Int!
    var typeLabel : String!
    var type : Int!
    var number : String!
    var departmentLabel : String!
    var department : Int!
    var mainDiagonse : String!
    var startTime : String!
    var endTime :  String!
    var patient : Patient!
    init() {
        
    }
    
    func generateDetail() -> String {
        var detailString = ""
        
        if let department = self.departmentLabel {
            detailString = "科室：\(self.departmentLabel)"
        }
        if let mainDiagonse = self.mainDiagonse {
            detailString += "      \(self.mainDiagonse)"
        }
        
        var timeText = "\n就诊时间："
        if let startTime =  self.startTime {
            timeText += startTime
        }
        
        if self.startTime != nil || self.endTime != nil {
            timeText += "~"
        }
        
        if let endTime = self.endTime {
            timeText += endTime
        }
        detailString += timeText
        return detailString
    }
}