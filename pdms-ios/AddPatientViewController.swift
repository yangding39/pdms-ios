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
        return savePatient()
    }
   
    func savePatient() -> Bool{
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
        return true
    }
    
    func postData(patient : Patient) {
        let url = SERVER_DOMAIN + "patients/save?token=" + TOKEN
        let params = ["name" : patient.name, "gender" : patient.gender, "birthday" : patient.birthday,
            "age" : "\(patient.age)", "caseNo" : patient.caseNo]
        HttpApiClient.sharedInstance.post(url, paramters : params, success: addPatientResult, fail : nil)
       
    }
    func addPatientResult(json : JSON) {
        println(json.description)
    }
    func showDatePicker(sender: UITextField) {
        
        var datePicker: UIDatePicker = UIDatePicker(frame: CGRectMake(0, 0, self.view.bounds.width,50))
        datePicker.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePicker
        
        var toolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.bounds.width,44))
        toolbar.barStyle = UIBarStyle.BlackTranslucent
        var flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        var barItem = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Done, target: self, action: Selector("handleDatePicker:"))
        toolbar.setItems([flexSpace, barItem], animated: true)
        sender.inputAccessoryView = toolbar
        
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
        let selectPicker = UIPickerView(frame: CGRectMake(0, 0, self.view.bounds.width, 10))
        selectPicker.dataSource = self
        selectPicker.delegate = self
        sender.inputView = selectPicker
        selectPicker.backgroundColor = UIColor.whiteColor()
        selectPicker.showsSelectionIndicator = true
        
        var toolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.bounds.width,44))
        toolbar.barStyle = UIBarStyle.BlackTranslucent
        var flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        var barItem = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Done, target: self, action: Selector("handleSelectPicker:"))
        toolbar.setItems([flexSpace, barItem], animated: true)
        gender.inputAccessoryView = toolbar
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
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = options[row]
        var myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
    }
    
}

