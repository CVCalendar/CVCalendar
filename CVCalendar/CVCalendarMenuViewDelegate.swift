//
//  CVCalendarMenuViewDelegate.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 15/04/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import Foundation
import UIKit

@objc
public protocol CVCalendarMenuViewDelegate {
    optional func firstWeekday() -> Weekday
    optional func dayOfWeekTextColor() -> UIColor
    optional func dayOfWeekTextUppercase() -> Bool
    optional func dayOfWeekFont() -> UIFont
    optional func weekdaySymbolType() -> WeekdaySymbolType
}