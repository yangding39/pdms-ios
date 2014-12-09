//
//  PatientDetailViewController.swift
//  pdms-ios
//
//  Created by HuLeehom on 12/8/14.
//  Copyright (c) 2014 unimedsci. All rights reserved.
//

import UIKit

class PatientDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "基本信息"
        }
        return "test"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            var cell: PatientDetailTableCell = tableView.dequeueReusableCellWithIdentifier("patientDetailCell") as PatientDetailTableCell
            cell.nameLabel?.text = "hello"
            return cell
        } else {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("otherInformationCell") as UITableViewCell
            cell.textLabel?.text = "oko"
            return cell
        }
    }
}
