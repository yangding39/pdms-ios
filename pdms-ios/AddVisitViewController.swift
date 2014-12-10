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
    
    var departmentOptions = Array<Option>()
    
    var currentOptions = Array<Option>()
    
    var currentTextField : UITextField?
    
    var patient : Patient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadOptions()
        
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
        HttpApiClient.sharedInstance.get(url, paramters : parameters, success: fillOptions, fail : nil)
    }
    
    func fillOptions(json : JSON) {
        //todo
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return saveVisit()
    }
    func saveVisit() -> Bool{
        let visit = Visit()
        for option in typeOptions {
            if option.label == typeLabel.text {
                visit.type = option.value
                break
            }
        }
        visit.number = number.text
        for option in departmentOptions {
            if option.label == departmentLabel.text {
                visit.department = option.value
                break
            }
        }
        visit.startTime = startTime.text
        visit.endTime = endTime.text
        postData(visit)
        return true
    }
    func postData(visit : Visit) {
        let url = SERVER_DOMAIN + "visit/save?token=" + TOKEN
        let params = ["patientId" : "\(patient.id!)", "visitType" : "\(visit.type!)", "visitNumber" : visit.number!, "department" : "\(visit.department!)", "startTime" : visit.startTime!, "endTime" : visit.endTime!]
        HttpApiClient.sharedInstance.post(url, paramters : params, success: addVisitResult, fail : nil)
    }
    
    func addVisitResult(json : JSON) {
        //todo
    }
    func showDatePicker(sender: UITextField) {
        var datePicker: UIDatePicker = UIDatePicker(frame: CGRectMake(0, 0, self.view.bounds.width,50))
        datePicker.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePicker
        
        var toolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.bounds.width,44))
        toolbar.barStyle = UIBarStyle.BlackTranslucent
        var flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        var selector : Selector!
        if (sender == self.startTime) {
            selector = Selector("handleStartTimeDatePicker:")
        } else {
            selector = Selector("handleEndTimeDatePicker:")
        }
        var barItem = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Done, target: self, action: selector)
        toolbar.setItems([flexSpace, barItem], animated: true)
        sender.inputAccessoryView = toolbar
        
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
        sender.inputAccessoryView = toolbar
        currentTextField = sender
    }
    
    func handleSelectPicker(sender: UIBarButtonItem) {
        
        var uiPicker = currentTextField!.inputView as UIPickerView?
        if let index = uiPicker?.selectedRowInComponent(0) {
            currentTextField!.text = self.currentOptions[index].label
            currentTextField!.endEditing(true)
        }
    }
}

extension AddVisitViewController : UIPickerViewDataSource {
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return currentOptions.count
    }
}

extension AddVisitViewController : UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        
        return currentOptions[row].label
    }
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = currentOptions[row].label
        var myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
    }
    
}
