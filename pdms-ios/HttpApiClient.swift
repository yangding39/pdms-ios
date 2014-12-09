//
//  HttpApiClient.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-9.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//

import Foundation

let _HttpApiClient = HttpApiClient()
class HttpApiClient {
    class var sharedInstance : HttpApiClient {
        return _HttpApiClient
    }
    
    func get(url : String, paramters: Dictionary<String,AnyObject>!, success : (JSON) -> Void, fail :(() -> Void)!) {
        let manager = AFHTTPRequestOperationManager()
        manager.GET(url,
            parameters:paramters,
            success: {(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let json = JSON(responseObject)
                success(json)
            },
            failure: {(operation: AFHTTPRequestOperation!, error: NSError!) in
                if (fail != nil) {
                    fail()
                }
            }
        )

    }
    func post(url : String, paramters: Dictionary<String,AnyObject>!, success : (JSON) -> Void, fail :(() -> Void)!) {
        let manager = AFHTTPRequestOperationManager()
        manager.POST(url,
            parameters:paramters,
            success: {(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let json = JSON(responseObject)
                success(json)
            },
            failure: {(operation: AFHTTPRequestOperation!, error: NSError!) in
                if (fail != nil) {
                    fail()
                }
            }
        )
        
    }
}
