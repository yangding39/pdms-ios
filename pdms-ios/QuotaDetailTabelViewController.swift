//
//  QuotaDetailTabelViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-15.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//

import UIKit

class QuotaDetailTabelViewController: UITableViewController{
    var quota : Quota!
    var patient : Patient!
    var datas = Array<Data>()
    var crowDefition : GroupDefinition!
    override func viewDidLoad() {
        super.viewDidLoad()
        if var frame = self.tableView.tableFooterView?.frame {
            frame.size.height = 44
            self.tableView.tableFooterView?.frame = frame
            self.tableView.updateConstraintsIfNeeded()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.loadData()
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let label = UILabel(frame: CGRectMake(15, 8, self.tableView.bounds.width - 30, 40))
        label.font = UIFont.systemFontOfSize(18)
        label.textColor = UIColor.grayColor()
        label.numberOfLines = 0
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.sizeToFit()
        let sectionHeaderView = UIView(frame: CGRectMake(0, 0, self.tableView.bounds.width, label.frame.height))
        sectionHeaderView.addSubview(label)
        sectionHeaderView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        return sectionHeaderView
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        if let namePath = quota.groupNamePath {
            title += namePath
            if let checkTime = quota.checkTime {
                title += "\n检查时间 ：" + checkTime
            }
        }
       
        return title
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let title = self.tableView(tableView, titleForHeaderInSection: section) {
            let height = UILabel.heightForDynamicText(title, font: UIFont.systemFontOfSize(18.0), width: self.tableView.bounds.width - 30 )
            if height == 0 {
                return 0
            } else {
              return height + 16
            }
        } else {
            return 0
        }
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
        if !data.isValid {
            cell.detailTextLabel?.textColor = UIColor.redColor()
        } else {
            cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
        }
        return cell
    }
  
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func loadData() {
        let url = SERVER_DOMAIN + "quota/quotaDetails"
        let parameters : [ String : AnyObject] = ["token": TOKEN, "quotaDataId": quota.id]
        HttpApiClient.sharedInstance.getLoading(url, paramters: parameters, loadingPosition: HttpApiClient.LOADING_POSTION.AFTER_TABLEVIEW, viewController: self, success: fillData, fail: nil)
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
                switchData.isValid = true
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
                //fieldData.definitionId = fieldDatasJson["quotaDefinitionId"].number
                fieldData.columnName = fieldDatasJson["columnName"].string
                fieldData.value = fieldDatasJson["quotaFieldValue"].string
                fieldData.unitName = fieldDatasJson["unitName"].string
                //fieldData.columnType = fieldDatasJson["columnType"].int
                //fieldData.isRequired = getBool(fieldDatasJson["isRequired"].int!)
                //fieldData.visibleType = fieldDatasJson["visibleType"].int
                //fieldData.isDrug = getBool(fieldDatasJson["isDrug"].int!)
                let isValid = fieldDatasJson["isValid"].int
                if isValid == 0 {
                    fieldData.isValid = true
                } else if isValid == 1 {
                    fieldData.isValid = false
                }
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
   
}
