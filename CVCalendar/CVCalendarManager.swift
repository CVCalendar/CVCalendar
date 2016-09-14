//
//  CVCalendarManager.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

private let yearUnit = NSCalendar.Unit.year
private let monthUnit = NSCalendar.Unit.month
private let weekUnit = NSCalendar.Unit.weekOfMonth
private let weekdayUnit = NSCalendar.Unit.weekday
private let dayUnit = NSCalendar.Unit.day
private let allUnits = yearUnit.union(monthUnit).union(weekUnit).union(weekdayUnit).union(dayUnit)

public final class CVCalendarManager {
    // MARK: - Private properties
    fileprivate var components: DateComponents
    fileprivate unowned let calendarView: CalendarView

    public var calendar: Calendar

    // MARK: - Public properties
    public var currentDate: Foundation.Date

    // MARK: - Private initialization

    public var starterWeekday: Int

    public init(calendarView: CalendarView) {
        self.calendarView = calendarView
        currentDate = Foundation.Date()
        calendar = Calendar.current
        components = (calendar as NSCalendar).components(monthUnit.union(dayUnit), from: currentDate)

        starterWeekday = calendarView.firstWeekday.rawValue
        calendar.firstWeekday = starterWeekday
    }

    // MARK: - Common date analysis

    public func monthDateRange(_ date: Foundation.Date) -> (countOfWeeks: NSInteger,
        monthStartDate: Foundation.Date, monthEndDate: Foundation.Date) {
            let units = (yearUnit.union(monthUnit).union(weekUnit))
            var components = (calendar as NSCalendar).components(units, from: date)

            // Start of the month.
            components.day = 1
            let monthStartDate = calendar.date(from: components)!

            // End of the month.
            components.month! += 1
            components.day! -= 1
            let monthEndDate = calendar.date(from: components)!

            // Range of the month.
            let range = (calendar as NSCalendar).range(of: weekUnit, in: monthUnit, for: date)
            let countOfWeeks = range.length

            return (countOfWeeks, monthStartDate, monthEndDate)
    }

    public static func dateRange(_ date: Foundation.Date) ->
        (year: Int, month: Int, weekOfMonth: Int, day: Int) {
            let components = componentsForDate(date)

            let year = components.year
            let month = components.month
            let weekOfMonth = components.weekOfMonth
            let day = components.day

            return (year!, month!, weekOfMonth!, day!)
    }

    public func weekdayForDate(_ date: Foundation.Date) -> Int {
        let units = weekdayUnit

        let components = (calendar as NSCalendar).components(units, from: date)

        // print("NSDate: \(date), Weekday: \(components.weekday)")

        // let weekday = calendar.ordinalityOfUnit(units, inUnit: WeekUnit, forDate: date)

        return Int(components.weekday!)
    }

    // MARK: - Analysis sorting

    public func weeksWithWeekdaysForMonthDate(_ date: Foundation.Date) ->
        (weeksIn: [[Int : [Int]]], weeksOut: [[Int : [Int]]]) {

            let countOfWeeks = self.monthDateRange(date).countOfWeeks
            let totalCountOfDays = countOfWeeks * 7
            let firstMonthDateIn = self.monthDateRange(date).monthStartDate
            let lastMonthDateIn = self.monthDateRange(date).monthEndDate
            let countOfDaysIn = Manager.dateRange(lastMonthDateIn).day
            let countOfDaysOut = totalCountOfDays - countOfDaysIn

            // Find all dates in.
            var datesIn = [NSDate]()
            for day in 1...countOfDaysIn {
                var components = Manager.componentsForDate(firstMonthDateIn)
                components.day = day
                let date = calendar.date(from: components)!
                datesIn.append(date as NSDate)
            }

            // Find all dates out.

            let firstMonthDateOut: Foundation.Date? = {
                let firstMonthDateInWeekday = self.weekdayForDate(firstMonthDateIn)
                if firstMonthDateInWeekday == self.starterWeekday {
                    return firstMonthDateIn
                }

                var components = Manager.componentsForDate(firstMonthDateIn)
                for _ in 1...7 {
                    components.day! -= 1
                    
                    
                    let updatedDate = self.calendar.date(from: components)!
                    let updatedDateWeekday = self.weekdayForDate(updatedDate)
                    if updatedDateWeekday == self.starterWeekday {
                        return updatedDate
                    }
                }

                let diff = 7 - firstMonthDateInWeekday
                for _ in diff..<7 {
                    components.day! += 1
                    let updatedDate = self.calendar.date(from: components)!
                    let updatedDateWeekday = self.weekdayForDate(updatedDate)
                    if updatedDateWeekday == self.starterWeekday {
                        return updatedDate
                    }
                }

                return nil
                }()

            // Constructing weeks.

            var firstWeekDates = [NSDate]()
            var lastWeekDates = [NSDate]()

            var firstWeekDate = (firstMonthDateOut != nil) ? firstMonthDateOut! : firstMonthDateIn
            var components = Manager.componentsForDate(firstWeekDate)
            components.day! += 6
            var lastWeekDate = calendar.date(from: components)!

            func nextWeekDateFromDate(_ date: Foundation.Date) -> Foundation.Date {
                var components = Manager.componentsForDate(date)
                components.day! += 7
                let nextWeekDate = calendar.date(from: components)!
                return nextWeekDate
            }

            for weekIndex in 1...countOfWeeks {
                firstWeekDates.append(firstWeekDate as NSDate)
                lastWeekDates.append(lastWeekDate as NSDate)

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

                var components = Manager.componentsForDate(firstWeekDate as Foundation.Date)
                for weekday in 1...7 {
                    let weekdate = calendar.date(from: components)!
                    components.day! += 1
                    let day = Manager.dateRange(weekdate).day

                    func addDay(_ weekdays: inout [Int : [Int]]) {
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

                if !weekdaysIn.isEmpty {
                    weeksIn.append(weekdaysIn)
                }

                if !weekdaysOut.isEmpty {
                    weeksOut.append(weekdaysOut)
                }
            }

            return (weeksIn, weeksOut)
    }

    // MARK: - Util methods

    public static func componentsForDate(_ date: Foundation.Date) -> DateComponents {
        let units = yearUnit.union(monthUnit).union(weekUnit).union(dayUnit)
        let components = (Calendar.current as NSCalendar).components(units, from: date)

        return components
    }

    public static func dateFromYear(_ year: Int, month: Int, week: Int, day: Int) -> Foundation.Date? {
        var comps = Manager.componentsForDate(Foundation.Date())
        comps.year = year
        comps.month = month
        comps.weekOfMonth = week
        comps.day = day

        return Calendar.current.date(from: comps)
    }
}
