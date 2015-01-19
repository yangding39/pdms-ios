//
//  CustomPickerView.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-17.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//

import UIKit

extension UIDatePicker {
    func customPickerStyle(parentView : UIView) -> UIDatePicker {
        
        var datePicker: UIDatePicker = UIDatePicker(frame: CGRectMake(0, 0, parentView.bounds.width,50))
        datePicker.datePickerMode = UIDatePickerMode.Date
        //datePicker.locale = NSLocale(localeIdentifier: "en_GB")
        self.backgroundColor = UIColor(red: 147.0, green: 146.0, blue: 144.0, alpha: 40.0)
        
        return datePicker
    }
}

extension UIToolbar {
    func customPickerToolBarStyle(parentView : UIView , doneSelector : Selector, target : AnyObject) -> UIToolbar {
        var toolbar = UIToolbar(frame: CGRectMake(0, 0, parentView.bounds.width, 44))
        toolbar.backgroundColor = UIColor(red: 241, green: 241, blue: 239, alpha: 100)
        var flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        var barItem = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Done, target: target, action: doneSelector)
        toolbar.setItems([flexSpace, barItem], animated: true)
        return toolbar
    }
}

extension UIPickerView {
    func customPickerStyle(parentView : UIView, delegate : UIPickerViewDelegate, dataSource : UIPickerViewDataSource) -> UIPickerView {
        let selectPicker = UIPickerView(frame: CGRectMake(0, 0, parentView.bounds.width, 10))
        selectPicker.dataSource = dataSource
        selectPicker.delegate = delegate
        
        return selectPicker
    }
}
