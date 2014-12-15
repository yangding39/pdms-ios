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
    var parentGroupDefinition : GroupDefinition!
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
        cell.textLabel.text = groupDefinitions[indexPath.row].name
        return cell
    }

    func loadData() {
        for i in 1...4 {
            let groupdDefinition = GroupDefinition()
           
            groupdDefinition.name = "职业史\(i)"
            groupDefinitions.append(groupdDefinition)
        }
        self.tableView.reloadData()
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        let hasNext = hasNextLevelGroup()
        if hasNext {
             let nextGroupDefinitionVC = self.navigationController?.storyboard?.instantiateViewControllerWithIdentifier("nextLevelGroupDefinitionTableViewController") as NextLevelGroupDefinitionTableViewController
            let indexPath = self.tableView.indexPathForCell(sender as UITableViewCell)!
            nextGroupDefinitionVC.navigationItem.title = groupDefinitions[indexPath.row].name
            nextGroupDefinitionVC.visit = visit
            nextGroupDefinitionVC.parentGroupDefinition = groupDefinitions[indexPath.row]
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
        }
    }
    
    func hasNextLevelGroup() -> Bool {
        return false
    }
}

