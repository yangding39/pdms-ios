//
//  UserSettingViewController.swift
//  pdms-ios
//
//  Created by HuLeehom on 12/12/14.
//  Copyright (c) 2014 unimedsci. All rights reserved.
//
import UIKit

class UserSettingViewController: UITableViewController {
    @IBOutlet weak var mobileText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var addressText: UITextField!
    
    var user: User!
    
    @IBAction func saveUserSetting(sender: AnyObject) {
        self.saveSetting()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
    }
    
    func loadData() {
        let url = SERVER_DOMAIN + "user/toSetting?token=" + TOKEN
        HttpApiClient.sharedInstance.getLoading(url, paramters: nil, loadingPosition: HttpApiClient.LOADING_POSTION.AFTER_TABLEVIEW, viewController: self, success: fillData, fail: nil)
        
    }
    func fillData(json: JSON) -> Void {
        mobileText.text = json["data"]["mobile"].string
        emailText.text  = json["data"]["email"].string
        addressText.text = json["data"]["address"].string
    }
    
    func saveSetting() {
        let mobile = mobileText.text
        let email = emailText.text
        let address = addressText.text
        let url = SERVER_DOMAIN + "user/setting"
        let params : [String : AnyObject] = ["token" : TOKEN ,"email" : email, "mobile" : mobile, "address" : address]
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
