//
//  EditPatientViewController.swift
//  pdms-ios
//
//  Created by HuLeehom on 12/15/14.
//  Copyright (c) 2014 unimedsci. All rights reserved.
//

import UIKit

class EditPatientViewController: UIViewController {
    @IBOutlet weak var namText: UITextField!
    @IBOutlet weak var genderText: UITextField!
    @IBOutlet weak var birthdayText: UITextField!
    @IBOutlet weak var caseNumberText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func displayDatePicker(sender: UITextField) {
        var datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePicker
        datePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerChanged(datePicker: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.birthdayText.text = dateFormatter.stringFromDate(datePicker.date)
    }
    
    @IBAction func savePatient(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}