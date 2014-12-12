//
//  UserSettingViewController.swift
//  pdms-ios
//
//  Created by HuLeehom on 12/12/14.
//  Copyright (c) 2014 unimedsci. All rights reserved.
//
import UIKit

class UserSettingViewController: UIViewController {
    @IBOutlet weak var mobileText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var addressText: UITextField!
    
    var user: User!
    
    @IBAction func saveUserSetting(sender: AnyObject) {
        var mobile = mobileText.text
        var email = emailText.text
        var address = addressText.text
        println("save...")
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        user = User()
        user.mobile = "15370201245"
        user.email = "sdfdsf@g.com"
        user.address = "无锡"
        if (user != nil) {
            mobileText.text = user.mobile
            emailText.text = user.email
            addressText.text = user.address
        }
    }
}
