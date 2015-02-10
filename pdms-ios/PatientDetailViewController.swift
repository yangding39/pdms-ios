//
//  PatientDetailViewController.swift
//  pdms-ios
//
//  Created by HuLeehom on 12/8/14.
//  Copyright (c) 2014 unimedsci. All rights reserved.
//

import UIKit

class PatientDetailViewController: UITableViewController{
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    var patient: Patient!
    var isDeleted = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveToRecent()
    }
    
    override func viewWillAppear(animated: Bool) {
        if isDeleted{
            self.navigationController?.popToRootViewControllerAnimated(false)
            isDeleted = false
        } else {
            
        }
        name.text = patient.name
        let detailString = patient.generateDetail()
        detailLabel.numberOfLines = 0
        detailLabel.text = detailString
        detailLabel.sizeToFit()
        self.tableView.reloadData()
    }
    
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let detailString = patient.generateDetail()
            let labelHeight = UILabel.heightForDynamicText(detailString, font: UIFont.systemFontOfSize(14.0), width: self.tableView.bounds.width - 49 )
            return 52 + labelHeight
        } else {
            return 44
        }
    }
    func saveToRecent() {
        let url = SERVER_DOMAIN + "patients/searchView"
        let parameters: [String : AnyObject] = ["token": TOKEN, "patientId": patient.id]
        HttpApiClient.sharedInstance.post(url, paramters : parameters, success: fillSaveResult, fail : nil)
    }
    
    func fillSaveResult(json : JSON) {
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "visitByPatientSegue" {
            let visitTabelViewController = segue.destinationViewController as VisitTableViewController
            visitTabelViewController.patient = patient
        } else if segue.identifier == "quotaByPatientSegue" {
            let quotaViewController = segue.destinationViewController as QuotaByPatientTableViewController
            quotaViewController.patient = patient
        } else if segue.identifier == "basicDetailPatitentSegue" {
            let basicDetailPatientController = segue.destinationViewController as BasciDetailPatientTableViewController
            basicDetailPatientController.patient = patient
        }
    }
    
    @IBAction func completeDeletePatient(segue : UIStoryboardSegue) {
        isDeleted = true
    }
}
