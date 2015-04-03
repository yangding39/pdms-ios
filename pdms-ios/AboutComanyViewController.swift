//
//  AboutComanyViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 15-3-6.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//

import UIKit

class  AboutComanyViewController: UIViewController {

    @IBOutlet weak var companyDesc: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        companyDesc.numberOfLines = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

