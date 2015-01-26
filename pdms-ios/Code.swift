//
//  StatusCode.swift
//  
//
//  Created by IMEDS on 14-12-4.
//
//

import Foundation
import UIKit

enum StatusCode: Int {
    case STATUS_OK = 200
    case STATUS_ERROR = 404
    case STATUS_NO_AUTH = 403
    init(httpCode : Int) {
        switch httpCode {
        case STATUS_OK.rawValue :
            self = STATUS_OK
        case STATUS_ERROR.rawValue :
            self = STATUS_ERROR
        case STATUS_NO_AUTH.rawValue :
            self = STATUS_NO_AUTH
        default :
            self = STATUS_OK
        }
      
    }
    var decription: String {
        get{
            switch self{
            case STATUS_OK :
                return "链接成功"
            case STATUS_ERROR :
                 return "网络异常"
            case STATUS_NO_AUTH :
                return "未登录"
            default :
                return "链接成功"
            }
        }
    }
}
