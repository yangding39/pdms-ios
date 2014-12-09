//
//  PatientDetailViewController.swift
//  pdms-ios
//
//  Created by HuLeehom on 12/8/14.
//  Copyright (c) 2014 unimedsci. All rights reserved.
//

import UIKit

class PatientDetailViewController: UITableViewController {
    
    var patient: Patient!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            var cell: PatientDetailTableCell = tableView.dequeueReusableCellWithIdentifier("patientDetailCell") as PatientDetailTableCell
            cell.nameLabel?.text = self.patient.name
            cell.genderLabel?.text = self.patient.gender
            cell.ageLabel?.text = String(self.patient.age)
            return cell
        } else {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("otherInformationCell") as UITableViewCell
            if (indexPath.row == 0) {
                cell.textLabel?.text = "就诊记录"
            }
            if (indexPath.row == 1) {
                cell.textLabel?.text = "数据指标"
            }
            return cell
        }
    }
}
