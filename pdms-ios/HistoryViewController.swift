//
//  ViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-5.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//

import UIKit

class HistoryViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
   
    var recentPatients: [Patient] = []
    var searchResult: [Patient] = []
    var toDetail = false
    var detailPatient : Patient!
    override func viewDidLoad() {
        super.viewDidLoad()
        if TOKEN.isEmpty {
            let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("loginTableViewController") as LoginTableViewController
            self.presentViewController(loginViewController, animated: true, completion: nil)
        }
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    override func viewWillAppear(animated: Bool) {
        if toDetail {
            let patientDetailView = self.navigationController?.storyboard?.instantiateViewControllerWithIdentifier("patitentDetailViewController") as PatientDetailViewController
            patientDetailView.patient = detailPatient
            self.navigationController?.pushViewController(patientDetailView, animated: false)
            toDetail = false
        } else {
            self.loadData()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController?.searchResultsTableView {
            return searchResult.count
        } else {
            return recentPatients.count
        }
    }
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 63
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 63
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("historyCell", forIndexPath: indexPath) as HistoryTableCell
        let cell = self.tableView.dequeueReusableCellWithIdentifier("patientCell") as PatientTableCell
        var patient : Patient!
        if tableView == self.searchDisplayController?.searchResultsTableView {
            patient = self.searchResult[indexPath.row]
        } else {
            patient = self.recentPatients[indexPath.row]
        }
        cell.name.text = patient.name
        cell.gender.text = "性别：" + patient.gender
        cell.age.text = "年龄：\(patient.age)"
        cell.birthday.text = "生日：" + patient.birthday
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        if (searchString != nil && !searchString.isEmpty) {
            self.searchResult = []
            self.searchPatient(controller, searchString: searchString)
            return true
        }
        return false
    }
    
    func searchPatient(controller: UISearchDisplayController, searchString: String) {
        let url = SERVER_DOMAIN + "patients/search"
        let parameters = ["token": TOKEN, "q": searchString]
        HttpApiClient.sharedInstance.get(url, paramters : parameters, success: fillSearchData, fail : nil)
    }
    
    func loadData() {
        recentPatients.removeAll(keepCapacity: true)
        let url = SERVER_DOMAIN + "patients/recent?token=" + TOKEN
        HttpApiClient.sharedInstance.getLoading(url, paramters: nil, loadingPosition: HttpApiClient.LOADING_POSTION.AFTER_TABLEVIEW, viewController: self, success: fillData, fail: nil)
        
    }
    func fillData(json: JSON) -> Void {
        for (index: String, patientJson: JSON) in json["data"] {
            let patient = Patient()
            patient.id = patientJson["patientId"].number
            patient.name = patientJson["patientName"].string
            patient.gender = patientJson["gender"].string
            patient.age = patientJson["age"].int
            patient.birthday = patientJson["birthday"].string
            patient.caseNo = patientJson["patientNo"].string
            self.recentPatients.append(patient)
        }
         self.tableView.reloadData()        
    }
    
    func fillSearchData(json: JSON) -> Void{
        for (index: String, patientJson: JSON) in json["data"]  {
            let patient = Patient()
            patient.id = patientJson["patientId"].number
            patient.name = patientJson["patientName"].string
            patient.gender = patientJson["gender"].string
            patient.age = patientJson["age"].int
            patient.birthday = patientJson["birthday"].string
            patient.caseNo = patientJson["patientNo"].string
            self.searchResult.append(patient)
        }
        self.searchDisplayController?.searchResultsTableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "patientDetailSegue") {
            let fromSearch = self.searchDisplayController?.active == true
            var patient: Patient!
            if (fromSearch) {
                var indexPath = self.searchDisplayController?.searchResultsTableView.indexPathForCell(sender as PatientTableCell)
                patient = self.searchResult[indexPath!.row]
            } else {
                var indexPath = self.tableView.indexPathForCell(sender as PatientTableCell)
                patient = self.recentPatients[indexPath!.row]
            }
            
            let patientDetailViewController = segue.destinationViewController as PatientDetailViewController
            patientDetailViewController.patient = patient
        } else if segue.identifier == "showAddPatientSegue" {
//
        }
    }
    @IBAction func completeAddPatient(segue : UIStoryboardSegue) {
        let addPatientViewController = segue.sourceViewController as AddPatientViewController
        let patient = addPatientViewController.patient
        detailPatient = patient
        toDetail = true
    }
    
    @IBAction func completeDeletePatient(segue : UIStoryboardSegue) {
        
    }
}

