//
//  CalendarViewDataSource.swift
//  Calendar
//
//  Created by E. Mozharovsky on 12/15/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

protocol CalendarViewDataSource {
    func calendarView(calendarViewData: CalendarViewData, numberOfDaysForCalendarView calendarView: CalendarView) -> Int
    func calendarView(calendarViewData: CalendarViewData, numberOfWeeksForCalendarView calendarView: CalendarView) -> Int
    func calendarView(calendarViewData: CalendarViewData, shouldShowDaysOutForCalendarView calendarView: CalendarView) -> Bool
    func calendarView(calendarViewData: CalendarViewData, presentedModeForCalendarView calendarView: CalendarView) -> CalendarViewMode
}
