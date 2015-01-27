//
//  QuotaTableViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-11.
//  Copyright (c) 2014年 unimedsci. All rights reserved.


import UIKit

class QuotaByPatientTableViewController: UITableViewController {

    var patient : Patient!
    var groupDefinitions = Array<GroupDefinition>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
         self.loadData()
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return groupDefinitions.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return groupDefinitions[section].quota.count
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = UITableViewHeaderFooterView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
       
        //sectionHeaderView.contentView.backgroundColor = UIColor.sectionColor()
        //sectionHeaderView.textLabel.textColor = UIColor.whiteColor()
        sectionHeaderView.textLabel.text = groupDefinitions[section].name
        return sectionHeaderView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("quotaCell", forIndexPath: indexPath) as QuotaCell
        let quota = groupDefinitions[indexPath.section].quota[indexPath.row]
        cell.name.text = quota.name
        cell.checkTime.text = "诊断时间：\(quota.checkTime)"
        cell.createTime.text = "创建时间：\(quota.createTime)"
        cell.lastModifiedTime.text = "修改时间：\(quota.lastModifiedTime)"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func loadData() {
        groupDefinitions.removeAll(keepCapacity: true)
        let url = SERVER_DOMAIN + "visit/patientQuotas"
        let parameters : [String : AnyObject] = ["token": TOKEN, "patientId": patient.id]
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
         if segue.identifier == "showQuotaDetailSegue" {
            let indexPath = self.tableView.indexPathForCell(sender as QuotaCell)!
            let quota = groupDefinitions[indexPath.section].quota[indexPath.row]
            let quotaDetailViewController = segue.destinationViewController as QuotaDetailTabelViewController
            quotaDetailViewController.quota = quota
            quotaDetailViewController.patient = patient
            quotaDetailViewController.crowDefition = groupDefinitions[indexPath.section]
        } 
    }

}

