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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveToRecent()
    }
    
    override func viewWillAppear(animated: Bool) {
        name.text = patient.name
        var detailString = ""
        if let gender = patient.gender {
            detailString += gender
        }
        if let age = patient.age {
            detailString += "      \(age)      "
        }
        if let birthday = patient.birthday {
            detailString += birthday
        }
        if let caseNo = patient.caseNo {
            detailString += "      病案号：\(caseNo)"
        }
        detailLabel.text = detailString
        detailLabel.adjustsFontSizeToFitWidth = true
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
    
}
