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
    @objc optional func firstWeekday() -> Weekday
    @objc optional func dayOfWeekTextColor(by weekday: Weekday) -> UIColor
    @objc optional func dayOfWeekBackGroundColor(by weekday: Weekday) -> UIColor
    @objc optional func dayOfWeekTextColor() -> UIColor
    @objc optional func dayOfWeekBackGroundColor() -> UIColor
    @objc optional func dayOfWeekTextUppercase() -> Bool
    @objc optional func dayOfWeekFont() -> UIFont
    @objc optional func weekdaySymbolType() -> WeekdaySymbolType
}
