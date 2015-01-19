//
//  QuotaDetailTabelViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-15.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//

import UIKit

class QuotaDetailTabelViewController: UITableViewController, UIActionSheetDelegate {
    var quota : Quota!
    var patient : Patient!
    var datas = Array<Data>()
    var crowDefition : GroupDefinition!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.loadData()
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = UITableViewHeaderFooterView(frame: CGRectMake(0, 0, tableView.frame.size.width, 80))
        
        sectionHeaderView.tintColor = UIColor.sectionColor()
        var label:UILabel = UILabel(frame: CGRectMake(10
            ,10, sectionHeaderView.frame.size.width - 10, 70));
        label.numberOfLines = 0;
        label.font = UIFont.systemFontOfSize(17.0);
        label.text = "\( quota.groupNamePath )\n检查时间：\(quota.checkTime)";
        sectionHeaderView.addSubview(label);
        label.adjustsFontSizeToFitWidth = true
        return sectionHeaderView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("showQuotaCell", forIndexPath: indexPath) as UITableViewCell
        let data = datas[indexPath.row]
        cell.textLabel?.text = data.columnName
        if data.unitName != nil {
            cell.detailTextLabel?.text = "\(data.value) \(data.unitName)"
        } else {
            cell.detailTextLabel?.text = data.value
        }
        return cell
    }
  
    func loadData() {
        let url = SERVER_DOMAIN + "quota/quotaDetails"
        let parameters : [ String : AnyObject] = ["token": TOKEN, "quotaDataId": quota.id]
        HttpApiClient.sharedInstance.get(url, paramters : parameters, success: fillData, fail : nil)
        
    }
    
    func fillData(json : JSON) {
        datas.removeAll(keepCapacity: true)
        quota.groupNamePath = json["data"]["groupNamePath"].string
        quota.checkTime = json["data"]["checkTimestampStr"].string
        if let type = json["data"]["groupDefinitionType"].int {
            if type == GroupDefinition.TYPE.TEXT {
               if crowDefition.name == "疾病诊断" {
                let switchData = Data()
                switchData.definitionId = Data.DefinitionId.DIAG_MAIN
                switchData.columnName = "主要诊断"
                switchData.columnType = Data.ColumnType.NUMBER
                switchData.isRequired = true
                switchData.visibleType = Data.VisibleType.DERAIL
                switchData.unitName = nil
                switchData.isDrug = false
                switchData.isValid = false
                switchData.value = "否"
                if let isImprotant = json["data"]["isImportant"].int {
                    if isImprotant ==  Data.BoolIntValue.TRUE {
                        switchData.value = "是"
                    }
                }
                datas.append(switchData)
                }
            }
            
        }
        for (groupIndex: String, fieldDatasJson : JSON) in json["data"]["quotaFieldDatas"]  {
                let fieldData = Data()
                //fieldData.definitionId = fieldDatasJson["quotaDefinitionId"].int
                fieldData.columnName = fieldDatasJson["columnName"].string
                fieldData.value = fieldDatasJson["quotaFieldValue"].string
                fieldData.unitName = fieldDatasJson["unitName"].string
                //fieldData.columnType = fieldDatasJson["columnType"].int
                //fieldData.isRequired = getBool(fieldDatasJson["isRequired"].int!)
                //fieldData.visibleType = fieldDatasJson["visibleType"].int
                //fieldData.isDrug = getBool(fieldDatasJson["isDrug"].int!)
                //fieldData.isValid = getBool(fieldDatasJson["isValid"].int!)
                datas.append(fieldData)
        }
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editQuotaSegue" {
            let editQuotaTableViewController = segue.destinationViewController  as EditQuotaTableViewController
            editQuotaTableViewController.quota = quota
            editQuotaTableViewController.patient = patient
            editQuotaTableViewController.crowDefinition = crowDefition
        }
    }
    @IBAction func completeEditQuota(segue : UIStoryboardSegue) {
        self.loadData()
    }
    
    @IBAction func didDeleteAction(sender: AnyObject) {
        if NSClassFromString("UIAlertController") != nil {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let deleteAction = UIAlertAction(title: "删除", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.removeQuota()
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
            removeQuota()
        }
    }
    
    func removeQuota() {
        let url = SERVER_DOMAIN + "quota/delete"
        let params : [String : AnyObject] = ["token" : TOKEN, "quotaDataId" : quota.id]
        HttpApiClient.sharedInstance.post(url, paramters : params, success: removeResult, fail : nil)
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
