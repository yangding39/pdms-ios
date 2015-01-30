//
//  LoginTableViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 15-1-22.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//


import UIKit

class LoginTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
//        if let backgroundImage = UIImage(named: "user-bg") {
//            let backgroundView = UIImageView(image: backgroundImage)
//            backgroundView.frame = self.tableView.frame
//            self.tableView.backgroundView = backgroundView
//        }
//        
        if var frame = self.tableView.tableHeaderView?.frame {
            frame.size.height = self.tableView.bounds.width / 400 * 190
            self.tableView.tableHeaderView?.frame = frame
        }
        
        if var frame = self.tableView.tableFooterView?.frame {
            frame.size.height = 44
            self.tableView.tableFooterView?.frame = frame
        }
        self.tableView.updateConstraintsIfNeeded()
        userNameTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    @IBAction func didLoginBtn(sender: AnyObject) {
        userNameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        self.login()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.login()
        return true
    }
    func login() {
        let name = userNameTextField.text
        let password = passwordTextField.text
        if !name.isEmpty && !password.isEmpty {
            let url = SERVER_DOMAIN + "user/login"
            let params : [String : AnyObject] = ["name" : name, "password" : password]
            HttpApiClient.sharedInstance.save(url, paramters: params, loadingPosition: HttpApiClient.LOADING_POSTION.AFTER_TABLEVIEW, viewController: self, success: loginResult, fail: nil)
        }
        
    }
    
    func loginResult(json : JSON) {
        var fieldErrors = Array<String>()
        var saveResult = false
        //set result and error from server
        saveResult = (json["stat"].int == 0 )
        for (index: String, errorJson: JSON) in json["fieldErrors"] {
            if let error = errorJson["message"].string {
                fieldErrors.append(error)
            }
        }
        if saveResult && fieldErrors.count == 0 {
            let user = User()
            if let id = json["data"]["id"].number {
                user.id = id
            }
            if let name = json["data"]["userName"].string {
                user.name = name
            }
            if let hospital = json["data"]["companyName"].string {
                user.hospital = hospital
            }
            if let department = json["data"]["organizationName"].string {
                user.department = department
            }
            LOGIN_USER = user
            if let token = json["data"]["token"].string {
                TOKEN = token
                self.dismissViewControllerAnimated(true, completion: nil)
            }
           
        }
        
    }
    
}

