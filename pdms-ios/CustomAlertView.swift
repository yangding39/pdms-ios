//
//  CustomAlertView.swift
//  pdms-ios
//
//  Created by IMEDS on 15-1-26.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//

import UIKit

class CustomAlertView {
    class func showMessage(message : String, parentViewController : UIViewController) {
        if !message.isEmpty {
            if NSClassFromString("UIAlertController") != nil {
                let alertController = UIAlertController(title: "出错了", message: message, preferredStyle: .Alert)
                parentViewController.presentViewController(alertController, animated: true, completion: nil)
                let cancelAction = UIAlertAction(title: "确定", style: .Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                })
                alertController.addAction(cancelAction)
            } else {
                let alert = UIAlertView()
                alert.title = "出错了"
                alert.message = message
                alert.addButtonWithTitle("确定")
                alert.show()
            }
        }
    }
}
