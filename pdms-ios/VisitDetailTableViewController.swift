//
//  VisitDetailTableViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 15-1-13.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//



import UIKit

class VisitDetailTableViewController: UITableViewController, UIActionSheetDelegate {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    var patient : Patient!
    var visit : Visit!
    var editCompelete = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
            }
    override func viewWillAppear(animated: Bool) {
        if editCompelete {
            self.navigationController?.popViewControllerAnimated(true)
            editCompelete = false
        } else {
            typeLabel.text = visit.typeLabel
            numberLabel.text = visit.number
            departmentLabel.text = visit.departmentLabel
            startTimeLabel.text =  visit.startTime
            endTimeLabel.text = visit.endTime
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editVisitSegue" {
            let navigateController =  segue.destinationViewController as UINavigationController
            let editVisitViewController = navigateController.topViewController as EditVisitTableViewController
            editVisitViewController.patient = patient
            editVisitViewController.visit = visit
        }
    }
    
    @IBAction func completeEditVisit(segue : UIStoryboardSegue) {
        editCompelete = true
    }

}

