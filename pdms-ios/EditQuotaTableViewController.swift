//
//  EditQuotaTableViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 15-1-13.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//



import UIKit

class EditQuotaTableViewController: UITableViewController, UIActionSheetDelegate,UITextFieldDelegate {
    var visit : Visit!
    var patient : Patient!
    var crowDefinition : GroupDefinition!
    var quota : Quota!
    var fieldDatas = Array<Data>()
    var inputDict = Dictionary<UIView, Int>()
    var currentEditField : UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fieldDatas.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let fieldData = fieldDatas[indexPath.row]
        if fieldData.visibleType == Data.VisibleType.DERAIL {
            let cell = tableView.dequeueReusableCellWithIdentifier("quotaFormSwitchCell", forIndexPath: indexPath) as QuotaFormSwitchCell
            cell.name.text = fieldData.columnName
            cell.swtichBtn.on = getBool(fieldData.value.toInt()!)
            inputDict[cell.swtichBtn] = indexPath.row
            return cell
        } else if fieldData.visibleType == Data.VisibleType.TEXT {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("quotaFormTextCell", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = fieldData.columnName
            cell.detailTextLabel?.text = fieldData.value
            return cell
        }  else {
            let cell = tableView.dequeueReusableCellWithIdentifier("quotaFormCell", forIndexPath: indexPath) as QuotaFormCell
            cell.name.numberOfLines = 0
            cell.name.text = fieldData.columnName
            cell.name.sizeToFit()
            cell.unit.text = fieldData.unitName
            cell.value.text = fieldData.value
            cell.value.tag = fieldData.visibleType
            cell.value.delegate = self
            inputDict[cell.value] = indexPath.row
//            if !fieldData.isValid {
//                cell.value.textColor = UIColor.redColor()
//            }
            if let visibleType = fieldData.visibleType {
                switch visibleType {
                case Data.VisibleType.INPUT :
                    if fieldData.columnType == Data.ColumnType.NUMBER {
                        cell.value.keyboardType = UIKeyboardType.DecimalPad
                    }
                case Data.VisibleType.TIME :
                    cell.value.addTarget(self, action: "showDatePicker:", forControlEvents: UIControlEvents.EditingDidBegin)
                case Data.VisibleType.RADIO, Data.VisibleType.CHECKBOX,Data.VisibleType.SELECT :
                    cell.value.userInteractionEnabled = false
                default :
                    if let value = cell.value {
                        cell.value.keyboardType = UIKeyboardType.Default
                    }
                }
            }
            return cell
            
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let fieldData = fieldDatas[indexPath.row]
        let labelHeight = UILabel.heightForDynamicText(fieldData.columnName, font: UIFont.systemFontOfSize(17.0), width: 125.0)
        return 23 + labelHeight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func loadData() {
        let url = SERVER_DOMAIN + "quota/toEditQuota"
        let parameters : [ String : AnyObject] = ["token": TOKEN, "quotaDataId": quota.id, "patientSeeDoctorId" : 1, "patientId" : 1]
        HttpApiClient.sharedInstance.getLoading(url, paramters: parameters, loadingPosition: HttpApiClient.LOADING_POSTION.AFTER_TABLEVIEW, viewController: self, success: fillData, fail: nil)
    }
    
    func fillData(json : JSON) {
        if patient == nil {
            patient = Patient()
        }
        if visit == nil {
            visit = Visit()
        }
        if quota == nil {
            quota = Quota()
        }
        
        patient.id = json["data"]["patientId"].number
        visit.id = json["data"]["patientSeeDoctorId"].number
        quota.name = json["data"]["groupDefinitionName"].string
        quota.groupNamePath = json["data"]["groupNamePath"].string
        
        if let type = json["data"]["groupDefinitionType"].int {
            if type == GroupDefinition.TYPE.TEXT {
                if crowDefinition.name == "疾病诊断" {
                    let switchData = Data()
                    switchData.id = Data.DefinitionId.DIAG_MAIN
                    switchData.definitionId = Data.DefinitionId.DIAG_MAIN
                    switchData.columnName = "主要诊断"
                    switchData.columnType = Data.ColumnType.NUMBER
                    switchData.isRequired = true
                    switchData.visibleType = Data.VisibleType.DERAIL
                    switchData.unitName = nil
                    switchData.isDrug = false
                    switchData.isValid = false
                    switchData.value = "0"
                    if let isImprotant = json["data"]["isImportant"].int {
                        if isImprotant ==  Data.BoolIntValue.TRUE {
                            switchData.value = "\(isImprotant)"
                        }
                    }
                    fieldDatas.append(switchData)
                }
            }
            
        }
        if let dDate = Data.generateCheckTime(crowDefinition) {
            dDate.value = json["data"]["checkTimestampStr"].string
            dDate.id = Data.DefinitionId.DIAG_DATE
            fieldDatas.append(dDate)
        }
        for (index: String, fieldDatasJson: JSON) in json["data"]["quotaFieldDatas"]  {
            let fieldData = Data()
            fieldData.id = fieldDatasJson["quotaFieldDataId"].number
            fieldData.definitionId = fieldDatasJson["quotaDefinitionId"].number
            fieldData.columnName = fieldDatasJson["columnName"].string
            fieldData.value = fieldDatasJson["quotaFieldValue"].string
            fieldData.columnType = fieldDatasJson["columnType"].int
            fieldData.isRequired = getBool(fieldDatasJson["isRequired"].int!)
            fieldData.visibleType = fieldDatasJson["visibleType"].int
            fieldData.unitName = fieldDatasJson["unitName"].string
            fieldData.isDrug = getBool(fieldDatasJson["isDrug"].int!)
            let isValid = fieldDatasJson["isValid"].int!
            if isValid == 0 {
                fieldData.isValid = true
            } else if isValid == 1 {
                fieldData.isValid = false
            }
            setVisibleTypeForDrug(fieldData)
            fieldDatas.append(fieldData)
            
        }
        self.tableView.reloadData()
    }

    func showDatePicker(sender: UITextField) {
        if sender.tag == Data.VisibleType.TIME {
            currentEditField = sender
            sender.inputView = UIDatePicker().customPickerStyle(self.view)
            sender.inputAccessoryView = UIToolbar().customPickerToolBarStyle(self.view, doneSelector: Selector("handleDatePicker:"), target : self)
        } else {
            sender.inputView = nil
            sender.inputAccessoryView = nil
        }
        
    }
    
    func handleDatePicker(sender: UIBarButtonItem) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var datePicker = currentEditField.inputView as UIDatePicker?
        if let date = datePicker?.date {
            currentEditField.text = dateFormatter.stringFromDate(date)
            currentEditField.endEditing(true)
        }
        
       currentEditField.inputView = nil
        currentEditField.inputAccessoryView = nil
    }
    
    func getBool(intValue : Int) -> Bool {
        if intValue == Data.BoolIntValue.FALSE {
            return false
        } else if intValue == Data.BoolIntValue.TRUE {
            return true
        }
        return false
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "showEditOptionSegue" {
            if let cell = sender as? QuotaFormCell {
                let indexPath = self.tableView.indexPathForCell(cell)!
                let data = fieldDatas[indexPath.row]
                if data.visibleType == Data.VisibleType.SELECT ||  data.visibleType == Data.VisibleType.CHECKBOX ||  data.visibleType == Data.VisibleType.RADIO {
                    return true
                }
            }
        } else if identifier == "completeEditQuotaSegue" {
            endTextFieldEditing()
            for var i = 0 ; i < fieldDatas.count; ++i {
                let fieldData = fieldDatas[i]
                if fieldData.isRequired && (fieldData.value == nil || fieldData.value.isEmpty) {
                    CustomAlertView.showMessage(fieldDatas[i].columnName + "必填", parentViewController: self)
                    return false
                }
            }
            self.saveQuotaForm()
        }
        return false
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEditOptionSegue" {
            endTextFieldEditing()
            let optionsTableViewController = segue.destinationViewController as OptionsTableViewController
            let cell = sender as QuotaFormCell
            let indexPath = self.tableView.indexPathForCell(cell)!
            let data = fieldDatas[indexPath.row]
            optionsTableViewController.navigationItem.title = data.columnName
            optionsTableViewController.data = data
            optionsTableViewController.editingCell = cell
            //optionsTableViewController.parentGroupDefinition = parentGroupDefinition
            if data.visibleType == Data.VisibleType.CHECKBOX {
                optionsTableViewController.mutilSelect = true
            }
        }
        
    }
    
