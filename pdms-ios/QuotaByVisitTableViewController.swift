//
//  QuotaByVisitTableViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-11.
//  Copyright (c) 2014年 unimedsci. All rights reserved.


import UIKit

class QuotaByVisitTableViewController: UITableViewController,UIActionSheetDelegate {

    var patient : Patient!
    var visit : Visit!
    var groupDefinitions = Array<GroupDefinition>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
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
        
        sectionHeaderView.tintColor = UIColor.sectionColor()
        
        return sectionHeaderView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("visitDetailCell", forIndexPath: indexPath) as VisitTableCell
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

        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("quotaCell", forIndexPath: indexPath) as QuotaCell
            let quota = groupDefinitions[indexPath.section - 1].quota[indexPath.row]
            cell.name.text = quota.name
            cell.checkTime.text = "诊断时间：\(quota.checkTime)"
            cell.createTime.text = "创建时间：\(quota.createTime)"
            cell.lastModifiedTime.text = "修改时间：\(quota.lastModifiedTime)"
            return cell
        }
        
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
            groupDefinition.id = groupJson["crowdDefinitionId"].int
            groupDefinition.name = groupJson["crowdDefinitionName"].string
            for (quotaIndex: String, quotaJson : JSON) in groupJson["quotaDatas"] {
                let quota = Quota()
                quota.id = quotaJson["quotaDataId"].int
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
  
    
    @IBAction func didDeleteAction(sender: AnyObject) {
        
        if NSClassFromString("UIAlertController") != nil {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let deleteAction = UIAlertAction(title: "删除", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.removeVisit()
            })
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                println("Cancelled")
            })
            
            optionMenu.addAction(deleteAction)
            optionMenu.addAction(cancelAction)
            self.presentViewController(optionMenu, animated: true, completion: nil)
        } else {
            let myActionSheet = UIActionSheet()
            myActionSheet.addButtonWithTitle("删除")
            myActionSheet.addButtonWithTitle("取消")
            myActionSheet.cancelButtonIndex = 1
            myActionSheet.showInView(self.view)
            myActionSheet.delegate = self
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        if buttonIndex == 0 {
            removeVisit()
        }
    }
    
    func removeVisit() {
        let url = SERVER_DOMAIN + "visit/delete"
        let params : [String : AnyObject] = ["token" : TOKEN, "visitId" : visit.id]
         HttpApiClient.sharedInstance.save(url, paramters: params, loadingPosition: HttpApiClient.LOADING_POSTION.FULL_SRCEEN, viewController: self, success: removeResult, fail: nil)
    }
    
    func removeResult(json : JSON) {
        var fieldErrors = Array<String>()
        var removeResult = false
        //set result and error from server
        removeResult = json["stat"].int == 0 ? true : false
        for (index: String, errorJson: JSON) in json["fieldErrors"] {
            if let error = errorJson[index].string {
                fieldErrors.append(error)
            }
        }
        if removeResult && fieldErrors.count == 0 {
            //self.performSegueWithIdentifier("completeAddPatientSegue", sender: self)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

    
}

