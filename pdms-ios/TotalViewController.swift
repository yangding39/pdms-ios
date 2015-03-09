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
    var totalPage = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        setPullToRefreshTitle()
//        page = 1
//        self.tableDatas.removeAll(keepCapacity: true)
//        self.tableView.reloadData()
        self.loadDataRefresh()
        //self.loadData()
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
        cell.gender.textColor = UIColor.valueColor()
        cell.gender.text = patient.gender
        let ageString = NSMutableAttributedString(string: "年龄：\(patient.age)")
        ageString.addAttribute(NSForegroundColorAttributeName, value: UIColor.columnColor(), range: NSMakeRange(0, 3))
        cell.age.attributedText = ageString
        let birthString = NSMutableAttributedString(string: "出生日期：" + patient.birthday)
        birthString.addAttribute(NSForegroundColorAttributeName, value: UIColor.columnColor(), range: NSMakeRange(0, 5))
        cell.birthday.attributedText = birthString
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
            if let total = json["data"]["total"].int {
                totalPage = total
            }
            
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
                let result = addPatientToArray(patient, head : false, insertIndex: self.tableDatas.count - 1)
                if result {
                    noData = false
                }
            }
            page = self.tableDatas.count / 20 + 1
            if self.tableDatas.count < 20 {
                noData = true
            }
            if noData {
                let label = UILabel(frame: CGRectMake(0, 0, 100, 20))
                label.text = "已加载全部"
                label.font = UIFont.systemFontOfSize(14)
                label.sizeToFit()
                self.tableView.infiniteScrollingView.setCustomView(label, forState: 10)
                self.tableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
            } else {
                setPullToRefreshTitle()
                self.tableView.infiniteScrollingView.setCustomView(nil, forState: 10)
                self.tableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            }
        } else {
            
        }
       
        self.tableView.pullToRefreshView.stopAnimating()
        self.tableView.infiniteScrollingView.stopAnimating()
        self.tableView.reloadData()
    }
    
    func fail() {
        self.tableView.pullToRefreshView.stopAnimating()
        self.tableView.infiniteScrollingView.stopAnimating()
    }
    
    func loadDataRefresh() {
        let url = SERVER_DOMAIN + "patients/list?token=" + TOKEN
        let params : [String : AnyObject] = ["page" : 1]
        HttpApiClient.sharedInstance.getLoading(url, paramters: params, loadingPosition: HttpApiClient.LOADING_POSTION.AFTER_TABLEVIEW, viewController: self, success: fillDataRefresh, fail: fail)
    }
    
    func fillDataRefresh(json: JSON) {
        if json["stat"].int == 0 {
            var noData = true
            if let total = json["data"]["total"].int {
                totalPage = total
            }
            let count = self.tableDatas.count
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
                let result = addPatientToArray(patient, head : true, insertIndex: self.tableDatas.count - count)
                if result {
                    noData = false
                }
            }
            page = self.tableDatas.count / 20 + 1
        }
        self.tableView.pullToRefreshView.stopAnimating()
        self.tableView.infiniteScrollingView.stopAnimating()
        self.tableView.reloadData()
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
            self.tableView.addPullToRefreshWithActionHandler(loadDataRefresh)
        }
        self.tableView.addInfiniteScrollingWithActionHandler(loadData)
        
        setPullToRefreshTitle()
    }
    
    func addPatientToArray(patient : Patient, head : Bool, insertIndex : Int) -> Bool {
        var notExisted = true
        for existPatient in self.tableDatas {
            if existPatient.id == patient.id {
                notExisted = false
            }
        }
        if notExisted {
            if head {
                self.tableDatas.insert(patient, atIndex: insertIndex)
            } else {
                self.tableDatas.append(patient)
            }
            
        }
        return notExisted
    }
   
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView == self.tableView {
            let view = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, 20))
            var label = UILabel(frame: CGRectMake(13, 0, 100, 20))
            view.backgroundColor = UIColor.sectionHeaderColor()
            label.font = UIFont.systemFontOfSize(14.0)
            label.textColor = UIColor.sectionTextColor()
            label.text = "共\(totalPage)条记录"
            view.addSubview(label)
            return view
        } else {
            return nil
        }
    }
    func setPullToRefreshTitle() {
       if let pullToRefreshView = self.tableView.pullToRefreshView {
        pullToRefreshView.setTitle("下拉刷新...", forState: SVPullToRefreshState.Stopped)
        pullToRefreshView.setTitle("松开刷新...", forState: SVPullToRefreshState.Triggered)
        pullToRefreshView.setTitle("加载中...", forState: SVPullToRefreshState.Loading)
        pullToRefreshView.arrowColor = UIColor.grayColor()
        }
    }
}

