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
        return 66
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
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
        println(searchString)
        if (searchString != nil && !searchString.isEmpty) {
            self.searchResult = []
            self.searchPatient(controller, searchString: searchString)
            return true
        }
        return false
    }
    
    func searchPatient(controller: UISearchDisplayController, searchString: String) {
        let manager = AFHTTPRequestOperationManager()
        let url = SERVER_DOMAIN + "patients/search"
        let parameters = ["token": TOKEN, "q": searchString]
        manager.GET(url,
            parameters: parameters,
            success: {(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let json = JSON(responseObject)
                println(json)
                for (index: String, patientJson: JSON) in json {
                    let patient = Patient()
                    patient.id = patientJson["patientId"].int
                    patient.name = patientJson["patientName"].string
                    patient.gender = patientJson["gender"].string
                    patient.age = patientJson["age"].int
                    // patient.birthday = data["birthday"].string
                    self.searchResult.append(patient)
                    controller.searchResultsTableView.reloadData()
                }
            },
            failure: {(operation: AFHTTPRequestOperation!, error: NSError!) in
                println(error)
            }
        )
    }
    
    func loadData() {
        let manager = AFHTTPRequestOperationManager()
        let url = SERVER_DOMAIN + "patients/recent?token=" + TOKEN
        manager.GET(url,
            parameters:[],
            success: {(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                //self.loadingIndicator.hidden = true
                //self.loadingIndicator.stopAnimating()
                self.fillData(responseObject)
                self.tableView.reloadData()
            },
            failure: {(operation: AFHTTPRequestOperation!, error: NSError!) in
                //self.loadingIndicator.hidden = true
                //self.loadingIndicator.stopAnimating()
                           }
        )
        
    }
    func fillData(responseObject: AnyObject!) {
        let json = JSON(responseObject)
        for (index: String, patientJson: JSON) in json {
            let patient = Patient()
            patient.id = patientJson["patientId"].int
            patient.name = patientJson["patientName"].string
            patient.gender = patientJson["gender"].string
            patient.age = patientJson["age"].int
           // patient.birthday = data["birthday"].string
            self.recentPatients.append(patient)
        }
        
    }
    
    @IBAction func completeAdd(segue : UIStoryboardSegue) {
        
    }
}

