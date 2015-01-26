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
        
        let label = UILabel(frame: CGRectMake(20, 180 , self.view.bounds.size.width - 40, 150))
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(14)
        label.text = "大数据的浪潮已经悄然降临，并已渗透到医疗服务的方方面面。在大数据时代，从简单的数据收集到数据的挖掘与应用都发生了很大的变化。\n\n PDMS以医疗服务为核心，致力于医疗数据的采集、处理、管理和利用，开发和建立高效便捷的系统工具与服务平台，让医生、医疗机构、医药企业及普通人群充分利用各种有用的临床数据，为医疗、科研、保健、疾病预防和公共卫生发挥最大的价值。\n\n PDMS网页版：www.ydata.org"
        label.sizeToFit()
        self.view.addSubview(label)
        self.view.updateConstraintsIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

