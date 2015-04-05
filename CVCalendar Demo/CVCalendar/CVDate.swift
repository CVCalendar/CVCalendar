//
//  CVDate.swift
//  CVCalendar
//
//  Created by Мак-ПК on 12/31/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVDate: NSObject {
    private let date: NSDate
    
    let year: Int
    let month: Int
    let week: Int
    let day: Int
    
    init(date: NSDate) {
        let calendarManager = CVCalendarManager.sharedManager
        let dateRange = calendarManager.dateRange(date)
        
        self.date = date
        self.year = dateRange.year
        self.month = dateRange.month
        self.week = dateRange.weekOfMonth
        self.day = dateRange.day
        
        super.init()
    }
    
    init(day: Int, month: Int, week: Int, year: Int) {
        let calendarManager = CVCalendarManager.sharedManager
        
        if let date = calendarManager.dateFromYear(year, month: month, week: week, day: day) {
            self.date = date
        } else {
            self.date = NSDate()
        }
        
        self.year = year
        self.month = month
        self.week = week
        self.day = day
        
        super.init()
    }
    
    func description() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM"
        
        let month = dateFormatter.stringFromDate(date)
        
        return "\(month), \(year)"
    }
}
