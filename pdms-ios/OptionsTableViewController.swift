//
//  OptionsTableViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 15-1-6.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//


import UIKit

class OptionsTableViewController: UITableViewController {
    
    var data : Data!
    var parentGroupDefinition : GroupDefinition!
    var editingCell : QuotaFormCell!
    var options = Array<Option>()
    var mutilSelect : Bool = false
    var selectedCells = Array<UITableViewCell>()
    var selectedOptions = Array<Option>()
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
        return options.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("optionCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = options[indexPath.row].label
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)  as UITableViewCell!
        if self.checkedCellIsSelected(cell){
            cell.accessoryType = UITableViewCellAccessoryType.None
            self.removeFromSelectedCell(cell)
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            selectedCells.append(cell)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        if !mutilSelect {
            for otherSelectedCell in selectedCells {
                if !otherSelectedCell.isEqual(cell) {
                    self.removeFromSelectedCell(otherSelectedCell)
                    otherSelectedCell.accessoryType = UITableViewCellAccessoryType.None
                }
            }
        }

    }
    
    func loadData() {
        let url = SERVER_DOMAIN + "quota/listDicts"
        var isDrug = 0
        let columnName = editingCell.name.text
        if parentGroupDefinition.type == GroupDefinition.TYPE.DRUG && (columnName != "用法" && columnName != "单位") {
            isDrug = 1
        }
        let parameters : [ String : AnyObject] = ["token": TOKEN, "quotaDefinitionId": data.definitionId, "drugType" : isDrug]
        HttpApiClient.sharedInstance.get(url, paramters : parameters, success: fillData, fail : nil)
    }
    
    func fillData(json : JSON) {
        for (index: String, optionsJson: JSON) in json["data"]["options"]  {
             let option = Option()
             option.label = optionsJson["lable"].string
             option.value = optionsJson["value"].int
             self.options.append(option)
        }
        self.tableView.reloadData()
    }
    
    func checkedCellIsSelected(cell : UITableViewCell) -> Bool {
        for selectedCell in selectedCells {
            if cell.isEqual(selectedCell) {
                return true
            }
        }
        return false
    }
    
    func removeFromSelectedCell(cell : UITableViewCell) {
        var index = 0
        for selectedCell in selectedCells {
            if cell.isEqual(selectedCell) {
                selectedCells.removeAtIndex(index)
                break
            } else {
                index++
            }
        }

    }
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        for selectedCell in selectedCells {
            let indexPath = self.tableView.indexPathForCell(selectedCell)!
            self.selectedOptions.append(options[indexPath.row])
        }
    }
}

