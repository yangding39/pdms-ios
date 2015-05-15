//
//  CustomDatePicker.swift
//  CustomDatePicker
//
//  Created by IMEDS on 15-2-7.
//  Copyright (c) 2015年 tom. All rights reserved.
//

import UIKit

class CustomDatePicker : UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate  {
    var years = Array<String>()
    var months = Array<String>()
    var days = Array<String>()
    var hours = Array<String>()
    var minutes = Array<String>()
    
    var selectedYearRow : Int! = 0
    var selectedMonthRow : Int! = 0
    var date : NSDate!
    
     convenience init() {
        self.init()
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        //params init
        for var i = 1900; i < 2999; i++ {
            let year = String(format: "%d", i)
            years.append(year)
        }
        
        for var i = 1; i <= 12; i++ {
            let month = String(format: "%02d", i)
            months.append(month)
        }
        
        for var i = 1; i <= 31; i++ {
            let day = String(format: "%02d", i)
            days.append(day)
        }
        
        for var i = 0; i < 24; i++ {
            let hour = String(format: "%02d", i)
            hours.append(hour)
        }
        
        for var i = 0; i < 60; i++ {
            let minute = String(format: "%02d", i)
            minutes.append(minute)
        }
        date = NSDate()
        self.delegate = self
        self.dataSource = self
        setDateV(date)
        self.showsSelectionIndicator = true
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 5
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return years.count
        } else if component == 1 {
            return months.count
        } else if component == 2 {
            if selectedMonthRow == 0 || selectedMonthRow == 2 || selectedMonthRow == 4 || selectedMonthRow == 6 || selectedMonthRow == 7 || selectedMonthRow == 9 || selectedMonthRow == 11 {
                return 31
            } else if selectedMonthRow == 1 {
                if let year = years[selectedYearRow].toInt() {
                    if isLeapYear(year) {
                        return 29
                    } else {
                        return 28
                    }
                } else {
                    return 28
                }
                
            } else {
                return 30
            }
        }  else if component == 3 {
            return hours.count
        } else {
            return minutes.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var label = view as? UILabel
        if label == nil {
            label = UILabel(frame: CGRectMake(0, 0, self.pickerView(pickerView, widthForComponent: component), 28))
            
            label?.textAlignment = NSTextAlignment.Center
            label?.font = UIFont.systemFontOfSize(17.0)
        }
        
        if component == 0 {
            label?.text = years[row] + "年"
        } else if component == 1 {
            label?.text = months[row] + "月"
        } else if component == 2 {
            label?.text = days[row] + "日"
        } else if component == 3 {
            label?.text = hours[row] + "时"
        } else {
            label?.text = minutes[row] + "分"
        }
        return label!
    }
    
    //    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    //        if component == 0 {
    //            return years[row] + "年"
    //        } else if component == 1 {
    //            return months[row] + "月"
    //        } else if component == 2 {
    //            return days[row] + "日"
    //        } else if component == 3 {
    //            return hours[row] + "时"
    //        } else {
    //            return minutes[row] + "分"
    //        }
    //    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0 {
            return 70.0
        }
        return 46.0
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedYearRow = row
            pickerView.reloadAllComponents()
        } else if component == 1 {
            selectedMonthRow = row
            pickerView.reloadAllComponents()
        }
        let year = years[pickerView.selectedRowInComponent(0)]
        let month = months[pickerView.selectedRowInComponent(1)]
        let day = days[pickerView.selectedRowInComponent(2)]
        let hour = hours[pickerView.selectedRowInComponent(3)]
        let mintue = minutes[pickerView.selectedRowInComponent(4)]
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd HHmm"
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()
        let dateString = year + month + day + " " + hour + mintue
        if let selectDate = dateFormatter.dateFromString(dateString) {
            self.date = selectDate
        }
    }
    
    func isLeapYear(year : Int) -> Bool {
        if (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 || (year % 3200 == 0 && year % 172800 == 0){
            return true
        }
        return false
    }
    
    func setDateV(date : NSDate) {
        let dateFormatter = NSDateFormatter()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
        let year = String(format: "%d", components.year)
        if let index = find(years, year) {
            selectedYearRow = index
            self.selectRow(index, inComponent: 0, animated: true)
        }
        let month = String(format: "%02d", components.month)
        if let index = find(months, month) {
            selectedMonthRow = index
            self.selectRow(index, inComponent: 1, animated: true)
        }
        
        let day = String(format: "%02d", components.day)
        if let index = find(days, day) {
            self.selectRow(index, inComponent: 2, animated: true)
        }
        
        let hour = String(format: "%02d", components.hour)
        if let index = find(hours, hour) {
            self.selectRow(index, inComponent: 3, animated: true)
        }
        
        let minute = String(format: "%02d", components.minute)
        if let index = find(minutes, minute) {
            self.selectRow(index, inComponent: 4, animated: true)
        }
        
    }
}
