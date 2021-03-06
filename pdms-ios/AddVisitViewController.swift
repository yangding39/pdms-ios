//
//  AddVisitViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-10.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//


import UIKit

class AddVisitViewController: UITableViewController {

    @IBOutlet weak var typeLabel: UITextField!

    @IBOutlet weak var number: UITextField!
    
    @IBOutlet weak var departmentLabel: UITextField!
    
    @IBOutlet weak var startTime: UITextField!
    
    @IBOutlet weak var endTime: UITextField!
    
    var typeOptions = Array<Option>()
    
    var departmentOptions : Dictionary<String, Array<Option>> = [:]
    
    var rootDepartments = Array<String>()
    
    var isDepartmentOptions = false
    
    var currentTextField : UITextField?
    
    var patient : Patient!
    
    var visit = Visit()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadOptions()
        
        startTime.addTarget(self, action: "showDatePicker:", forControlEvents: UIControlEvents.EditingDidBegin)
        endTime.addTarget(self, action: "showDatePicker:", forControlEvents: UIControlEvents.EditingDidBegin)
        
        typeLabel.addTarget(self, action: "showSelectPicker:", forControlEvents: UIControlEvents.EditingDidBegin)
        departmentLabel.addTarget(self, action: "showSelectPicker:", forControlEvents: UIControlEvents.EditingDidBegin)
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadOptions() {
        let url = SERVER_DOMAIN + "visit/add"
        let parameters = ["token": TOKEN]
        HttpApiClient.sharedInstance.getLoading(url, paramters: parameters, loadingPosition: HttpApiClient.LOADING_POSTION.AFTER_TABLEVIEW, viewController: self, success: fillOptions, fail: nil)
    }
    
    func fillOptions(json : JSON) {
        for (index: String, subJson: JSON) in json["data"]  {
            let dictId = subJson["dictId"].number
            if let dictName = subJson["dictName"].string {
                var subOptions = Array<Option>()
                for (optionIndex : String, optionJson : JSON) in subJson["options"] {
                    let option = Option()
                    option.label = optionJson["lable"].string!
                    option.value = optionJson["value"].number!
                    subOptions.append(option)
                }
                if dictName == "就诊类型" {
                    self.typeOptions = subOptions
                } else {
                    rootDepartments.append(dictName)
                    self.departmentOptions[dictName] = subOptions
                }
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "completeAddVisitSegue" {
            if typeLabel.text.isEmpty {
                CustomAlertView.showMessage("就诊类型必填", parentViewController: self)
                return false
            } else if number.text.isEmpty{
                CustomAlertView.showMessage("就诊号必填", parentViewController: self)
                return false
            } else if count(number.text) > 20 {
                CustomAlertView.showMessage("就诊号长度不能超过20", parentViewController: self)
                return false
            } else if departmentLabel.text.isEmpty{
                CustomAlertView.showMessage("科室必填", parentViewController: self)
                return false
            } else if startTime.text.isEmpty{
                CustomAlertView.showMessage("开始时间必填", parentViewController: self)
                return false
            }
            saveVisit()
        }
        return false
    }
    func saveVisit() {
        for option in typeOptions {
            if option.label == typeLabel.text {
                visit.type = option.value
                visit.typeLabel = option.label
                break
            }
        }
        visit.number = number.text
        for options in departmentOptions.values {
            for option in options {
                if option.label == departmentLabel.text {
                    visit.department = option.value
                    visit.departmentLabel = option.label
                    break
                }
            }
        }
        visit.startTime = startTime.text
        visit.endTime = endTime.text
        postData(visit)
    }
    func postData(visit : Visit) {
        let url = SERVER_DOMAIN + "visit/save"
        let params : [String : AnyObject] = ["token" : TOKEN, "patientId" : patient.id, "visitType" : visit.type, "visitNumber" : visit.number, "department" : visit.department, "startTime" : visit.startTime, "endTime" : visit.endTime]
        HttpApiClient.sharedInstance.save(url, paramters: params, loadingPosition: HttpApiClient.LOADING_POSTION.NAIGATIONBAR, viewController: self, success: addVisitResult, fail: nil)
    }
    
    func addVisitResult(json : JSON) {
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
            visit.id = json["data"]["visitId"].number
            visit.typeLabel = json["data"]["visitTypeLabel"].string
            visit.number = json["data"]["visitNumber"].string
            visit.departmentLabel = json["data"]["departmentLabel"].string
            visit.mainDiagonse = json["data"]["mainDiagnose"].string
            visit.startTime = json["data"]["startDate"].string
            visit.endTime = json["data"]["endDate"].string

            self.performSegueWithIdentifier("completeAddVisitSegue", sender: self)
        }

    }
    func showDatePicker(sender: UITextField) {
         sender.inputView = CustomDatePicker(frame : CGRectMake(0, 0, self.view.bounds.width, 160))

        var selector : Selector!
        if (sender == self.startTime) {
            selector = Selector("handleStartTimeDatePicker:")
        } else {
            selector = Selector("handleEndTimeDatePicker:")
        }
        sender.inputAccessoryView = UIToolbar().customPickerToolBarStyle(self.view, doneSelector: selector, target : self)
    }
    
    func handleStartTimeDatePicker(sender: UIBarButtonItem) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var datePicker = startTime.inputView as? CustomDatePicker
        if let date = datePicker?.date {
            startTime.text = dateFormatter.stringFromDate(date)
            startTime.endEditing(true)
        }
    }
    
