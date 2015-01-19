//
//  EditQuotaTableViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 15-1-13.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//



import UIKit

class EditQuotaTableViewController: UITableViewController,UITextFieldDelegate {
    var visit : Visit!
    var patient : Patient!
    var crowDefinition : GroupDefinition!
    var quota : Quota!
    var fieldDatas = Array<Data>()
    
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
            return cell
        } else if fieldData.visibleType == Data.VisibleType.TEXT {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("quotaFormTextCell", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = fieldData.columnName
            cell.detailTextLabel?.text = fieldData.value
            return cell
        }  else {
            let cell = tableView.dequeueReusableCellWithIdentifier("quotaFormCell", forIndexPath: indexPath) as QuotaFormCell
            cell.name.text = fieldData.columnName
            cell.name.sizeToFit()
            cell.unit.text = fieldData.unitName
            cell.value.text = fieldData.value
            cell.value.delegate = self
            if let visibleType = fieldData.visibleType {
                switch visibleType {
                case Data.VisibleType.INPUT :
                    if fieldData.columnType == Data.ColumnType.NUMBER {
                        cell.value.keyboardType = UIKeyboardType.NumberPad
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
    
    func loadData() {
        let url = SERVER_DOMAIN + "quota/toEditQuota"
        let parameters : [ String : AnyObject] = ["token": TOKEN, "quotaDataId": quota.id, "patientSeeDoctorId" : 1, "patientId" : 1]
        HttpApiClient.sharedInstance.get(url, paramters : parameters, success: fillData, fail : nil)
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
        
        patient.id = json["data"]["patientId"].int
        visit.id = json["data"]["patientSeeDoctorId"].int
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
            fieldData.id = fieldDatasJson["quotaFieldDataId"].int
            fieldData.definitionId = fieldDatasJson["quotaDefinitionId"].int
            fieldData.columnName = fieldDatasJson["columnName"].string
            fieldData.value = fieldDatasJson["quotaFieldValue"].string
            fieldData.columnType = fieldDatasJson["columnType"].int
            fieldData.isRequired = getBool(fieldDatasJson["isRequired"].int!)
            fieldData.visibleType = fieldDatasJson["visibleType"].int
            fieldData.unitName = fieldDatasJson["unitName"].string
            fieldData.isDrug = getBool(fieldDatasJson["isDrug"].int!)
            fieldData.isValid = getBool(fieldDatasJson["isValid"].int!)
            setVisibleTypeForDrug(fieldData)
            fieldDatas.append(fieldData)
        }
        self.tableView.reloadData()
    }
    
    func showDatePicker(sender: UITextField) {
        currentEditField = sender
        sender.inputView = UIDatePicker().customPickerStyle(self.view)
        sender.inputAccessoryView = UIToolbar().customPickerToolBarStyle(self.view, doneSelector: Selector("handleDatePicker:"), target : self)
    }
    
    func handleDatePicker(sender: UIBarButtonItem) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var datePicker = currentEditField.inputView as UIDatePicker?
        if let date = datePicker?.date {
            currentEditField.text = dateFormatter.stringFromDate(date)
            currentEditField.endEditing(true)
        }
    }
    
    func getBool(intValue : Int) -> Bool {
        if intValue == Data.BoolIntValue.FALSE {
            return false
        } else if intValue == Data.BoolIntValue.TRUE {
            return true
        }
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let cell = textField.superview?.superview?.superview as? QuotaFormCell {
            let indexPath = self.tableView.indexPathForCell(cell)!
            let data = fieldDatas[indexPath.row]
            if data.visibleType == Data.VisibleType.INPUT || data.visibleType == Data.VisibleType.TIME {
                data.value = textField.text
            }
        }
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
            self.saveQuotaForm()
        }
        return false
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEditOptionSegue" {
            let optionsTableViewController = segue.destinationViewController as OptionsTableViewController
            let cell = sender as QuotaFormCell
            let indexPath = self.tableView.indexPathForCell(cell)!
            let data = fieldDatas[indexPath.row]
            optionsTableViewController.navigationItem.title = data.columnName
            optionsTableViewController.data = data
            optionsTableViewController.editingCell = cell
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
    
    @IBAction func swithcDidEndEditing(sender: UISwitch) {
        let cell = sender.superview?.superview?.superview as QuotaFormSwitchCell
        let indexPath = self.tableView.indexPathForCell(cell)!
        let data = fieldDatas[indexPath.row]
        if sender.on {
            data.value = "\(Data.BoolIntValue.TRUE)"
        } else {
            data.value = "\(Data.BoolIntValue.FALSE)"
        }
    }
    
    func saveQuotaForm() {
        let url = SERVER_DOMAIN + "quota/editQuota"
        let quotaFieldDataIds = ",".join(fieldDatas.map({ "\($0.id)" }))
        let columnTypes = ",".join(fieldDatas.map({ "\($0.columnType)" }))
        let columnNames = ",".join(fieldDatas.map({ "\($0.columnName)" }))
        let quotaFieldValues = ",".join(fieldDatas.map({ "\($0.value)" }))
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
        HttpApiClient.sharedInstance.post(url, paramters : parameters, success: addResult, fail : nil)
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
            data.visibleType = Data.VisibleType.SELECT
        } else if data.columnName == "中文通用名" || data.columnName == "英文通用名" {
            data.visibleType = Data.VisibleType.TEXT
        }
    }
}