    @IBAction func completeSelectOption(segue : UIStoryboardSegue) {
        let optionsTableViewController = segue.sourceViewController as OptionsTableViewController
        if optionsTableViewController.selectedOptions.count > 0 {
            let selectedLabel = ",".join(optionsTableViewController.selectedOptions.map({ "\($0.label)" }))
            //let selectedValue = ",".join(optionsTableViewController.selectedOptions.map({ "\($0.value)" }))
            setTextFieldValueAndData(optionsTableViewController.editingCell, textFieldValue: selectedLabel, dataValue: selectedLabel)
        } else {
            optionsTableViewController.editingCell.value.text = nil
            setTextFieldValueAndData(optionsTableViewController.editingCell, textFieldValue: nil, dataValue: nil)
        }
        
    }
    
    func setTextFieldValueAndData(cell: QuotaFormCell, textFieldValue: String?, dataValue : String?) {
        cell.value.text = textFieldValue
        let indexPath = self.tableView.indexPathForCell(cell)!
        fieldDatas[indexPath.row].value = dataValue
    }
    func textFieldDidEndEditing(textField: UITextField) {
        if let row = inputDict[textField] {
            let data = fieldDatas[row]
            if data.visibleType == Data.VisibleType.INPUT || data.visibleType == Data.VisibleType.TIME {
                data.value = textField.text
            }
        }
    }
    
