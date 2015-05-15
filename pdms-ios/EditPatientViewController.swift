//
//  EditPatientViewController.swift
//  pdms-ios
//
//  Created by HuLeehom on 12/15/14.
//  Copyright (c) 2014 unimedsci. All rights reserved.
//

import UIKit

class EditPatientViewController: UITableViewController, UIActionSheetDelegate  {
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var genderText: UITextField!
    
    @IBOutlet weak var birthdayText: UITextField!
    
    @IBOutlet weak var caseNoText: UITextField!
    
    let options = ["男", "女", "未知"]
    var patient : Patient!
    override func viewDidLoad() {
        super.viewDidLoad()
        nameText.text = patient.name
        genderText.text = patient.gender
        birthdayText.text = patient.birthday
        caseNoText.text = patient.caseNo
        
        birthdayText.addTarget(self, action: "showDatePicker:", forControlEvents: UIControlEvents.EditingDidBegin)
        genderText.addTarget(self, action: "showSelectPicker:", forControlEvents: UIControlEvents.EditingDidBegin)
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        
        if identifier == "completeEditPatientSegue" {
            if nameText.text.isEmpty {
                CustomAlertView.showMessage("姓名必填", parentViewController: self)
                return false
            } else if count(nameText.text) > 10 {
                CustomAlertView.showMessage("姓名不能超过10", parentViewController: self)
                return false
            } else if genderText.text.isEmpty {
                CustomAlertView.showMessage("性别必填", parentViewController: self)
                return false
            } else if birthdayText.text.isEmpty {
                CustomAlertView.showMessage("出生日期必填", parentViewController: self)
                return false
            } else if count(caseNoText.text) > 20 {
                CustomAlertView.showMessage("病案号不能超过20", parentViewController: self)
                return false
            }
            savePatient()

        }
        return false
    }
    
    func savePatient(){
        patient.name = nameText.text
        patient.gender = genderText.text
        patient.birthday = birthdayText.text
        patient.caseNo = caseNoText.text
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let ageComponents = calendar.components(.CalendarUnitYear,
            fromDate: dateFormatter.dateFromString(birthdayText.text)!,
            toDate: now,
            options: nil)
        let age = ageComponents.year
        patient.age = age
        postData(patient)
    }
    
    func postData(patient : Patient) {
        let url = SERVER_DOMAIN + "patients/save"
        let params : [String : AnyObject] = ["token" : TOKEN, "patientName" : patient.name, "gender" : patient.gender, "birthday" : patient.birthday,
            "age" : patient.age, "patientNo" : patient.caseNo, "patientId" : patient.id]
        HttpApiClient.sharedInstance.save(url, paramters: params, loadingPosition: HttpApiClient.LOADING_POSTION.NAIGATIONBAR, viewController: self, success: addPatientResult, fail: nil)
        
    }
    func addPatientResult(json : JSON) {
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
            self.performSegueWithIdentifier("completeEditPatientSegue", sender: self)
        }
        
    }
    func showDatePicker(sender: UITextField) {
        sender.inputView = UIDatePicker().customPickerStyle(self.view)
        sender.inputAccessoryView = UIToolbar().customPickerToolBarStyle(self.view, doneSelector: Selector("handleDatePicker:"), target : self)
    }
    
    func handleDatePicker(sender: UIBarButtonItem) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var datePicker = birthdayText.inputView as! UIDatePicker?
        if let date = datePicker?.date {
            birthdayText.text = dateFormatter.stringFromDate(date)
            birthdayText.endEditing(true)
        }
        
    }
    
    func showSelectPicker(sender: UITextField) {
        sender.inputView = UIPickerView().customPickerStyle(self.view, delegate: self, dataSource: self)
        sender.inputAccessoryView = UIToolbar().customPickerToolBarStyle(self.view, doneSelector: Selector("handleSelectPicker:"), target : self)
    }
    
    func handleSelectPicker(sender: UIBarButtonItem) {
        var uiPicker = genderText.inputView as! UIPickerView?
        if let index = uiPicker?.selectedRowInComponent(0) {
            genderText.text = self.options[index]
            genderText.endEditing(true)
        }
    }
    @IBAction func didCancelBtn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didClickDeleteBtn(sender: AnyObject) {
        if NSClassFromString("UIAlertController") != nil {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let deleteAction = UIAlertAction(title: "删除", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.removePatient()
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
            removePatient()
        }
    }
    
    func removePatient() {
        let url = SERVER_DOMAIN + "patients/delete"
        let params : [String : AnyObject] = ["token" : TOKEN, "patientId" : patient.id]
        HttpApiClient.sharedInstance.save(url, paramters: params, loadingPosition: HttpApiClient.LOADING_POSTION.FULL_SRCEEN, viewController: self, success: removePatientResult, fail: nil)
    }
    
    func removePatientResult(json : JSON) {
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
            self.performSegueWithIdentifier("completeDeletePatientSegue", sender: self)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
}

extension EditPatientViewController : UIPickerViewDataSource {
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return 3
    }
}

extension EditPatientViewController : UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return options[row]
    }
    
    
}