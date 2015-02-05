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
    var deleteComplete = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        // Do any additional setup after loading the view, typically from a nib.
            }
    override func viewWillAppear(animated: Bool) {
        if editCompelete {
            self.navigationController?.popViewControllerAnimated(false)
            editCompelete = false
        } else if deleteComplete {
            if let viewControllers = self.navigationController?.viewControllers{
                for viewController in viewControllers {
                    if let visitTableViewController = viewController as? VisitTableViewController {
                        self.navigationController?.popToViewController(visitTableViewController, animated: false)
                        break
                    }
                }
            }
            
            deleteComplete = false
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

    @IBAction func completeDeleteVisit(segue : UIStoryboardSegue) {
        deleteComplete = true
    }
}

