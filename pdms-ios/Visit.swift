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
    
    func generateDetail() -> NSMutableAttributedString {
        var detailString : NSMutableAttributedString = NSMutableAttributedString()
        
        if let number = self.number {
            let tmpString = NSMutableAttributedString(string: "就诊号:    \(self.number)")
            tmpString.addAttribute(NSForegroundColorAttributeName, value: UIColor.columnColor(), range: NSMakeRange(0, 4))
            detailString.appendAttributedString(tmpString)
        }
        if let department = self.departmentLabel {
            let tmpString = NSMutableAttributedString(string: "\n科室:       \(self.departmentLabel)")
            tmpString.addAttribute(NSForegroundColorAttributeName, value: UIColor.columnColor(), range: NSMakeRange(0, 3))
            detailString.appendAttributedString(tmpString)
        }
        if let mainDiagonse = self.mainDiagonse {
            let tmpString = NSMutableAttributedString(string: "\n\(self.mainDiagonse)")
            tmpString.addAttribute(NSForegroundColorAttributeName, value: UIColor.columnColor(), range: NSMakeRange(0, 5))
            detailString.appendAttributedString(tmpString)
        }
        
        if let startTime =  self.startTime {
            let tmpString = NSMutableAttributedString(string: "\n开始时间:" + startTime)
            tmpString.addAttribute(NSForegroundColorAttributeName, value: UIColor.columnColor(), range: NSMakeRange(0, 5))
            detailString.appendAttributedString(tmpString)
        }
        
        if let endTime = self.endTime {
            if !endTime.isEmpty {
                let tmpString = NSMutableAttributedString(string: "\n结束时间:" + endTime)
                tmpString.addAttribute(NSForegroundColorAttributeName, value: UIColor.columnColor(), range: NSMakeRange(0, 5))
                detailString.appendAttributedString(tmpString)
            }
        }
        
        return detailString
    }
    
    func setVisitMainDiagnose(fieldDatas : Array<Data>, mainDiagnose : String) {
        for data in fieldDatas {
            if data.definitionId == Data.DefinitionId.DIAG_MAIN {
                if self.mainDiagonse == nil || self.mainDiagonse.isEmpty {
                    self.mainDiagonse = "疾病诊断：\(mainDiagnose)"
                } else {
                    if data.value.toInt() == Data.BoolIntValue.TRUE {
                        self.mainDiagonse = "疾病诊断：\(mainDiagnose)"
                    }
                }
                break;
            }
        }
    }
}