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
    var toDetail = false
    var detailVisit : Visit!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(animated: Bool) {
        if toDetail {
            let quotaByVisitTableViewController = self.navigationController?.storyboard?.instantiateViewControllerWithIdentifier("quotaByVisitTableViewController") as QuotaByVisitTableViewController
            quotaByVisitTableViewController.patient = patient
            quotaByVisitTableViewController.visit = detailVisit
            self.navigationController?.pushViewController(quotaByVisitTableViewController, animated: true)
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
        return visits.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("visitAllCell", forIndexPath: indexPath) as VisitTableCell
        let visit  = visits[indexPath.row]
        cell.typeLabel.text = visit.typeLabel
        cell.number.text =  "就诊号：\(visit.number)"
        cell.departmentLabel.text = "科室：\(visit.departmentLabel)"
        cell.departmentLabel.adjustsFontSizeToFitWidth = true
        cell.mainDiagnose.text = "\(visit.mainDiagonse)"
        cell.mainDiagnose.adjustsFontSizeToFitWidth = true
       
        var timeText = "就诊时间："
        if let startTime =  visit.startTime {
            timeText += startTime
        }
        
        if visit.startTime != nil || visit.endTime != nil {
            timeText += "~"
        }
        
        if let endTime = visit.endTime {
            timeText += endTime
        }
         cell.time.text = timeText
        return cell
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 77
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 77
    }
    
    func loadData() {
        loadingIndicator.startAnimating()
        let url = SERVER_DOMAIN + "visit/\(patient.id)"
        let parameters = ["token": TOKEN]
        HttpApiClient.sharedInstance.get(url, paramters : parameters, success: fillData, fail : nil)
        
    }
    
    func fillData(json : JSON) {
        visits.removeAll(keepCapacity: true)
        self.loadingIndicator.hidden = true
        self.loadingIndicator.stopAnimating()
        for (index: String, visitJson: JSON) in json["data"]  {
            let visit = Visit()
            visit.id = visitJson["visitId"].int
            visit.typeLabel = visitJson["visitTypeLabel"].string
            visit.number = visitJson["visitNumber"].string
            visit.departmentLabel = visitJson["departmentLabel"].string
            visit.mainDiagonse = visitJson["mainDiagnose"].string
            visit.startTime = visitJson["startDate"].string
            visit.endTime = visitJson["endDate"].string
            visits.append(visit)
        }
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addVisitSegue" {
            let navigateController =  segue.destinationViewController as UINavigationController
            let addVisitViewController = navigateController.topViewController as AddVisitViewController
            addVisitViewController.patient = patient
        } else if segue.identifier == "quotaByVisitSegue" {
            let quotaByVisitTableViewController = segue.destinationViewController as QuotaByVisitTableViewController
            let indexPath = self.tableView.indexPathForCell(sender as VisitTableCell)!
            let visit = visits[indexPath.row]
            quotaByVisitTableViewController.visit = visit
            quotaByVisitTableViewController.patient = patient
        }
    }
    
    @IBAction func completeAddVisit(segue : UIStoryboardSegue) {
        let addVisitViewController = segue.sourceViewController as AddVisitViewController
        detailVisit = addVisitViewController.visit
        toDetail = true
    }
    
}

