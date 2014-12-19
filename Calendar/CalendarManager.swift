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
    
    func weekdayForDate(date: NSDate) -> Int {
        let units = NSCalendarUnit.WeekdayCalendarUnit
        
        let components = self.calendar!.components(units, fromDate: date)
        
        return Int(components.weekday)
    }
    
    func sortedWeekdaysForDate(date: NSDate) -> (weekdaysIn: [Int : [Int]], weekdaysOut: [Int : [Int]]) {
        
        func dateBeforeDate(date: NSDate) -> NSDate {
            let components = self.componentsForDate(date)
            components.day -= 1
            
            return self.calendar!.dateFromComponents(components)!
        }
        
        func dateAfterDate(date: NSDate) -> NSDate {
            let components = self.componentsForDate(date)
            components.day += 1
            
            return self.calendar!.dateFromComponents(components)!
        }
        
        func isMonthOfDate(currentDate: NSDate, initialDate: NSDate) -> Bool {
            let currentMonth = self.dateRange(currentDate).month
            let initialMonth = self.dateRange(initialDate).month
            
            if currentMonth == initialMonth {
                println("Given month: \(currentMonth), initial: \(initialMonth)")
                return true
            } else {
                return false
            }
        }
        
        func isWeekOfDate(currentDate: NSDate, initialDate: NSDate) -> Bool {
            let currentComponents = self.componentsForDate(currentDate)
            let initialComponents = self.componentsForDate(initialDate)
            
            let currentWeek  = currentComponents.weekOfMonth
            let initialWeek = initialComponents.weekOfMonth
            
            if currentWeek == initialWeek {
                return true
            } else {
                return false
            }
        }
        
        var weekdaysIn = [Int : [Int]]()
        var weekdaysOut = [Int : [Int]]()
        
        let firstDateInMonth = self.monthDateRange(date).monthStartDate
        let lastDateInMonth = self.monthDateRange(date).monthEndDate
        let daysInRight = abs(7 - self.weekdayForDate(firstDateInMonth)) + 1
        let weeksCount = self.monthDateRange(firstDateInMonth).countOfWeeks
        let lastDayInMonth = self.dateRange(self.monthDateRange(date).monthEndDate).day
        
        let firstWeekdayInMonth = self.weekdayForDate(firstDateInMonth)
        
        // Check the left part
        let daysInLeft = 7 - daysInRight
        if daysInLeft > 0 {
            var leftDay = firstDateInMonth
            for i in 0..<daysInLeft {
                var daysIn = [Int]()
                var daysOut = [Int]()
                
                leftDay = dateBeforeDate(leftDay)
                if isMonthOfDate(leftDay, firstDateInMonth) {
                    daysIn.append(self.dateRange(leftDay).day)
                } else {
                    if isWeekOfDate(leftDay, firstDateInMonth) {
                        daysOut.append(self.dateRange(leftDay).day)
                    }
                    
                }
                
                let weekday = self.weekdayForDate(leftDay)
                
                var _leftDay = leftDay
                for j in 1..<weeksCount {
                    let components = self.componentsForDate(_leftDay)
                    components.day += 7
                    _leftDay = self.calendar!.dateFromComponents(components)!
                    
                    if isMonthOfDate(_leftDay, firstDateInMonth) {
                        daysIn.append(self.dateRange(_leftDay).day)
                    } else {
                        if isWeekOfDate(_leftDay, firstDateInMonth) {
                            daysOut.append(self.dateRange(_leftDay).day)
                        }
                    }
                }
                
                weekdaysIn.updateValue(daysIn, forKey: weekday)
                weekdaysOut.updateValue(daysOut, forKey: weekday)
            }
        }
        
        
        
        // Check the right side
        var rightDay = firstDateInMonth
        for i in 0..<daysInRight {
            var daysIn = [Int]()
            var daysOut = [Int]()
            
            if i != 0 {
                rightDay = dateAfterDate(rightDay)
            }
            
            daysIn.append(self.dateRange(rightDay).day)
            
            let weekday = self.weekdayForDate(rightDay)
            
            var _rightDay = rightDay
            for j in 1..<weeksCount {
                let components = self.componentsForDate(_rightDay)
                components.day += 7
                _rightDay = self.calendar!.dateFromComponents(components)!
                
                if isMonthOfDate(_rightDay, firstDateInMonth) {
                    daysIn.append(self.dateRange(_rightDay).day)
                } else {
                    if isWeekOfDate(_rightDay, lastDateInMonth) {
                        daysOut.append(self.dateRange(_rightDay).day)
                    }
                }
            }
            
            weekdaysIn.updateValue(daysIn, forKey: weekday)
            weekdaysOut.updateValue(daysOut, forKey: weekday)
        }
        
        
        return (weekdaysIn, weekdaysOut)
    }
    
    func componentsForDate(date: NSDate) -> NSDateComponents {
        let units = NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.WeekCalendarUnit | NSCalendarUnit.DayCalendarUnit
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