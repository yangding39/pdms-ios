//
//  FieldData.swift
//  pdms-ios
//
//  Created by IMEDS on 15-1-4.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//

import Foundation

class Data {
    struct ColumnType {
        static let NUMBER = 1  //数字
        static let TEXT = 2 //文本
        static let LEVEL = 3 //分级
        static let DICITIONARY = 4 //选项
        static let DATE = 5 //日期
    }
    
    struct VisibleType {
        static let INPUT = 0 //输入框
        static let SELECT = 1 //下拉列表
        static let RADIO = 2 //单选框
        static let CHECKBOX = 3 //多选框
        static let TIME = 4 //日期控件
        static let DERAIL = 5 //开关控件
        static let TEXT = 6 //不可编辑文本
    }
    
    struct BoolIntValue {
        static let FALSE = 0
        static let TRUE = 1
    }
    
    struct DefinitionId {
        static let DIAG_DATE = -1
        static let DIAG_MAIN = -2
    }
    var id : NSNumber!
    var definitionId : NSNumber!
    var columnName : String!
    var value : String!
    var columnType : Int!
    var isRequired : Bool!
    var visibleType :  Int!
    var unitName : String!
    var isDrug : Bool!
    var isValid : Bool!

    init(){
        
    }
    
    class func generateCheckTime(crowDefinition : GroupDefinition) -> Data?{
        let dDate = Data()
        dDate.definitionId = Data.DefinitionId.DIAG_DATE
        dDate.columnName = "诊断日期"
        dDate.value = ""
        dDate.columnType = Data.ColumnType.DATE
        dDate.isRequired = true
        dDate.visibleType = Data.VisibleType.TIME
        dDate.unitName = nil
        dDate.isDrug = false
        dDate.isValid = false
        let crowName = crowDefinition.name
        if crowName == "个人史" || crowName == "遗传家族史" || crowName == "药物治疗"{
            return nil
        } else if crowName == "疾病诊断" || crowName == "症状体征" {
            dDate.columnName = "诊断日期"
        } else if crowName == "体格检查" || crowName == "实验室检查" || crowName == "辅助检查"{
            dDate.columnName = "检查时间"
        } else if crowName == "治疗操作" {
            dDate.columnName = "操作时间"
        }
        return dDate
    }
}