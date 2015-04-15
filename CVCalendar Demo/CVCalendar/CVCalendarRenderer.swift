//
//  CVCalendarRenderer.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarRenderer {
    private unowned let calendarView: CalendarView
    
    private var appearance: Appearance {
        get {
            return calendarView.appearance
        }
    }
    
    init(calendarView: CalendarView) {
        self.calendarView = calendarView
    }
    
    // MARK: - Rendering 
    
    func renderWeekFrameForRect(rect: CGRect) -> CGRect {
        let width = rect.width
        let space = self.appearance.spaceBetweenWeekViews!
        var height = CGFloat((rect.height / CGFloat(4)) - space) + space / 0.5
        
        let y: CGFloat = (height + space)
        let x: CGFloat = 0
        
        return CGRectMake(x, y, width, height)
    }
    
    func renderWeekFrameForMonthView(monthView: MonthView, weekIndex: Int) -> CGRect {
        let width = monthView.frame.width
        let space = self.appearance.spaceBetweenWeekViews!
        var height = CGFloat((monthView.frame.height / CGFloat(monthView.numberOfWeeks!)) - space) + space / 0.5
        
        let y: CGFloat = CGFloat(weekIndex) * (height + space)
        let x: CGFloat = 0

        return CGRectMake(x, y, width, height)
    }
    
    func renderDayFrameForMonthView(weekView: WeekView, dayIndex: Int) -> CGRect {
        let space = self.appearance.spaceBetweenDayViews!
        let width = CGFloat((weekView.frame.width / 7) - space)
        let height = weekView.frame.height
        
        let x = CGFloat(dayIndex) * (width + space) + space / 2
        let y = CGFloat(0)
        
        return CGRectMake(x, y, width, height)
    }

}
