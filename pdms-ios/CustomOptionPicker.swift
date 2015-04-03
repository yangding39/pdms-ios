//
//  CustomOptionPicker.swift
//  pdms-ios
//
//  Created by IMEDS on 15-2-10.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//

import UIKit

class CustomOptionPicker : UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate  {
    var options = Array<Option>()
    var data : Data!
    var value : String!
    var activityIndicator : UIActivityIndicatorView!
    
    func commonInit() {
        //params init
        loadData()
        self.delegate = self
        self.dataSource = self
        self.showsSelectionIndicator = true
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var label = view as? UILabel
        if label == nil {
            label = UILabel(frame: CGRectMake(0, 0, self.pickerView(pickerView, widthForComponent: component), 28))
            
            label?.textAlignment = NSTextAlignment.Center
            label?.font = UIFont.systemFontOfSize(17.0)
        }
        
        if component == 0 {
            if data.columnName == "中文商品名" {
                label?.text = getTradeCN(options[row].label)
            } else {
                label?.text = options[row].label
            }
        }
        label?.adjustsFontSizeToFitWidth = true
        return label!
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if let superView = self.superview {
            return superView.bounds.width
        }
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row < options.count {
            self.value = options[row].label
        }
    }
    
    func loadData() {
        self.options.removeAll(keepCapacity: true)
        let url = SERVER_DOMAIN + "quota/listDicts"
        var isDrug = 0
        let columnName = data.columnName
        if data.isDrug && (columnName != "用法" && columnName != "单位") {
            isDrug = 1
        }
        let parameters : [ String : AnyObject] = ["token": TOKEN, "quotaDefinitionId": data.definitionId, "drugType" : isDrug]
        HttpApiClient.sharedInstance.get(url, paramters: parameters,success: fillData, fail: nil)
        
        activityIndicator = UIActivityIndicatorView(frame : self.bounds)
        activityIndicator.center = self.center
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.startAnimating()
        self.addSubview(activityIndicator)
    }
    
    func fillData(json : JSON) {
        if activityIndicator != nil {
            activityIndicator.stopAnimating()
            activityIndicator.hidden = true
        }
        for (index: String, optionsJson: JSON) in json["data"]["options"]  {
            let option = Option()
            option.label = optionsJson["lable"].string
            option.value = optionsJson["value"].number
            self.options.append(option)
        }
        if !options.isEmpty {
            self.value = options[0].label
        }
        self.reloadAllComponents()
    }

    func getTradeCN(label : String) -> String {
        if let range = label.rangeOfString("-") {
            let newLabel = label.substringToIndex(range.startIndex)
            return newLabel
        }
       return label
    }
    
    func getTradeEN(label : String) -> String? {
        if let range = label.rangeOfString("-") {
            let newLabel = label.substringFromIndex(range.endIndex)
            return newLabel
        }
        return nil
    }
}
