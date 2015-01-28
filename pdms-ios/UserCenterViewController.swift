//
//  UserCenterViewController.swift
//  pdms-ios
//
//  Created by HuLeehom on 12/12/14.
//  Copyright (c) 2014 unimedsci. All rights reserved.
//

import UIKit

class UserCenterViewController: UITableViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hospitalLabel: UILabel!
    override func viewDidLoad() {
        
        let backgroundImage = UIImage(named: "user-bg")
        let backgroundView = UIImageView(image: backgroundImage)
        backgroundView.frame = self.tableView.frame
        self.tableView.backgroundView = backgroundView
        
        if var frame = self.tableView.tableHeaderView?.frame {
             frame.size.height = UIScreen.mainScreen().bounds.size.width/400 * 120
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
        self.hospitalLabel.text = user.hospital + "  " + user.department
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    @IBAction func didLogoutBtn(sender: AnyObject) {
        logout()
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
            let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("loginTableViewController") as LoginTableViewController
            self.presentViewController(loginViewController, animated: true, completion: nil)
        }
        
    }
}