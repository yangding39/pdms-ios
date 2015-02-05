//
//  CustomDatePicker.swift
//  pdms-ios
//
//  Created by IMEDS on 15-1-30.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//

import Foundation
import UIKit

class CustomDatePicker : UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
//    func createDatePicker() -> UIPickerView {
//        
//        return nil
//    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return ""
    }
}