//
//  QuotaTableViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-11.
//  Copyright (c) 2014年 unimedsci. All rights reserved.


import UIKit

class QuotaByPatientTableViewController: UITableViewController {

    var patient : Patient!
    var url : String!
    var crowDefintions = Array<CrowDefintion>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        for i in 1...3 {
            var crowDefintion = CrowDefintion()
            crowDefintion.name = "生活史\(i)"
            for j in 1...2 {
                var quota = Quota()
                quota.name = "霍乱\(i)-\(j)"
                crowDefintion.quota.append(quota)
            }
            crowDefintions.append(crowDefintion)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return crowDefintions.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return crowDefintions[section].quota.count
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        let headerLabel = UILabel(frame: CGRectMake(10, 10, sectionHeaderView.frame.size.width, 25))
        sectionHeaderView.addSubview(headerLabel)
        
        headerLabel.font = UIFont(name: "Verdana", size: 14)
        headerLabel.text = crowDefintions[section].name
        sectionHeaderView.backgroundColor = UIColor.lightGrayColor()
        headerLabel.backgroundColor = UIColor.lightGrayColor()
        
        return sectionHeaderView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("quotaCell", forIndexPath: indexPath) as QuotaCell
        cell.name.text = crowDefintions[indexPath.section].quota[indexPath.row].name
        
        return cell
    }
}
