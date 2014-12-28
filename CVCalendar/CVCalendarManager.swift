//
//  CVCalendarManager.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

private let sharedInstance = CVCalendarManager()

class CVCalendarManager: NSObject {
    // MARK: - Private properties
    private var components: NSDateComponents?
    
    var calendar: NSCalendar?
    
    // MARK: - Public properties
    var currentDate: NSDate?
    
    class var sharedManager: CVCalendarManager {
        return sharedInstance
    }
    
    // MARK: - Private initialization
    
    private override init() {
        self.calendar = NSCalendar.currentCalendar()
        self.currentDate = NSDate()
        self.components = self.calendar?.components(NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit, fromDate: self.currentDate!)
    }
    
    // MARK: - Common date analysis
    
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
    
    // MARK: - Analysis sorting
    
    func weekdaysForDate(date: NSDate) -> (weekdaysIn: [Int : [Int]], weekdaysOut: [Int : [Int]]) {
        
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
                    daysOut.append(self.dateRange(leftDay).day)
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
                        daysOut.append(self.dateRange(_leftDay).day)
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
                    daysOut.append(self.dateRange(_rightDay).day)
                }
            }
            
            weekdaysIn.updateValue(daysIn, forKey: weekday)
            weekdaysOut.updateValue(daysOut, forKey: weekday)
        }
        
        
        return (weekdaysIn, weekdaysOut)
    }
    
    func weekdaysInForWeek(index: Int, weekdaysIn: [Int : [Int]], date: NSDate) -> [Int : [Int]] {
        func doesBelongToWeek(day: Int) -> Bool {
            let components = self.componentsForDate(date)
            components.day = day
            
            let _date = self.calendar!.dateFromComponents(components)!
            let _components = self.componentsForDate(_date)
            let dayWeekOfMonth = _components.weekOfMonth
            
            if dayWeekOfMonth == index  {
                return true
            } else {
                return false
            }
        }
        
        
        
        var _weekdays = [Int : [Int]]()
        
        let keys = weekdaysIn.keys
        for key in keys {
            let values = weekdaysIn[key]
            
            if let _values = values {
                for value in _values {
                    if doesBelongToWeek(value) {
                        _weekdays.updateValue([value], forKey: key)
                        
                        break
                    }
                }
            }
        }
        
        return _weekdays
    }
    
    func weekdaysOutForWeek(index: Int, weekdaysOut: [Int : [Int]], date: NSDate) -> [Int : [Int]] {
        let countOfWeeks = self.monthDateRange(date).countOfWeeks
        var weekdays = [Int : [Int]]()
        if index == 1 || index == countOfWeeks {
            let keys = weekdaysOut.keys
            for key in keys {
                let values = weekdaysOut[key]!
                for value in values {
                    if index == 1 {
                        if value > 20 {
                            weekdays.updateValue([value], forKey: key)
                            break
                        }
                    } else if index == countOfWeeks {
                        if value < 10 {
                            weekdays.updateValue([value], forKey: key)
                            break
                        }
                    }
                    
                }
            }
        }
        
        return weekdays
    }
    
    func weeksWithWeekdaysForMonthDate(date: NSDate) -> (weeksIn: [[Int : [Int]]], weeksOut: [[Int : [Int]]]) {
        let numberOfWeeks = self.monthDateRange(date).countOfWeeks
        
        let weekdays = self.weekdaysForDate(date)
        var weeksIn = [[Int : [Int]]]()
        var weeksOut = [[Int : [Int]]]()
        
        for i in 1...numberOfWeeks {
            let weekIn = self.weekdaysInForWeek(i, weekdaysIn: weekdays.weekdaysIn, date: date)
            let weekOut = self.weekdaysOutForWeek(i, weekdaysOut: weekdays.weekdaysOut, date: date)
            
            if weekIn.count > 0 {
                weeksIn.append(weekIn)
            }
            
            if weekOut.count > 0 {
                weeksOut.append(weekOut)
            }
        }
        
        return (weeksIn, weeksOut)
    }
    
    // MARK: - Util methods
    
    func componentsForDate(date: NSDate) -> NSDateComponents {
        let units = NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.WeekOfMonthCalendarUnit | NSCalendarUnit.DayCalendarUnit
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
