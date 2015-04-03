//
//  AddPatientViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 14-11-26.
//  Copyright (c) 2014年 IMEDS. All rights reserved.
//

import UIKit

class AddPatientViewController: UITableViewController {

    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var genderText: UITextField!
    
    @IBOutlet weak var birthdayText: UITextField!
    
    @IBOutlet weak var caseNoText: UITextField!
    
    let options = ["男", "女", "未知"]
    let patient = Patient()
    var historyViewController : HistoryViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        birthdayText.addTarget(self, action: "showDatePicker:", forControlEvents: UIControlEvents.EditingDidBegin)
        genderText.addTarget(self, action: "showSelectPicker:", forControlEvents: UIControlEvents.EditingDidBegin)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
    }
  
    @IBAction func clickSaveBtn(sender: AnyObject) {
        if nameText.text.isEmpty {
            CustomAlertView.showMessage("姓名必填", parentViewController: self)
            return
        } else if countElements(nameText.text) > 10 {
            CustomAlertView.showMessage("姓名不能超过10", parentViewController: self)
            return
        } else if genderText.text.isEmpty {
            CustomAlertView.showMessage("性别必填", parentViewController: self)
            return
        } else if birthdayText.text.isEmpty {
            CustomAlertView.showMessage("出生日期必填", parentViewController: self)
            return
        } else if countElements(caseNoText.text) > 20 {
            CustomAlertView.showMessage("病案号不能超过20", parentViewController: self)
            return 
        }
        savePatient()
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
            //self.performSegueWithIdentifier("completeAddPatientSegue", sender: self)
            if let tabBarController = self.presentingViewController as? UITabBarController {
                if let viewControllers = tabBarController.viewControllers {
                    var tabSelectedIndex = 0
                    for viewController in viewControllers {
                        if let navigationController = viewController as? UINavigationController {
                            if tabBarController.selectedIndex == tabSelectedIndex {
                                 navigationController.popToRootViewControllerAnimated(false)
                                let patientDetailView = self.navigationController?.storyboard?.instantiateViewControllerWithIdentifier("patitentDetailViewController") as PatientDetailViewController
                                patientDetailView.patient = patient
                                navigationController.pushViewController(patientDetailView, animated: false)
                            }
                            tabSelectedIndex++
                        }
                    }
                }
                
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
    func showDatePicker(sender: UITextField) {
        sender.inputView = UIDatePicker().customPickerStyle(self.view)
        sender.inputAccessoryView = UIToolbar().customPickerToolBarStyle(self.view, doneSelector: Selector("handleDatePicker:"), target : self)
    }
    
    func handleDatePicker(sender: UIBarButtonItem) {
        var dateFormatter = NSDateFormatter()
       
        var datePicker = birthdayText.inputView as UIDatePicker?
        if let date = datePicker?.date {
                dateFormatter.dateFormat = "yyyy-MM-dd"
                birthdayText.text = dateFormatter.stringFromDate(date)
                birthdayText.endEditing(true)
        }
        
    }
    
    func showSelectPicker(sender: UITextField) {
        sender.inputView = UIPickerView().customPickerStyle(self.view, delegate: self, dataSource: self)
        sender.inputAccessoryView = UIToolbar().customPickerToolBarStyle(self.view, doneSelector: Selector("handleSelectPicker:"), target : self)
    }
    
    func handleSelectPicker(sender: UIBarButtonItem) {
        var uiPicker = genderText.inputView as UIPickerView?
        if let index = uiPicker?.selectedRowInComponent(0) {
            genderText.text = self.options[index]
            genderText.endEditing(true)
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

