//
//  CategorySearchBar.swift
//  pdms-ios
//
//  Created by IMEDS on 15-2-28.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//

import UIKit

class CategorySearchBar : UISearchBar, UISearchBarDelegate {
    
    override func layoutSubviews() {
        self.delegate = self
        super.layoutSubviews()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        if let searchTextField = getSearchTextField() {
            let label = UILabel(frame: CGRectMake(0, 0, 56, 20))
            label.font = UIFont.systemFontOfSize(14)
            label.textColor = UIColor.grayColor()
            label.text = "全部全部"
            searchTextField.leftView = label
        }
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        if let searchTextField = getSearchTextField() {
            searchTextField.leftView = nil
        }
    }
    
    func getSearchTextField() -> UITextField? {
        var searchTextField : UITextField?
        for view in self.subviews {
            if let textField  = view as? UITextField {
                searchTextField = textField
                break
            }
            for nextView in view.subviews {
                if let textField  = nextView as? UITextField {
                    searchTextField = textField
                    break
                }
            }
        }
        return searchTextField
    }
}
