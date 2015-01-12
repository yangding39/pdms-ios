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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
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
        cell.textLabel?.text = groupDefinitions[indexPath.row].name
        return cell
    }

    func loadData() {
        let url = SERVER_DOMAIN + "quota/nextLevelQuota"
        let parameters : [ String : AnyObject] = ["token": TOKEN, "groupDefinitionId": parentGroupDefinition.id]
        HttpApiClient.sharedInstance.get(url, paramters : parameters, success: fillData, fail : nil)
    }
    
    func fillData(json : JSON) {
        for (index: String, groupJson: JSON) in json["data"]["groupDefinitions"]  {
            let groupDefintion = GroupDefinition()
            groupDefintion.id = groupJson["groupDefinitionId"].int
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

