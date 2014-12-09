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
    override func viewDidLoad() {
        super.viewDidLoad()
 
        recentPatients.removeAll(keepCapacity: true)
     
       // loadingIndicator.startAnimating()
        self.loadData()
        // Do any additional setup after loading the view, typically from a nib.
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
        if tableView == self.searchDisplayController?.searchResultsTableView {
            let patient = self.searchResult[indexPath.row]
            cell.name.text = patient.name
            cell.gender.text = patient.gender
            cell.age.text = String(patient.age)
        } else {
            let patient = self.recentPatients[indexPath.row]
            cell.name.text = patient.name
            cell.gender.text = patient.gender
            cell.age.text = String(patient.age)
        }
        return cell
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
        let url = SERVER_DOMAIN + "patients/recent?token=" + TOKEN
        HttpApiClient.sharedInstance.get(url, paramters : nil, success: fillData, fail : nil)
        
    }
    func fillData(json: JSON) -> Void{
        for (index: String, patientJson: JSON) in json {
            let patient = Patient()
            patient.id = patientJson["patientId"].int
            patient.name = patientJson["patientName"].string
            patient.gender = patientJson["gender"].string
            patient.age = patientJson["age"].int
           // patient.birthday = data["birthday"].string
            self.recentPatients.append(patient)
        }
         self.tableView.reloadData()        
    }
    
    func fillSearchData(json: JSON) -> Void{
        for (index: String, patientJson: JSON) in json {
            let patient = Patient()
            patient.id = patientJson["patientId"].int
            patient.name = patientJson["patientName"].string
            patient.gender = patientJson["gender"].string
            patient.age = patientJson["age"].int
            // patient.birthday = data["birthday"].string
            self.searchResult.append(patient)
        }
        self.searchDisplayController?.searchResultsTableView.reloadData()
    }
    
    @IBAction func completeAdd(segue : UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "patientDetailSegue") {
        } else {
            
        }
    }
}

