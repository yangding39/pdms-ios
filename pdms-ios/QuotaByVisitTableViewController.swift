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
        let sectionHeaderView = UIView()
        let label = UILabel(frame: CGRectMake(15, 8, self.tableView.bounds.width, 20))
        label.font = UIFont.systemFontOfSize(18)
        label.textColor = UIColor.grayColor()
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        sectionHeaderView.addSubview(label)
        sectionHeaderView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        return sectionHeaderView
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "就诊记录"
        } else {
            if section - 1 < groupDefinitions.count {
                return groupDefinitions[section - 1].name
            } else {
                return ""
            }
            
        }
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
            cell.name.adjustsFontSizeToFitWidth = true
            var detailString = ""
            if let dDate = Data.generateCheckTime(groupDefinitions[indexPath.section - 1], forForm: false) {
                if let dateName = dDate.columnName {
                    detailString += "\(dDate.columnName)：\(quota.checkTime)\n"
                }
            }
            
            detailString +=  "创建时间：\(quota.createTime)\n"
            detailString +=  "修改时间：\(quota.lastModifiedTime)"
            cell.detailLabel.numberOfLines = 0
            cell.detailLabel.text = detailString
            cell.detailLabel.sizeToFit()

            return cell
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let detailString = visit.generateDetail()
            let labelHeight = UILabel.heightForDynamicText(detailString, font: UIFont.systemFontOfSize(14.0), width: self.tableView.bounds.width - 59 )
            return 46 + labelHeight
        } else {
            if let dDate = Data.generateCheckTime(groupDefinitions[indexPath.section - 1], forForm: false) {
                if dDate.columnName == nil{
                    return 80.0
                }
            }
            return 96.0
        }
        
    }
    
    
    func loadData() {
       let url = SERVER_DOMAIN + "visit/\(visit.id)/quota/list"
        let parameters = ["token": TOKEN]
        HttpApiClient.sharedInstance.getLoading(url, paramters: parameters, loadingPosition: HttpApiClient.LOADING_POSTION.AFTER_TABLEVIEW, viewController: self, success: fillData, fail: nil)
    }
    
    func fillData(json : JSON) {
        groupDefinitions.removeAll(keepCapacity: true)
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
                quotaDetailViewController.visit = visit
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

