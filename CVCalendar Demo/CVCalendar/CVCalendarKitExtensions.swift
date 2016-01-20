//
//  CVCalendarKitExtensions.swift
//  CVCalendarKit
//
//  Created by Eugene Mozharovsky on 05/05/15.
//  Copyright (c) 2015 Dwive. All rights reserved.
//

import Foundation

protocol BidirectionalType {
    func next() -> Self
    func previous() -> Self
}

protocol DescriptionType {
    typealias Value
    func descriptionValue() -> Value
}

protocol OffsetValueType {
    typealias Offset
    func valueWithOffset(offset: Offset) -> Self
}

/**
 A wrapper around weekday raw value. The values match ones presented in NSCalendar.
 */
public enum Weekday: Int, BidirectionalType, DescriptionType {
    case Sunday = 1
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    
    public func next() -> Weekday {
        switch self {
        case .Sunday: return .Monday
        case .Monday: return .Tuesday
        case .Tuesday: return .Wednesday
        case .Wednesday: return .Thursday
        case .Thursday: return .Friday
        case .Friday: return .Saturday
        case .Saturday: return .Sunday
        }
    }
    
    public func previous() -> Weekday {
        switch self {
        case .Sunday: return .Saturday
        case .Monday: return .Sunday
        case .Tuesday: return .Monday
        case .Wednesday: return .Tuesday
        case .Thursday: return .Wednesday
        case .Friday: return .Thursday
        case .Saturday: return .Friday
        }
    }
    
    public func descriptionValue() -> String {
        switch self {
        case .Sunday: return "Sunday".localized
        case .Monday: return "Monday".localized
        case .Tuesday: return "Tuesday".localized
        case .Wednesday: return "Wednesday".localized
        case .Thursday: return "Thursday".localized
        case .Friday: return "Friday".localized
        case .Saturday: return "Saturday".localized
        }
    }
    
    /**
    Offset is the first weekday.
    */
//    public func valueWithOffset(offset: Int) -> Weekday {
//        if offset == 1 {
//            return self
//        }
//        
//        
//    }
}

/**
 Date format for string description and date construction.
 */
public enum DateFormat: String {
    case YYMMDD = "yy-MM-dd"
    case YYYYMMDD = "yyyy-MM-dd"
    case YYMMMMDD = "yy-MMMM-dd"
    case YYMMMMDDDD = "yy-MMMM-dddd"
    case YYYYMMMMDD = "yyyy-MMMM-dddd"
    
    case DDMMYY = "dd-MM-yy"
    case DDMMYYYY = "dd-MM-yyyy"
    case DDMMMMYY = "dd-MMMM-yy"
    case DDDDMMMMYY = "dddd-MMMM-yy"
    case DDDDMMMMYYYY = "dddd-MMMM-yyyy"
}

private let YearUnit = NSCalendarUnit.Year
private let MonthUnit = NSCalendarUnit.Month
private let WeekUnit = NSCalendarUnit.WeekOfMonth
private let WeekOfYearUnit = NSCalendarUnit.WeekOfYear
private let WeekdayUnit = NSCalendarUnit.Weekday
private let DayUnit = NSCalendarUnit.Day
private let HourUnit = NSCalendarUnit.Hour
private let MinuteUnit = NSCalendarUnit.Minute
private let SecondUnit = NSCalendarUnit.Second
private let AllUnits: NSCalendarUnit = [YearUnit , MonthUnit , WeekUnit , WeekOfYearUnit , WeekdayUnit , DayUnit, HourUnit, MinuteUnit, SecondUnit]

public extension NSCalendar {
    /**
     Returns the NSDateComponents instance for all main units.
     
     :param: Date The date for components construction.
     :returns: The NSDateComponents instance for all main units.
     */
    func allComponentsFromDate(date: NSDate) -> NSDateComponents {
        return components(AllUnits, fromDate: date)
    }
}


public extension NSDate {
    private typealias DateRange = (year: Int, month: Int, day: Int)
    
    /**
     Calculates the date values.
     
     :returns: A tuple with date year, month and day values.
     */
    private func dateRange() -> DateRange {
        let calendar = NSCalendar.currentCalendar()
        let comps = calendar.allComponentsFromDate(self)
        
        return (comps.year, comps.month, comps.day)
    }
    
