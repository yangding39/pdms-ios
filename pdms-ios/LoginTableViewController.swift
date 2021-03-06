//
//  LoginTableViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 15-1-22.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//


import UIKit
import CoreData

class LoginTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    let managedObectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

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
        
        setHistoryForUserName()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            if let id = json["data"]["userId"].number {
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
            user.loginName = userNameTextField.text
            LOGIN_USER = user
            if let token = json["data"]["token"].string {
                TOKEN = token
                saveUserToLocal()
                if let tabBarController = self.presentingViewController as? UITabBarController {
                    tabBarController.selectedIndex = 0
                    if let viewControllers = tabBarController.viewControllers {
                        for viewController in viewControllers {
                            if let navigationController = viewController as? UINavigationController {
                                //setTotalViewController(navigationController)
                                navigationController.popToRootViewControllerAnimated(false)
                            }
                        }
                    }
                    
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
           
        }
        
    }
   
    func saveUserToLocal() {
        //check existed record
        let fetchRequest = NSFetchRequest(entityName:"UserLocal")
        let predicate = NSPredicate(format: "loginName == %@", LOGIN_USER.loginName)
        fetchRequest.predicate = predicate
        if let fetchResult = self.managedObectContext?.executeFetchRequest(fetchRequest, error: nil) as? [UserLocal] {
            if fetchResult.count > 0 {
                for user in fetchResult {
                    setUserLocalDetails(user)
                    self.managedObectContext?.save(nil)
                }
            } else {
                let localUser = NSEntityDescription.insertNewObjectForEntityForName("UserLocal", inManagedObjectContext : self.managedObectContext!) as! UserLocal
                setUserLocalDetails(localUser)
                self.managedObectContext?.save(nil)
            }
        }
    }
    
    func setUserLocalDetails(userLocal :UserLocal) {
        userLocal.id = LOGIN_USER.id
        userLocal.name = LOGIN_USER.name
        userLocal.loginName = LOGIN_USER.loginName
        userLocal.mobile = LOGIN_USER.mobile
        userLocal.email = LOGIN_USER.email
        userLocal.address = LOGIN_USER.address
        userLocal.hospital = LOGIN_USER.hospital
        userLocal.department = LOGIN_USER.department
        userLocal.title = LOGIN_USER.title
        userLocal.token = TOKEN
        userLocal.isLogined = true
        userLocal.loginDate = NSDate()
    }
    func setHistoryForUserName () {
        let fetchRequest = NSFetchRequest(entityName:"UserLocal")
        let sortDescriptor = NSSortDescriptor(key: "loginDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1
        if let userInLocal = self.managedObectContext?.executeFetchRequest(fetchRequest, error: nil)?.first as? UserLocal {
            self.userNameTextField.text = userInLocal.loginName
        }
    }

    func setTotalViewController(navigationController : UINavigationController) {
        if let inNavControllers = navigationController.viewControllers {
            for inController in inNavControllers {
                if let totalViewController = inController as? TotalViewController {
                    totalViewController.page = 1
                }
            }
        }
    }
}

