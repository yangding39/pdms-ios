//
// TotalViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-5.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//

import UIKit

class TotalViewController: UITableViewController, LoadMoreTableFooterDelegate {
    var loadMoreTableFooterView : LoadMoreTableFooterView!
    var isLoadMoreing = false
    var tableDatas = Array<Patient>()
    var page = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
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
        cell.gender.text = "性别：" + patient.gender
        cell.age.text = "年龄：\(patient.age)"
        cell.birthday.text = "生日：" + patient.birthday
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func loadData() {
        let url = SERVER_DOMAIN + "patients/list?token=" + TOKEN
        let params : [String : AnyObject] = ["page" : page]
        HttpApiClient.sharedInstance.getLoading(url, paramters: params, loadingPosition: HttpApiClient.LOADING_POSTION.AFTER_TABLEVIEW, viewController: self, success: fillData, fail: nil)
        
    }
    func fillData(json: JSON) {
        if page == 1 {
             self.tableDatas.removeAll(keepCapacity: true)
        }
        if json["stat"].int == 0 {
            var hasData = false
            for (index: String, data: JSON) in json["data"]["data"] {
                hasData = true
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
                self.tableDatas.append(patient)
            }
            if hasData {
                page += 1
            }
        } else {
            
        }
        self.tableView.reloadData()
        if (loadMoreTableFooterView == nil) {
            loadMoreTableFooterView = LoadMoreTableFooterView(frame: CGRectMake(0.0, self.tableView.contentSize.height, self.view.frame.size.width, self.tableView.bounds.size.height))
            loadMoreTableFooterView.delegate = self
            self.tableView.addSubview(loadMoreTableFooterView)
        }
        loadMoreTableFooterView.frame = CGRectMake(0.0, self.tableView.contentSize.height, self.view.frame.size.width, self.tableView.bounds.size.height)
        isLoadMoreing = false
    }
    
    func fail() {
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
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if loadMoreTableFooterView != nil {
            self.loadMoreTableFooterView.loadMoreScrollViewDidScroll(scrollView)
        }
        
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if loadMoreTableFooterView != nil {
            self.loadMoreTableFooterView.loadMoreScrollViewDidEndDragging(scrollView)
        }
    }
   func loadMoreTableFooterDidTriggerLoadMore(view : LoadMoreTableFooterView) {
       isLoadMoreing = true
       self.loadData()
    }
    
    func loadMoreTableFooterDataSourceIsLoading(view : LoadMoreTableFooterView) -> Bool {
        return isLoadMoreing
    }

}

