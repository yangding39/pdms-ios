//
//  CustomUITableViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 15-2-2.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//

import UIKit

extension UITableViewController {
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
