//
//  EditVisitTableViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 15-1-13.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//


import UIKit

class EditVisitTableViewController: UITableViewController,UIActionSheetDelegate {

    @IBOutlet weak var typeLabel: UITextField!
    
    @IBOutlet weak var number: UITextField!
    
    @IBOutlet weak var departmentLabel: UITextField!
    
    @IBOutlet weak var startTime: UITextField!
    
    @IBOutlet weak var endTime: UITextField!
    
    var typeOptions = Array<Option>()
    
    var departmentOptions = Array<Option>()
    
    var currentOptions = Array<Option>()
    
    var currentTextField : UITextField?
    
    var patient : Patient!
    var visit : Visit!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadOptions()
        
        typeLabel.text = visit.typeLabel
        number.text = visit.number
        departmentLabel.text = visit.departmentLabel
        startTime.text =  visit.startTime
        endTime.text = visit.endTime
        
        startTime.addTarget(self, action: "showDatePicker:", forControlEvents: UIControlEvents.EditingDidBegin)
        endTime.addTarget(self, action: "showDatePicker:", forControlEvents: UIControlEvents.EditingDidBegin)
        
        typeLabel.addTarget(self, action: "showSelectPicker:", forControlEvents: UIControlEvents.EditingDidBegin)
        departmentLabel.addTarget(self, action: "showSelectPicker:", forControlEvents: UIControlEvents.EditingDidBegin)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loadOptions() {
        let url = SERVER_DOMAIN + "visit/add"
        let parameters = ["token": TOKEN]
        HttpApiClient.sharedInstance.getLoading(url, paramters: parameters, loadingPosition: HttpApiClient.LOADING_POSTION.NAIGATIONBAR, viewController: self, success: fillOptions, fail: nil)
    }
    
    func fillOptions(json : JSON) {
        for (index: String, subJson: JSON) in json["data"]  {
            let dictId = subJson["dictId"].int
            for (optionIndex : String, optionJson : JSON) in subJson["options"] {
                let option = Option()
                
                option.label = optionJson["lable"].string!
                option.value = optionJson["value"].int!
                if dictId == 5 {
                    self.typeOptions.append(option)
                } else if dictId == 6 {
                    self.departmentOptions.append(option)
                }
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "completeEditVisitSegue" {
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
        for option in departmentOptions {
            if option.label == departmentLabel.text {
                visit.department = option.value
                visit.departmentLabel = option.label
                break
            }
        }
        visit.startTime = startTime.text
        visit.endTime = endTime.text
        postData(visit)
    }
    func postData(visit : Visit) {
        let url = SERVER_DOMAIN + "visit/save"
        let params : [String : AnyObject] = ["token" : TOKEN, "patientId" : patient.id, "visitId" : visit.id, "visitType" : visit.type, "visitNumber" : visit.number, "department" : visit.department, "startTime" : visit.startTime, "endTime" : visit.endTime]
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
            self.performSegueWithIdentifier("completeEditVisitSegue", sender: self)
        }
        
    }
    
    func showDatePicker(sender: UITextField) {
        sender.inputView = UIDatePicker().customPickerStyle(self.view)
        
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
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var datePicker = startTime.inputView as UIDatePicker?
        if let date = datePicker?.date {
            startTime.text = dateFormatter.stringFromDate(date)
            startTime.endEditing(true)
        }
    }
    
    func handleEndTimeDatePicker(sender: UIBarButtonItem) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var datePicker = endTime.inputView as UIDatePicker?
        if let date = datePicker?.date {
            endTime.text = dateFormatter.stringFromDate(date)
            endTime.endEditing(true)
        }
    }
    
    func showSelectPicker(sender: UITextField) {
        
        if (sender == self.typeLabel) {
            currentOptions = self.typeOptions
        } else {
            currentOptions = self.departmentOptions
        }
        sender.inputView = UIPickerView().customPickerStyle(self.view, delegate: self, dataSource: self)
        sender.inputAccessoryView = UIToolbar().customPickerToolBarStyle(self.view, doneSelector: Selector("handleSelectPicker:"), target : self)
        currentTextField = sender
    }
    
    func handleSelectPicker(sender: UIBarButtonItem) {
        
        var uiPicker = currentTextField!.inputView as UIPickerView?
        if let index = uiPicker?.selectedRowInComponent(0) {
            currentTextField!.text = self.currentOptions[index].label
            currentTextField!.endEditing(true)
        }
    }
    @IBAction func didCancelBtn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
            self.dismissViewControllerAnimated(false, completion: nil)
            self.performSegueWithIdentifier("completeDeleteVisitSegue", sender: self)
        }
    }

}


extension EditVisitTableViewController : UIPickerViewDataSource {
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return currentOptions.count
    }
}

extension EditVisitTableViewController : UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        
        return currentOptions[row].label
    }
}
