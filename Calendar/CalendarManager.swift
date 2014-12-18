//
//  CalendarManager.swift
//  Calendar
//
//  Created by E. Mozharovsky on 12/15/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CalendarManager: NSObject {
    private var components: NSDateComponents?
    private var calendar: NSCalendar?
    
    var currentDate: NSDate?
    
    class func sharedManager() -> CalendarManager {
        var calendarManager: CalendarManager? = nil
        var t: dispatch_once_t = 0
        
        dispatch_once(&t, { () -> Void in
            calendarManager = CalendarManager()
        })
        
        return calendarManager!
    }
    
    private override init() {
        self.calendar = NSCalendar.currentCalendar()
        self.currentDate = NSDate()
        self.components = self.calendar?.components(NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit, fromDate: self.currentDate!)
    }
    
    func monthDateRange(date: NSDate) -> (countOfWeeks: NSInteger, monthStartDate: NSDate, monthEndDate: NSDate) {
        let units = (NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.WeekCalendarUnit)
        var components = self.calendar!.components(units, fromDate: date)
        
        // Start of the month.
        components.day = 1
        let monthStartDate = self.calendar?.dateFromComponents(components)
        
        // End of the month.
        components.month += 1
        components.day -= 1
        let monthEndDate = self.calendar?.dateFromComponents(components)
        
        // Range of the month.
        let range = self.calendar?.rangeOfUnit(NSCalendarUnit.WeekCalendarUnit, inUnit: NSCalendarUnit.MonthCalendarUnit, forDate: date)
        let countOfWeeks = range?.length
        
        return (countOfWeeks!, monthStartDate!, monthEndDate!)
    }
    
    func dateRange(date: NSDate) -> (year: Int, month: Int, day: Int) {
        let units = NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.WeekCalendarUnit | NSCalendarUnit.DayCalendarUnit
        let components = self.calendar?.components(units, fromDate: date)
        
        let year = components?.year
        let month = components?.month
        let day = components?.day
        
        return (year!, month!, day!)
    }
    
    func weekdayForDate(date: NSDate) -> CalendarWeekday {
        let units = NSCalendarUnit.WeekdayCalendarUnit
        
        let components = self.calendar!.components(units, fromDate: date)
        
        return CalendarWeekday(rawValue: Int(components.weekday))!
    }
    
    func sortedWeekdaysForDate(date: NSDate) -> [Int : [Int]] {
        var weekdays = [Int : [Int]]()
        
        let firstDateInMonth = self.monthDateRange(date).monthStartDate
        let daysInFirstWeek = self.dateRange(firstDateInMonth).day - 7
        let weeksCount = self.monthDateRange(firstDateInMonth).countOfWeeks
        let lastDayInMonth = self.dateRange(self.monthDateRange(date).monthEndDate).day
        
        for i in 0..<daysInFirstWeek {
            var days = [Int]()
            
            let day = self.componentsForDate(firstDateInMonth).day + i
            days.append(day)
            
            for j in 1...weeksCount {
                let _day = day + 7
                if _day < lastDayInMonth {
                    days.append(_day)
                } else {
                    break
                }
            }
            
            weekdays.updateValue(days, forKey: i)
        }
        
        return weekdays
    }
    
    func componentsForDate(date: NSDate) -> NSDateComponents {
        let units = (NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.WeekCalendarUnit)
        let components = self.calendar!.components(units, fromDate: date)
        
        return components
    }
    
    func monthSymbols() -> [AnyObject] {
        return self.calendar!.monthSymbols
    }
    
    func shortWeekdaySymbols() -> [AnyObject] {
        return self.calendar!.shortWeekdaySymbols
    }
}