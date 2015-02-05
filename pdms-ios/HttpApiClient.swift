//
//  HttpApiClient.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-9.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//

import Foundation

private let _HttpApiClient = HttpApiClient()
class HttpApiClient {
    struct LOADING_POSTION {
      static let NAIGATIONBAR = 0
      static let FULL_SRCEEN = 1
      static let AFTER_TABLEVIEW = 2
    }
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
    func getLoading(url : String, paramters: Dictionary<String,AnyObject>!, loadingPosition: Int, viewController : UIViewController, success : (JSON) -> Void, fail :(() -> Void)!) {
        var completeView : AnyObject!
        var activityIndicator : UIActivityIndicatorView!
        showLoadingIndicator(loadingPosition, viewController: viewController, activityIndicator: &activityIndicator, replacedView: &completeView)
        
        let manager = AFHTTPRequestOperationManager()
        manager.GET(url,
            parameters:paramters,
            success: {(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let json = JSON(responseObject)
                success(json)
                self.dismissLoadingIndicator(loadingPosition, activityIndicator: activityIndicator, viewController: viewController, completeView: completeView)
            },
            failure: {(operation: AFHTTPRequestOperation!, error: NSError!) in
                
                var statusCode : StatusCode?
                if let response = operation.response {
                    statusCode = StatusCode(httpCode: response.statusCode)
                }
                
                if statusCode == StatusCode.STATUS_NO_AUTH {
                    self.showLoginView(viewController)
                } else {
                    if statusCode == StatusCode.STATUS_ERROR {
                        CustomAlertView.showMessage(" 无法连接服务器", parentViewController:viewController)
                    } else if error != nil {
                        CustomAlertView.showMessage(" 无法连接服务器", parentViewController:viewController)
                    }
                    if (fail != nil) {
                        fail()
                    }
                }
               
                self.dismissLoadingIndicator(loadingPosition, activityIndicator: activityIndicator, viewController: viewController, completeView: completeView)
            }
        )
    }
    func save(url : String, paramters: Dictionary<String,AnyObject>!, loadingPosition: Int, viewController : UIViewController, success : (JSON) -> Void, fail :(() -> Void)!) {
        var completeView : AnyObject!
        var activityIndicator : UIActivityIndicatorView!
        showLoadingIndicator(loadingPosition, viewController: viewController, activityIndicator: &activityIndicator, replacedView: &completeView)
        
        let manager = AFHTTPRequestOperationManager()
        manager.POST(url,
            parameters:paramters,
            success: {(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let json = JSON(responseObject)
                var fieldErrors = Array<String>()
                for (index: String, errorJson: JSON) in json["fieldErrors"] {
                    if let error = errorJson["message"].string {
                        fieldErrors.append(error)
                    }
                }
                let message =  ";".join(fieldErrors)
                CustomAlertView.showMessage(message, parentViewController:viewController)
                
                success(json)
                self.dismissLoadingIndicator(loadingPosition, activityIndicator: activityIndicator, viewController: viewController, completeView: completeView)
            },
            failure: {(operation: AFHTTPRequestOperation!, error: NSError!) in
                var statusCode : StatusCode?
                if let response = operation.response {
                    statusCode = StatusCode(httpCode: response.statusCode)
                }
                if statusCode == StatusCode.STATUS_NO_AUTH {
                    self.showLoginView(viewController)
                } else {
                    if statusCode == StatusCode.STATUS_ERROR {
                        CustomAlertView.showMessage(" 无法连接服务器", parentViewController:viewController)
                    } else if error != nil {
                        CustomAlertView.showMessage(" 无法连接服务器", parentViewController:viewController)
                    }
                    if (fail != nil) {
                        fail()
                    }
                }
                self.dismissLoadingIndicator(loadingPosition, activityIndicator: activityIndicator, viewController: viewController, completeView: completeView)
            }
        )
        
    }
    
    func showLoadingIndicator(loadingPosition : Int, viewController : UIViewController, inout activityIndicator : UIActivityIndicatorView!, inout replacedView : AnyObject!) {
        if loadingPosition == LOADING_POSTION.NAIGATIONBAR {
            if let navigationItem = viewController.navigationItem as UINavigationItem? {
                replacedView = navigationItem.rightBarButtonItem!
                activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 20, 20))
                activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                let loadingBtton = UIBarButtonItem(customView: activityIndicator)
                navigationItem.rightBarButtonItem = loadingBtton
                activityIndicator.startAnimating()
            }
        } else if loadingPosition == LOADING_POSTION.FULL_SRCEEN {
            if let view = viewController.view {
               activityIndicator = UIActivityIndicatorView(frame: view.bounds)
                activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
                activityIndicator.center = view.center
                let color = UIColor.grayColor()
                let backgroupColor = color.colorWithAlphaComponent(0.3)
                activityIndicator.backgroundColor = backgroupColor
                activityIndicator.startAnimating()
                view.addSubview(activityIndicator)
            }
        } else if loadingPosition == LOADING_POSTION.AFTER_TABLEVIEW {
            if let tableViewController = viewController as? UITableViewController {
                let tableView = tableViewController.tableView
                //let loadingView = UIView(frame: CGRectMake(0, 0, tableView.bounds.width, 40))
                activityIndicator = UIActivityIndicatorView(frame : tableViewController.view.bounds)
                activityIndicator.center = tableViewController.view.center
                activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                activityIndicator.startAnimating()
                //loadingView.addSubview(activityIndicator)
                tableViewController.view.addSubview(activityIndicator)
                //replacedView = loadingView
            }
        }

    }
    func dismissLoadingIndicator(loadingPosition : Int, activityIndicator : UIActivityIndicatorView, viewController : UIViewController, completeView : AnyObject?) {
//        let delay = 0.5 * Double(NSEC_PER_SEC)
//        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//        dispatch_after(time, dispatch_get_main_queue(), {
//            
//        })
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        if loadingPosition == LOADING_POSTION.NAIGATIONBAR {
            if let navigationItem = viewController.navigationItem as UINavigationItem? {
                if let rightbarItem = completeView as? UIBarButtonItem {
                    navigationItem.rightBarButtonItem = rightbarItem
                }
            }
        } else if loadingPosition == LOADING_POSTION.FULL_SRCEEN {
            if let view = viewController.view {
                activityIndicator.removeFromSuperview()
            }
        } else if loadingPosition == LOADING_POSTION.AFTER_TABLEVIEW {
            if let tableViewController = viewController as? UITableViewController {
                
            }
        }
    }
    
    func showLoginView(viewController : UIViewController) {
            let loginViewController = viewController.storyboard?.instantiateViewControllerWithIdentifier("loginTableViewController") as LoginTableViewController
            viewController.presentViewController(loginViewController, animated: true, completion: nil)
    }
}
