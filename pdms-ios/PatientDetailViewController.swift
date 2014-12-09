//
//  PatientDetailViewController.swift
//  pdms-ios
//
//  Created by HuLeehom on 12/8/14.
//  Copyright (c) 2014 unimedsci. All rights reserved.
//

import UIKit

class PatientDetailViewController: UITableViewController {
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var caseNo: UILabel!
    
    @IBOutlet weak var gender: UILabel!
    
    @IBOutlet weak var age: UILabel!
    
    @IBOutlet weak var birthday: UILabel!
    
    var patient: Patient!
    override func viewDidLoad() {
        super.viewDidLoad()
        name.text = patient.name
        caseNo.text = patient.caseNo
        gender.text = patient.gender
        age.text = "\(patient.age)"
        birthday.text = patient.birthday
    }
    
}
