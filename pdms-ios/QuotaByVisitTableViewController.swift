//
//  QuotaByVisitTableViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-11.
//  Copyright (c) 2014年 unimedsci. All rights reserved.


import UIKit

class QuotaByVisitTableViewController: UITableViewController {

    var patient : Patient!
    var visit : Visit!
    var groupDefinitions = Array<GroupDefinition>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.loadData()
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return groupDefinitions.count + 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return groupDefinitions[section - 1].quota.count
        }
        
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = UITableViewHeaderFooterView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        if section == 0 {
            sectionHeaderView.textLabel.text = "就诊记录"
        } else {
            sectionHeaderView.textLabel.text = groupDefinitions[section - 1].name
        }
        
        //sectionHeaderView.contentView.backgroundColor = UIColor.sectionColor()
        //sectionHeaderView.textLabel.textColor = UIColor.whiteColor()
        return sectionHeaderView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("visitDetailCell", forIndexPath: indexPath) as VisitTableCell
            cell.typeLabel.text = visit.typeLabel
            let detailString = visit.generateDetail()
            cell.detailLabel.numberOfLines = 0
            cell.detailLabel.text = detailString
            cell.detailLabel.sizeToFit()
            return cell

        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("quotaCell", forIndexPath: indexPath) as QuotaCell
            let quota = groupDefinitions[indexPath.section - 1].quota[indexPath.row]
            cell.name.text = quota.name
            cell.name.adjustsFontSizeToFitWidth = true
            cell.checkTime.text = "诊断时间：\(quota.checkTime)"
            cell.createTime.text = "创建时间：\(quota.createTime)"
            cell.lastModifiedTime.text = "修改时间：\(quota.lastModifiedTime)"
            return cell
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let detailString = visit.generateDetail()
            let labelHeight = UILabel.heightForDynamicText(detailString, font: UIFont.systemFontOfSize(14.0), width: self.tableView.bounds.width - 59 )
            return 46 + labelHeight
        } else {
            return 85
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func loadData() {
        groupDefinitions.removeAll(keepCapacity: true)
       let url = SERVER_DOMAIN + "visit/\(visit.id)/quota/list"
        let parameters = ["token": TOKEN]
        HttpApiClient.sharedInstance.getLoading(url, paramters: parameters, loadingPosition: HttpApiClient.LOADING_POSTION.AFTER_TABLEVIEW, viewController: self, success: fillData, fail: nil)
    }
    
    func fillData(json : JSON) {
        for (groupIndex: String, groupJson : JSON) in json["data"]["crowdDefinitions"]  {
            let groupDefinition = GroupDefinition()
            groupDefinition.id = groupJson["crowdDefinitionId"].number
            groupDefinition.name = groupJson["crowdDefinitionName"].string
            for (quotaIndex: String, quotaJson : JSON) in groupJson["quotaDatas"] {
                let quota = Quota()
                quota.id = quotaJson["quotaDataId"].number
                quota.name = quotaJson["groupDefinitionName"].string
                quota.createTime = quotaJson["createdTimestampStr"].string
                quota.checkTime = quotaJson["checkTimestampStr"].string
                quota.lastModifiedTime = quotaJson["lastModifiedStr"].string
                groupDefinition.quota.append(quota)
            }
            groupDefinitions.append(groupDefinition)
       }
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     
        if segue.identifier == "showSearchCatgorySegue" {
            let categoryTableviewController = segue.destinationViewController  as CategoryTableViewController
            categoryTableviewController.visit = visit
            categoryTableviewController.patient = patient
        } else if segue.identifier == "showQuotaDetailSegue" {
            let indexPath = self.tableView.indexPathForCell(sender as QuotaCell)!
            if indexPath.section != 0  {
                let quota = groupDefinitions[indexPath.section - 1].quota[indexPath.row]
                let quotaDetailViewController = segue.destinationViewController as QuotaDetailTabelViewController
                quotaDetailViewController.quota = quota
                quotaDetailViewController.patient = patient
                quotaDetailViewController.crowDefition = groupDefinitions[indexPath.section - 1]
            }
           
        } else if segue.identifier == "detailVisitSegue" {
            let visitDeatilViewController = segue.destinationViewController  as VisitDetailTableViewController
            visitDeatilViewController.patient = patient
            visitDeatilViewController.visit = visit
        }
    }
   
    @IBAction func addQuotaByVisitComplete(segue : UIStoryboardSegue) {
         self.loadData()
    }
    
    @IBAction func completeDeleteQuota(segue : UIStoryboardSegue) {
        
    }
}

