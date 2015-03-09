//
//  AboutViewController.swift
//  pdms-ios
//
//  Created by IMEDS on 15-1-22.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel(frame: CGRectMake(20, 70 , self.view.bounds.size.width - 40, 150))
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(14)
        label.text = "大数据的浪潮已经悄然降临，并已渗透到医疗服务的方方面面。在大数据时代，从简单的数据收集到数据的挖掘与应用都发生了很大的变化。\n\n PDMS以医疗服务为核心，致力于医疗数据的采集、处理、管理和利用，开发和建立高效便捷的系统工具与服务平台，让医生、医疗机构、医药企业及普通人群充分利用各种有用的临床数据，为医疗、科研、保健、疾病预防和公共卫生发挥最大的价值。\n\n"
        
        label.sizeToFit()
        self.view.addSubview(label)
        self.view.updateConstraintsIfNeeded()
        
        let linkView = UIView(frame: CGRectMake(20, 70 + label.frame.height, self.view.bounds.size.width - 40, 21))
        let label1 = UILabel(frame: CGRectMake(0, 0, 100, 21))
        label1.font = UIFont.systemFontOfSize(14)
        label1.text = "PDMS网页版："
        linkView.addSubview(label1)
        
        let label2 = UILabel(frame: CGRectMake(0 + label1.frame.width, 0, 100, 21))
        label2.textColor = UIColor.appColor()
        label2.font = UIFont.systemFontOfSize(14)
        label2.text = "http://pdms.ydata.org"
        label2.sizeToFit()
        linkView.addSubview(label2)
        self.view.addSubview(linkView)
        
        label2.userInteractionEnabled = true
        let gestureRec = UITapGestureRecognizer(target: self, action: "openWebPage")
        label2.addGestureRecognizer(gestureRec)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func openWebPage() {
        let url = NSURL(string: "http://pdms.ydata.org")
        UIApplication.sharedApplication().openURL(url!)
    }

}

