//
//  CategoryTableViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-12.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//


import UIKit

class CategoryTableViewController : UITableViewController {

    var visit : Visit!
    var patient : Patient!
    var categoryDatas = Array<GroupDefinition>()
    var searchQuotaData = Array<GroupDefinition>()
    var isFavorite = true
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData(0)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if tableView == self.searchDisplayController?.searchResultsTableView {
           return searchQuotaData.count
       } else {
            return categoryDatas.count + 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.searchDisplayController?.searchResultsTableView {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("categorySearchCell") as UITableViewCell
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = searchQuotaData[indexPath.row].name
            return cell
        } else {
           if indexPath.row == 0 {
              let cell = tableView.dequeueReusableCellWithIdentifier("categorySelectCell", forIndexPath: indexPath) as UITableViewCell
              return cell
           } else {
              let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath) as UITableViewCell
              cell.textLabel?.text = categoryDatas[indexPath.row - 1 ].name
              return cell
           }
        }
       
    }
    
    @IBAction func categoryChanged(sender: UISegmentedControl) {
        loadData(sender.selectedSegmentIndex)
    }
    
    func loadData(categoryIndex : Int) {
        var url = SERVER_DOMAIN + "quota/favoriteCategory"
        isFavorite = true
        if categoryIndex == 1 {
            url = SERVER_DOMAIN + "quota/allQuotas"
            isFavorite = false
        }
        let parameters = ["token": TOKEN]
        HttpApiClient.sharedInstance.getLoading(url, paramters: parameters, loadingPosition: HttpApiClient.LOADING_POSTION.AFTER_TABLEVIEW, viewController: self, success: fillData, fail: nil)
    }
    
    func fillData(json : JSON) {
        categoryDatas.removeAll(keepCapacity: true)
        for (index: String, favoriteJson: JSON) in json["data"]  {
            let groupDefintion = GroupDefinition()
            groupDefintion.id = favoriteJson["groupDefinitionId"].number
            groupDefintion.name = favoriteJson["groupDefinitionName"].string
            groupDefintion.type = favoriteJson["groupDefinitionType"].int
            categoryDatas.append(groupDefintion)
        }
        self.tableView.reloadData()
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        if (searchString != nil && !searchString.isEmpty) {
            self.searchQuotaData.removeAll(keepCapacity: true)
            self.searchQuota(controller, searchString: searchString)
            return true
        }
        return false
    }
    
    func searchQuota(controller: UISearchDisplayController, searchString: String) {
        let url = SERVER_DOMAIN + "quota/searchQuota"
        let parameters = ["token": TOKEN, "groupDefinitionName": searchString]
        HttpApiClient.sharedInstance.get(url, paramters : parameters, success: fillSearchData, fail : nil)
    }
    
    func fillSearchData(json: JSON) -> Void{
        for (index: String, favoriteJson: JSON) in json["data"]  {
            let groupDefintion = GroupDefinition()
            groupDefintion.id = favoriteJson["groupDefinitionId"].number
            var crowName = ""
            if let namePath = favoriteJson["namePath"].string {
                if let range = namePath.rangeOfString("/") {
                    crowName = namePath.substringToIndex(range.startIndex) + "-"
                }
            }
            groupDefintion.name = crowName + favoriteJson["groupDefinitionName"].string!
            groupDefintion.type = favoriteJson["groupDefinitionType"].int
            
            searchQuotaData.append(groupDefintion)
        }

        self.searchDisplayController?.searchResultsTableView.reloadData()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if self.searchDisplayController?.active == true {
            if segue.identifier == "searchQuotaToFormSegue" {
                if let indexPath = self.searchDisplayController?.searchResultsTableView.indexPathForCell(sender as UITableViewCell) {
                    let formTableViewController = segue.destinationViewController as FormTableViewController
                    formTableViewController.visit = visit
                    formTableViewController.patient = patient
                    let groupDefinition = self.searchQuotaData[indexPath.row]
                    formTableViewController.navigationItem.title = groupDefinition.name
                    formTableViewController.parentGroupDefinition = groupDefinition
                    //formTableViewController.crowDefinition = crowDefinition
                }
            }
        } else {
            if segue.identifier == "nextGroupDefinitionSegue" {
                let nextGroupDefinitionVC = segue.destinationViewController as NextLevelGroupDefinitionTableViewController
                let indexPath = self.tableView.indexPathForCell(sender as UITableViewCell)!
                nextGroupDefinitionVC.navigationItem.title = categoryDatas[indexPath.row - 1].name
                nextGroupDefinitionVC.visit = visit
                nextGroupDefinitionVC.patient = patient
                nextGroupDefinitionVC.parentGroupDefinition = categoryDatas[indexPath.row - 1]
                nextGroupDefinitionVC.crowDefinition = categoryDatas[indexPath.row - 1]
                nextGroupDefinitionVC.isFavorite = isFavorite
            }

        }
    }
   
}

