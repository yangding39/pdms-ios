//
//  GroupDefinition.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-12.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//

class GroupDefinition {
    struct TYPE {
        static let PARENT = 0  //父类
        static let TEXT = 1  //文本
        static let QUOTA = 2  //指标
        static let DRUG = 3  //药物
    }
    var id : Int!
    var name : String!
    var type : Int!
    var quota  = Array<Quota>()

    init() {
        
    }
}