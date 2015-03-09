//
//  EditQuotaTableViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 15-1-13.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//



import UIKit

class EditQuotaTableViewController: UITableViewController, UITextFieldDelegate {
    var visit : Visit!
    var patient : Patient!
    var crowDefinition : GroupDefinition!
    var quota : Quota!
    var fieldDatas = Array<Data>()
    var inputTexts = Dictionary<UIView, Int>()
    var currentEditField : UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
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
            inputTexts[cell.swtichBtn] = indexPath.row
            return cell
        } else if fieldData.visibleType == Data.VisibleType.TEXT {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("quotaFormTextCell", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = fieldData.columnName
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = fieldData.value
            return cell
        }  else {
            let cell = tableView.dequeueReusableCellWithIdentifier("quotaFormCell", forIndexPath: indexPath) as QuotaFormCell
            cell.name.numberOfLines = 0
            cell.name.text = fieldData.columnName
            if fieldData.columnName == "天" {
                cell.name.text = "用量（天）"
            }
            if fieldData.columnName == "次" {
                cell.name.text = "用量（次）"
            }
            cell.name.sizeToFit()
            cell.unit.text = fieldData.unitName
            cell.value.text = fieldData.value
            cell.value.tag = fieldData.visibleType
            cell.value.delegate = self
            inputTexts[cell.value] = indexPath.row
            cell.value.userInteractionEnabled = true
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
                case Data.VisibleType.RADIO, Data.VisibleType.CHECKBOX,Data.VisibleType.SELECT, Data.VisibleType.SELECT_INPUT :
                    cell.value.addTarget(self, action: "showOptionsPicker:", forControlEvents: UIControlEvents.EditingDidBegin)
                case Data.VisibleType.CHECKBOX :
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
        
        if let dDate = Data.generateCheckTime(crowDefinition, forForm : true) {
            dDate.value = json["data"]["checkTimestampStr"].string
            dDate.id = Data.DefinitionId.DIAG_DATE
            fieldDatas.append(dDate)
        }
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
            sender.inputView = CustomDatePicker(frame : CGRectMake(0, 0, self.view.bounds.width, 160))
            sender.inputAccessoryView = UIToolbar().customPickerToolBarStyle(self.view, doneSelector: Selector("handleDatePicker:"), target : self)
        } else {
            sender.inputView = nil
            sender.inputAccessoryView = nil
        }
        
    }
    
    func handleDatePicker(sender: UIBarButtonItem) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var datePicker = currentEditField.inputView as? CustomDatePicker
        if let date = datePicker?.date {
            currentEditField.text = dateFormatter.stringFromDate(date)
            currentEditField.endEditing(true)
        }
        
    }
    func showOptionsPicker(sender: UITextField) {
        if sender.tag == Data.VisibleType.SELECT  ||  sender.tag == Data.VisibleType.RADIO || sender.tag == Data.VisibleType.SELECT_INPUT {
            currentEditField = sender
            if let row  = self.inputTexts[sender] {
                let optionPicker = CustomOptionPicker(frame: CGRectMake(0, 0, self.view.bounds.width, 160))
                optionPicker.data = self.fieldDatas[row]
                sender.inputView = optionPicker
                optionPicker.commonInit()
                var toolBar = UIToolbar().customPickerToolBarStyle(self.view, doneSelector: Selector("handleOptionsPicker:"), target : self)
                if sender.tag == Data.VisibleType.SELECT_INPUT {
                    toolBar = UIToolbar().customPickerToolBarAndKeyBoard(self.view, doneSelector: Selector("handleOptionsPicker:"), inputSelector: Selector("showKeyBoard:"), target: self)
                }
                sender.inputAccessoryView = toolBar
            }
            
        } else {
            sender.inputView = nil
            sender.inputAccessoryView = nil
        }
        
    }
    
    func handleOptionsPicker(sender: UIBarButtonItem) {
        let optionsPicker = currentEditField.inputView as? CustomOptionPicker
        if let value = optionsPicker?.value {
            if optionsPicker?.data.columnName == "中文商品名" {
                let optionPickerValue = value
                currentEditField.text = optionsPicker?.getTradeCN(optionPickerValue)
                var index = 0
                for data in self.fieldDatas {
                    if data.columnName == "英文商品名" {
                        for (view, row) in inputTexts {
                            if row == index {
                                if let tradeENTextField = view as? UITextField {
                                    let tradeENValue = optionsPicker?.getTradeEN(optionPickerValue)
                                    tradeENTextField.text = tradeENValue
                                    data.value = tradeENValue
                                }
                                break;
                            }
                        }
                    }
                    index++
                }
            } else {
                currentEditField.text = value
            }
        }
        currentEditField.endEditing(true)
    }
    
    func showKeyBoard(sender: UIBarButtonItem) {
        currentEditField.endEditing(true)
        currentEditField.inputView = nil
        currentEditField.inputAccessoryView = nil
        currentEditField.removeTarget(self, action: "showOptionsPicker:", forControlEvents: UIControlEvents.EditingDidBegin)
        currentEditField.keyboardType = UIKeyboardType.Default
        currentEditField.becomeFirstResponder()
        
        currentEditField.addTarget(self, action: "showOptionsPicker:", forControlEvents: UIControlEvents.EditingDidBegin)
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
                if  data.visibleType == Data.VisibleType.CHECKBOX {
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
        if let row = inputTexts[textField] {
            let data = fieldDatas[row]
            if data.visibleType != Data.VisibleType.CHECKBOX {
                data.value = textField.text
                setDrugQuantityAndTime()
            }
        }
    }
    
    @IBAction func swithcDidEndEditing(sender: UISwitch) {
        if let row = inputTexts[sender] {
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
            visit.setVisitMainDiagnose(fieldDatas, mainDiagnose : quota.name)
            self.performSegueWithIdentifier("completeEditQuotaSegue", sender: self)
        }
    }
    
    func setVisibleTypeForDrug(data : Data) {
        if data.columnName == "英文通用名" || data.columnName == "中文商品名" || data.columnName == "剂型" || data.columnName == "规格" || data.columnName == "单位" || data.columnName == "用法" {
            data.visibleType = Data.VisibleType.SELECT_INPUT
        } else if data.columnName == "中文通用名" || data.columnName == "日剂量" || data.columnName == "总天数" || data.columnName == "总剂量" {
            data.visibleType = Data.VisibleType.TEXT
        }
    }
    
    func setDrugQuantityAndTime() {
        var startTime : Data?
        var endTime : Data?
        var quantityUnit : Data?
        var day : Data?
        var number : Data?
        
        var dayQuantity : Data?
        var dayNumber : Data?
        var totalQuantity : Data?
        for data in fieldDatas {
            if data.columnName == "开始时间" {
                startTime = data
            } else if data.columnName == "结束时间" {
                endTime = data
            } else if data.columnName == "剂量" {
                quantityUnit = data
            } else if data.columnName == "天" {
                day = data
            } else if data.columnName == "次" {
                number = data
            } else if data.columnName == "日剂量" {
                dayQuantity = data
            } else if data.columnName == "总天数" {
                dayNumber = data
            }  else if data.columnName == "总剂量" {
                totalQuantity = data
            }
        }
        
        dayQuantity?.value = getDayQuantity(quantityUnit, day: day, number: number)
        let days = getDays(startTime, endTime: endTime)
        dayNumber?.value = "\(days)"
        totalQuantity?.value = getTotalQuantity(dayQuantity, dayNumber: dayNumber)
        
        for var i = 0; i < fieldDatas.count; ++i {
            let data = fieldDatas[i]
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) {
                if cell.textLabel?.text != data.columnName {
                    continue
                }
                if data.columnName == "日剂量" {
                    cell.detailTextLabel?.text = dayQuantity?.value
                   
                } else if data.columnName == "总天数" {
                    cell.detailTextLabel?.text = dayNumber?.value
                }  else if data.columnName == "总剂量" {
                    cell.detailTextLabel?.text = totalQuantity?.value
                }
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            }
        }
        
    }
    
    func getDays(startTime : Data?, endTime : Data?) -> String {
        if var startTimeValue = startTime?.value {
            if var endTimeValue = endTime?.value {
                if startTimeValue.isEmpty || endTimeValue.isEmpty {
                    return ""
                }
                startTimeValue = startTimeValue.componentsSeparatedByString(" ")[0]
                endTimeValue = endTimeValue.componentsSeparatedByString(" ")[0]
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let calendar = NSCalendar.currentCalendar()
                let timeComponents = calendar.components(.CalendarUnitDay,
                    fromDate: dateFormatter.dateFromString(startTimeValue)!,
                    toDate: dateFormatter.dateFromString(endTimeValue)!,
                    options: nil)
                if timeComponents.day < 0 {
                    return ""
                } else if timeComponents.day == 0 {
                    return "1"
                }else {
                    return "\(timeComponents.day)"
                }
            }
        }
        return ""
    }
    
    func getDayQuantity(quantityUnit : Data?, day : Data?, number : Data?) -> String {
        if let quantityUnitValue = quantityUnit?.value {
            if let dayValue = day?.value {
                if let numberValue = number?.value {
                    let quantityUnitDouble = (quantityUnitValue as NSString).doubleValue
                    let numberDouble = (numberValue  as NSString).doubleValue
                    let dayDouble = (dayValue as NSString).doubleValue
                    let dayQuantity = quantityUnitDouble * numberDouble / dayDouble
                    if dayQuantity <= 0 {
                        return ""
                    }
                    return String(format:"%.2f", dayQuantity)
                }
            }
        }
        return ""
    }
    
    
    func getTotalQuantity(dayQuantity : Data?, dayNumber : Data?) -> String {
        if let dayQuantityValue = dayQuantity?.value {
            if let dayNumberValue = dayNumber?.value {
                let dayQuantityDouble = (dayQuantityValue as NSString).doubleValue
                let dayNumberDouble = (dayNumberValue as NSString).doubleValue
                let totalQuantity = dayQuantityDouble * dayNumberDouble
                if totalQuantity <= 0 {
                    return ""
                }
                return String(format:"%.2f", totalQuantity)
            }
        }
        return ""
    }
        
    func endTextFieldEditing() {
        for key in inputTexts.keys {
            if let textField = key as? UITextField {
                textField.endEditing(true)
            }
        }
    }
}

