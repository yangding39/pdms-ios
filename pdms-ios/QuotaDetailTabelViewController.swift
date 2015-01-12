//
//  QuotaDetailTabelViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-15.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//

import UIKit

class QuotaDetailTabelViewController: UITableViewController {
    var quota = Quota()
    var patient : Patient!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = UITableViewHeaderFooterView(frame: CGRectMake(0, 0, tableView.frame.size.width, 60))
        
        sectionHeaderView.textLabel.text = quota.name
        sectionHeaderView.tintColor = UIColor.sectionColor()
        return sectionHeaderView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quota.quotaDatas.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("showQuotaCell", forIndexPath: indexPath) as UITableViewCell
        let data = quota.quotaDatas[indexPath.row]
        cell.textLabel?.text = data.columnName
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        if data.unitName != nil {
            cell.detailTextLabel?.text = "\(data.value) \(data.unitName)"
        } else {
            cell.detailTextLabel?.text = data.value
        }
        return cell
    }
  
    func loadData() {
        for i in 1...5 {
            let data = Data()
            data.columnName = "红细胞红红细胞红细胞细胞\(i)"
            data.value = "\(90)"
            data.unitName = "L"
            quota.quotaDatas.append(data)
        }
        self.tableView.reloadData()
    }
}
