//
//  UserCenterViewController.swift
//  pdms-ios
//
//  Created by HuLeehom on 12/12/14.
//  Copyright (c) 2014 unimedsci. All rights reserved.
//

import UIKit
import CoreData

class UserCenterViewController: UITableViewController,UIAlertViewDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hospitalLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    let managedObectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    override func viewDidLoad() {
        
//        let backgroundImage = UIImage(named: "user-bg")
//        let backgroundView = UIImageView(image: backgroundImage)
//        backgroundView.frame = self.tableView.frame
//        self.tableView.backgroundView = backgroundView
        
        if var frame = self.tableView.tableHeaderView?.frame {
             frame.size.height = UIScreen.mainScreen().bounds.size.width/400 * 145
             self.tableView.tableHeaderView?.frame = frame
            self.tableView.updateConstraintsIfNeeded()
        }
       
        if var frame = self.tableView.tableFooterView?.frame {
            frame.size.height = 44
            self.tableView.tableFooterView?.frame = frame
            self.tableView.updateConstraintsIfNeeded()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        var user = LOGIN_USER
        self.nameLabel.text = user.name
        self.hospitalLabel.text = user.hospital
        self.hospitalLabel.adjustsFontSizeToFitWidth = true
        self.departmentLabel.text = user.department
        self.departmentLabel.adjustsFontSizeToFitWidth = true
    }
    
    
    @IBAction func didLogoutBtn(sender: AnyObject) {
        CustomAlertView.showDialog("确定退出登录？", parentViewController: self, okFunc: logout, cancelFunc: nil)
    }
    
    func logout() {
        let url = SERVER_DOMAIN + "user/logout"
        let params : [String : AnyObject] = ["token" : TOKEN ]
        HttpApiClient.sharedInstance.save(url, paramters: params, loadingPosition: HttpApiClient.LOADING_POSTION.AFTER_TABLEVIEW, viewController: self, success: logoutResult, fail: nil)
    }
    
    func logoutResult(json : JSON) {
        var fieldErrors = Array<String>()
        var saveResult = false
        //set result and error from server
        saveResult = (json["stat"].int == 0 )
        for (index: String, errorJson: JSON) in json["fieldErrors"] {
            if let error = errorJson[index].string {
                fieldErrors.append(error)
            }
        }
        if saveResult && fieldErrors.count == 0 {
            TOKEN = ""
            deleteUserFromLocal()
            let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("loginTableViewController")as! LoginTableViewController
            self.presentViewController(loginViewController, animated: true, completion: nil)
        }
        
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            self.logout()
        }
    }
    
    func deleteUserFromLocal() {
        let fetchRequest = NSFetchRequest(entityName:"UserLocal")
        let predicate = NSPredicate(format: "loginName == %@", LOGIN_USER.loginName)
        fetchRequest.predicate = predicate
        if let fetchResult = self.managedObectContext?.executeFetchRequest(fetchRequest, error: nil) as? [UserLocal] {
            for user in fetchResult {
                user.isLogined = false
                user.token = ""
                self.managedObectContext?.save(nil)            }
        }
    }
}