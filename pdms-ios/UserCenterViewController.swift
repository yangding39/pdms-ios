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
    
    override func viewDidLoad() {
        var user = User()
        user.name = "茅医生"
        
        self.nameLabel.text = user.name
    }
}