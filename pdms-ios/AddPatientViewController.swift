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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        birthday.addTarget(self, action: "showDatePicker:", forControlEvents: UIControlEvents.EditingDidBegin)
        gender.addTarget(self, action: "showSelectPicker:", forControlEvents: UIControlEvents.EditingDidBegin)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        
        if name.text.isEmpty {
            name.layer.borderColor = UIColor.redColor().CGColor
            name.layer.borderWidth = 1.0
            name.layer.cornerRadius = 5
            return false
        } else if gender.text.isEmpty {
            gender.layer.borderColor = UIColor.redColor().CGColor
            gender.layer.borderWidth = 1.0
            gender.layer.cornerRadius = 5
            return false
        } else if birthday.text.isEmpty {
            birthday.layer.borderColor = UIColor.redColor().CGColor
            birthday.layer.borderWidth = 1.0
            birthday.layer.cornerRadius = 5
            return false
        } else if caseNo.text.isEmpty {
            caseNo.layer.borderColor = UIColor.redColor().CGColor
            caseNo.layer.borderWidth = 1.0
            caseNo.layer.cornerRadius = 5
            return false
        }
        savePatient()
        return false
    }
   
    func savePatient(){
        var patient = Patient()
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
            "age" : patient.age, "caseNo" : patient.caseNo]
        HttpApiClient.sharedInstance.post(url, paramters : params, success: addPatientResult, fail : nil)
       
    }
    func addPatientResult(json : JSON) {
        var fieldErrors = Array<String>()
        var saveResult = false
        println(json)
        //set result and error from server
        saveResult = json["stat"].int == 0 ? true : false
        for (index: String, errorJson: JSON) in json["fieldErrors"] {
            if let error = errorJson[index].string {
                fieldErrors.append(error)
            }
        }
        if saveResult && fieldErrors.count == 0 {
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

