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
        if var frame = self.tableView.tableFooterView?.frame {
            frame.size.height = 44
            self.tableView.tableFooterView?.frame = frame
            self.tableView.updateConstraintsIfNeeded()
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(animated: Bool) {
        if editCompelete {
            self.navigationController?.popViewControllerAnimated(false)
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
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 18
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
    
    @IBAction func didDeleteAction(sender: AnyObject) {
        
        if NSClassFromString("UIAlertController") != nil {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let deleteAction = UIAlertAction(title: "删除", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.removeVisit()
            })
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                println("Cancelled")
            })
            
            optionMenu.addAction(deleteAction)
            optionMenu.addAction(cancelAction)
            self.presentViewController(optionMenu, animated: true, completion: nil)
        } else {
            let myActionSheet = UIActionSheet()
            myActionSheet.addButtonWithTitle("删除")
            myActionSheet.addButtonWithTitle("取消")
            myActionSheet.cancelButtonIndex = 1
            myActionSheet.showInView(self.view)
            myActionSheet.delegate = self
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        if buttonIndex == 0 {
            removeVisit()
        }
    }
    
    func removeVisit() {
        let url = SERVER_DOMAIN + "visit/delete"
        let params : [String : AnyObject] = ["token" : TOKEN, "visitId" : visit.id]
        HttpApiClient.sharedInstance.save(url, paramters: params, loadingPosition: HttpApiClient.LOADING_POSTION.FULL_SRCEEN, viewController: self, success: removeResult, fail: nil)
    }
    
    func removeResult(json : JSON) {
        var fieldErrors = Array<String>()
        var removeResult = false
        //set result and error from server
        removeResult = json["stat"].int == 0 ? true : false
        for (index: String, errorJson: JSON) in json["fieldErrors"] {
            if let error = errorJson[index].string {
                fieldErrors.append(error)
            }
        }
        if removeResult && fieldErrors.count == 0 {
            if let viewControllers = self.navigationController?.viewControllers{
                for viewController in viewControllers {
                    if let visitTableViewController = viewController as? VisitTableViewController {
                        self.navigationController?.popToViewController(visitTableViewController, animated: true)
                        break
                    }
                }
            }
        }
    }
}

