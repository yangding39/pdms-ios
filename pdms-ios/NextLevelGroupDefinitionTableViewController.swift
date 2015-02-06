//
//  NextLevelGroupDefinitionTableViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-12.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//

import UIKit

class NextLevelGroupDefinitionTableViewController : UITableViewController {

    var visit : Visit!
    var patient : Patient!
    var parentGroupDefinition : GroupDefinition!
    var crowDefinition : GroupDefinition!
    var groupDefinitions = Array<GroupDefinition> ()
    var isFavorite =  false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupDefinitions.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("groupDefinitionCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = groupDefinitions[indexPath.row].name
        cell.textLabel?.sizeToFit()
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let groupDefinition = groupDefinitions[indexPath.row]
        let labelHeight = UILabel.heightForDynamicText(groupDefinition.name, font: UIFont.systemFontOfSize(17.0), width: self.tableView.bounds.width)
        return 23 + labelHeight
    }
    
    func loadData() {
        var url = ""
        if isFavorite {
            url = SERVER_DOMAIN + "quota/favoriteQuotas"
        } else {
            url = SERVER_DOMAIN + "quota/nextLevelQuota"
        }
        
        let parameters : [ String : AnyObject] = ["token": TOKEN, "groupDefinitionId": parentGroupDefinition.id]
        HttpApiClient.sharedInstance.getLoading(url, paramters: parameters, loadingPosition: HttpApiClient.LOADING_POSTION.AFTER_TABLEVIEW, viewController: self, success: fillData, fail: nil)
    }
    
    func fillData(json : JSON) {
        for (index: String, groupJson: JSON) in json["data"]["groupDefinitions"]  {
            let groupDefintion = GroupDefinition()
            groupDefintion.id = groupJson["groupDefinitionId"].number
            groupDefintion.name = groupJson["groupDefinitionName"].string
            groupDefintion.type = groupJson["groupDefinitionType"].int
            groupDefinitions.append(groupDefintion)
        }
        self.tableView.reloadData()
    }
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        let hasNext = hasNextLevelGroup(sender)
        if hasNext {
             let nextGroupDefinitionVC = self.navigationController?.storyboard?.instantiateViewControllerWithIdentifier("nextLevelGroupDefinitionTableViewController") as NextLevelGroupDefinitionTableViewController
            let indexPath = self.tableView.indexPathForCell(sender as UITableViewCell)!
            nextGroupDefinitionVC.navigationItem.title = groupDefinitions[indexPath.row].name
            nextGroupDefinitionVC.visit = visit
            nextGroupDefinitionVC.patient = patient
            nextGroupDefinitionVC.parentGroupDefinition = groupDefinitions[indexPath.row]
            nextGroupDefinitionVC.crowDefinition = crowDefinition
            self.navigationController?.navigationItem.backBarButtonItem?.title = parentGroupDefinition.name
            self.navigationController?.pushViewController(nextGroupDefinitionVC, animated: true)
            
            return false
        } else {
            return true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "formSegue" {
            let formTableViewController = segue.destinationViewController as FormTableViewController
            formTableViewController.visit = visit
            formTableViewController.patient = patient
            let indexPath = self.tableView.indexPathForCell(sender as UITableViewCell)!
            let groupDefinition = groupDefinitions[indexPath.row]
            formTableViewController.navigationItem.title = groupDefinition.name
            formTableViewController.parentGroupDefinition = groupDefinition
            formTableViewController.crowDefinition = crowDefinition
            formTableViewController.navigationItem.backBarButtonItem?.title = "返回"
        }
    }
    
    func hasNextLevelGroup(sender: AnyObject?) -> Bool {
        if let tableCell = sender as? UITableViewCell {
            let indexPath = self.tableView.indexPathForCell(tableCell)!
            let groupDefinition = groupDefinitions[indexPath.row]
            if groupDefinition.type == GroupDefinition.TYPE.PARENT {
                return true
            }
        }
        return false
    }
}

