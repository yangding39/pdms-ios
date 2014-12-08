//
//  ViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-5.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//

import UIKit

class HistoryViewController: UITableViewController {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    var tableDatas = Array<Patient>()
    override func viewDidLoad() {
        tableDatas.removeAll(keepCapacity: true)
        super.viewDidLoad()
     
        loadingIndicator.startAnimating()
        self.loadData()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDatas.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("historyCell", forIndexPath: indexPath) as HistoryTableCell
        let patient = self.tableDatas[indexPath.row]
        cell.name.text = patient.name
        cell.gender.text = patient.gender
        cell.age.text = String(patient.age)
        return cell
    }
    func loadData() {
        let manager = AFHTTPRequestOperationManager()
        let url = SERVER_DOMAIN + "patients/recent?token=" + TOKEN
        manager.GET(url,
            parameters:[],
            success: {(
                operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                self.loadingIndicator.hidden = true
                self.loadingIndicator.stopAnimating()
                self.fillData(responseObject)
                self.tableView.reloadData()
            },
            failure: {(
                operation: AFHTTPRequestOperation!,
                error: NSError!) in
                self.loadingIndicator.hidden = true
                self.loadingIndicator.stopAnimating()
                println(error)
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
            self.tableDatas.append(patient)
        }
        
    }
}

