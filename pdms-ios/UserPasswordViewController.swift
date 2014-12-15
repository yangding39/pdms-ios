//
//  UserPasswordViewController.swift
//  pdms-ios
//
//  Created by HuLeehom on 12/15/14.
//  Copyright (c) 2014 unimedsci. All rights reserved.
//

import UIKit

class UserPasswordViewController: UIViewController {
    @IBOutlet weak var passwordConfirmText: UITextField!
    @IBOutlet weak var newPasswordText: UITextField!
    @IBOutlet weak var oldPasswordText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func updatePassword(sender: AnyObject) {
        let newPassword = newPasswordText.text
        let passwordConfirm = passwordConfirmText.text
        if (newPassword != passwordConfirm) {
            println("Please confirm the password")
            let alert = UIAlertView()
            alert.title = "出错了"
            alert.message = "两次输入的密码不一致"
            alert.addButtonWithTitle("确定")
            alert.show()
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}