    func handleEndTimeDatePicker(sender: UIBarButtonItem) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var datePicker = endTime.inputView as? CustomDatePicker
        if let date = datePicker?.date {
            endTime.text = dateFormatter.stringFromDate(date)
            endTime.endEditing(true)
        }
    }
    
    func showSelectPicker(sender: UITextField) {
        
        if (sender == self.typeLabel) {
            isDepartmentOptions = false
        } else {
            isDepartmentOptions = true
        }
        let pickerView = UIPickerView().customPickerStyle(self.view, delegate: self, dataSource: self)
        pickerView.showsSelectionIndicator = true
        sender.inputView = pickerView
        sender.inputAccessoryView = UIToolbar().customPickerToolBarStyle(self.view, doneSelector: Selector("handleSelectPicker:"), target : self)
        currentTextField = sender
    }
    
    func handleSelectPicker(sender: UIBarButtonItem) {
        
        var uiPicker = currentTextField!.inputView as! UIPickerView?
        if let index = uiPicker?.selectedRowInComponent(0) {
            if isDepartmentOptions {
                let fisrtLabel = self.rootDepartments[index]
                if let subIndex = uiPicker?.selectedRowInComponent(1) {
                    if let options = self.departmentOptions[fisrtLabel] {
                         currentTextField!.text = options[subIndex].label
                    }
                }
            } else {
                currentTextField!.text = self.typeOptions[index].label
            }
            
            currentTextField!.endEditing(true)
        }
    }
    
    @IBAction func didCancelBtn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension AddVisitViewController : UIPickerViewDataSource {
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if isDepartmentOptions {
            return 2
        }
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if isDepartmentOptions {
            if component == 0 {
                return self.departmentOptions.keys.array.count
            } else {
                let index = pickerView.selectedRowInComponent(0)
                let key = self.rootDepartments[index]
                if let options = self.departmentOptions[key] {
                     return  options.count
                } else {
                    return 0
                }
            }
        } else {
              return self.typeOptions.count
        }
    }
}

extension AddVisitViewController : UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if isDepartmentOptions {
            if component == 0 {
                return self.rootDepartments[row]
            } else {
                let index = pickerView.selectedRowInComponent(0)
                let key = self.rootDepartments[index]
                if let options = self.departmentOptions[key] {
                    if row < options.count {
                        return  options[row].label
                    } else {
                        return nil
                    }
                    
                } else {
                    return nil
                }
            }
        } else {
            return self.typeOptions[row].label
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if isDepartmentOptions {
            if component == 0 {
                pickerView.reloadComponent(1)
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let pickerLabel = UILabel()
        if isDepartmentOptions {
            pickerLabel.font = UIFont.systemFontOfSize(18.0)
        } else {
            pickerLabel.font = UIFont.systemFontOfSize(20.0)
        }
        pickerLabel.textAlignment = NSTextAlignment.Center
        pickerLabel.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        return pickerLabel
    }
    
}
