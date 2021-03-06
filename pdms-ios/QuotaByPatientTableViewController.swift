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
    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let sectionHeaderView = UIView()
//        let label = UILabel(frame: CGRectMake(15, 8, self.tableView.bounds.width, 20))
//        label.font = UIFont.systemFontOfSize(18)
//        label.textColor = UIColor.grayColor()
//        label.text = self.tableView(tableView, titleForHeaderInSection: section)
//        sectionHeaderView.addSubview(label)
//        sectionHeaderView.backgroundColor = UIColor.groupTableViewBackgroundColor()
//        return sectionHeaderView
//    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, 40))
        var label = UILabel(frame: CGRectMake(13, 0, 100, 40))
        view.backgroundColor = UIColor.sectionHeaderColor()
        label.text = groupDefinitions[section].name
        label.textColor = UIColor.sectionTextColor()
        label.font = UIFont.systemFontOfSize(14.0)
        view.addSubview(label)
        return view
    }
//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40
//    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("quotaCell", forIndexPath: indexPath) as! QuotaCell
        let quota = groupDefinitions[indexPath.section].quota[indexPath.row]
        cell.name.text = quota.name
        cell.name.adjustsFontSizeToFitWidth = true
        var detailString = ""
        if let dDate = Data.generateCheckTime(groupDefinitions[indexPath.section], forForm: false) {
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let dDate = Data.generateCheckTime(groupDefinitions[indexPath.section], forForm: false) {
            if dDate.columnName == nil{
                return 80.0
            }
        }
        return 96.0
    }
    func loadData() {
        let url = SERVER_DOMAIN + "visit/patientQuotas"
        let parameters : [String : AnyObject] = ["token": TOKEN, "patientId": patient.id]
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
        if let pullToRefreshView = self.tableView.pullToRefreshView {
            pullToRefreshView.stopAnimating()
        }
        self.tableView.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
         if segue.identifier == "showQuotaDetailSegue" {
            let indexPath = self.tableView.indexPathForCell(sender as! QuotaCell)!
            let quota = groupDefinitions[indexPath.section].quota[indexPath.row]
            let quotaDetailViewController = segue.destinationViewController as! QuotaDetailTabelViewController
            quotaDetailViewController.quota = quota
            quotaDetailViewController.patient = patient
            quotaDetailViewController.crowDefition = groupDefinitions[indexPath.section]
        } 
    }
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)
        if self.tableView.pullToRefreshView == nil {
            self.tableView.addPullToRefreshWithActionHandler(loadData, position: SVPullToRefreshPosition.Top)
        }
        setPullToRefreshTitle()
    }
    func setPullToRefreshTitle() {
        if let pullToRefreshView = self.tableView.pullToRefreshView {
            pullToRefreshView.setTitle("下拉刷新...", forState: SVPullToRefreshState.Stopped)
            pullToRefreshView.setTitle("松开刷新...", forState: SVPullToRefreshState.Triggered)
            pullToRefreshView.setTitle("加载中...", forState: SVPullToRefreshState.Loading)
            pullToRefreshView.arrowColor = UIColor.grayColor()
        }
    }
}

