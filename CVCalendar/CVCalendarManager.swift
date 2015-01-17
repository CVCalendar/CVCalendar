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
    
    var starterWeekday: Int?
    
    private override init() {
        self.calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        self.currentDate = NSDate()
        self.components = self.calendar?.components(NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit, fromDate: self.currentDate!)
        
        let propertyName = "CVCalendarStarterWeekday"
        let firstWeekday = NSBundle.mainBundle().objectForInfoDictionaryKey(propertyName) as? Int
        if firstWeekday != nil {
            self.starterWeekday = firstWeekday
            self.calendar!.firstWeekday = starterWeekday!
        } else {
            let currentCalendar = NSCalendar.currentCalendar()
            let firstWeekday = currentCalendar.firstWeekday
            self.starterWeekday = firstWeekday
            self.calendar!.firstWeekday = starterWeekday!
        }
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
        
        //println("NSDate: \(date), Weekday: \(components.weekday)")
        
        let weekday = self.calendar!.ordinalityOfUnit(.WeekdayCalendarUnit, inUnit: .WeekCalendarUnit, forDate: date)
        
        return Int(components.weekday)
    }
    
    // MARK: - Analysis sorting
    
    func weeksWithWeekdaysForMonthDate(date: NSDate) -> (weeksIn: [[Int : [Int]]], weeksOut: [[Int : [Int]]]) {
        
        let countOfWeeks = self.monthDateRange(date).countOfWeeks
        let totalCountOfDays = countOfWeeks * 7
        let firstMonthDateIn = self.monthDateRange(date).monthStartDate
        let lastMonthDateIn = self.monthDateRange(date).monthEndDate
        let countOfDaysIn = self.dateRange(lastMonthDateIn).day
        let countOfDaysOut = totalCountOfDays - countOfDaysIn
        
        // Find all dates in.
        var datesIn = [NSDate]()
        for day in 1...countOfDaysIn {
            let components = self.componentsForDate(firstMonthDateIn)
            components.day = day
            let date = self.calendar!.dateFromComponents(components)!
            datesIn.append(date)
        }
        
        // Find all dates out.
        
        
        let firstMonthDateOut: NSDate? = {
            let firstMonthDateInWeekday = self.weekdayForDate(firstMonthDateIn)
            if firstMonthDateInWeekday == self.starterWeekday {
                println("here")
                return firstMonthDateIn
            }
            
            let components = self.componentsForDate(firstMonthDateIn)
            for _ in 1...7 {
                components.day -= 1
                let updatedDate = self.calendar!.dateFromComponents(components)!
                updatedDate
                let updatedDateWeekday = self.weekdayForDate(updatedDate)
                if updatedDateWeekday == self.starterWeekday {
                    updatedDate
                    return updatedDate
                }
            }
            
            let diff = 7 - firstMonthDateInWeekday
            for _ in diff..<7 {
                components.day += 1
                let updatedDate = self.calendar!.dateFromComponents(components)!
                let updatedDateWeekday = self.weekdayForDate(updatedDate)
                if updatedDateWeekday == self.starterWeekday {
                    updatedDate
                    return updatedDate
                }
            }
            
            return nil
            }()
        
        
        // Constructing weeks.
        
        var firstWeekDates = [NSDate]()
        var lastWeekDates = [NSDate]()
        
        var firstWeekDate = (firstMonthDateOut != nil) ? firstMonthDateOut! : firstMonthDateIn
        let components = self.componentsForDate(firstWeekDate)
        components.day += 6
        var lastWeekDate = self.calendar!.dateFromComponents(components)!
        
        func nextWeekDateFromDate(date: NSDate) -> NSDate {
            let components = self.componentsForDate(date)
            components.day += 7
            let nextWeekDate = self.calendar!.dateFromComponents(components)!
            return nextWeekDate
        }
        
        for weekIndex in 1...countOfWeeks {
            firstWeekDates.append(firstWeekDate)
            lastWeekDates.append(lastWeekDate)
            
            firstWeekDate = nextWeekDateFromDate(firstWeekDate)
            lastWeekDate = nextWeekDateFromDate(lastWeekDate)
        }
        
        // Dictionaries.
        
        var weeksIn = [[Int : [Int]]]()
        var weeksOut = [[Int : [Int]]]()
        
        let count = firstWeekDates.count
        
        for i in 0..<count {
            var weekdaysIn = [Int : [Int]]()
            var weekdaysOut = [Int : [Int]]()
            
            let firstWeekDate = firstWeekDates[i]
            let lastWeekDate = lastWeekDates[i]
            
            let components = self.componentsForDate(firstWeekDate)
            for weekday in 1...7 {
                let weekdate = self.calendar!.dateFromComponents(components)!
                components.day += 1
                let day = self.dateRange(weekdate).day
                
                func addDay(inout weekdays: [Int : [Int]]) {
                    var days = weekdays[weekday]
                    if days == nil {
                        days = [Int]()
                    }
                    
                    days!.append(day)
                    weekdays.updateValue(days!, forKey: weekday)
                }
                
                if i == 0 && day > 20 {
                    addDay(&weekdaysOut)
                } else if i == countOfWeeks - 1 && day < 10 {
                    addDay(&weekdaysOut)
                    
                } else {
                    addDay(&weekdaysIn)
                }
            }
            
            if weekdaysIn.count > 0 {
                weeksIn.append(weekdaysIn)
            }
            
            if weekdaysOut.count > 0 {
                weeksOut.append(weekdaysOut)
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