//
//  VisitTableViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-10.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//


import UIKit

class VisitTableViewController : UITableViewController {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    var visits = Array<Visit>()
    var patient : Patient!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visits.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("visitAllCell", forIndexPath: indexPath) as VisitTableCell
        let visit  = visits[indexPath.row]
        cell.typeLabel.text = visit.typeLabel
        cell.number.text =  "就诊号：\(visit.number)"
        cell.departmentLabel.text = "科室：\(visit.departmentLabel)"
        cell.mainDiagnose.text = "疾病诊断：\(visit.mainDiagonse)"
        cell.time.text = "就诊时间：\(visit.startTime) ~ \(visit.endTime)"
        return cell
    }
    
    func loadData() {
        loadingIndicator.startAnimating()
        let url = SERVER_DOMAIN + "visit/\(patient.id)"
        let parameters = ["token": TOKEN]
        HttpApiClient.sharedInstance.get(url, paramters : parameters, success: fillData, fail : nil)
        self.loadingIndicator.hidden = true
        self.loadingIndicator.stopAnimating()
    }
    
    func fillData(json : JSON) {
        for (index: String, visitJson: JSON) in json["data"]  {
            let visit = Visit()
            visit.id = visitJson["visitId"].int
            visit.typeLabel = visitJson["visitTypeLabel"].string
            visit.number = visitJson["visitNumber"].string
            visit.departmentLabel = visitJson["departmentLabel"].string
            visit.mainDiagonse = visitJson["mainDiagnose"].string
            visit.startTime = visitJson["startTime"].string
            visit.endTime = visitJson["endTime"].string
            visits.append(visit)
        }
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addVisitSegue" {
            let addVisitViewController = segue.destinationViewController as AddVisitViewController
        } else if segue.identifier == "quotaByVisitSegue" {
            let quotaByVisitTableViewController = segue.destinationViewController as QuotaByVisitTableViewController
            let indexPath = self.tableView.indexPathForCell(sender as QuotaCell)!
            let visit = visits[indexPath.row]
            quotaByVisitTableViewController.visit = visit
            quotaByVisitTableViewController.patient = patient
        }
    }
    
    @IBAction func completeAdd(segue : UIStoryboardSegue) {
        
    }
}

