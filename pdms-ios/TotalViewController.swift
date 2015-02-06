//
// TotalViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-5.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//

import UIKit

class TotalViewController: UITableViewController {
    var tableDatas = Array<Patient>()
    var page = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        setPullToRefreshTitle()
        page = 1
        self.loadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDatas.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("patientCell", forIndexPath: indexPath) as PatientTableCell
        let patient = self.tableDatas[indexPath.row]
        cell.name.text = patient.name
        cell.gender.text = patient.gender
        cell.age.text = "年龄：\(patient.age)"
        cell.birthday.text = "出生日期：" + patient.birthday
        return cell
    }
    
    func loadData() {
        let url = SERVER_DOMAIN + "patients/list?token=" + TOKEN
        let params : [String : AnyObject] = ["page" : page]
        HttpApiClient.sharedInstance.getLoading(url, paramters: params, loadingPosition: HttpApiClient.LOADING_POSTION.AFTER_TABLEVIEW, viewController: self, success: fillData, fail: fail)
        
    }
    func fillData(json: JSON) {
        if page == 1 {
             self.tableDatas.removeAll(keepCapacity: true)
        }
        if json["stat"].int == 0 {
            var noData = true
            for (index: String, data: JSON) in json["data"]["data"] {
                let patient = Patient()
                patient.id = data["patientId"].number
                patient.name = data["patientName"].string
                patient.gender = data["gender"].string
                if let age = data["age"].int {
                    patient.age = age
                } else {
                    patient.age = 0
                }
                patient.birthday = data["birthday"].string
                patient.caseNo = data["patientNo"].string
                let result = addPatientToArray(patient)
                if result {
                    noData = false
                }
            }
            page = self.tableDatas.count / 20 + 1
            if self.tableDatas.count < 20 {
                noData = true
            }
            if noData {
                self.tableView.pullToRefreshView.setTitle("已加载全部", forState: SVPullToRefreshState.All)
                self.tableView.pullToRefreshView.arrowColor = UIColor.whiteColor()
            } else {
                setPullToRefreshTitle()
            }
        } else {
            
        }
       
        self.tableView.pullToRefreshView.stopAnimating()
        self.tableView.reloadData()
    }
    
    func fail() {
        self.tableView.pullToRefreshView.stopAnimating()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "patientDetailSegue") {
            let indexPath = self.tableView.indexPathForCell(sender as PatientTableCell)!
            let patient = self.tableDatas[indexPath.row]
            let patientDetailViewController = segue.destinationViewController as PatientDetailViewController
            patientDetailViewController.patient = patient
        } else {
            
        }
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)
        if self.tableView.pullToRefreshView == nil {
            self.tableView.addPullToRefreshWithActionHandler(loadData, position: SVPullToRefreshPosition.Bottom)
        }
        setPullToRefreshTitle()
    }
    
    func addPatientToArray(patient : Patient) -> Bool {
        var notExisted = true
        for existPatient in self.tableDatas {
            if existPatient.id == patient.id {
                notExisted = false
            }
        }
        if notExisted {
            self.tableDatas.append(patient)
        }
        return notExisted
    }
    
    func setPullToRefreshTitle() {
       if let pullToRefreshView = self.tableView.pullToRefreshView {
            pullToRefreshView.setTitle("上拉加载更多...", forState: SVPullToRefreshState.Stopped)
            pullToRefreshView.setTitle("松开开始刷新...", forState: SVPullToRefreshState.Triggered)
            pullToRefreshView.setTitle("加载中...", forState: SVPullToRefreshState.Loading)
            pullToRefreshView.arrowColor = UIColor.grayColor()
        }
       
    }
}

