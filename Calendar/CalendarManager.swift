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
    
    func monthSymbols() -> [AnyObject] {
        return self.calendar!.monthSymbols
    }
    
    func shortWeekdaySymbols() -> [AnyObject] {
        return self.calendar!.shortWeekdaySymbols
    }
}