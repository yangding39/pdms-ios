//
//  UserPasswordViewController.swift
//  pdms-ios
//
//  Created by HuLeehom on 12/15/14.
//  Copyright (c) 2014 unimedsci. All rights reserved.
//

import UIKit

class UserPasswordViewController: UITableViewController {
    
    @IBOutlet weak var loginNameText: UILabel!
    @IBOutlet weak var passwordConfirmText: UITextField!
    @IBOutlet weak var newPasswordText: UITextField!
    @IBOutlet weak var oldPasswordText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        loginNameText.text = LOGIN_USER.loginName
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    
    @IBAction func updatePassword(sender: AnyObject) {
        let newPassword = newPasswordText.text
        let passwordConfirm = passwordConfirmText.text
        if oldPasswordText.text.isEmpty {
            CustomAlertView.showMessage("原密码必填", parentViewController:self)
        } else if newPasswordText.text.isEmpty {
            CustomAlertView.showMessage("新密码必填", parentViewController:self)
        } else if count(newPasswordText.text) < 0 || count(newPasswordText.text) > 32 {
            CustomAlertView.showMessage("新密码必须是1-32个字符", parentViewController:self)
        } else if (newPassword != passwordConfirm) {
            CustomAlertView.showMessage("两次密码不一致", parentViewController:self)
        } else {
            self.updatePassword()
        }
    }
    
    
    func updatePassword() {
        let newPassword = newPasswordText.text
        let oldPassword = oldPasswordText.text
        let url = SERVER_DOMAIN + "user/password"
        let params : [String : AnyObject] = ["token" : TOKEN ,"oldPassword" : oldPassword, "newPassword" : newPassword]
        HttpApiClient.sharedInstance.save(url, paramters: params, loadingPosition: HttpApiClient.LOADING_POSTION.AFTER_TABLEVIEW, viewController: self, success: saveResult, fail: nil)
    }
    
    func saveResult(json : JSON) {
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
            self.navigationController?.popViewControllerAnimated(true)
        }
        
    }
}
