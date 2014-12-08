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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
    func savePatient() {
        var patient = Patient()
        patient.name = name.text
        patient.gender = gender.text
        patient.birthday = birthday.text
        patient.caseNo = caseNo.text
        
        if !birthday.text.isEmpty {
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
        }
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       println("start...")
    }

}

