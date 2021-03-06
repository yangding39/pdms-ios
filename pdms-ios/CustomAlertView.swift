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
                let alertController = UIAlertController(title: "提示", message: message, preferredStyle: .Alert)
                parentViewController.presentViewController(alertController, animated: true, completion: nil)
                let cancelAction = UIAlertAction(title: "确定", style: .Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                })
                alertController.addAction(cancelAction)
            } else {
                let alert = UIAlertView()
                alert.title = "提示"
                alert.message = message
                alert.addButtonWithTitle("确定")
                alert.show()
            }
        }
    }
    
    class func showDialog(message : String, parentViewController : UIViewController,okFunc : (() -> Void)!, cancelFunc :(() -> Void)!) {
        if !message.isEmpty {
            if NSClassFromString("UIAlertController") != nil {
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                parentViewController.presentViewController(alertController, animated: true, completion: nil)
                let okAction = UIAlertAction(title: "确定", style: .Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    if okFunc != nil {
                        okFunc()
                    }
                })
                let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                    if cancelFunc != nil {
                        cancelFunc()
                    }
                })
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
            } else {
                let alert = UIAlertView()
                alert.message = message
                alert.addButtonWithTitle("确定")
                alert.addButtonWithTitle("取消")
                alert.delegate = parentViewController
                alert.show()
            }
        }
    }
}
