//
//  UIColor+ColorFromCode.swift
//  Calendar
//
//  Created by Мак-ПК on 12/18/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

extension UIColor {
    class func colorFromCode(code: Int) -> UIColor {
        let red = CGFloat((code & 0xFF0000) >> 16) / 255
        let green = CGFloat((code & 0xFF00) >> 8) / 255
        let blue = CGFloat((code & 0xFF)) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}