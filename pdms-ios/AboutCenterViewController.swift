//
//  AboutCenterViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 15-3-5.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//

import UIKit

class AboutCenterViewController: UITableViewController {

    @IBOutlet weak var pdmsAboutImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if var frame = self.tableView.tableHeaderView?.frame {
            
            frame.size.height = 130
            self.tableView.tableHeaderView?.frame = frame
            self.tableView.tableHeaderView?.backgroundColor = UIColor.sectionHeaderColor()
            self.tableView.tableHeaderView?.updateConstraintsIfNeeded()
            
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

