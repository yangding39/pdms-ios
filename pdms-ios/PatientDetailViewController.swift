//
//  PatientDetailViewController.swift
//  pdms-ios
//
//  Created by HuLeehom on 12/8/14.
//  Copyright (c) 2014 unimedsci. All rights reserved.
//

import UIKit

class PatientDetailViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.text = "hello"
    }
}
