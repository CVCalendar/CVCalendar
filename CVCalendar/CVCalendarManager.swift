//
//  CVCalendarManager.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 5/2/15.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

private let YearUnit = NSCalendarUnit.Year
private let MonthUnit = NSCalendarUnit.Month
private let WeekUnit = NSCalendarUnit.WeekOfMonth
private let WeekdayUnit = NSCalendarUnit.Weekday
private let DayUnit = NSCalendarUnit.Day
private let AllUnits = [YearUnit, MonthUnit, WeekUnit, WeekdayUnit, DayUnit]

/*
NSCalendarUnitEra                = kCFCalendarUnitEra,
NSCalendarUnitYear               = kCFCalendarUnitYear,
NSCalendarUnitMonth              = kCFCalendarUnitMonth,
NSCalendarUnitDay                = kCFCalendarUnitDay,
NSCalendarUnitHour               = kCFCalendarUnitHour,
NSCalendarUnitMinute             = kCFCalendarUnitMinute,
NSCalendarUnitSecond             = kCFCalendarUnitSecond,
NSCalendarUnitWeekday            = kCFCalendarUnitWeekday,
NSCalendarUnitWeekdayOrdinal     = kCFCalendarUnitWeekdayOrdinal,
*/

private let iOS9: Bool = {
    if #available(iOS 9, *) {
        return true
    } else {
        return false
    }
}()

public final class CVCalendarManager {
    typealias Calendar = Weekday -> NSCalendar
    typealias Components = (NSCalendar, NSCalendarUnit, NSDate) -> NSDateComponents
    typealias Date = (Offset?, NSDateComponents, NSCalendar) -> NSDate?
    
    // MARK: - Functional properties
    
    internal let calendar: Calendar = { weekday in
        let calendar = NSCalendar.currentCalendar()
        calendar.firstWeekday = weekday.rawValue
        
        return calendar
    }
    
    internal let components: Components = { cal, units, date in
        cal.components(units, fromDate: date)
    }
    
    // MARK: - Public properties
    
    public var currentCalendar: NSCalendar {
        get {
            return calendar(firstWeekday)
        }
    }
    
    
    // MARK: - Inner properties
    
    private var firstWeekday: Weekday
    private var calendarView: CalendarView
    
    // MARK: - Initialization
    
    public init(calendarView: CalendarView) {
        firstWeekday = Weekday(rawValue: calendarView.firstWeekday.rawValue)!
        self.calendarView = calendarView
        
        #if DEBUG
            print("First \(firstWeekday.stringValue())")
        #endif
    }
    
    // MARK: - Weekdays management
    
    public func weekdaysForDate(date: NSDate) -> [[Weekday : NSDate]] {
        return weekdaysForDate()(monthDateRange(date))
    }
    
    // MARK: - Weekdays calculation
    
    typealias Weekdays = DateRange -> [[Weekday : NSDate]]
    
    private struct DateValue {
        let weekday: Weekday
        let date: NSDate
    }
    
    private func weekdaysForDate() -> Weekdays {
        return { start, end, _ in
            var weekdays = [[Weekday : NSDate]]()
            var date = start
            
            for _ in 0...self.monthDateRange(start).numberOfWeeks {
                var weekday = self.firstWeekday
                var week: [Weekday : NSDate] = [:]
                
                for _ in 0..<7 {
                    week[weekday] = date
                    date = date.day + 1
                    weekday = weekday.next()
                }
                
                weekdays += [week]
            }

            
            assert(weekdays[0].count == 7)
            
            return weekdays
        }
    }
    
    private func weekOfYear(date: NSDate) -> Int {
        return currentCalendar.allComponentsFromDate(date).weekOfYear
    }
    
    typealias DateOffset = Offset -> NSDate?
    
    private func dateWithOffset(comps: NSDateComponents) -> DateOffset {
        return { offset in
            comps.year += offset.year
            comps.month += offset.month
            comps.day += offset.day
            
            return self.currentCalendar.dateFromComponents(comps)
        }
    }
    
    // MARK: - Date range management
    
    public typealias DateRange = (monthStart: NSDate, monthEnd: NSDate, numberOfWeeks: Int)
    
    public func monthDateRange(presentedDate: NSDate) -> DateRange {
        
        // Number of weeks.
        let range = currentCalendar.rangeOfUnit(.WeekOfMonth, inUnit: .Month, forDate: presentedDate)
        let numberOfWeeks = range.length
        
        var start = (presentedDate.month - 1).lastMonthDate().day + 1
        let startDiff: Int
        if presentedDate.firstMonthDate().weekday.rawValue != currentCalendar.firstWeekday {
            startDiff = ((start.weekday.rawValue + 7) - currentCalendar.firstWeekday) % 7
        } else {
            startDiff = 0
        }
        
        start = start.day - startDiff
        
        let end = start.day + ((numberOfWeeks * 7) - 1)
        
        #if DEBUG
            print("[CURRENT] \(presentedDate.day == 1)")
            print("[RESULT] Start = \(start), End = \(end)")
        #endif
        
        return (start, end, numberOfWeeks)
    }
    
    // MARK: - Util methods
    
    public static func componentsForDate(date: NSDate) -> NSDateComponents {
        let units = YearUnit.union(MonthUnit).union(WeekUnit).union(DayUnit)
        let components = NSCalendar.currentCalendar().components(units, fromDate: date)
        return components
    }
    
    public static func dateFromYear(year: Int, month: Int, week: Int, day: Int) -> NSDate? {
        let comps = CVCalendarManager.componentsForDate(NSDate())
        comps.year = year
        comps.month = month
        comps.weekOfMonth = week
        comps.day = day
        
        return NSCalendar.currentCalendar().dateFromComponents(comps)
    }
}

public extension Dictionary {
    public init(pairs: [(Key, Value)]) {
        self = [:]
        for (k, v) in pairs {
            self[k] = v
        }
    }
}

extension CollectionType {
    func splitAt(@noescape isSplit: Generator.Element throws -> Bool) rethrows -> [SubSequence] {
        var p = startIndex
        var result: [SubSequence] = try indices.flatMap { i in
            guard try isSplit(self[i]) else { return nil }
            defer { p = i.successor() }
            return self[p...i]
        }
        if p != endIndex { result.append(suffixFrom(p)) }
        return result
    }
}