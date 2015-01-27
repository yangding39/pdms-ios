//
//  AddPatientViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 14-11-26.
//  Copyright (c) 2014年 IMEDS. All rights reserved.
//

import UIKit

class AddPatientViewController: UITableViewController {

    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var gender: UITextField!
    
    @IBOutlet weak var birthday: UITextField!
    
    @IBOutlet weak var caseNo: UITextField!
    
    let options = ["男", "女", "未知"]
    let patient = Patient()
    var historyViewController : HistoryViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        birthday.addTarget(self, action: "showDatePicker:", forControlEvents: UIControlEvents.EditingDidBegin)
        gender.addTarget(self, action: "showSelectPicker:", forControlEvents: UIControlEvents.EditingDidBegin)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
    }
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        
        if name.text.isEmpty {
            CustomAlertView.showMessage("姓名必填", parentViewController: self)
            return false
        } else if gender.text.isEmpty {
            CustomAlertView.showMessage("性别必填", parentViewController: self)
            return false
        } else if birthday.text.isEmpty {
            CustomAlertView.showMessage("生日必填", parentViewController: self)
            return false
        }
        savePatient()
        return false
    }
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "completeAddPatientSegue" {
//            let patientDetailViewController = segue.destinationViewController as PatientDetailViewController
//            patientDetailViewController.patient = patient
        }
    }
    func savePatient(){
        patient.name = name.text
        patient.gender = gender.text
        patient.birthday = birthday.text
        patient.caseNo = caseNo.text
        
       let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let ageComponents = calendar.components(.CalendarUnitYear,
                fromDate: dateFormatter.dateFromString(birthday.text)!,
                toDate: now,
                options: nil)
        let age = ageComponents.year
        patient.age = age
        postData(patient)
    }
    
    func postData(patient : Patient) {
        
        let url = SERVER_DOMAIN + "patients/save"
        let params : [String : AnyObject] = ["token" : TOKEN, "patientName" : patient.name, "gender" : patient.gender, "birthday" : patient.birthday,
            "age" : patient.age, "patientNo" : patient.caseNo]
         HttpApiClient.sharedInstance.save(url, paramters: params, loadingPosition: HttpApiClient.LOADING_POSTION.NAIGATIONBAR, viewController: self, success: addPatientResult, fail: nil)
       
    }
    func addPatientResult(json : JSON) {
        var fieldErrors = Array<String>()
        var saveResult = false
        //set result and error from server
        saveResult = (json["stat"].int == 0 )
        for (index: String, errorJson: JSON) in json["fieldErrors"] {
            if let error = errorJson[index].string {
                fieldErrors.append(error)
            }
        }
        if saveResult && fieldErrors.count == 0 {
            patient.id = json["data"]["patientId"].number
            patient.name = json["data"]["patientName"].string
            patient.gender = json["data"]["gender"].string
            if let age = json["data"]["age"].int {
                patient.age = age
            } else {
                patient.age = 0
            }
            patient.birthday = json["data"]["birthday"].string
            patient.caseNo = json["data"]["patientNo"].string
            self.performSegueWithIdentifier("completeAddPatientSegue", sender: self)
        }

    }
    
    func showDatePicker(sender: UITextField) {
        sender.inputView = UIDatePicker().customPickerStyle(self.view)
        sender.inputAccessoryView = UIToolbar().customPickerToolBarStyle(self.view, doneSelector: Selector("handleDatePicker:"), target : self)
    }
    
    func handleDatePicker(sender: UIBarButtonItem) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var datePicker = birthday.inputView as UIDatePicker?
        if let date = datePicker?.date {
            birthday.text = dateFormatter.stringFromDate(date)
            birthday.endEditing(true)
        }
        
    }
    
    func showSelectPicker(sender: UITextField) {
        sender.inputView = UIPickerView().customPickerStyle(self.view, delegate: self, dataSource: self)
        sender.inputAccessoryView = UIToolbar().customPickerToolBarStyle(self.view, doneSelector: Selector("handleSelectPicker:"), target : self)
    }
    
    func handleSelectPicker(sender: UIBarButtonItem) {
        var uiPicker = gender.inputView as UIPickerView?
        if let index = uiPicker?.selectedRowInComponent(0) {
            gender.text = self.options[index]
            gender.endEditing(true)
        }
    }
    
    @IBAction func didCancelBtn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
extension AddPatientViewController : UIPickerViewDataSource {
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return 3
    }
}

extension AddPatientViewController : UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return options[row]
    }

    
}