    /**
     Calculates the specific date values.
     
     :returns: A tuple with date hours and minutes.
     */
    private typealias DateSpecificRange = (week: Int, hours: Int, minutes: Int)
    private func dateSpecificRange() -> DateSpecificRange {
        let calendar = NSCalendar.currentCalendar()
        let comps = calendar.allComponentsFromDate(self)
        
        return (comps.weekOfMonth, comps.hour, comps.minute)
    }
    
    var hour: DateUnit {
        get {
            return .Hour(self, dateSpecificRange().hours)
        }
    }
    
    var minute: DateUnit {
        get {
            return .Minute(self, dateSpecificRange().minutes)
        }
    }
    
    /**
     Current date weekday.
     */
    var weekday: Weekday {
        get {
            return Weekday(rawValue: NSCalendar.currentCalendar().allComponentsFromDate(self).weekday)!
        }
    }
    
    /**
     Date year.
     */
    var year: DateUnit {
        get {
            return .Year(self, dateRange().year)
        }
    }
    
    /**
     Date month.
     */
    var month: DateUnit {
        get {
            return .Month(self, dateRange().month)
        }
    }
    
    /**
     Date week of month.
     */
    var week: DateUnit {
        get {
            return .Week(self, dateSpecificRange().week)
        }
    }
    
    /**
     Date day.
     */
    var day: DateUnit {
        get {
            return .Day(self, dateRange().day)
        }
    }
    
    /**
     Returns the first date in the current date's month.
     
     :returns: The first date in the current date's month.
     */
    func firstMonthDate() -> NSDate {
        return (self.day == 1)
    }
    
    /**
     Returns the last date in the current date's month.
     
     :returns: The las date in the current date's month.
     */
    func lastMonthDate() -> NSDate {
        return ((firstMonthDate().month + 1).day - 1)
    }
    
    /**
     Returns the first date in the current date's year.
     
     :returns: The first date in the current date's year.
     */
    func firstYearDate() -> NSDate {
        return ((NSDate().month == 1).day == 1)
    }
    
    /**
     Returns the last date in the current date's year.
     
     :returns: The last date in the current date's year.
     */
    func lastYearDate() -> NSDate {
        return (((firstYearDate().month == 12).month + 1).day - 1)
    }
    
    convenience init?(date: NSDate, hour: Int, minute: Int) {
        let calendar = NSCalendar.currentCalendar()
        let comps = calendar.components([.Hour , .Minute], fromDate: date)
        comps.hour = 0
        comps.minute = 0
        
        let first = calendar.dateFromComponents(comps)!
        
        let compss = calendar.components([.Hour , .Minute], fromDate: first)
        compss.hour = hour
        compss.minute = minute
        
        if let result = calendar.dateFromComponents(compss) {
            self.init(timeIntervalSince1970: result.timeIntervalSince1970)
        } else {
            self.init()
            return nil
        }
    }
    
    /**
     Returns a date description string with the given locale and format.
     
     - parameter locale: The locale for converting the date.
     - parameter format: String format for the converted date.
     - parameter style: String style for the converted date.
     - returns: A date description string with the given locale and format.
     */
    func descriptionWithLocale(locale: NSLocale? = nil, format: DateFormat = .YYMMDD, style: NSDateFormatterStyle?) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format.rawValue
        
        if let formatterLocale = locale {
            formatter.locale = formatterLocale
        }
        
        if let formatterStyle = style {
            formatter.dateStyle = formatterStyle
        }
        
        return formatter.stringFromDate(self)
    }
}

public extension String {
    /**
     Returns an optional associated with date from the given string and format.
     
     - parameter format: Date format used for date conversion.
     - parameter style: Date style for date conversion.
     - returns: Either an NSDate instance or nil if a String can't be converted.
     */
    func date(format: DateFormat, style: NSDateFormatterStyle? = .LongStyle) -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format.rawValue
        if let formatterStyle = style {
            formatter.dateStyle = formatterStyle
        }
        
        return formatter.dateFromString(self)
    }
    
    /**
     
     */
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}