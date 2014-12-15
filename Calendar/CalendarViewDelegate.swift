//
//  CalendarViewDelegate.swift
//  Calendar
//
//  Created by E. Mozharovsky on 12/15/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

@objc
protocol CalendarViewDelegate {
    func calendarView(calendarViewData: CalendarViewData, firstWeekdayForCalendarView calendarView: CalendarView) -> Int
    
    optional func calendarView(calendarViewData: CalendarViewData, highlightedDayViewColorForCalendarView calendarView: CalendarView) -> UIColor?
    optional func calendarView(calendarViewData: CalendarViewData, selectedDayViewColorForCalendarView calendarView: CalendarView) -> UIColor?
    optional func calendarView(calendarViewData: CalendarViewData, textFontForCalendarView calendarView: CalendarView) -> UIFont?
    optional func calendarView(calendarViewData: CalendarViewData, textColorForCalendarView calendarView: CalendarView) -> UIColor?
    
    optional func calendarView(calendarViewData: CalendarViewData, weekViewHeightForCalendarView calendarView: CalendarView) -> Float
    optional func calendarView(calendarViewData: CalendarViewData, verticalSpaceBetweenWeekViewsForCalendarView calendarView: CalendarView) -> Float
    
    optional func calendarView(calendarViewData: CalendarViewData, dayViewWidthForCalendarView calendarView: CalendarView) -> Float
    optional func calendarView(calendarViewData: CalendarViewData, horizontalSpaceBetweenDayViewsForCalendarView calendarView: CalendarView) -> Float
}