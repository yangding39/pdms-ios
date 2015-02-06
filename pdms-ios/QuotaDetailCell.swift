//
//  QuotaDetailCell.swift
//  pdms-ios
//
//  Created by IMEDS on 15-2-6.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//
import  UIKit

class QuotaDetailCell : UITableViewCell {

    @IBOutlet weak var columnNameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.textLabel?.numberOfLines = 0
//        var cellHeight:CGFloat = 44.0
//        let cellFrame = self.frame
//        var textLabelFrame : CGRect?
//        var detailLabelFrame : CGRect?
//        if let font  = self.textLabel?.font {
//            if let text = self.textLabel?.text  {
//               let height = UILabel.heightForDynamicText(text, font: font, width: 150)
//                cellHeight = height + 23
//                if var frame = self.textLabel?.frame {
//                    frame = CGRectMake(frame.origin.x, frame.origin.y, 150, height)
//                    textLabelFrame = frame
//                }
//            }
//        }
//        
//        if let font  = self.detailTextLabel?.font {
//            if let text = self.detailTextLabel?.text  {
//                let height = UILabel.heightForDynamicText(text, font: font, width: cellFrame.width - 165)
//                if height > cellHeight {
//                    cellHeight = height + 23
//                }
//                if var frame = self.detailTextLabel?.frame {
//                    frame = CGRectMake(150, frame.origin.y, cellFrame.width - 165, height)
//                    self.detailTextLabel?.frame = frame
//                }
//            }
//        }
//        self.frame = CGRectMake(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, cellHeight)
//        if let frame = textLabelFrame {
//            self.textLabel?.frame = frame
//        }
    }
}