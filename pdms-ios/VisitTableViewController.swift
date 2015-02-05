//
//  VisitTableViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-10.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//


import UIKit

class VisitTableViewController : UITableViewController {

    var visits = Array<Visit>()
    var patient : Patient!
    var toDetail = false
    var detailVisit : Visit!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(animated: Bool) {
        if toDetail {
            let quotaByVisitTableViewController = self.navigationController?.storyboard?.instantiateViewControllerWithIdentifier("quotaByVisitTableViewController") as QuotaByVisitTableViewController
            quotaByVisitTableViewController.patient = patient
            quotaByVisitTableViewController.visit = detailVisit
            self.navigationController?.pushViewController(quotaByVisitTableViewController, animated: false)
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
        
        let detailString = visit.generateDetail()
        cell.detailLabel.numberOfLines = 0
        cell.detailLabel.text = detailString
        cell.detailLabel.sizeToFit()
        return cell
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let visit = visits[indexPath.row]
        let detailString = visit.generateDetail()
        let labelHeight = UILabel.heightForDynamicText(detailString, font: UIFont.systemFontOfSize(14.0), width: self.tableView.bounds.width - 59 )
        return 46 + labelHeight
    }
    
    func loadData() {
        let url = SERVER_DOMAIN + "visit/\(patient.id)"
        let parameters = ["token": TOKEN]
        HttpApiClient.sharedInstance.getLoading(url, paramters: parameters, loadingPosition: HttpApiClient.LOADING_POSTION.AFTER_TABLEVIEW, viewController: self, success: fillData, fail: nil)
    }
    
    func fillData(json : JSON) {
        visits.removeAll(keepCapacity: true)
        for (index: String, visitJson: JSON) in json["data"]  {
            let visit = Visit()
            visit.id = visitJson["visitId"].number
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

