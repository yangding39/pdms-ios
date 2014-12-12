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
    var categoryDatas = Array<CrowDefintion>()
    var searchQuotaData = Array<GroupDefinition>()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData(0)
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
            let cell = self.tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel.text = searchQuotaData[indexPath.row].name
            return cell
        } else {
           if indexPath.row == 0 {
              let cell = tableView.dequeueReusableCellWithIdentifier("categorySelectCell", forIndexPath: indexPath) as UITableViewCell
              return cell
           } else {
              let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath) as UITableViewCell
              cell.textLabel.text = categoryDatas[indexPath.row - 1 ].name
              return cell
           }
        }
       
    }
    @IBAction func categoryChanged(sender: UISegmentedControl) {
        loadData(sender.selectedSegmentIndex)
    }
    
    func loadData(categoryIndex : Int) {
        categoryDatas.removeAll(keepCapacity: true)
        if categoryIndex == 0 {
            for i in 1...4 {
                let crowDefintion = CrowDefintion()
                crowDefintion.name = "生活史\(i)"
                categoryDatas.append(crowDefintion)
            }
        } else {
            for i in 1...4 {
                let crowDefintion = CrowDefintion()
                crowDefintion.name = "疾病诊断\(i)"
                categoryDatas.append(crowDefintion)
            }

        }
        
        self.tableView.reloadData()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if self.searchDisplayController?.active == true {
            
        } else {
            if segue.identifier == "nextGroupDefinitionSegue" {
                let nextGroupDefinitionVC = segue.destinationViewController as NextLevelGroupDefinitionTableViewController
                let indexPath = self.tableView.indexPathForCell(sender as UITableViewCell)!
                nextGroupDefinitionVC.navigationItem.title = categoryDatas[indexPath.row - 1].name
                nextGroupDefinitionVC.visit = visit
                nextGroupDefinitionVC.parentId = categoryDatas[indexPath.row - 1].id
            }

        }
    }
}

