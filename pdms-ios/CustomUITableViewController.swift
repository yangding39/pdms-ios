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
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.accessoryType == UITableViewCellAccessoryType.DisclosureIndicator {
            let image = UIImage(named: "accessory")
            cell.accessoryView = UIImageView(image: image)
        }
    }
}
