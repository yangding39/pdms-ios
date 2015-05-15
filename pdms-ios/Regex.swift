//
//  Regex.swift
//  pdms-ios
//
//  Created by IMEDS on 15-1-27.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//

import Foundation
import UIKit

class Regex {
    let internalExpression : NSRegularExpression
    let pattern :String
    init (_pattern : String) {
        self.pattern = _pattern
        var error : NSError?
        self.internalExpression = NSRegularExpression(pattern: self.pattern, options: NSRegularExpressionOptions.CaseInsensitive, error: &error)!
    }
    
    func test(input : String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: nil, range: NSMakeRange(0, count(input)))
        return matches.count > 0
    }
}