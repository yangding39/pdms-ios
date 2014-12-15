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
        // Do any additional setup after loading the view, typically from a nib.
        self.loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return groupDefinitions.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return groupDefinitions[section].quota.count
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        let headerLabel = UILabel(frame: CGRectMake(10, 10, sectionHeaderView.frame.size.width, 25))
        sectionHeaderView.addSubview(headerLabel)
        
        headerLabel.font = UIFont(name: "Verdana", size: 14)
        headerLabel.text = groupDefinitions[section].name
        sectionHeaderView.backgroundColor = UIColor.lightGrayColor()
        headerLabel.backgroundColor = UIColor.lightGrayColor()
        
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
    
    func loadData() {
       let url = SERVER_DOMAIN + "visit/\(visit.id)/quota/list"
        let parameters = ["token": TOKEN]
        HttpApiClient.sharedInstance.get(url, paramters : parameters, success: fillData, fail : nil)
    }
    
    func fillData(json : JSON) {
        for (groupIndex: String, groupJson : JSON) in json["data"]["crowdDefinitions"]  {
            let groupDefinition = GroupDefinition()
            groupDefinition.id = groupJson["crowdDefinitionId"].int
            groupDefinition.name = groupJson["crowdDefinitionName"].string
            for (quotaIndex: String, quotaJson : JSON) in groupJson["listQuotaData"] {
                let quota = Quota()
                quota.id = quotaJson["groupDefinitionId"].int
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
        } else if segue.identifier == "showQuotaDetailSegue" {
            println("11232")
        }
    }
  
}