    @IBAction func swithcDidEndEditing(sender: UISwitch) {
        if let row = inputDict[sender] {
          let data = fieldDatas[row]
          if sender.on {
              data.value = "\(Data.BoolIntValue.TRUE)"
            } else {
                data.value = "\(Data.BoolIntValue.FALSE)"
            }
        }
    }


    func saveQuotaForm() {
        let url = SERVER_DOMAIN + "quota/editQuota"
        let quotaFieldDataIds = ",".join(fieldDatas.map({ "\($0.id)" }))
        let columnTypes = ",".join(fieldDatas.map({ "\($0.columnType)" }))
        let columnNames = ",".join(fieldDatas.map({ "\($0.columnName)" }))
        let quotaFieldValues = ",".join(fieldDatas.map({ "\(StringUtil.igonreNilString($0.value))" }))
        let parameters : [ String : AnyObject] = [
            "token": TOKEN,
            "patientSeeDoctorId": visit.id,
            "quotaFieldDataId" : quotaFieldDataIds,
            "crowdDefinitionId" : crowDefinition.id,
            "columnTypes" : columnTypes,
            "columnNames" : columnNames,
            "quotaFieldValues" : quotaFieldValues,
            "patientId" : patient.id,
            "quotaDataId" : quota.id
        ]
        HttpApiClient.sharedInstance.save(url, paramters: parameters, loadingPosition: HttpApiClient.LOADING_POSTION.NAIGATIONBAR, viewController: self, success: addResult, fail: nil)
    }
    
    
    func addResult(json : JSON) {
        //reset result and errors
        var fieldErrors = Array<String>()
        var saveResult = false
        //set result and error from server
        saveResult = json["stat"].int == 0 ? true : false
        for (index: String, errorJson: JSON) in json["fieldErrors"] {
            if let error = errorJson[index].string {
                fieldErrors.append(error)
            }
        }
        if saveResult && fieldErrors.count == 0 {
            self.performSegueWithIdentifier("completeEditQuotaSegue", sender: self)
        }
    }
    
    func setVisibleTypeForDrug(data : Data) {
        if data.columnName == "中文商品名" ||  data.columnName == "英文商品名" || data.columnName == "剂型" || data.columnName == "规格" || data.columnName == "单位" || data.columnName == "用法" {
            if data.columnName == "英文商品名" {
                data.isRequired = false
            }
            data.visibleType = Data.VisibleType.SELECT
        } else if data.columnName == "中文通用名" || data.columnName == "英文通用名" {
            data.visibleType = Data.VisibleType.TEXT
        }
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
            self.dismissViewControllerAnimated(false, completion: nil)
            self.performSegueWithIdentifier("completeDeleteQuotaSegue", sender: self)

        }
    }
    
    func endTextFieldEditing() {
        for key in inputDict.keys {
            if let textField = key as? UITextField {
                textField.endEditing(true)
            }
        }
    }
}

