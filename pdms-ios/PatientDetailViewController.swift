//
//  PatientDetailViewController.swift
//  pdms-ios
//
//  Created by HuLeehom on 12/8/14.
//  Copyright (c) 2014 unimedsci. All rights reserved.
//

import UIKit

class PatientDetailViewController: UITableViewController, UIActionSheetDelegate {
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var caseNo: UILabel!
    
    @IBOutlet weak var gender: UILabel!
    
    @IBOutlet weak var age: UILabel!
    
    @IBOutlet weak var birthday: UILabel!
    
    var patient: Patient!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
            name.text = patient.name
            caseNo.text = patient.caseNo
            gender.text = patient.gender
            age.text = "\(patient.age)"
            birthday.text = patient.birthday
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
    @IBAction func didClickDeleteBtn(sender: AnyObject) {
        if NSClassFromString("UIAlertController") != nil {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let deleteAction = UIAlertAction(title: "删除", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.removePatient()
            })
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                println("Cancelled")
            })
            
            optionMenu.addAction(deleteAction)
            optionMenu.addAction(cancelAction)
            self.presentViewController(optionMenu, animated: true, completion: nil)
        } else {
            let myActionSheet = UIActionSheet()
            myActionSheet.addButtonWithTitle("删除")
            myActionSheet.addButtonWithTitle("取消")
            myActionSheet.cancelButtonIndex = 1
            myActionSheet.showInView(self.view)
            myActionSheet.delegate = self
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        if buttonIndex == 0 {
            removePatient()
        }
    }
    
    func removePatient() {
        let url = SERVER_DOMAIN + "patients/delete"
        let params : [String : AnyObject] = ["token" : TOKEN, "patientId" : patient.id]
        HttpApiClient.sharedInstance.post(url, paramters : params, success: removePatientResult, fail : nil)
    }
    
    func removePatientResult(json : JSON) {
        var fieldErrors = Array<String>()
        var removeResult = false
        //set result and error from server
        removeResult = json["stat"].int == 0 ? true : false
        for (index: String, errorJson: JSON) in json["fieldErrors"] {
            if let error = errorJson[index].string {
                fieldErrors.append(error)
            }
        }
        if removeResult && fieldErrors.count == 0 {
            //self.performSegueWithIdentifier("completeAddPatientSegue", sender: self)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
   
}
