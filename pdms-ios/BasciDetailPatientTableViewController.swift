//
//  DetailPatientTableViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 15-1-12.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//


import UIKit

class BasciDetailPatientTableViewController: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var caseNoLabel: UILabel!
    var patient : Patient!
    var editCompelete = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(animated: Bool) {
        if editCompelete {
            self.navigationController?.popViewControllerAnimated(false)
            editCompelete = false
        } else {
            fillLabel()
            self.loadData()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func loadData() {
        let url = SERVER_DOMAIN + "patients/basic/\(patient.id)?token=" + TOKEN
        HttpApiClient.sharedInstance.getLoading(url, paramters: nil, loadingPosition: HttpApiClient.LOADING_POSTION.AFTER_TABLEVIEW, viewController: self, success: fillData, fail: nil)
        
    }
    func fillData(json: JSON) {
        if json["stat"].int == 0 {
                patient.id = json["data"]["patientId"].number
                patient.name = json["data"]["patientName"].string
                patient.gender = json["data"]["gender"].string
                if let age = json["data"]["age"].int {
                    patient.age = age
                } else {
                    patient.age = 0
                }
                patient.birthday = json["data"]["birthday"].string
                patient.caseNo = json["data"]["patientNo"].string
                fillLabel()
        } else {
            
        }
    }
    
    func fillLabel() {
        nameLabel.text = patient.name
        genderLabel.text = patient.gender
        birthdayLabel.text = patient.birthday
        ageLabel.text = "\(patient.age)"
        caseNoLabel.text = patient.caseNo
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editPatitentSegue" {
            let navigateController = segue.destinationViewController as UINavigationController
           let editPatitentViewController =  navigateController.topViewController as EditPatientViewController
            editPatitentViewController.patient = patient
        }
    }
    
    @IBAction func completeEditPatient(segue : UIStoryboardSegue) {
        editCompelete = true
        
    }
    
}

