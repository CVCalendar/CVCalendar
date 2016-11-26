//
//  CVDate.swift
//  CVCalendar
//
//  Created by Мак-ПК on 12/31/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

public final class CVDate: NSObject {
    fileprivate let date: Foundation.Date

    public let year: Int
    public let month: Int
    public let week: Int
    public let day: Int

    public init(date: Foundation.Date, calendar: Calendar) {
        let dateRange = Manager.dateRange(date, calendar: calendar)

        self.date = date
        self.year = dateRange.year
        self.month = dateRange.month
        self.week = dateRange.weekOfMonth
        self.day = dateRange.day

        super.init()
    }

    public init(day: Int, month: Int, week: Int, year: Int, calendar: Calendar) {
        if let date = Manager.dateFromYear(year, month: month, week: week, day: day, calendar: calendar) {
            self.date = date
        } else {
            self.date = Foundation.Date()
        }

        self.year = year
        self.month = month
        self.week = week
        self.day = day

        super.init()
    }
}

extension CVDate {
    public func weekDay(calendar: Calendar) -> Weekday? {
        let components = (calendar as NSCalendar).components(NSCalendar.Unit.weekday, from: self.date)
        return Weekday(rawValue: components.weekday!)
    }
    
    public func convertedDate(calendar: Calendar) -> Foundation.Date? {
        var comps = Manager.componentsForDate(Foundation.Date(), calendar: calendar)

        comps.year = year
        comps.month = month
        comps.weekOfMonth = week
        comps.day = day

        return calendar.date(from: comps)
    }
}

extension CVDate {
    public var globalDescription: String {
        let month = dateFormattedStringWithFormat("MMMM", fromDate: date)
        return "\(month), \(year)"
    }

    public var commonDescription: String {
        let month = dateFormattedStringWithFormat("MMMM", fromDate: date)
        return "\(day) \(month), \(year)"
    }
}

private extension CVDate {
    func dateFormattedStringWithFormat(_ format: String, fromDate date: Foundation.Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
